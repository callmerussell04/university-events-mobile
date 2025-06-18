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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: Headers.jsonContentType,
  ))
    ..interceptors.add(PrettyDioLogger(responseBody: true, requestBody: true))
    ..interceptors.add(AuthInterceptor());

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<InvitationRepository>(
          create: (context) => InvitationRepository(_dio, context.read<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: 'University events',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/home': (context) => BlocProvider<HomeBloc>(
            lazy: false,
            create: (context) => HomeBloc(context.read<InvitationRepository>()),
            child: const HomePage(),
          ),
        },
      ),
    );
  }
}