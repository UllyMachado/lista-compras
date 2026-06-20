// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) => ShoppingItem(
  id: json['id'] as String?,
  description: json['description'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: $enumDecodeNullable(_$ShoppingItemUnitEnumMap, json['unit']),
  price: (json['price'] as num?)?.toDouble(),
  isChecked: json['isChecked'] as bool?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShoppingItemToJson(ShoppingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit': _$ShoppingItemUnitEnumMap[instance.unit],
      'price': instance.price,
      'isChecked': instance.isChecked,
      'category': instance.category?.toJson(),
    };

const _$ShoppingItemUnitEnumMap = {
  ShoppingItemUnit.und: 'und',
  ShoppingItemUnit.g: 'g',
  ShoppingItemUnit.kg: 'kg',
  ShoppingItemUnit.l: 'l',
  ShoppingItemUnit.ml: 'ml',
};
