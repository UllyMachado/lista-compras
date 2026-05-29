// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'openapi.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Openapi extends Openapi {
  _$Openapi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Openapi;

  @override
  Future<Response<ShoppingItem>> _apiListsListIdItemsItemIdPut({
    required String? listId,
    required String? itemId,
    required ShoppingItem? body,
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
  }) {
    final Uri $url = Uri.parse('/api/lists/${listId}/items/${itemId}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShoppingItem, ShoppingItem>($request);
  }

  @override
  Future<Response<dynamic>> _apiListsListIdItemsItemIdDelete({
    required String? listId,
    required String? itemId,
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
  }) {
    final Uri $url = Uri.parse('/api/lists/${listId}/items/${itemId}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<ShoppingList>> _apiListsIdGet({
    required String? id,
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
  }) {
    final Uri $url = Uri.parse('/api/lists/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<ShoppingList, ShoppingList>($request);
  }

  @override
  Future<Response<ShoppingList>> _apiListsIdPut({
    required String? id,
    required ShoppingList? body,
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
  }) {
    final Uri $url = Uri.parse('/api/lists/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShoppingList, ShoppingList>($request);
  }

  @override
  Future<Response<dynamic>> _apiListsIdDelete({
    required String? id,
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
  }) {
    final Uri $url = Uri.parse('/api/lists/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<ShoppingList>>> _apiListsGet({
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
  }) {
    final Uri $url = Uri.parse('/api/lists');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<ShoppingList>, ShoppingList>($request);
  }

  @override
  Future<Response<ShoppingList>> _apiListsPost({
    required ShoppingList? body,
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
  }) {
    final Uri $url = Uri.parse('/api/lists');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShoppingList, ShoppingList>($request);
  }

  @override
  Future<Response<ShoppingItem>> _apiListsListIdItemsPost({
    required String? listId,
    required ShoppingItem? body,
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
  }) {
    final Uri $url = Uri.parse('/api/lists/${listId}/items');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShoppingItem, ShoppingItem>($request);
  }

  @override
  Future<Response<ShoppingList>> _apiAiRecipeToListPost({
    required RecipeRequest? body,
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
  }) {
    final Uri $url = Uri.parse('/api/ai/recipe-to-list');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShoppingList, ShoppingList>($request);
  }
}
