

class ShoppingItem {
  final String? id;
  final String description;
  final double quantity;
  final double price;
  final bool isChecked;

  ShoppingItem({
    this.id,
    required this.description,
    required this.quantity,
    required this.price,
    this.isChecked = false,
  });

  double get totalValue => quantity * price;

  ShoppingItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? price,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String?,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      isChecked: json['isChecked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'description': description,
      'quantity': quantity,
      'price': price,
      'isChecked': isChecked,
    };
  }
}
