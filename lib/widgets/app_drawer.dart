import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/shopping_provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final providerForSync = context.watch<ShoppingProvider>();

    return Drawer(
      backgroundColor: AppTheme.background,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primary),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shopping_cart, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Listas de Compras',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'admin@gmail.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy, color: AppTheme.secondary),
            title: const Text('Receita Inteligente'),
            onTap: () {
              Navigator.pop(context);
              context.go('/create_recipe');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category, color: AppTheme.secondary),
            title: const Text('Gerenciar Categorias'),
            onTap: () {
              Navigator.pop(context);
              context.go('/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: AppTheme.secondary),
            title: const Text('Suas Listas'),
            onTap: () {
              Navigator.pop(context);
              context.go('/manage');
            },
          ),
          Column(
            children: providerForSync.allLists.map((list) {
              final isCurrent = list.id == providerForSync.currentList?.id;
              return ListTile(
                contentPadding: const EdgeInsets.only(left: 48, right: 16),
                dense: true,
                title: Text(
                  list.name ?? 'Sem Nome',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCurrent ? AppTheme.primary : AppTheme.secondary,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  if (list.id != null) {
                    providerForSync.switchList(list.id!);
                  }
                  Navigator.pop(context);
                  context.go('/');
                },
              );
            }).toList(),
          ),
          const Spacer(),
          const Divider(color: AppTheme.secondary),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.danger),
            title: const Text('Sair', style: TextStyle(color: AppTheme.danger)),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
