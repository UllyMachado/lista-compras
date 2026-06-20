import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

part 'shopping_item.g.dart';

enum ShoppingItemUnit {
  und,
  g,
  kg,
  l,
  ml;

  String get value => name;
}

@JsonSerializable(explicitToJson: true)
class ShoppingItem {
  final String? id;
  final String? description;
  final double? quantity;
  final ShoppingItemUnit? unit;
  final double? price;
  final bool? isChecked;
  final Category? category;

  const ShoppingItem({
    this.id,
    this.description,
    this.quantity,
    this.unit,
    this.price,
    this.isChecked,
    this.category,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => _$ShoppingItemFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingItemToJson(this);

  ShoppingItem copyWith({
    String? id,
    String? description,
    double? quantity,
    ShoppingItemUnit? unit,
    double? price,
    bool? isChecked,
    Category? category,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
    );
  }

  ShoppingItem clearCategory() {
    return ShoppingItem(
      id: id,
      description: description,
      quantity: quantity,
      unit: unit,
      price: price,
      isChecked: isChecked,
      category: null,
    );
  }
}
