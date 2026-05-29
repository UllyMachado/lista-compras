// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum ShoppingItemUnit {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('und')
  und('und'),
  @JsonValue('g')
  g('g'),
  @JsonValue('kg')
  kg('kg'),
  @JsonValue('l')
  l('l'),
  @JsonValue('ml')
  ml('ml');

  final String? value;

  const ShoppingItemUnit(this.value);
}
