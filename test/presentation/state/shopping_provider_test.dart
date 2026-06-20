import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lista_compras/domain/repositories/shopping_repository.dart';
import 'package:lista_compras/presentation/state/shopping_provider.dart';
import 'package:lista_compras/data/datasources/remote/api/openapi.swagger.dart';
import 'package:lista_compras/core/filter_enums.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockShoppingRepository mockRepository;

  final item1 = ShoppingItem(
    id: '1',
    description: 'Apple',
    quantity: 2,
    price: 1.5,
    isChecked: false,
    category: Category(id: 'c1', name: 'Fruits'),
  );

  final item2 = ShoppingItem(
    id: '2',
    description: 'Banana',
    quantity: 3,
    price: 0.5,
    isChecked: true,
    category: Category(id: 'c1', name: 'Fruits'),
  );

  final list1 = ShoppingList(
    id: 'l1',
    name: 'Groceries',
    budget: 50.0,
    items: [item1, item2],
  );

  setUp(() {
    mockRepository = MockShoppingRepository();
    // Default answers for constructor calls
    when(() => mockRepository.getLists()).thenAnswer((_) async => [list1]);
    when(() => mockRepository.getCategories()).thenAnswer((_) async => []);
  });

  ShoppingProvider createProvider() {
    return ShoppingProvider(mockRepository);
  }

  group('ShoppingProvider filtering and sorting', () {
    test('currentBalance calculation is correct', () async {
      final provider = createProvider();
      // Wait for fetchLists to complete
      await Future.delayed(Duration.zero);
      
      // budget is 50.0
      // item2 is checked: 3 * 0.5 = 1.5
      // balance = 50.0 - 1.5 = 48.5
      expect(provider.currentBalance, 48.5);
    });

    test('search query filters items by description or category', () async {
      final provider = createProvider();
      await Future.delayed(Duration.zero);

      provider.setSearchQuery('apple');
      expect(provider.filteredItems.length, 1);
      expect(provider.filteredItems.first.description, 'Apple');

      provider.setSearchQuery('fruits');
      expect(provider.filteredItems.length, 2);
    });

    test('status filter works', () async {
      final provider = createProvider();
      await Future.delayed(Duration.zero);

      provider.setStatusFilter(ItemStatusFilter.checked);
      expect(provider.filteredItems.length, 1);
      expect(provider.filteredItems.first.description, 'Banana');

      provider.setStatusFilter(ItemStatusFilter.unchecked);
      expect(provider.filteredItems.length, 1);
      expect(provider.filteredItems.first.description, 'Apple');
    });

    test('sorts by name works', () async {
      final provider = createProvider();
      await Future.delayed(Duration.zero);

      provider.setSortMode(ItemSortMode.nameAsc);
      expect(provider.filteredItems[0].description, 'Apple');
      expect(provider.filteredItems[1].description, 'Banana');

      provider.setSortMode(ItemSortMode.nameDesc);
      expect(provider.filteredItems[0].description, 'Banana');
      expect(provider.filteredItems[1].description, 'Apple');
    });

    test('clear filters resets everything', () async {
      final provider = createProvider();
      await Future.delayed(Duration.zero);

      provider.setSearchQuery('apple');
      provider.setStatusFilter(ItemStatusFilter.checked);
      provider.setSortMode(ItemSortMode.priceAsc);

      provider.clearFilters();

      expect(provider.searchQuery, '');
      expect(provider.statusFilter, ItemStatusFilter.all);
      expect(provider.sortMode, ItemSortMode.none);
      expect(provider.filteredItems.length, 2);
    });
  });
}
