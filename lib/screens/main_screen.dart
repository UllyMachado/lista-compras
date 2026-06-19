import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/shopping_provider.dart';
import '../core/filter_enums.dart';

import '../core/theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shopping_list_summary.dart';
import '../widgets/category_icon.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _lastSyncedListIndex = -1;
  final _searchController = TextEditingController();

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
                              .fold(
                                0.0,
                                (sum, item) =>
                                    sum +
                                    ((item.quantity ?? 1.0) *
                                        (item.price ?? 0.0)),
                              );
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          onTap: () => _showRenameDialog(
                                            context,
                                            currentListModel,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  currentListModel.name ?? 'Sem Nome',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.edit,
                                                color: Colors.white70,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppTheme.danger,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => _showDeleteDialog(
                                            context,
                                            currentListModel,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.analytics_outlined,
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => ShoppingListSummary(
                                                list: currentListModel,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.share,
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => ShoppingListSummary.shareList(currentListModel),
                                        ),
                                      ],
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

                              // Filter Bar + List Content (JP's individual feature)
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
                                      : Column(
                                          children: [
                                            // --- FILTER BAR ---
                                            _buildFilterBar(context, providerForSync),
                                            // --- ITEM LIST (filtered) ---
                                            Expanded(
                                              child: Builder(
                                                builder: (context) {
                                                  final displayItems = providerForSync.filteredItems;
                                                  if (displayItems.isEmpty && providerForSync.hasActiveFilters) {
                                                    return Center(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.filter_list_off,
                                                            size: 48,
                                                            color: AppTheme.background.withValues(alpha: 0.3),
                                                          ),
                                                          const SizedBox(height: 12),
                                                          Text(
                                                            'Nenhum item corresponde aos filtros.',
                                                            style: TextStyle(
                                                              color: AppTheme.background.withValues(alpha: 0.5),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          TextButton.icon(
                                                            onPressed: () => providerForSync.clearFilters(),
                                                            icon: const Icon(Icons.clear_all, size: 18),
                                                            label: const Text('Limpar Filtros'),
                                                            style: TextButton.styleFrom(
                                                              foregroundColor: AppTheme.primary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  return ListView.separated(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                    itemCount: displayItems.length,
                                                    separatorBuilder: (context, index) =>
                                                        Divider(
                                                          height: 1,
                                                          color: AppTheme.secondary
                                                              .withValues(alpha: 0.3),
                                                        ),
                                                    itemBuilder: (context, index) {
                                                      final item = displayItems[index];
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
                                                          if (listIndex != _lastSyncedListIndex) {
                                                            return false;
                                                          }
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
                                                            if (listIndex == _lastSyncedListIndex) {
                                                              context.push(
                                                                '/edit',
                                                                extra: item.id!,
                                                              );
                                                            }
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
                                                                  value:
                                                                      item.isChecked ??
                                                                      false,
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
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisSize:
                                                                        MainAxisSize.min,
                                                                    children: [
                                                                      Text(
                                                                        item.description ??
                                                                            '',
                                                                        maxLines: 1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style: TextStyle(
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w600,
                                                                          decoration:
                                                                              (item.isChecked ??
                                                                                  false)
                                                                              ? TextDecoration
                                                                                    .lineThrough
                                                                              : null,
                                                                          decorationColor:
                                                                              textColor,
                                                                        ),
                                                                      ),
                                                                      if (item.category !=
                                                                          null) ...[
                                                                        const SizedBox(
                                                                          height: 2,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              getCategoryIcon(
                                                                                item.category!.name,
                                                                              ),
                                                                              size: 12,
                                                                              color: textColor
                                                                                  .withValues(
                                                                                    alpha:
                                                                                        0.6,
                                                                                  ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                item.category!.name ?? '',
                                                                                style: TextStyle(
                                                                                  color: textColor.withValues(alpha: 0.6),
                                                                                  fontSize: 11,
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ],
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
                                                                          if (listIndex == _lastSyncedListIndex) {
                                                                            providerForSync.updateQuantity(
                                                                              item.id!,
                                                                              -1,
                                                                            );
                                                                          }
                                                                        },
                                                                      ),
                                                                      Text(
                                                                        (item.quantity ??
                                                                                    1.0)
                                                                                .toStringAsFixed(
                                                                                  (item.quantity ??
                                                                                                  1.0)
                                                                                              .truncateToDouble() ==
                                                                                          (item.quantity ??
                                                                                              1.0)
                                                                                      ? 0
                                                                                      : 2,
                                                                                ) +
                                                                            (item.unit?.value !=
                                                                                    null
                                                                                ? ' ${item.unit!.value}'
                                                                                : ''),
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
                                                                          if (listIndex == _lastSyncedListIndex) {
                                                                            providerForSync.updateQuantity(
                                                                              item.id!,
                                                                              1,
                                                                            );
                                                                          }
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
                                                                            item.price ??
                                                                                0.0,
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
                                                                      currencyFormatter.format(
                                                                        (item.quantity ??
                                                                                1.0) *
                                                                            (item.price ??
                                                                                0.0),
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
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
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

  // --- Filter Bar Widget (JP's individual feature) ---
  Widget _buildFilterBar(BuildContext context, ShoppingProvider provider) {
    return Container(
      color: AppTheme.background.withValues(alpha: 0.03),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Search field + Sort dropdown
          Row(
            children: [
              // Search field
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppTheme.background,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar itens...',
                      hintStyle: TextStyle(
                        color: AppTheme.background.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: AppTheme.background.withValues(alpha: 0.5),
                      ),
                      suffixIcon: provider.searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: AppTheme.background.withValues(alpha: 0.5),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.background.withValues(alpha: 0.06),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppTheme.background.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (value) => provider.setSearchQuery(value),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort dropdown button
              SizedBox(
                height: 38,
                child: PopupMenuButton<ItemSortMode>(
                  tooltip: 'Ordenar',
                  onSelected: (mode) => provider.setSortMode(mode),
                  offset: const Offset(0, 40),
                  color: AppTheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    _buildSortMenuItem(
                      ItemSortMode.none,
                      'Padrão',
                      Icons.format_list_numbered,
                      provider.sortMode,
                    ),
                    const PopupMenuDivider(),
                    _buildSortMenuItem(
                      ItemSortMode.nameAsc,
                      'Nome (A → Z)',
                      Icons.sort_by_alpha,
                      provider.sortMode,
                    ),
                    _buildSortMenuItem(
                      ItemSortMode.nameDesc,
                      'Nome (Z → A)',
                      Icons.sort_by_alpha,
                      provider.sortMode,
                    ),
                    const PopupMenuDivider(),
                    _buildSortMenuItem(
                      ItemSortMode.priceAsc,
                      'Preço (Menor)',
                      Icons.arrow_downward,
                      provider.sortMode,
                    ),
                    _buildSortMenuItem(
                      ItemSortMode.priceDesc,
                      'Preço (Maior)',
                      Icons.arrow_upward,
                      provider.sortMode,
                    ),
                    const PopupMenuDivider(),
                    _buildSortMenuItem(
                      ItemSortMode.totalAsc,
                      'Total (Menor)',
                      Icons.trending_down,
                      provider.sortMode,
                    ),
                    _buildSortMenuItem(
                      ItemSortMode.totalDesc,
                      'Total (Maior)',
                      Icons.trending_up,
                      provider.sortMode,
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: provider.sortMode != ItemSortMode.none
                          ? AppTheme.primary.withValues(alpha: 0.12)
                          : AppTheme.background.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: provider.sortMode != ItemSortMode.none
                            ? AppTheme.primary.withValues(alpha: 0.5)
                            : AppTheme.background.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort,
                          size: 16,
                          color: provider.sortMode != ItemSortMode.none
                              ? AppTheme.primary
                              : AppTheme.background.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getSortLabel(provider.sortMode),
                          style: TextStyle(
                            fontSize: 12,
                            color: provider.sortMode != ItemSortMode.none
                                ? AppTheme.primary
                                : AppTheme.background.withValues(alpha: 0.6),
                            fontWeight: provider.sortMode != ItemSortMode.none
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                          color: AppTheme.background.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Status filter chips + clear button
          Row(
            children: [
              _buildStatusChip(
                'Todos',
                ItemStatusFilter.all,
                Icons.list,
                provider,
              ),
              const SizedBox(width: 6),
              _buildStatusChip(
                'Comprados',
                ItemStatusFilter.checked,
                Icons.check_circle_outline,
                provider,
              ),
              const SizedBox(width: 6),
              _buildStatusChip(
                'Pendentes',
                ItemStatusFilter.unchecked,
                Icons.radio_button_unchecked,
                provider,
              ),
              const Spacer(),
              if (provider.hasActiveFilters)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    provider.clearFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear_all, size: 14, color: AppTheme.danger),
                        SizedBox(width: 4),
                        Text(
                          'Limpar',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(
            height: 1,
            color: AppTheme.background.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    String label,
    ItemStatusFilter filter,
    IconData icon,
    ShoppingProvider provider,
  ) {
    final isSelected = provider.statusFilter == filter;
    return GestureDetector(
      onTap: () => provider.setStatusFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.background.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.background.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.background.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ItemSortMode> _buildSortMenuItem(
    ItemSortMode mode,
    String label,
    IconData icon,
    ItemSortMode currentMode,
  ) {
    final isSelected = mode == currentMode;
    return PopupMenuItem<ItemSortMode>(
      value: mode,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppTheme.primary : Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 16, color: AppTheme.primary),
          ],
        ],
      ),
    );
  }

  String _getSortLabel(ItemSortMode mode) {
    switch (mode) {
      case ItemSortMode.none:
        return 'Ordenar';
      case ItemSortMode.nameAsc:
        return 'A→Z';
      case ItemSortMode.nameDesc:
        return 'Z→A';
      case ItemSortMode.priceAsc:
        return 'R\$ ↑';
      case ItemSortMode.priceDesc:
        return 'R\$ ↓';
      case ItemSortMode.totalAsc:
        return 'Total ↑';
      case ItemSortMode.totalDesc:
        return 'Total ↓';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
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
