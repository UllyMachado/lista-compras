import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/shopping_provider.dart';
import '../api/openapi.swagger.dart';
import '../core/theme.dart';
import '../widgets/app_drawer.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipeController = TextEditingController();

  void _editItemDialog(BuildContext context, ShoppingItem item, Function(ShoppingItem) onSave) {
    final formKey = GlobalKey<FormState>();
    final descController = TextEditingController(text: item.description ?? '');
    final qtyController = TextEditingController(text: item.quantity?.toString() ?? '1');
    final priceController = TextEditingController(text: item.price != null && item.price! > 0 ? item.price!.toStringAsFixed(2) : '0.00');
    ShoppingItemUnit selectedUnit = item.unit ?? ShoppingItemUnit.und;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSubState) {
            return AlertDialog(
              backgroundColor: AppTheme.background,
              title: const Text('Editar Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: qtyController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Qtd.',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requerido';
                              if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<ShoppingItemUnit>(
                            value: selectedUnit,
                            dropdownColor: AppTheme.background,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Unid.',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            items: ShoppingItemUnit.values
                                .where((u) => u != ShoppingItemUnit.swaggerGeneratedUnknown)
                                .map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit.value!.toUpperCase(), style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSubState(() {
                                  selectedUnit = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Preço (R\$)',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppTheme.secondary)),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updated = item.copyWith(
                        description: descController.text.trim(),
                        quantity: double.tryParse(qtyController.text.replaceAll(',', '.')) ?? 1.0,
                        unit: selectedUnit,
                        price: double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0,
                      );
                      onSave(updated);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final recipe = _recipeController.text.trim();
    final provider = context.read<ShoppingProvider>();
    
    final ShoppingList? parsedList = await provider.parseRecipe(recipe);
    
    if (parsedList == null || parsedList.items == null || parsedList.items!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível extrair os ingredientes da receita.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
      return;
    }
    
    if (!mounted) return;

    final List<ShoppingItem> localItems = List<ShoppingItem>.from(parsedList.items ?? []);
    
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.background,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      parsedList.name ?? 'Confirmar Lista',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.success, size: 24),
                    tooltip: 'Adicionar Item',
                    onPressed: () {
                      _editItemDialog(
                        context,
                        const ShoppingItem(
                          description: '',
                          quantity: 1.0,
                          unit: ShoppingItemUnit.und,
                          price: 0.0,
                          isChecked: false,
                        ),
                        (newItem) {
                          setDialogState(() {
                            localItems.add(newItem);
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              content: localItems.isEmpty
                  ? const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Nenhum item na lista.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  : Container(
                      constraints: const BoxConstraints(maxHeight: 350),
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: localItems.length,
                        itemBuilder: (context, index) {
                          final item = localItems[index];
                          final priceFormatted = item.price != null && item.price! > 0
                              ? 'R\$ ${item.price!.toStringAsFixed(2)}'
                              : 'R\$ 0.00';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.description ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              priceFormatted,
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${item.quantity?.toStringAsFixed(0) ?? '1'} ${(item.unit?.value ?? 'und').toUpperCase()}',
                                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                                  onPressed: () {
                                    _editItemDialog(context, item, (updatedItem) {
                                      setDialogState(() {
                                        localItems[index] = updatedItem;
                                      });
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                                  onPressed: () {
                                    setDialogState(() {
                                      localItems.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.secondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Confirmar',
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
      },
    );
    
    if (confirmed == true && mounted) {
      final success = await provider.createListWithItems(parsedList.copyWith(items: localItems));
      if (success && mounted) {
        context.go('/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar a lista de compras.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingProvider>();
    final isLoading = provider.isLoading;

    return Scaffold(
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Extrair Ingredientes de Receita (IA)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cole o texto da receita abaixo. A IA irá identificar o nome da receita e os ingredientes, criando uma nova lista de compras automaticamente.',
                    style: TextStyle(color: AppTheme.secondary.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _recipeController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Texto da Receita',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.secondary),
                            foregroundColor: AppTheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _save,
                          child: isLoading 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('EXTRAIR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
  }
}
