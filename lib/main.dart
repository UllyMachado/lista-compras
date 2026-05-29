import 'package:flutter/material.dart';
import 'core/config.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'providers/auth_provider.dart';
import 'providers/shopping_provider.dart';
import 'api/openapi.swagger.dart';
import 'services/auth_service.dart';
import 'services/token_storage.dart';
import 'services/auth_interceptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final authService = AuthService();
  final authProvider = AuthProvider(authService, tokenStorage);

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
            final api = Openapi.create(
              baseUrl: Uri.parse(AppConfig.apiBaseUrl),
              interceptors: [
                AuthInterceptor(tokenStorage, authService, () {
                  authProvider.logout();
                }),
              ],
            );
            return ShoppingProvider(api);
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final auth = context.read<AuthProvider>();
          final router = createRouter(auth);
          return MaterialApp.router(
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
