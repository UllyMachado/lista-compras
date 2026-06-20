import 'shopping_item.dart';

class ShoppingList {
  final String id;
  String name;
  double budget;
  List<ShoppingItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    this.budget = 0.0,
    List<ShoppingItem>? items,
  }) : items = items ?? [];
}
