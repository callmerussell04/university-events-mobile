import 'package:json_annotation/json_annotation.dart';

part 'invitation_update_dto.g.dart';

@JsonSerializable()
class InvitationUpdateDto {
  final int userId;
  final int eventId;
  final String status;

  InvitationUpdateDto({required this.userId, required this.eventId, required this.status});

  factory InvitationUpdateDto.fromJson(Map<String, dynamic> json) => _$InvitationUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$InvitationUpdateDtoToJson(this);
}