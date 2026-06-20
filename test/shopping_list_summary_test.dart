import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compras/data/datasources/remote/api/openapi.swagger.dart';
import 'package:lista_compras/presentation/widgets/shopping_list_summary.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

class MockSharePlatform extends SharePlatform {
  String? sharedText;
  String? sharedSubject;

  @override
  Future<ShareResult> share(ShareParams params) async {
    sharedText = params.text;
    sharedSubject = params.subject;
    return const ShareResult('success', ShareResultStatus.success);
  }

  @override
  Future<ShareResult> shareFiles(
    List<String> paths, {
    List<String>? mimeTypes,
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    return const ShareResult('success', ShareResultStatus.success);
  }

  @override
  Future<ShareResult> shareUri(
    Uri uri, {
    Rect? sharePositionOrigin,
  }) async {
    return const ShareResult('success', ShareResultStatus.success);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSharePlatform mockSharePlatform;

  setUp(() {
    mockSharePlatform = MockSharePlatform();
    SharePlatform.instance = mockSharePlatform;
  });

  tearDown(() {});

  testWidgets('ShoppingListSummary displays correct stats and renders pie chart', (WidgetTester tester) async {
    final mockList = ShoppingList(
      id: 'list-123',
      name: 'Churrasco Fim de Semana',
      budget: 200.0,
      items: [
        ShoppingItem(
          id: 'item-1',
          description: 'Carne',
          quantity: 2.0,
          price: 45.0, // Total: 90.0
          isChecked: true,
          category: const Category(id: 'cat-1', name: 'Açougue'),
        ),
        ShoppingItem(
          id: 'item-2',
          description: 'Cerveja',
          quantity: 12.0,
          price: 5.0, // Total: 60.0
          isChecked: false,
          category: const Category(id: 'cat-2', name: 'Bebidas'),
        ),
      ],
    );

    // Calculations verify:
    // Total Estimated: 90.0 + 60.0 = 150.0
    // Total Checked: 90.0
    // Economy (budget - totalEstimated): 200.0 - 150.0 = 50.0
    // Checked percentage: 1 / 2 = 50%

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ShoppingListSummary(list: mockList),
                  );
                },
                child: const Text('Show Summary'),
              );
            },
          ),
        ),
      ),
    );

    // Open Bottom Sheet
    await tester.tap(find.text('Show Summary'));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Resumo: Churrasco Fim de Semana'), findsOneWidget);

    // Verify Budget
    expect(find.text('R\$ 200,00'), findsOneWidget);

    // Verify Total Estimated
    expect(find.text('R\$ 150,00'), findsOneWidget);

    // Verify Total Checked (purchased)
    expect(find.text('R\$ 90,00'), findsOneWidget);

    // Verify Economy
    expect(find.text('R\$ 50,00'), findsOneWidget);

    // Verify Progress indicators
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1 itens'), findsNWidgets(2)); // "1 itens" under Legend (Comprados and Pendentes)
    expect(find.text('Total da lista: 2 itens'), findsOneWidget);
  });

  testWidgets('ShoppingListSummary handles empty list gracefully', (WidgetTester tester) async {
    final emptyList = ShoppingList(
      id: 'list-empty',
      name: 'Lista Vazia',
      budget: 100.0,
      items: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ShoppingListSummary(list: emptyList),
                  );
                },
                child: const Text('Show Empty Summary'),
              );
            },
          ),
        ),
      ),
    );

    // Open Bottom Sheet
    await tester.tap(find.text('Show Empty Summary'));
    await tester.pumpAndSettle();

    // Verify fallback UI text
    expect(find.text('Nenhum item na lista para gerar gráficos.'), findsOneWidget);
    expect(find.text('R\$ 100,00'), findsNWidgets(2)); // Budget R$ 100,00 and Economy R$ 100,00
    expect(find.text('R\$ 0,00'), findsNWidgets(2)); // Total Estimated R$ 0,00 and Checked R$ 0,00
  });

  test('ShoppingListSummary.shareList formats and invokes sharing service correctly', () {
    final shareList = ShoppingList(
      id: 'list-share',
      name: 'Mercado Mensal',
      budget: 100.0,
      items: [
        ShoppingItem(
          id: 'item-1',
          description: 'Arroz 5kg',
          quantity: 1.0,
          price: 25.0,
          isChecked: true,
          unit: ShoppingItemUnit.und,
          category: const Category(id: 'cat-1', name: 'Mercearia'),
        ),
        ShoppingItem(
          id: 'item-2',
          description: 'Detergente',
          quantity: 2.0,
          price: 2.50,
          isChecked: false,
          unit: ShoppingItemUnit.und,
          category: const Category(id: 'cat-2', name: 'Limpeza'),
        ),
      ],
    );

    ShoppingListSummary.shareList(shareList);

    // Verify sharing service was invoked
    expect(mockSharePlatform.sharedSubject, 'Lista de Compras: Mercado Mensal');
    final sharedText = mockSharePlatform.sharedText ?? '';

    expect(sharedText, contains('🛒 LISTA DE COMPRAS: Mercado Mensal'));
    expect(sharedText, contains('💰 Orçamento: R\$ 100,00'));
    expect(sharedText, contains('📉 Estimativa Total: R\$ 30,00'));
    expect(sharedText, contains('✅ Total Comprado: R\$ 25,00'));
    expect(sharedText, contains('💵 Saldo Restante: R\$ 75,00'));
    expect(sharedText, contains('[x] 1 und Arroz 5kg - R\$ 25,00 (Cat: Mercearia)'));
    expect(sharedText, contains('[ ] 2 und Detergente - R\$ 2,50 (Cat: Limpeza)'));
  });
}


