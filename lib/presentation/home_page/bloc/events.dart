abstract class HomeEvent {
  const HomeEvent();
}

class HomeLoadDataEvent extends HomeEvent {
  final int? nextPage;
  const HomeLoadDataEvent({this.nextPage});
}
