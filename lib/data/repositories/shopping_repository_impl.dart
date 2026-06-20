import 'package:dio/dio.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../models/models.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final Dio _dio;

  ShoppingRepositoryImpl(this._dio);

  @override
  Future<List<ShoppingList>> getLists() async {
    final response = await _dio.get('/api/lists');
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return (response.data as List).map((i) => ShoppingList.fromJson(i)).toList();
    }
    throw Exception('Failed to get lists');
  }

  @override
  Future<ShoppingList> createList(String name) async {
    final response = await _dio.post('/api/lists', data: {'name': name, 'budget': 0.0});
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return ShoppingList.fromJson(response.data);
    }
    throw Exception('Failed to create list');
  }

  @override
  Future<ShoppingList> createListWithItems(ShoppingList list) async {
    final response = await _dio.post('/api/lists', data: list.toJson());
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return ShoppingList.fromJson(response.data);
    }
    throw Exception('Failed to create list with items');
  }

  @override
  Future<ShoppingList> updateList(String id, ShoppingList list) async {
    final response = await _dio.put('/api/lists/$id', data: list.toJson());
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return ShoppingList.fromJson(response.data);
    }
    throw Exception('Failed to update list');
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      final response = await _dio.delete('/api/lists/$id', options: Options(responseType: ResponseType.plain));
      if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw Exception('Failed to delete list');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete list: ${e.response?.statusCode} ${e.response?.data} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete list: $e');
    }
  }

  @override
  Future<ShoppingItem> addItem(String listId, ShoppingItem item) async {
    try {
      final response = await _dio.post('/api/lists/$listId/items', data: item.toJson());
      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception('Failed to add item');
      }
      return ShoppingItem.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to add item: ${e.response?.statusCode} ${e.response?.data} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  @override
  Future<ShoppingItem> updateItem(String listId, String itemId, ShoppingItem item) async {
    final response = await _dio.put(
      '/api/lists/$listId/items/$itemId',
      data: item.toJson(),
    );
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return ShoppingItem.fromJson(response.data);
    }
    throw Exception('Failed to update item');
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    try {
      final response = await _dio.delete('/api/lists/$listId/items/$itemId', options: Options(responseType: ResponseType.plain));
      if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw Exception('Failed to delete item');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete item: ${e.response?.statusCode} ${e.response?.data} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  @override
  Future<ShoppingList?> parseRecipe(String recipe) async {
    final response = await _dio.post('/api/ai/recipe-to-list', data: {'recipe': recipe});
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return ShoppingList.fromJson(response.data);
    }
    return null;
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/api/categories');
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return (response.data as List).map((i) => Category.fromJson(i)).toList();
    }
    throw Exception('Failed to get categories');
  }

  @override
  Future<Category> createCategory(Category category) async {
    final response = await _dio.post('/api/categories', data: category.toJson());
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return Category.fromJson(response.data);
    }
    throw Exception('Failed to create category');
  }

  @override
  Future<Category> updateCategory(String id, Category category) async {
    final response = await _dio.put('/api/categories/$id', data: category.toJson());
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
      return Category.fromJson(response.data);
    }
    throw Exception('Failed to update category');
  }

  @override
  Future<void> deleteCategory(String id) async {
    final response = await _dio.delete('/api/categories/$id');
    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      throw Exception('Failed to delete category');
    }
  }
}
