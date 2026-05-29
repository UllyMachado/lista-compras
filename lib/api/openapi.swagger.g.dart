// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openapi.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) => ShoppingItem(
  id: json['id'] as String?,
  description: json['description'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: shoppingItemUnitNullableFromJson(json['unit']),
  price: (json['price'] as num?)?.toDouble(),
  isChecked: json['isChecked'] as bool?,
);

Map<String, dynamic> _$ShoppingItemToJson(ShoppingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit': shoppingItemUnitNullableToJson(instance.unit),
      'price': instance.price,
      'isChecked': instance.isChecked,
    };

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
  id: json['id'] as String?,
  name: json['name'] as String?,
  budget: (json['budget'] as num?)?.toDouble(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ShoppingListToJson(ShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'budget': instance.budget,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

RecipeRequest _$RecipeRequestFromJson(Map<String, dynamic> json) =>
    RecipeRequest(recipe: json['recipe'] as String?);

Map<String, dynamic> _$RecipeRequestToJson(RecipeRequest instance) =>
    <String, dynamic>{'recipe': instance.recipe};
