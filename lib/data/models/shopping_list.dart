import 'package:json_annotation/json_annotation.dart';
import 'shopping_item.dart';

part 'shopping_list.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingList {
  final String? id;
  final String? name;
  final double? budget;
  final String? description;
  final String? status;
  final String? createdAt;
  final List<ShoppingItem>? items;

  const ShoppingList({
    this.id,
    this.name,
    this.budget,
    this.description,
    this.status,
    this.createdAt,
    this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);

  ShoppingList copyWith({
    String? id,
    String? name,
    double? budget,
    String? description,
    String? status,
    String? createdAt,
    List<ShoppingItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
