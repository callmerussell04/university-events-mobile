import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_events/data/repositories/invitation_repository.dart';
import 'package:university_events/presentation/home_page/bloc/events.dart';
import 'package:university_events/presentation/home_page/bloc/state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final InvitationRepository repo;

  HomeBloc(this.repo) : super(const HomeState()) {
    on<HomeLoadDataEvent>(_onLoadData);
  }

  Future<void> _onLoadData(HomeLoadDataEvent event, Emitter<HomeState> emit) async {
    if (event.nextPage == null) {
      emit(state.copyWith(isLoading: true));
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }

    final data = await repo.loadData(
      page: event.nextPage ?? 0,
    );

    if (event.nextPage != null) {
      data?.data?.insertAll(0, state.data?.data ?? []);
    }

    emit(state.copyWith(
      isLoading: false,
      isPaginationLoading: false,
      data: data,
    ));
  }
}
