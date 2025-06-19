import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_events/domain/models/card.dart';
import 'package:university_events/presentation/details_page/details_page.dart';
import 'package:university_events/presentation/home_page/bloc/bloc.dart';
import 'package:university_events/presentation/home_page/bloc/events.dart';
import 'package:university_events/presentation/home_page/bloc/state.dart';
import 'package:university_events/data/services/auth_service.dart'; 
import 'package:university_events/presentation/login_page/login_page.dart'; 

part 'card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  void _logout() async {
    
    final AuthService authService = context.read<AuthService>();

    await authService.signOut();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ваши мероприятия',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: _logout, 
            tooltip: 'Выйти из аккаунта', 
          ),
        ],
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(const HomeLoadDataEvent());
    });

    scrollController.addListener(_onNextPageListener);

    super.initState();
  }

  void _onNextPageListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      final bloc = context.read<HomeBloc>();
      if (!bloc.state.isPaginationLoading) {
        bloc.add(HomeLoadDataEvent(
          nextPage: bloc.state.data?.nextPage,
        ));
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) => state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: state.data?.data?.length ?? 0,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = state.data?.data?[index];
                    return data != null
                        ? _Card.fromData(
                      data,
                      onTap: () => _navToDetails(context, data),
                    )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) => state.isPaginationLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(const HomeLoadDataEvent());
    return Future.value(null);
  }

  void _navToDetails(BuildContext context, CardData data) async {
    final bool? result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => DetailsPage(data)),
    );

    if (result == true) {
      context.read<HomeBloc>().add(const HomeLoadDataEvent());
    }
  }
}