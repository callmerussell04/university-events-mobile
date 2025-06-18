import 'package:university_events/domain/models/card.dart';

class HomeData {
  final List<CardData>? data;
  final int? nextPage;

  HomeData({this.data, this.nextPage});
}
