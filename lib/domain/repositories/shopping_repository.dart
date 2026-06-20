import 'package:lista_compras/data/models/models.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingList>> getLists();
  Future<ShoppingList> createList(String name);
  Future<ShoppingList> createListWithItems(ShoppingList list);
  Future<ShoppingList> updateList(String id, ShoppingList list);
  Future<void> deleteList(String id);
  
  Future<ShoppingItem> addItem(String listId, ShoppingItem item);
  Future<ShoppingItem> updateItem(String listId, String itemId, ShoppingItem item);
  Future<void> deleteItem(String listId, String itemId);
  
  Future<ShoppingList?> parseRecipe(String recipe);
  
  Future<List<Category>> getCategories();
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(String id, Category category);
  Future<void> deleteCategory(String id);
}
