import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/shopping_provider.dart';
import '../models/shopping_list.dart';
import '../core/theme.dart';
import '../widgets/app_drawer.dart';

class ManageListsScreen extends StatefulWidget {
  const ManageListsScreen({super.key});

  @override
  State<ManageListsScreen> createState() => _ManageListsScreenState();
}

class _ManageListsScreenState extends State<ManageListsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showRenameDialog(ShoppingList list) {
    final renameController = TextEditingController(text: list.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          title: const Text(
            'Renomear Lista',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: renameController,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Novo nome',
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.secondary),
              ),
            ),
            TextButton(
              onPressed: () {
                if (renameController.text.isNotEmpty) {
                  context.read<ShoppingProvider>().renameList(
                    list.id,
                    renameController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Salvar',
                style: TextStyle(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(ShoppingList list) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          title: const Text(
            'Confirmar exclusão',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Tem certeza que deseja excluir "${list.name}" permanentemente?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.secondary),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<ShoppingProvider>().deleteList(list.id);
                Navigator.pop(context);
              },
              child: const Text(
                'Excluir',
                style: TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundList,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: GestureDetector(
          onTap: () => context.go('/manage'),
          child: const Text('Listas de Compras'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Search Section
                    Container(
                      color: AppTheme.background, // Color(0xFF021140)
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Pesquisar lista...',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppTheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {
                            _searchQuery = v.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const Divider(
                      color: AppTheme.secondary,
                      height: 1,
                      thickness: 1,
                    ),

                    // Lists View
                    Expanded(
                      child: Container(
                        color: Colors.white, // Fundo branco para a área de listagem
                        child: Consumer<ShoppingProvider>(
                          builder: (context, provider, child) {
                            final lists = provider.allLists.where((l) {
                              return l.name.toLowerCase().contains(_searchQuery);
                            }).toList();

                            if (lists.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhuma lista encontrada.',
                                  style: TextStyle(
                                    color: AppTheme.background.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: lists.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: AppTheme.background.withValues(alpha: 0.1),
                              ),
                              itemBuilder: (context, index) {
                                final list = lists[index];
                                final isCurrent =
                                    list.id == provider.currentList.id;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isCurrent
                                        ? AppTheme.primary
                                        : AppTheme.secondary.withValues(
                                            alpha: 0.2,
                                          ),
                                    child: Icon(
                                      Icons.shopping_cart,
                                      color: isCurrent
                                          ? Colors.white
                                          : AppTheme.background,
                                    ),
                                  ),
                                  title: Text(
                                    list.name,
                                    style: TextStyle(
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: AppTheme.background, // Cor da fonte escura
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${list.items.length} itens',
                                    style: TextStyle(
                                      color: AppTheme.background.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppTheme.background,
                                        ),
                                        onPressed: () => _showRenameDialog(list),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.danger,
                                        ),
                                        onPressed: provider.allLists.length > 1
                                            ? () => _showDeleteDialog(list)
                                            : null,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    provider.switchList(list.id);
                                    context.go('/');
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Incluir Nova Lista',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => context.push('/create_list'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
