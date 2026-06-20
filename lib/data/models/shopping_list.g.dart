// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
  id: json['id'] as String?,
  name: json['name'] as String?,
  budget: (json['budget'] as num?)?.toDouble(),
  description: json['description'] as String?,
  status: json['status'] as String?,
  createdAt: json['createdAt'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ShoppingListToJson(ShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'budget': instance.budget,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };
