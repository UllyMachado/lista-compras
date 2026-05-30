import 'package:flutter/foundation.dart' hide Category;
import '../api/openapi.swagger.dart';

class ShoppingProvider with ChangeNotifier {
  final Openapi _api;
  List<ShoppingList> _lists = [];
  List<Category> _categories = [];
  String? _currentListId;
  bool _isLoading = false;

  ShoppingProvider(this._api) {
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
      final response = await _api.apiListsGet();
      if (response.isSuccessful && response.body != null) {
        _lists = response.body!;
        if (_currentListId == null && _lists.isNotEmpty) {
          _currentListId = _lists.first.id;
        }
      }
    } catch (e) {
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
      final response = await _api.apiListsPost(
        body: ShoppingList(name: name, budget: 0.0),
      );
      if (response.isSuccessful && response.body != null) {
        _lists.add(response.body!);
        _currentListId = response.body!.id;
      }
    } catch (e) {
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
      final response = await _api.apiListsIdPut(
        id: id,
        body: list.copyWith(name: newName),
      );
      if (response.isSuccessful && response.body != null) {
        final index = _lists.indexWhere((l) => l.id == id);
        _lists[index] = response.body!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error renaming list: $e");
    }
  }

  Future<void> deleteList(String id) async {
    try {
      final response = await _api.apiListsIdDelete(id: id);
      if (response.isSuccessful) {
        _lists.removeWhere((l) => l.id == id);
        if (_currentListId == id) {
          _currentListId = _lists.isNotEmpty ? _lists.first.id : null;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error deleting list: $e");
    }
  }

  void switchList(String id) {
    if (_lists.any((l) => l.id == id)) {
      _currentListId = id;
      notifyListeners();
    }
  }

  Future<void> setBudget(double newValue) async {
    if (currentList == null) return;
    try {
      final response = await _api.apiListsIdPut(
        id: currentList!.id,
        body: currentList!.copyWith(budget: newValue),
      );
      if (response.isSuccessful && response.body != null) {
        final index = _lists.indexWhere((l) => l.id == currentList!.id);
        _lists[index] = response.body!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error setting budget: $e");
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    if (currentList == null || currentList!.id == null) return;
    try {
      final response = await _api.apiListsListIdItemsPost(
        listId: currentList!.id,
        body: item,
      );
      if (response.isSuccessful && response.body != null) {
        final index = _lists.indexWhere((l) => l.id == currentList!.id);
        final currentItems = List<ShoppingItem>.from(_lists[index].items ?? []);
        currentItems.add(response.body!);
        _lists[index] = _lists[index].copyWith(items: currentItems);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error adding item: $e");
    }
  }

  Future<void> updateItem(String itemId, ShoppingItem updatedItem) async {
    if (currentList == null || currentList!.id == null) return;
    try {
      final response = await _api.apiListsListIdItemsItemIdPut(
        listId: currentList!.id,
        itemId: itemId,
        body: updatedItem,
      );
      if (response.isSuccessful && response.body != null) {
        final index = _lists.indexWhere((l) => l.id == currentList!.id);
        final currentItems = List<ShoppingItem>.from(_lists[index].items ?? []);
        final itemIndex = currentItems.indexWhere((i) => i.id == itemId);
        if (itemIndex != -1) {
          currentItems[itemIndex] = response.body!;
          _lists[index] = _lists[index].copyWith(items: currentItems);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error updating item: $e");
    }
  }

  Future<void> removeItem(String itemId) async {
    if (currentList == null || currentList!.id == null) return;
    try {
      final response = await _api.apiListsListIdItemsItemIdDelete(
        listId: currentList!.id,
        itemId: itemId,
      );
      if (response.isSuccessful) {
        final index = _lists.indexWhere((l) => l.id == currentList!.id);
        final currentItems = List<ShoppingItem>.from(_lists[index].items ?? []);
        currentItems.removeWhere((i) => i.id == itemId);
        _lists[index] = _lists[index].copyWith(items: currentItems);
        notifyListeners();
      }
    } catch (e) {
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

      final response = await _api.apiAiRecipeToListPost(
        body: RecipeRequest(recipe: recipe),
      );

      if (response.isSuccessful && response.body != null) {
        return response.body;
      } else {
        debugPrint(
          "Failed to parse recipe: ${response.statusCode} - ${response.error}",
        );
        return null;
      }
    } catch (e) {
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
      final response = await _api.apiListsPost(body: list);
      if (response.isSuccessful && response.body != null) {
        _lists.add(response.body!);
        _currentListId = response.body!.id;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
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
      final response = await _api.apiCategoriesGet();
      if (response.isSuccessful && response.body != null) {
        _categories = response.body!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> createCategory(String name, String description) async {
    try {
      final response = await _api.apiCategoriesPost(
        body: Category(name: name, description: description),
      );
      if (response.isSuccessful && response.body != null) {
        _categories.add(response.body!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error creating category: $e");
    }
  }

  Future<void> updateCategory(
    String id,
    String name,
    String description,
  ) async {
    try {
      final response = await _api.apiCategoriesIdPut(
        id: id,
        body: Category(id: id, name: name, description: description),
      );
      if (response.isSuccessful && response.body != null) {
        final index = _categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          _categories[index] = response.body!;
          // Also update categories within cached lists
          for (var i = 0; i < _lists.length; i++) {
            final items = List<ShoppingItem>.from(_lists[i].items ?? []);
            bool updated = false;
            for (var j = 0; j < items.length; j++) {
              if (items[j].category?.id == id) {
                items[j] = items[j].copyWith(category: response.body!);
                updated = true;
              }
            }
            if (updated) {
              _lists[i] = _lists[i].copyWith(items: items);
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error updating category: $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final response = await _api.apiCategoriesIdDelete(id: id);
      if (response.isSuccessful) {
        _categories.removeWhere((c) => c.id == id);
        // Null out category for items referencing the deleted one
        for (var i = 0; i < _lists.length; i++) {
          final items = List<ShoppingItem>.from(_lists[i].items ?? []);
          bool updated = false;
          for (var j = 0; j < items.length; j++) {
            if (items[j].category?.id == id) {
              items[j] = items[j].copyWithWrapped(
                category: const Wrapped.value(null),
              );
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
      debugPrint("Error deleting category: $e");
    }
  }
}
