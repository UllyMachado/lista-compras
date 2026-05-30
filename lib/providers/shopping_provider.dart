import 'package:flutter/foundation.dart';
import '../api/openapi.swagger.dart';

class ShoppingProvider with ChangeNotifier {
  final Openapi _api;
  List<ShoppingList> _lists = [];
  String? _currentListId;
  bool _isLoading = false;

  ShoppingProvider(this._api) {
    _fetchLists();
  }

  bool get isLoading => _isLoading;

  List<ShoppingList> get allLists => List.unmodifiable(_lists);

  ShoppingList? get currentList {
    if (_lists.isEmpty) return null;
    return _lists.firstWhere((l) => l.id == _currentListId, orElse: () => _lists.first);
  }

  double get budget => currentList?.budget ?? 0.0;
  List<ShoppingItem> get items => List.unmodifiable(currentList?.items ?? []);

  double get currentBalance {
    if (currentList == null) return 0.0;
    double checkedTotal = items
        .where((item) => item.isChecked ?? false)
        .fold(0.0, (sum, item) => sum + ((item.quantity ?? 1.0) * (item.price ?? 0.0)));
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
      final response = await _api.apiListsPost(body: ShoppingList(name: name, budget: 0.0));
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
      final response = await _api.apiListsIdPut(id: id, body: list.copyWith(name: newName));
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
      final response = await _api.apiListsIdPut(id: currentList!.id, body: currentList!.copyWith(budget: newValue));
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
      final response = await _api.apiListsListIdItemsPost(listId: currentList!.id, body: item);
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
      final response = await _api.apiListsListIdItemsItemIdPut(listId: currentList!.id, itemId: itemId, body: updatedItem);
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
      final response = await _api.apiListsListIdItemsItemIdDelete(listId: currentList!.id, itemId: itemId);
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
    await updateItem(itemId, item.copyWith(isChecked: !(item.isChecked ?? false)));
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

      final response = await _api.apiAiRecipeToListPost(body: RecipeRequest(recipe: recipe));

      if (response.isSuccessful && response.body != null) {
        return response.body;
      } else {
        debugPrint("Failed to parse recipe: ${response.statusCode} - ${response.error}");
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
}
