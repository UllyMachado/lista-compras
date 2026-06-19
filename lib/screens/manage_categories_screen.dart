import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/shopping_provider.dart';
import '../api/openapi.swagger.dart';
import '../core/theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_icon.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showAddEditDialog([Category? category]) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          title: Text(
            isEditing ? 'Editar Categoria' : 'Nova Categoria',
            style: const TextStyle(color: Colors.white),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome da Categoria',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (v.trim().length < 2) {
                      return 'Mínimo de 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
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
                if (formKey.currentState!.validate()) {
                  final provider = context.read<ShoppingProvider>();
                  final name = nameController.text.trim();
                  final description = descController.text.trim();

                  if (isEditing) {
                    provider.updateCategory(category.id!, name, description);
                  } else {
                    provider.createCategory(name, description);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(
                isEditing ? 'Salvar' : 'Criar',
                style: const TextStyle(
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

  void _showDeleteDialog(Category category) {
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
            'Tem certeza que deseja excluir a categoria "${category.name ?? ''}" permanentemente? Itens associados a ela ficarão sem categoria.',
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
                context.read<ShoppingProvider>().deleteCategory(category.id!);
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
                      color: AppTheme.background,
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Pesquisar categoria...',
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

                    // Categories List
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Consumer<ShoppingProvider>(
                          builder: (context, provider, child) {
                            final categories = provider.categories.where((c) {
                              return (c.name ?? '').toLowerCase().contains(_searchQuery);
                            }).toList();

                            if (categories.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhuma categoria encontrada.',
                                  style: TextStyle(
                                    color: AppTheme.background.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: categories.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: AppTheme.background.withValues(alpha: 0.1),
                              ),
                              itemBuilder: (context, index) {
                                final category = categories[index];

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.secondary.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: Icon(
                                      getCategoryIcon(category.name),
                                      color: AppTheme.background,
                                    ),
                                  ),
                                  title: Text(
                                    category.name ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.background,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: category.description != null && category.description!.isNotEmpty
                                      ? Text(
                                          category.description!,
                                          style: TextStyle(
                                            color: AppTheme.background.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppTheme.background,
                                        ),
                                        onPressed: () => _showAddEditDialog(category),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.danger,
                                        ),
                                        onPressed: () => _showDeleteDialog(category),
                                      ),
                                    ],
                                  ),
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
                'Incluir Nova Categoria',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddEditDialog(),
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
