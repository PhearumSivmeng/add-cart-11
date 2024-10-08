class Product {
  final String? id;
  final String name;
  final double price;
  int qty;
  final String imageUrl;

  Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.qty,
      required this.imageUrl});

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
        id: id,
        name: map['name'],
        price: map['price'],
        qty: map['qty'],
        imageUrl: map['imageUrl']);
  }
}
