import '../datasources/remote/api/openapi.swagger.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final Openapi _api;

  ShoppingRepositoryImpl(this._api);

  @override
  Future<List<ShoppingList>> getLists() async {
    final response = await _api.apiListsGet();
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to get lists');
  }

  @override
  Future<ShoppingList> createList(String name) async {
    final response = await _api.apiListsPost(body: ShoppingList(name: name, budget: 0.0));
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to create list');
  }

  @override
  Future<ShoppingList> createListWithItems(ShoppingList list) async {
    final response = await _api.apiListsPost(body: list);
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to create list with items');
  }

  @override
  Future<ShoppingList> updateList(String id, ShoppingList list) async {
    final response = await _api.apiListsIdPut(id: id, body: list);
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to update list');
  }

  @override
  Future<void> deleteList(String id) async {
    final response = await _api.apiListsIdDelete(id: id);
    if (!response.isSuccessful) {
      throw Exception('Failed to delete list');
    }
  }

  @override
  Future<ShoppingItem> addItem(String listId, ShoppingItem item) async {
    final response = await _api.apiListsListIdItemsPost(listId: listId, body: item);
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to add item');
  }

  @override
  Future<ShoppingItem> updateItem(String listId, String itemId, ShoppingItem item) async {
    final response = await _api.apiListsListIdItemsItemIdPut(
      listId: listId,
      itemId: itemId,
      body: item,
    );
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to update item');
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    final response = await _api.apiListsListIdItemsItemIdDelete(listId: listId, itemId: itemId);
    if (!response.isSuccessful) {
      throw Exception('Failed to delete item');
    }
  }

  @override
  Future<ShoppingList?> parseRecipe(String recipe) async {
    final response = await _api.apiAiRecipeToListPost(body: RecipeRequest(recipe: recipe));
    if (response.isSuccessful && response.body != null) {
      return response.body;
    }
    return null;
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _api.apiCategoriesGet();
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to get categories');
  }

  @override
  Future<Category> createCategory(Category category) async {
    final response = await _api.apiCategoriesPost(body: category);
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to create category');
  }

  @override
  Future<Category> updateCategory(String id, Category category) async {
    final response = await _api.apiCategoriesIdPut(id: id, body: category);
    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }
    throw Exception('Failed to update category');
  }

  @override
  Future<void> deleteCategory(String id) async {
    final response = await _api.apiCategoriesIdDelete(id: id);
    if (!response.isSuccessful) {
      throw Exception('Failed to delete category');
    }
  }
}
