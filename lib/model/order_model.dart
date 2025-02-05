class Order {
  final String itemTitle;
  final String price;
  final int quantity;
  final String orderDate;

  Order({
    required this.itemTitle,
    required this.price,
    required this.quantity,
    required this.orderDate,
  });

  // Factory method to create an Order from a Map (Firestore data)
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      itemTitle: map['itemTitle'] ?? '',
      price: map['price'] ?? '',
      quantity: map['quantity'] ?? 0,
      orderDate: map['orderDate'] ?? '',
    );
  }
}
