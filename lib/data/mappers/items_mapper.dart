import 'package:university_events/data/dtos/items_dto.dart';
import 'package:university_events/domain/models/card.dart';
import 'package:university_events/domain/models/home.dart';

extension ItemDataDtoToModel on ItemDataDto {
  CardData toDomain() => CardData(
    id ?? 0,
    event?.name ?? 'UNKNOWN',
    event?.status ?? 'UNKNOWN',
    event?.startDateTime ?? 'UNKNOWN',
    event?.endDateTime ?? 'UNKNOWN',
    event?.organizer ?? 'UNKNOWN',
    event?.locationName ?? 'UNKNOWN',
    status ?? 'UNKNOWN',
    userId ?? 0,
    event?.id ?? 0
  );
}

extension ItemsDtoToModel on ItemsDto {
  HomeData toDomain() => HomeData(
    data: items?.map((e) => e.toDomain()).toList(),
    nextPage: (hasNextPage ?? false) ? ((currentPage ?? 0) + 1) : null);
}