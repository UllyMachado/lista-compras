import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../api/openapi.swagger.dart';
import '../providers/shopping_provider.dart';
import '../core/theme.dart';
import '../widgets/app_drawer.dart';

class EditItemScreen extends StatefulWidget {
  final String? itemId;

  const EditItemScreen({super.key, this.itemId});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  ShoppingItemUnit _selectedUnit = ShoppingItemUnit.und;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ShoppingProvider>();
    if (widget.itemId != null) {
      final item = provider.items.firstWhere((i) => i.id == widget.itemId);
      _descriptionController.text = item.description ?? '';
      _quantityController.text = item.quantity?.toString() ?? '1';
      _priceController.text = item.price?.toStringAsFixed(2) ?? '0.00';
      _selectedUnit = item.unit ?? ShoppingItemUnit.und;
      if (item.category != null) {
        try {
          _selectedCategory = provider.categories.firstWhere(
            (c) => c.id == item.category!.id,
          );
        } catch (_) {
          _selectedCategory = item.category;
        }
      } else {
        try {
          _selectedCategory = provider.categories.firstWhere(
            (c) => c.name == 'Outros',
          );
        } catch (_) {
          _selectedCategory = null;
        }
      }
    } else {
      // Default values
      _quantityController.text = '1';
      try {
        _selectedCategory = provider.categories.firstWhere(
          (c) => c.name == 'Outros',
        );
      } catch (_) {
        _selectedCategory = null;
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ShoppingProvider>();
    final description = _descriptionController.text.trim();
    final quantity =
        double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 1.0;

    double price = 0.0;
    if (_priceController.text.trim().isNotEmpty) {
      price =
          double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    }

    final isChecked = widget.itemId != null
        ? provider.items.firstWhere((i) => i.id == widget.itemId).isChecked
        : false;

    final newItem = ShoppingItem(
      id: widget.itemId,
      description: description,
      quantity: quantity,
      unit: _selectedUnit,
      price: price,
      isChecked: isChecked,
      category: _selectedCategory,
    );

    if (widget.itemId != null) {
      provider.updateItem(widget.itemId!, newItem);
    } else {
      provider.addItem(newItem);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final providerForSync = context.watch<ShoppingProvider>();
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
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obrigatório';
                      }
                      final length = v.trim().length;
                      if (length < 2) {
                        return 'Mínimo de 2 caracteres';
                      }
                      if (length > 100) {
                        return 'Máximo de 100 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Category?>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: providerForSync.categories.map((cat) {
                      return DropdownMenuItem<Category?>(
                        value: cat,
                        child: Text(cat.name ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Quantidade',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Requerido';
                            }
                            final val = double.tryParse(v.replaceAll(',', '.'));
                            if (val == null) {
                              return 'Inválido';
                            }
                            if (val < 0.01) {
                              return 'Mínimo 0.01';
                            }
                            if (val > 9999.0) {
                              return 'Máximo 9.999';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<ShoppingItemUnit>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(labelText: 'Unid.'),
                          items: ShoppingItemUnit.values
                              .where(
                                (u) =>
                                    u !=
                                    ShoppingItemUnit.swaggerGeneratedUnknown,
                              )
                              .map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit.value!.toUpperCase()),
                                );
                              })
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedUnit = val;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Preço (R\$)',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return null;
                            }
                            final val = double.tryParse(v.replaceAll(',', '.'));
                            if (val == null) {
                              return 'Inválido';
                            }
                            if (val < 0) {
                              return 'Mínimo 0.00';
                            }
                            if (val > 99999.99) {
                              return 'Máximo 99.999,99';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.secondary),
                            foregroundColor: AppTheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'CANCELAR',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text(
                            'SALVAR',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
