import 'package:go_router/go_router.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/edit_item_screen.dart';
import '../presentation/screens/manage_lists_screen.dart';
import '../presentation/screens/create_list_screen.dart';
import '../presentation/screens/create_recipe_screen.dart';
import '../presentation/screens/manage_categories_screen.dart';
import '../presentation/state/auth_provider.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      if (isLoggedIn && isGoingToLogin) {
        return '/manage';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/manage',
        builder: (context, state) => const ManageListsScreen(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final itemId = state.extra as String?;
          return EditItemScreen(itemId: itemId);
        },
      ),
      GoRoute(
        path: '/create_list',
        builder: (context, state) => const CreateListScreen(),
      ),
      GoRoute(
        path: '/create_recipe',
        builder: (context, state) => const CreateRecipeScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const ManageCategoriesScreen(),
      ),
    ],
  );
}


