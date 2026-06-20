import 'package:json_annotation/json_annotation.dart';

part 'recipe_request.g.dart';

@JsonSerializable()
class RecipeRequest {
  final String? recipe;

  const RecipeRequest({this.recipe});

  factory RecipeRequest.fromJson(Map<String, dynamic> json) => _$RecipeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeRequestToJson(this);
}
