import 'package:flutter/foundation.dart' hide Category;
import 'package:lista_compras/data/models/models.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../../core/filter_enums.dart';
import '../../core/globals.dart';

class ShoppingProvider with ChangeNotifier {
  final ShoppingRepository _repository;
  List<ShoppingList> _lists = [];
  List<Category> _categories = [];
  String? _currentListId;
  bool _isLoading = false;

  // --- Filter & Sort state ---
  String _searchQuery = '';
  ItemStatusFilter _statusFilter = ItemStatusFilter.all;
  ItemSortMode _sortMode = ItemSortMode.none;

  ShoppingProvider(this._repository) {
    _fetchLists();
    fetchCategories();
  }

  bool get isLoading => _isLoading;

  List<ShoppingList> get allLists => List.unmodifiable(_lists);

  ShoppingList? get currentList {
    if (_lists.isEmpty) return null;
    return _lists.firstWhere(
      (l) => l.id == _currentListId,
      orElse: () => _lists.first,
    );
  }

  double get budget => currentList?.budget ?? 0.0;
  List<ShoppingItem> get items => List.unmodifiable(currentList?.items ?? []);

  String get searchQuery => _searchQuery;
  ItemStatusFilter get statusFilter => _statusFilter;
  ItemSortMode get sortMode => _sortMode;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _statusFilter != ItemStatusFilter.all ||
      _sortMode != ItemSortMode.none;

  List<ShoppingItem> get filteredItems {
    List<ShoppingItem> result = List.from(currentList?.items ?? []);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((item) {
        final desc = (item.description ?? '').toLowerCase();
        final cat = (item.category?.name ?? '').toLowerCase();
        return desc.contains(query) || cat.contains(query);
      }).toList();
    }

    switch (_statusFilter) {
      case ItemStatusFilter.checked:
        result = result.where((item) => item.isChecked ?? false).toList();
        break;
      case ItemStatusFilter.unchecked:
        result = result.where((item) => !(item.isChecked ?? false)).toList();
        break;
      case ItemStatusFilter.all:
        break;
    }

    switch (_sortMode) {
      case ItemSortMode.nameAsc:
        result.sort((a, b) => (a.description ?? '').compareTo(b.description ?? ''));
        break;
      case ItemSortMode.nameDesc:
        result.sort((a, b) => (b.description ?? '').compareTo(a.description ?? ''));
        break;
      case ItemSortMode.priceAsc:
        result.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case ItemSortMode.priceDesc:
        result.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case ItemSortMode.totalAsc:
        result.sort((a, b) {
          final totalA = (a.quantity ?? 1.0) * (a.price ?? 0.0);
          final totalB = (b.quantity ?? 1.0) * (b.price ?? 0.0);
          return totalA.compareTo(totalB);
        });
        break;
      case ItemSortMode.totalDesc:
        result.sort((a, b) {
          final totalA = (a.quantity ?? 1.0) * (a.price ?? 0.0);
          final totalB = (b.quantity ?? 1.0) * (b.price ?? 0.0);
          return totalB.compareTo(totalA);
        });
        break;
      case ItemSortMode.none:
        break;
    }

