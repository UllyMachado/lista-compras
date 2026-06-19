// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openapi.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
};

ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) => ShoppingItem(
  id: json['id'] as String?,
  description: json['description'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: shoppingItemUnitNullableFromJson(json['unit']),
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
      'unit': shoppingItemUnitNullableToJson(instance.unit),
      'price': instance.price,
      'isChecked': instance.isChecked,
      'category': instance.category?.toJson(),
    };

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
  id: json['id'] as String?,
  name: json['name'] as String?,
  budget: (json['budget'] as num?)?.toDouble(),
  description: json['description'] as String?,
  status: json['status'] as String?,
  createdAt: json['createdAt'] as String?,
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
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    RefreshRequest(refreshToken: json['refreshToken'] as String?);

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

AuthRequest _$AuthRequestFromJson(Map<String, dynamic> json) => AuthRequest(
  email: json['email'] as String?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$AuthRequestToJson(AuthRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RecipeRequest _$RecipeRequestFromJson(Map<String, dynamic> json) =>
    RecipeRequest(recipe: json['recipe'] as String?);

Map<String, dynamic> _$RecipeRequestToJson(RecipeRequest instance) =>
    <String, dynamic>{'recipe': instance.recipe};
