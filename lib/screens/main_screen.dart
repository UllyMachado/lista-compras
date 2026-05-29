import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/shopping_provider.dart';

import '../core/theme.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _lastSyncedListIndex = -1;

  @override
  void initState() {
    super.initState();
    // Setup PageController for Infinite Carousel
    final provider = context.read<ShoppingProvider>();
    final currentIndex = provider.allLists.indexWhere(
      (l) => l.id == provider.currentList?.id,
    );
    final validIndex = currentIndex != -1 ? currentIndex : 0;
    final initialPage = provider.allLists.isNotEmpty
        ? (10000 * provider.allLists.length) + validIndex
        : 0;

    _pageController = PageController(initialPage: initialPage);
    _lastSyncedListIndex = validIndex;
  }

  void _handlePageChanged(int index) {
    final provider = context.read<ShoppingProvider>();
    if (provider.allLists.isEmpty) return;

    final listIndex = index % provider.allLists.length;
    provider.switchList(provider.allLists[listIndex].id!);
  }

  void _showRenameDialog(BuildContext context, dynamic list) {
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
                    list.id!,
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

  void _showDeleteDialog(BuildContext context, dynamic list) {
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
            'Tem certeza que deseja excluir "${list.name ?? 'Sem Nome'}" permanentemente?',
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
                context.read<ShoppingProvider>().deleteList(list.id!);
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final providerForSync = context.watch<ShoppingProvider>();

    // Synchronize page controller with external switches
    if (providerForSync.allLists.isNotEmpty) {
      final safeCurrentIndex = providerForSync.allLists.indexWhere(
        (l) => l.id == providerForSync.currentList?.id,
      );
      if (safeCurrentIndex != -1 &&
          safeCurrentIndex != _lastSyncedListIndex &&
          _pageController.hasClients) {
        final currentPage = _pageController.page?.round() ?? 0;
        final currentMod = currentPage % providerForSync.allLists.length;
        final difference = safeCurrentIndex - currentMod;
        final targetPage = currentPage + difference;

        if (currentPage != targetPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                targetPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
        _lastSyncedListIndex = safeCurrentIndex;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: GestureDetector(
          onTap: () => context.go('/manage'),
          child: const Text('Lista de Compras'),
        ),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Expanded(
                child: providerForSync.allLists.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma lista encontrada.',
                          style: TextStyle(
                            color: AppTheme.secondary.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        onPageChanged: _handlePageChanged,
                        itemBuilder: (context, pageIndex) {
                          final listIndex =
                              pageIndex % providerForSync.allLists.length;
                          final currentListModel =
                              providerForSync.allLists[listIndex];
                          final items = currentListModel.items ?? [];

                          double checkedTotal = items
                              .where((item) => item.isChecked ?? false)
                              .fold(0.0, (sum, item) => sum + ((item.quantity ?? 1.0) * (item.price ?? 0.0)));
                          double currentBalance =
                              (currentListModel.budget ?? 0.0) - checkedTotal;

                          return Column(
                            children: [
                              // Local Header (Current List Name & Share)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showRenameDialog(context, currentListModel),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            currentListModel.name ?? 'Sem Nome',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.edit, color: Colors.white70, size: 18),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppTheme.danger,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _showDeleteDialog(context, currentListModel),
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.share,
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Link copiado para a área de transferência!',
                                                  ),
                                                  backgroundColor: AppTheme.success,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Header Segment (Reverted Financial Layout)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.1),
                                  border: const Border(
                                    bottom: BorderSide(
                                      color: AppTheme.secondary,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: _BudgetTextField(
                                        budget: currentListModel.budget ?? 0.0,
                                        onChanged: (newVal) {
                                          if (listIndex ==
                                              _lastSyncedListIndex) {
                                            providerForSync.setBudget(newVal);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Saldo Atual',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppTheme.secondary,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              currencyFormatter.format(
                                                currentBalance,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    color: currentBalance < 0
                                                        ? AppTheme.danger
                                                        : AppTheme.success,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // List Content
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: items.isEmpty
                                      ? Center(
                                          child: Text(
                                            'Sua lista está vazia. Adicione itens!',
                                            style: TextStyle(
                                              color: AppTheme.background
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          itemCount: items.length,
                                          separatorBuilder: (context, index) =>
                                              Divider(
                                                height: 1,
                                                color: AppTheme.secondary
                                                    .withValues(alpha: 0.3),
                                              ),
                                          itemBuilder: (context, index) {
                                            final item = items[index];
                                            const textColor =
                                                AppTheme.background;

                                            return Dismissible(
                                              key: ValueKey(
                                                item.id ?? '$listIndex-$index',
                                              ),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                color: AppTheme.danger,
                                                alignment:
                                                    Alignment.centerRight,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              confirmDismiss: (direction) async {
                                                if (listIndex !=
                                                    _lastSyncedListIndex)
                                                  return false;
                                                return await showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          AppTheme.background,
                                                      title: const Text(
                                                        "Confirmar Exclusão",
                                                      ),
                                                      content: Text(
                                                        "Tem certeza que deseja excluir o item '${item.description}'?",
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(false),
                                                          child: const Text(
                                                            "Cancelar",
                                                            style: TextStyle(
                                                              color: AppTheme
                                                                  .secondary,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(true),
                                                          child: const Text(
                                                            "Excluir",
                                                            style: TextStyle(
                                                              color: AppTheme
                                                                  .danger,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              onDismissed: (direction) {
                                                if (listIndex ==
                                                    _lastSyncedListIndex) {
                                                  providerForSync.removeItem(
                                                    item.id!,
                                                  );
                                                }
                                              },
                                              child: InkWell(
                                                onTap: () {
                                                  if (listIndex ==
                                                      _lastSyncedListIndex)
                                                    context.push(
                                                      '/edit',
                                                      extra: item.id!,
                                                    );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12.0,
                                                        horizontal: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        value: item.isChecked ?? false,
                                                        activeColor:
                                                            AppTheme.success,
                                                        checkColor:
                                                            Colors.white,
                                                        side: const BorderSide(
                                                          color: AppTheme
                                                              .background,
                                                          width: 2,
                                                        ),
                                                        onChanged: (_) {
                                                          if (listIndex ==
                                                              _lastSyncedListIndex) {
                                                            providerForSync
                                                                .toggleItemCheck(
                                                                  item.id!,
                                                                );
                                                          }
                                                        },
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          item.description ?? '',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            decoration:
                                                                (item.isChecked ?? false)
                                                                ? TextDecoration
                                                                      .lineThrough
                                                                : null,
                                                            decorationColor:
                                                                textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 36,
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppTheme
                                                              .background
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              iconSize: 16,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(
                                                                    minWidth:
                                                                        32,
                                                                    minHeight:
                                                                        32,
                                                                  ),
                                                              icon: const Icon(
                                                                Icons.remove,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              onPressed: () {
                                                                if (listIndex ==
                                                                    _lastSyncedListIndex)
                                                                  providerForSync
                                                                      .updateQuantity(
                                                                        item.id!,
                                                                        -1,
                                                                      );
                                                              },
                                                            ),
                                                            Text(
                                                              (item.quantity ?? 1.0).toStringAsFixed(
                                                                (item.quantity ?? 1.0)
                                                                            .truncateToDouble() ==
                                                                        (item.quantity ?? 1.0)
                                                                    ? 0
                                                                    : 2,
                                                              ) + (item.unit?.value != null ? ' ${item.unit!.value}' : ''),
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            IconButton(
                                                              iconSize: 16,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(
                                                                    minWidth:
                                                                        32,
                                                                    minHeight:
                                                                        32,
                                                                  ),
                                                              icon: const Icon(
                                                                Icons.add,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              onPressed: () {
                                                                if (listIndex ==
                                                                    _lastSyncedListIndex)
                                                                  providerForSync
                                                                      .updateQuantity(
                                                                        item.id!,
                                                                        1,
                                                                      );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            currencyFormatter
                                                                .format(
                                                                  item.price ?? 0.0,
                                                                ),
                                                            style: TextStyle(
                                                              color: textColor
                                                                  .withValues(
                                                                    alpha: 0.7,
                                                                  ),
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        flex: 2,
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            currencyFormatter
                                                                .format(
                                                                  (item.quantity ?? 1.0) * (item.price ?? 0.0),
                                                                ),
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // Fixed Footer
              if (providerForSync.allLists.isNotEmpty)
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
                      'Incluir Novo Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => context.push('/edit'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _BudgetTextField extends StatefulWidget {
  final double budget;
  final Function(double) onChanged;

  const _BudgetTextField({required this.budget, required this.onChanged});

  @override
  State<_BudgetTextField> createState() => _BudgetTextFieldState();
}

class _BudgetTextFieldState extends State<_BudgetTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.budget > 0 ? widget.budget.toStringAsFixed(2) : '',
    );
  }

  @override
  void didUpdateWidget(covariant _BudgetTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.budget != widget.budget && !FocusScope.of(context).hasFocus) {
      _controller.text = widget.budget > 0
          ? widget.budget.toStringAsFixed(2)
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Orçamento',
        prefixText: 'R\$ ',
      ),
      onChanged: (val) {
        final parsed = double.tryParse(val.replaceAll(',', '.'));
        widget.onChanged(parsed ?? 0.0);
      },
    );
  }
}
