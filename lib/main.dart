import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'core/globals.dart';
import 'core/router.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/shopping_provider.dart';
import 'package:dio/dio.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/local/token_local_datasource.dart';
import 'core/network/auth_interceptor.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/shopping_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final authService = AuthService();
  final authRepository = AuthRepositoryImpl(authService, tokenStorage);
  final authProvider = AuthProvider(authRepository);

  // Try to restore session from stored tokens
  await authProvider.tryAutoLogin();

  runApp(MyApp(
    authProvider: authProvider,
    tokenStorage: tokenStorage,
    authService: authService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final TokenStorage tokenStorage;
  final AuthService authService;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.tokenStorage,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) {
            final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
            dio.interceptors.add(
              AuthInterceptor(tokenStorage, authService, () {
                authProvider.logout();
              }, dio),
            );
            final shoppingRepository = ShoppingRepositoryImpl(dio);
            return ShoppingProvider(shoppingRepository);
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final auth = context.read<AuthProvider>();
          final router = createRouter(auth);
          return MaterialApp.router(
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'Listas de Compras',
            theme: AppTheme.themeData,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
