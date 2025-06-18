// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemsDto _$ItemsDtoFromJson(Map<String, dynamic> json) => ItemsDto(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ItemDataDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasNextPage: json['hasNext'] as bool?,
  currentPage: (json['currentPage'] as num?)?.toInt(),
);

ItemDataDto _$ItemDataDtoFromJson(Map<String, dynamic> json) => ItemDataDto(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  status: json['status'] as String?,
  event: json['event'] == null
      ? null
      : EventDataDto.fromJson(json['event'] as Map<String, dynamic>),
);

EventDataDto _$EventDataDtoFromJson(Map<String, dynamic> json) => EventDataDto(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  status: json['status'] as String?,
  startDateTime: json['startDateTime'] as String?,
  endDateTime: json['endDateTime'] as String?,
  organizer: json['organizer'] as String?,
  locationName: json['locationName'] as String?,
);
