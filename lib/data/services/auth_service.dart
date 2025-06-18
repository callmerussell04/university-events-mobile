import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:university_events/data/dtos/auth_dtos.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class AuthService {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  AuthService() : _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api/1.0/auth',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: Headers.jsonContentType,
  )) {
    _dio.interceptors.add(PrettyDioLogger(responseBody: true, requestBody: true));
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

  Future<JwtResponse> signIn(String username, String password, {String? otp}) async {
    try {
      final response = await _dio.post(
        '/signin',
        data: SigninRequestDto(username: username, password: password, otp: otp).toJson(),
      );
      final jwtResponse = JwtResponse.fromJson(response.data);
      if (jwtResponse.accessToken != null) {
        await saveToken(jwtResponse.accessToken!);
        await saveUserId(jwtResponse.id);
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
      final response = await _dio.post(
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
}