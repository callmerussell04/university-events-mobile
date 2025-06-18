import 'package:flutter/material.dart';
import 'package:university_events/presentation/home_page/home_page.dart';
import 'package:university_events/presentation/login_page/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_events/data/repositories/invitation_repository.dart';
import 'package:university_events/presentation/home_page/bloc/bloc.dart';
import 'package:university_events/data/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:university_events/utils/auth_interceptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Dio _authenticatedDio;
  late Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _authenticatedDio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    ))
      ..interceptors.add(PrettyDioLogger(responseBody: true, requestBody: true))
      ..interceptors.add(AuthInterceptor());

    _isLoggedInFuture = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    final authService = AuthService();
    return await authService.autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (ctx) {
            final authServiceInstance = AuthService();
            return authServiceInstance;
          },
        ),
        RepositoryProvider<InvitationRepository>(
          create: (ctx) {
            final authServiceFromContext = ctx.read<AuthService>();
            final invitationRepoInstance = InvitationRepository(_authenticatedDio, authServiceFromContext);
            return invitationRepoInstance;
          },
        ),
      ],
      child: MaterialApp(
        title: 'University events',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: FutureBuilder<bool>(
          future: _isLoggedInFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Ошибка загрузки: ${snapshot.error}'),
                ),
              );
            } else {
              final bool isLoggedIn = snapshot.data ?? false;
              if (isLoggedIn) {
                return BlocProvider<HomeBloc>(
                  lazy: false,
                  create: (blocCtx) {
                    final repo = blocCtx.read<InvitationRepository>();
                    return HomeBloc(repo);
                  },
                  child: const HomePage(),
                );
              } else {
                return const LoginPage();
              }
            }
          },
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            return MaterialPageRoute(
              builder: (ctx) => BlocProvider<HomeBloc>(
                lazy: false,
                create: (blocCtx) {
                  final repo = blocCtx.read<InvitationRepository>();
                  return HomeBloc(repo);
                },
                child: const HomePage(),
              ),
            );
          }
          return MaterialPageRoute(builder: (ctx) => const Text('Error: Unknown route or route not handled'));
        },
      ),
    );
  }
}