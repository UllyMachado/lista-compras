// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;
import 'openapi.enums.swagger.dart' as enums;
import 'openapi.metadata.swagger.dart';
export 'openapi.enums.swagger.dart';

part 'openapi.swagger.chopper.dart';
part 'openapi.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Openapi extends ChopperService {
  static Openapi create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Openapi(client);
    }

    final newClient = ChopperClient(
      services: [_$Openapi()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl ?? Uri.parse('http://'),
    );
    return _$Openapi(newClient);
  }

  ///
  ///@param listId
  ///@param itemId
  Future<chopper.Response<ShoppingItem>> apiListsListIdItemsItemIdPut({
    required String? listId,
    required String? itemId,
    required ShoppingItem? body,
  }) {
    generatedMapping.putIfAbsent(
      ShoppingItem,
      () => ShoppingItem.fromJsonFactory,
    );

    return _apiListsListIdItemsItemIdPut(
      listId: listId,
      itemId: itemId,
      body: body,
    );
  }

  ///
  ///@param listId
  ///@param itemId
  @PUT(path: '/api/lists/{listId}/items/{itemId}', optionalBody: true)
  Future<chopper.Response<ShoppingItem>> _apiListsListIdItemsItemIdPut({
    @Path('listId') required String? listId,
    @Path('itemId') required String? itemId,
    @Body() required ShoppingItem? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'updateItem',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  ///@param listId
  ///@param itemId
  Future<chopper.Response> apiListsListIdItemsItemIdDelete({
    required String? listId,
    required String? itemId,
  }) {
    return _apiListsListIdItemsItemIdDelete(listId: listId, itemId: itemId);
  }

  ///
  ///@param listId
  ///@param itemId
  @DELETE(path: '/api/lists/{listId}/items/{itemId}')
  Future<chopper.Response> _apiListsListIdItemsItemIdDelete({
    @Path('listId') required String? listId,
    @Path('itemId') required String? itemId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'deleteItem',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  ///@param id
  Future<chopper.Response<ShoppingList>> apiListsIdGet({required String? id}) {
    generatedMapping.putIfAbsent(
      ShoppingList,
      () => ShoppingList.fromJsonFactory,
    );

    return _apiListsIdGet(id: id);
  }

  ///
  ///@param id
  @GET(path: '/api/lists/{id}')
  Future<chopper.Response<ShoppingList>> _apiListsIdGet({
    @Path('id') required String? id,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getListById',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  ///@param id
  Future<chopper.Response<ShoppingList>> apiListsIdPut({
    required String? id,
    required ShoppingList? body,
  }) {
    generatedMapping.putIfAbsent(
      ShoppingList,
      () => ShoppingList.fromJsonFactory,
    );

    return _apiListsIdPut(id: id, body: body);
  }

  ///
  ///@param id
  @PUT(path: '/api/lists/{id}', optionalBody: true)
  Future<chopper.Response<ShoppingList>> _apiListsIdPut({
    @Path('id') required String? id,
    @Body() required ShoppingList? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'updateList',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  ///@param id
  Future<chopper.Response> apiListsIdDelete({required String? id}) {
    return _apiListsIdDelete(id: id);
  }

  ///
  ///@param id
  @DELETE(path: '/api/lists/{id}')
  Future<chopper.Response> _apiListsIdDelete({
    @Path('id') required String? id,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'deleteList',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<List<ShoppingList>>> apiListsGet() {
    generatedMapping.putIfAbsent(
      ShoppingList,
      () => ShoppingList.fromJsonFactory,
    );

    return _apiListsGet();
  }

  ///
  @GET(path: '/api/lists')
  Future<chopper.Response<List<ShoppingList>>> _apiListsGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getAllLists',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<ShoppingList>> apiListsPost({
    required ShoppingList? body,
  }) {
    generatedMapping.putIfAbsent(
      ShoppingList,
      () => ShoppingList.fromJsonFactory,
    );

    return _apiListsPost(body: body);
  }

  ///
  @POST(path: '/api/lists', optionalBody: true)
  Future<chopper.Response<ShoppingList>> _apiListsPost({
    @Body() required ShoppingList? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'createList',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  ///@param listId
  Future<chopper.Response<ShoppingItem>> apiListsListIdItemsPost({
    required String? listId,
    required ShoppingItem? body,
  }) {
    generatedMapping.putIfAbsent(
      ShoppingItem,
      () => ShoppingItem.fromJsonFactory,
    );

    return _apiListsListIdItemsPost(listId: listId, body: body);
  }

  ///
  ///@param listId
  @POST(path: '/api/lists/{listId}/items', optionalBody: true)
  Future<chopper.Response<ShoppingItem>> _apiListsListIdItemsPost({
    @Path('listId') required String? listId,
    @Body() required ShoppingItem? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'addItem',
      consumes: [],
      produces: [],
      security: [],
      tags: ["list-controller"],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<ShoppingList>> apiAiRecipeToListPost({
    required RecipeRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      ShoppingList,
      () => ShoppingList.fromJsonFactory,
    );

    return _apiAiRecipeToListPost(body: body);
  }

  ///
  @POST(path: '/api/ai/recipe-to-list', optionalBody: true)
  Future<chopper.Response<ShoppingList>> _apiAiRecipeToListPost({
    @Body() required RecipeRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'createListFromRecipe',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ai-agent-controller"],
      deprecated: false,
    ),
  });
}

@JsonSerializable(explicitToJson: true)
class ShoppingItem {
  const ShoppingItem({
    this.id,
    this.description,
    this.quantity,
    this.unit,
    this.price,
    this.isChecked,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);

  static const toJsonFactory = _$ShoppingItemToJson;
  Map<String, dynamic> toJson() => _$ShoppingItemToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'quantity')
  final double? quantity;
  @JsonKey(
    name: 'unit',
    toJson: shoppingItemUnitNullableToJson,
    fromJson: shoppingItemUnitNullableFromJson,
  )
  final enums.ShoppingItemUnit? unit;
  @JsonKey(name: 'price')
  final double? price;
  @JsonKey(name: 'isChecked')
  final bool? isChecked;
  static const fromJsonFactory = _$ShoppingItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShoppingItem &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.quantity, quantity) ||
                const DeepCollectionEquality().equals(
                  other.quantity,
                  quantity,
                )) &&
            (identical(other.unit, unit) ||
                const DeepCollectionEquality().equals(other.unit, unit)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.isChecked, isChecked) ||
                const DeepCollectionEquality().equals(
                  other.isChecked,
                  isChecked,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(quantity) ^
      const DeepCollectionEquality().hash(unit) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(isChecked) ^
      runtimeType.hashCode;
}

extension $ShoppingItemExtension on ShoppingItem {
  ShoppingItem copyWith({
    String? id,
    String? description,
    double? quantity,
    enums.ShoppingItemUnit? unit,
    double? price,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  ShoppingItem copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? description,
    Wrapped<double?>? quantity,
    Wrapped<enums.ShoppingItemUnit?>? unit,
    Wrapped<double?>? price,
    Wrapped<bool?>? isChecked,
  }) {
    return ShoppingItem(
      id: (id != null ? id.value : this.id),
      description: (description != null ? description.value : this.description),
      quantity: (quantity != null ? quantity.value : this.quantity),
      unit: (unit != null ? unit.value : this.unit),
      price: (price != null ? price.value : this.price),
      isChecked: (isChecked != null ? isChecked.value : this.isChecked),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShoppingList {
  const ShoppingList({this.id, this.name, this.budget, this.items});

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);

  static const toJsonFactory = _$ShoppingListToJson;
  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'budget')
  final double? budget;
  @JsonKey(name: 'items', defaultValue: <ShoppingItem>[])
  final List<ShoppingItem>? items;
  static const fromJsonFactory = _$ShoppingListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShoppingList &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.budget, budget) ||
                const DeepCollectionEquality().equals(other.budget, budget)) &&
            (identical(other.items, items) ||
                const DeepCollectionEquality().equals(other.items, items)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(budget) ^
      const DeepCollectionEquality().hash(items) ^
      runtimeType.hashCode;
}

extension $ShoppingListExtension on ShoppingList {
  ShoppingList copyWith({
    String? id,
    String? name,
    double? budget,
    List<ShoppingItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      items: items ?? this.items,
    );
  }

  ShoppingList copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? name,
    Wrapped<double?>? budget,
    Wrapped<List<ShoppingItem>?>? items,
  }) {
    return ShoppingList(
      id: (id != null ? id.value : this.id),
      name: (name != null ? name.value : this.name),
      budget: (budget != null ? budget.value : this.budget),
      items: (items != null ? items.value : this.items),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RecipeRequest {
  const RecipeRequest({this.recipe});

  factory RecipeRequest.fromJson(Map<String, dynamic> json) =>
      _$RecipeRequestFromJson(json);

  static const toJsonFactory = _$RecipeRequestToJson;
  Map<String, dynamic> toJson() => _$RecipeRequestToJson(this);

  @JsonKey(name: 'recipe')
  final String? recipe;
  static const fromJsonFactory = _$RecipeRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RecipeRequest &&
            (identical(other.recipe, recipe) ||
                const DeepCollectionEquality().equals(other.recipe, recipe)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(recipe) ^ runtimeType.hashCode;
}

extension $RecipeRequestExtension on RecipeRequest {
  RecipeRequest copyWith({String? recipe}) {
    return RecipeRequest(recipe: recipe ?? this.recipe);
  }

  RecipeRequest copyWithWrapped({Wrapped<String?>? recipe}) {
    return RecipeRequest(recipe: (recipe != null ? recipe.value : this.recipe));
  }
}

String? shoppingItemUnitNullableToJson(
  enums.ShoppingItemUnit? shoppingItemUnit,
) {
  return shoppingItemUnit?.value;
}

String? shoppingItemUnitToJson(enums.ShoppingItemUnit shoppingItemUnit) {
  return shoppingItemUnit.value;
}

enums.ShoppingItemUnit shoppingItemUnitFromJson(
  Object? shoppingItemUnit, [
  enums.ShoppingItemUnit? defaultValue,
]) {
  return enums.ShoppingItemUnit.values.firstWhereOrNull(
        (e) => e.value == shoppingItemUnit,
      ) ??
      defaultValue ??
      enums.ShoppingItemUnit.swaggerGeneratedUnknown;
}

enums.ShoppingItemUnit? shoppingItemUnitNullableFromJson(
  Object? shoppingItemUnit, [
  enums.ShoppingItemUnit? defaultValue,
]) {
  if (shoppingItemUnit == null) {
    return null;
  }
  return enums.ShoppingItemUnit.values.firstWhereOrNull(
        (e) => e.value == shoppingItemUnit,
      ) ??
      defaultValue;
}

String shoppingItemUnitExplodedListToJson(
  List<enums.ShoppingItemUnit>? shoppingItemUnit,
) {
  return shoppingItemUnit?.map((e) => e.value!).join(',') ?? '';
}

List<String> shoppingItemUnitListToJson(
  List<enums.ShoppingItemUnit>? shoppingItemUnit,
) {
  if (shoppingItemUnit == null) {
    return [];
  }

  return shoppingItemUnit.map((e) => e.value!).toList();
}

List<enums.ShoppingItemUnit> shoppingItemUnitListFromJson(
  List? shoppingItemUnit, [
  List<enums.ShoppingItemUnit>? defaultValue,
]) {
  if (shoppingItemUnit == null) {
    return defaultValue ?? [];
  }

  return shoppingItemUnit
      .map((e) => shoppingItemUnitFromJson(e.toString()))
      .toList();
}

List<enums.ShoppingItemUnit>? shoppingItemUnitNullableListFromJson(
  List? shoppingItemUnit, [
  List<enums.ShoppingItemUnit>? defaultValue,
]) {
  if (shoppingItemUnit == null) {
    return defaultValue;
  }

  return shoppingItemUnit
      .map((e) => shoppingItemUnitFromJson(e.toString()))
      .toList();
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
    chopper.Response response,
  ) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
        body:
            DateTime.parse((response.body as String).replaceAll('"', ''))
                as ResultType,
      );
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
      body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType,
    );
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
