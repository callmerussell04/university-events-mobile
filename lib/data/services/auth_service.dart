import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:university_events/data/dtos/auth_dtos.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:university_events/utils/auth_interceptor.dart'; // Убедитесь, что этот импорт есть

class AuthService {
  final Dio _dio; // Dio для аутентификации (без интерсептора)
  final Dio _authenticatedDio; // Dio для запросов, требующих аутентификации
  final _storage = const FlutterSecureStorage();

  static const String _fcmTokenKey = 'fcm_token';

  AuthService({required Dio authenticatedDio})
      : _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.212:8080/api/1.0/auth', // Базовый URL для аутентификации
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    contentType: Headers.jsonContentType,
  ))
    ..interceptors.add(PrettyDioLogger(responseBody: true, requestBody: true)),
        _authenticatedDio = authenticatedDio;

  Future<bool> autoLogin() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && userId != null;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> saveUserId(int id) async {
    await _storage.write(key: 'user_id', value: id.toString());
  }

  Future<int?> getUserId() async {
    final idString = await _storage.read(key: 'user_id');
    return idString != null ? int.tryParse(idString) : null;
  }

  Future<void> deleteTokenAndUserId() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> saveFCMTokenLocally(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
    print('FCM Token saved locally.');
  }

  Future<String?> getFCMTokenLocally() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  Future<void> deleteFCMTokenLocally() async {
    await _storage.delete(key: _fcmTokenKey);
    print('FCM Token deleted locally.');
  }

  Future<JwtResponse> signIn(String username, String password, {String? otp}) async {
    try {
      final response = await _dio.post( // Используем _dio для signIn
        '/signin',
        data: SigninRequestDto(username: username, password: password, otp: otp).toJson(),
      );
      final jwtResponse = JwtResponse.fromJson(response.data);
      if (jwtResponse.accessToken != null) {
        await saveToken(jwtResponse.accessToken!);
        await saveUserId(jwtResponse.id);
      }

      final storedFCMToken = await getFCMTokenLocally();
      if (storedFCMToken != null) {
        print('Attempting to send locally stored FCM token after login.');
        await sendFCMToken(storedFCMToken);
      }

      return jwtResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Произошла ошибка при входе.');
      } else {
        throw Exception(e.message ?? 'Произошла непредвиденная ошибка при входе.');
      }
    }
  }

  Future<MessageResponse> resendOtp(String username) async {
    try {
      final response = await _dio.post( // Используем _dio для resendOtp
        '/resend-otp',
        data: OtpResendRequestDto(username: username).toJson(),
      );
      return MessageResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Произошла ошибка при повторной отправке OTP.');
      } else {
        throw Exception(e.message ?? 'Произошла непредвиденная ошибка при повторной отправке OTP.');
      }
    }
  }

  Future<void> sendFCMToken(String token) async {
    final userId = await getUserId();
    if (userId == null) {
      print('AuthService: User ID is null. Cannot send FCM token without user ID.');
      return;
    }

    try {
      await _authenticatedDio.post(
        'http://192.168.1.212:8080/api/1.0/user/$userId/device-token',
        data: DeviceTokenDto(deviceToken: token).toJson(),
      );
      print('FCM Token successfully sent to backend for userId: $userId');
    } on DioException catch (e) {
      print('Error sending FCM Token to backend: ${e.response?.data ?? e.message}');
      // Обработайте ошибку отправки токена (например, повторная попытка, логирование)
    } catch (e) {
      print('Unexpected error sending FCM Token: $e');
    }
  }
  Future<void> signOut() async {
    final userId = await getUserId(); // <--- Добавлено: Удаляем FCM-токен при выходе
    try {
      await _authenticatedDio.post(
        'http://192.168.1.212:8080/api/1.0/user/$userId/device-token',
        data: DeviceTokenDto(deviceToken: null).toJson(),
      );
      print('FCM Token successfully cleared for userId: $userId');
    } on DioException catch (e) {
      print('Error clearing FCM Token on backend: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Unexpected error clearing FCM Token: $e');
    }
    await deleteTokenAndUserId(); // Удаляем токены доступа и user ID
    await deleteFCMTokenLocally();
    print('User signed out. Authentication tokens and user ID cleared, FCM token deleted.');
  }
}