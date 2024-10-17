import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';
import 'package:intl/intl.dart';


class AnalyticsView extends StatefulWidget {
  @override
  _AnalyticsViewState createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedTimeFrame = 'Daily';
  double _totalRevenue = 0.0;
  int _totalCompletedOrders = 0;
  List<Map<String, dynamic>> _sellersData = [];
  DateTime? _startDate;
  DateTime? _endDate;

  // Method to fetch analytics data
  void _fetchAnalyticsData() async {
    final now = DateTime.now();
    DateTime startDate;

    // Determine start date based on the selected time frame
    if (_selectedTimeFrame == 'Daily') {
      startDate = DateTime(now.year, now.month, now.day); // Start of the day
    } else if (_selectedTimeFrame == 'Monthly') {
      startDate = DateTime(now.year, now.month, 1); // Start of the month
    } else { // Yearly
      startDate = DateTime(now.year, 1, 1); // Start of the year
    }

    // Fetch orders and filter by the start date
    final ordersSnapshot = await _firestore
        .collection('orders')
        .where('completedAt', isGreaterThanOrEqualTo: startDate)
        .where('completedAt', isLessThanOrEqualTo: now)
        .get();

    // Create a map to store seller data
    Map<String, Map<String, dynamic>> sellerMap = {};

    // Fetch sellers from users collection
    final sellersSnapshot = await _firestore
        .collection('users')
        .where('type', isEqualTo: 'seller')
        .get();

    // Initialize sellerMap for each seller
    for (var seller in sellersSnapshot.docs) {
      String sellerId = seller.id;
      sellerMap[sellerId] = {
        'name': seller['name'],
        'id': sellerId,
        'revenue': 0.0,
        'completedOrders': 0,
        'readyOrders': 0,
        'pendingOrders': 0,
      };
    }

      double overallRevenue = 0.0;
      int overallCompletedOrders = 0;

    // Process orders and update the sellerMap accordingly
    for (var order in ordersSnapshot.docs) {
      String sellerId = order['sellerId']; // Assuming orders have 'sellerId'

      if (order['status'] == 'Completed') {
            overallCompletedOrders++;
            overallRevenue += order['totalPrice']; // Assuming the order document has a 'totalPrice' field
      }
        
      // Make sure the seller exists in the sellerMap
      if (sellerMap.containsKey(sellerId)) {
        if (order['status'] == 'Completed') {
          sellerMap[sellerId]!['completedOrders']++;
          sellerMap[sellerId]!['revenue'] += order['totalPrice'];
        } else if (order['status'] == 'Ready') {
          sellerMap[sellerId]!['readyOrders']++;
        } else if (order['status'] == 'Pending') {
          sellerMap[sellerId]!['pendingOrders']++;
        }
      }
    }

    // Convert sellerMap to a list for displaying
    List<Map<String, dynamic>> sellersData = sellerMap.values.toList();

    setState(() {
      _sellersData = sellersData; // Update the seller data for display
      _totalRevenue =  overallRevenue;
      _totalCompletedOrders = overallCompletedOrders;
      _startDate = startDate;
      _endDate = now;
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData(); // Fetch data when the view initializes
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Row(
        children: [
          NavigationMenu(), // Sidebar navigation menu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Dropdown to select time frame
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Time Frame:'),
                      Text('${_startDate != null && _endDate != null ? DateFormat('MMM d, yyyy').format(_startDate!) + ' - ' + DateFormat('MMM d, yyyy').format(_endDate!) : ''}',
),
                      DropdownButton<String>(
                        value: _selectedTimeFrame,
                        items: ['Daily', 'Monthly', 'Yearly']
                            .map((timeFrame) => DropdownMenuItem(
                                  value: timeFrame,
                                  child: Text(timeFrame),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTimeFrame = value!;
                          });
                          _fetchAnalyticsData(); // Fetch data again on selection change
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Total Revenue and Completed Orders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total Revenue Card
                      Expanded(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(Icons.attach_money, size: 40, color: Colors.green),
                                const SizedBox(height: 10),
                                Text(
                                  'Total Revenue',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '₱${_totalRevenue.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Total Completed Orders Card
                      Expanded(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(Icons.shopping_cart, size: 40, color: Colors.blue),
                                const SizedBox(height: 10),
                                Text(
                                  'Completed Orders',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$_totalCompletedOrders',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Display the list of sellers and their analytics data
                  Expanded(
                    child: ListView.builder(
                      itemCount: _sellersData.length,
                      itemBuilder: (context, index) {
                        final seller = _sellersData[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left side: Seller info (name, avatar)
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      child: Text(seller['name'][0]),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          seller['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID: ${seller['id']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Right side: Seller analytics (Revenue, Orders)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Revenue: ₱${seller['revenue'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Completed Orders:'),
                                            const SizedBox(height: 4),
                                            Text(
                                              seller['completedOrders'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Ready Orders:'),
                                            const SizedBox(height: 4),
                                            Text(
                                              seller['readyOrders'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Pending Orders:'),
                                            const SizedBox(height: 4),
                                            Text(
                                              seller['pendingOrders'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  }