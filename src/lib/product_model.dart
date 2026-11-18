class Product {
  final String name;
  final dynamic price;

  Product({required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? 'منتج غير معروف',
      price: json['price'] ?? 0,
    );
  }
}