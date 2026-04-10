import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';
import '../core/theme.dart';
import '../widgets/app_drawer.dart';

class EditItemScreen extends StatefulWidget {
  final int? itemIndex;

  const EditItemScreen({super.key, this.itemIndex});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.itemIndex != null) {
      final provider = context.read<ShoppingProvider>();
      final item = provider.items[widget.itemIndex!];
      _descriptionController.text = item.description;
      _quantityController.text = item.quantity.toString();
      _priceController.text = item.price.toStringAsFixed(2);
    } else {
      // Default values
      _quantityController.text = '1';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ShoppingProvider>();
    final description = _descriptionController.text.trim();
    final quantity = double.parse(
      _quantityController.text.replaceAll(',', '.'),
    );
    final price = double.parse(_priceController.text.replaceAll(',', '.'));

    final newItem = ShoppingItem(
      id: widget.itemIndex != null
          ? provider.items[widget.itemIndex!].id
          : DateTime.now().toIso8601String(),
      description: description,
      quantity: quantity,
      price: price,
      isChecked: widget.itemIndex != null
          ? provider.items[widget.itemIndex!].isChecked
          : false,
    );

    if (widget.itemIndex != null) {
      provider.updateItem(widget.itemIndex!, newItem);
    } else {
      provider.addItem(newItem);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
                      if (v == null || v.trim().isEmpty)
                        return 'Campo obrigatório';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Quantidade',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Requerido';
                            if (double.tryParse(v.replaceAll(',', '.')) == null)
                              return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Preço (R\$)',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Requerido';
                            if (double.tryParse(v.replaceAll(',', '.')) == null)
                              return 'Inválido';
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
