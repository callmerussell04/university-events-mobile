import 'package:json_annotation/json_annotation.dart';

part 'items_dto.g.dart';

@JsonSerializable(createToJson: false)
class ItemsDto {
  final List<ItemDataDto>? items;
  @JsonKey(name: 'hasNext')
  final bool? hasNextPage;
  final int? currentPage;

  const ItemsDto({this.items, this.hasNextPage, this.currentPage});

  factory ItemsDto.fromJson(Map<String, dynamic> json) => _$ItemsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ItemDataDto {
  final int? id;
  final int? userId;
  final String? status;
  final EventDataDto? event;

  const ItemDataDto({this.id, this.userId, this.status, this.event});

  factory ItemDataDto.fromJson(Map<String, dynamic> json) => _$ItemDataDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventDataDto {
  final int? id;
  final String? name;
  final String? status;
  final String? startDateTime;
  final String? endDateTime;
  final String? organizer;
  final String? locationName;

  const EventDataDto({this.id, this.name, this.status, this.startDateTime, this.endDateTime, this.organizer, this.locationName});

  factory EventDataDto.fromJson(Map<String, dynamic> json) =>
      _$EventDataDtoFromJson(json);
}
