// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationUpdateDto _$InvitationUpdateDtoFromJson(Map<String, dynamic> json) =>
    InvitationUpdateDto(
      userId: (json['userId'] as num).toInt(),
      eventId: (json['eventId'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$InvitationUpdateDtoToJson(
  InvitationUpdateDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'eventId': instance.eventId,
  'status': instance.status,
};
