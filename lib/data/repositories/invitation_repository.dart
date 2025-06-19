import 'package:dio/dio.dart';
import 'package:university_events/data/dtos/items_dto.dart';
import 'package:university_events/data/mappers/items_mapper.dart';
import 'package:university_events/data/repositories/api_interface.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:university_events/domain/models/home.dart';
import 'package:university_events/data/services/auth_service.dart';
import 'package:university_events/data/dtos/invitation_update_dto.dart';

class InvitationRepository extends ApiInterface {
  final Dio _dio;
  final AuthService _authService;

  InvitationRepository(this._dio, this._authService);

  static const String _baseUrl = 'http://192.168.113.247:8080';

  @override
  Future<HomeData?> loadData({String? q, int page = 0, OnErrorCallback? onError}) async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        onError?.call('Пользователь не авторизован или ID не найден.');
        return null;
      }

      final String url = '$_baseUrl/api/1.0/invitation/by-user/$userId';

      final Response<dynamic> response = await _dio.get<Map<dynamic, dynamic>>(
          url,
          queryParameters: {'page': page}
      );

      final ItemsDto dto = ItemsDto.fromJson(response.data as Map<String, dynamic>);

      final HomeData data = dto.toDomain();
      return data;
    } on DioException catch (e) {
      onError?.call(e.response?.statusMessage ?? e.message);
      return null;
    }
  }

  Future<bool> updateInvitationStatus(int invitationId, int userId, int eventId, String newStatus, {OnErrorCallback? onError}) async {
    try {
      final String url = '$_baseUrl/api/1.0/invitation/$invitationId';

      final response = await _dio.put(
        url,
        data: InvitationUpdateDto(userId: userId, eventId: eventId, status: newStatus).toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        onError?.call(response.statusMessage ?? 'Неизвестная ошибка при обновлении статуса.');
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        onError?.call(e.response!.data['message'] ?? 'Ошибка при обновлении статуса.');
      } else {
        onError?.call(e.message ?? 'Ошибка сети или непредвиденная ошибка при обновлении статуса.');
      }
      return false;
    }
  }
}