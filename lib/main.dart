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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';



final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
  late final FirebaseMessaging _firebaseMessaging;
  late AuthService _authService;

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

    _authService = AuthService(authenticatedDio: _authenticatedDio);

    _isLoggedInFuture = _checkLoginStatus();

    _firebaseMessaging = FirebaseMessaging.instance;
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications.');
    } else {
      print('User denied permission for notifications.');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              '${message.notification!.title}: ${message.notification!.body}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
        print('Message also contained a notification: ${message.notification!.title}: ${message.notification!.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');
      
    });

    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      print("FCM Token refreshed: $token");
      final userId = await _authService.getUserId();
      if (userId != null) {
        await _authService.sendFCMToken(token);
      } else {
        print("User not logged in, ignoring refreshed FCM token.");
      }
    });
  }

  Future<bool> _checkLoginStatus() async {
    return await _authService.autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (ctx) {
            return _authService;
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
        
        scaffoldMessengerKey: scaffoldMessengerKey,
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
                _ensureFCMTokenIsSentOnLogin();
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
              builder: (ctx) {
                _ensureFCMTokenIsSentOnLogin();
                return BlocProvider<HomeBloc>(
                  lazy: false,
                  create: (blocCtx) {
                    final repo = blocCtx.read<InvitationRepository>();
                    return HomeBloc(repo);
                  },
                  child: const HomePage(),
                );
              },
            );
          }
          return MaterialPageRoute(builder: (ctx) => const Text('Error: Unknown route or route not handled'));
        },
      ),
    );
  }

  Future<void> _ensureFCMTokenIsSentOnLogin() async {
    final String? newToken = await _firebaseMessaging.getToken();
    if (newToken != null) {
      print('Obtained new FCM token on login: $newToken');
      await _authService.sendFCMToken(newToken);
    }
  }
}