    return List.unmodifiable(result);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(ItemStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSortMode(ItemSortMode mode) {
    _sortMode = mode;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = ItemStatusFilter.all;
    _sortMode = ItemSortMode.none;
    notifyListeners();
  }

  double get currentBalance {
    if (currentList == null) return 0.0;
    double checkedTotal = items
        .where((item) => item.isChecked ?? false)
        .fold(
          0.0,
          (sum, item) => sum + ((item.quantity ?? 1.0) * (item.price ?? 0.0)),
        );
    return (currentList!.budget ?? 0.0) - checkedTotal;
  }

  Future<void> _fetchLists() async {
    _isLoading = true;
    notifyListeners();
    try {
      _lists = await _repository.getLists();
      if (_currentListId == null && _lists.isNotEmpty) {
        _currentListId = _lists.first.id;
      }
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao buscar listas.');
      debugPrint("Error fetching lists: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createList(String name) async {
    if (name.trim().isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final newList = await _repository.createList(name);
      _lists.add(newList);
      _currentListId = newList.id;
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao criar lista.');
      debugPrint("Error creating list: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> renameList(String id, String newName) async {
    if (newName.trim().isEmpty) return;
    final list = _lists.firstWhere((l) => l.id == id);
    try {
      final updatedList = await _repository.updateList(id, list.copyWith(name: newName));
      final index = _lists.indexWhere((l) => l.id == id);
      _lists[index] = updatedList;
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao renomear lista.');
      debugPrint("Error renaming list: $e");
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await _repository.deleteList(id);
      _lists.removeWhere((l) => l.id == id);
      if (_currentListId == id) {
        _currentListId = _lists.isNotEmpty ? _lists.first.id : null;
      }
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao excluir lista.');
      debugPrint("Error deleting list: $e");
    }
  }

  void switchList(String id) {
    if (_lists.any((l) => l.id == id)) {
      _currentListId = id;
      _searchQuery = '';
      _statusFilter = ItemStatusFilter.all;
      _sortMode = ItemSortMode.none;
      notifyListeners();
    }
  }

  Future<void> setBudget(double newValue) async {
    if (currentList == null) return;
    try {
      final updatedList = await _repository.updateList(currentList!.id!, currentList!.copyWith(budget: newValue));
      final index = _lists.indexWhere((l) => l.id == currentList!.id);
      _lists[index] = updatedList;
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao definir orçamento.');
      debugPrint("Error setting budget: $e");
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    if (currentList == null || currentList!.id == null) return;
    try {
      final newItem = await _repository.addItem(currentList!.id!, item);
      final index = _lists.indexWhere((l) => l.id == currentList!.id);
      final currentItems = List<ShoppingItem>.from(_lists[index].items ?? []);
      currentItems.add(newItem);
      _lists[index] = _lists[index].copyWith(items: currentItems);
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao adicionar item.');
      debugPrint("Error adding item: $e");
    }
  }

  Future<void> updateItem(String itemId, ShoppingItem updatedItem) async {
    if (currentList == null || currentList!.id == null) return;
    try {
      final resultItem = await _repository.updateItem(currentList!.id!, itemId, updatedItem);
      final index = _lists.indexWhere((l) => l.id == currentList!.id);
      final currentItems = List<ShoppingItem>.from(_lists[index].items ?? []);
      final itemIndex = currentItems.indexWhere((i) => i.id == itemId);
      if (itemIndex != -1) {
        currentItems[itemIndex] = resultItem;
        _lists[index] = _lists[index].copyWith(items: currentItems);
        notifyListeners();
      }
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao atualizar item.');
      debugPrint("Error updating item: $e");
    }
  }

  Future<void> removeItem(String itemId) async {
    if (currentList == null || currentList!.id == null) return;
    try {
      await _repository.deleteItem(currentList!.id!, itemId);
      final index = _lists.indexWhere((l) => l.id == currentList!.id);
      final currentItems = List<ShoppingItem>.from(_lists[index].items ?? []);
      currentItems.removeWhere((i) => i.id == itemId);
      _lists[index] = _lists[index].copyWith(items: currentItems);
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao excluir item.');
      debugPrint("Error removing item: $e");
    }
  }

  Future<void> toggleItemCheck(String itemId) async {
    if (currentList == null) return;
    final item = items.firstWhere((i) => i.id == itemId);
    await updateItem(
      itemId,
      item.copyWith(isChecked: !(item.isChecked ?? false)),
    );
  }

  Future<void> updateQuantity(String itemId, double amount) async {
    if (currentList == null) return;
    final item = items.firstWhere((i) => i.id == itemId);
    double newQuantity = (item.quantity ?? 1.0) + amount;
    if (newQuantity < 1) newQuantity = 1;
    await updateItem(itemId, item.copyWith(quantity: newQuantity));
  }

  Future<ShoppingList?> parseRecipe(String recipe) async {
    try {
      _isLoading = true;
      notifyListeners();
      return await _repository.parseRecipe(recipe);
    } catch (e) {
      showErrorSnackBar('Erro ao processar receita com inteligência artificial.');
      debugPrint("Error parsing recipe: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createListWithItems(ShoppingList list) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newList = await _repository.createListWithItems(list);
      _lists.add(newList);
      _currentListId = newList.id;
      notifyListeners();
      return true;
    } catch (e) {
      showErrorSnackBar('Erro ao criar lista a partir dos itens.');
      debugPrint("Error creating list with items: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Category> get categories => List.unmodifiable(_categories);

  Future<void> fetchCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao buscar categorias.');
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> createCategory(String name, String description) async {
    try {
      final newCat = await _repository.createCategory(Category(name: name, description: description));
      _categories.add(newCat);
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao criar categoria.');
      debugPrint("Error creating category: $e");
    }
  }

  Future<void> updateCategory(
    String id,
    String name,
    String description,
  ) async {
    try {
      final updatedCat = await _repository.updateCategory(id, Category(id: id, name: name, description: description));
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCat;
        for (var i = 0; i < _lists.length; i++) {
          final items = List<ShoppingItem>.from(_lists[i].items ?? []);
          bool updated = false;
          for (var j = 0; j < items.length; j++) {
            if (items[j].category?.id == id) {
              items[j] = items[j].copyWith(category: updatedCat);
              updated = true;
            }
          }
          if (updated) {
            _lists[i] = _lists[i].copyWith(items: items);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao atualizar categoria.');
      debugPrint("Error updating category: $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      for (var i = 0; i < _lists.length; i++) {
        final items = List<ShoppingItem>.from(_lists[i].items ?? []);
        bool updated = false;
        for (var j = 0; j < items.length; j++) {
          if (items[j].category?.id == id) {
            items[j] = items[j].clearCategory();
            updated = true;
          }
        }
        if (updated) {
          _lists[i] = _lists[i].copyWith(items: items);
        }
      }
      notifyListeners();
    } catch (e) {
      showErrorSnackBar('Erro de conexão ao excluir categoria.');
      debugPrint("Error deleting category: $e");
    }
  }
}
