class Seller {
  final String id;
  final String name;
  double revenue;
  int completedOrders;
  int readyOrders;
  int pendingOrders;

  Seller({
    required this.id,
    required this.name,
    this.revenue = 0.0,
    this.completedOrders = 0,
    this.readyOrders = 0,
    this.pendingOrders = 0,
  });
}
