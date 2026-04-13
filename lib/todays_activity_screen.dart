import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/color_constants.dart';

class TodaysActivityScreen extends StatefulWidget {
  const TodaysActivityScreen({super.key});

  @override
  State<TodaysActivityScreen> createState() => _TodaysActivityScreenState();
}

class _TodaysActivityScreenState extends State<TodaysActivityScreen> {
  // Mock List of Today's Customers
  final List<Map<String, dynamic>> _todayCustomers = [
    {
      "name": "Manish Kumar",
      "accountType": "Savings Account",
      "time": "10:30 AM",
      "status": "Verified",
      "id": "A-1029",
      "mobile": "+91 9898989898"
    },
    {
      "name": "Priya Singh",
      "accountType": "Current Account",
      "time": "11:15 AM",
      "status": "Pending",
      "id": "A-1030",
      "mobile": "+91 8787878787"
    },
    {
      "name": "Ramesh Patel",
      "accountType": "Fixed Deposit",
      "time": "01:45 PM",
      "status": "Verified",
      "id": "A-1031",
      "mobile": "+91 7676767676"
    },
    {
      "name": "Sonia Gandhi",
      "accountType": "Savings Account",
      "time": "03:20 PM",
      "status": "Verified",
      "id": "A-1032",
      "mobile": "+91 6565656565"
    },
  ];

  void _showQuickView(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.darkNavy.withOpacity(0.1),
                    child: Text(
                      customer['name'][0],
                      style: const TextStyle(color: AppColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.darkNavy)),
                        Text(customer['accountType'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: customer['status'] == 'Verified' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      customer['status'],
                      style: TextStyle(
                        color: customer['status'] == 'Verified' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.tag, "Account Ref", customer['id']),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.phone, "Mobile Number", customer['mobile']),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.access_time, "Time Created", customer['time']),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleEdit(customer);
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  label: const Text("Edit Full Details", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }

  void _handleEdit(Map<String, dynamic> customer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening form for ${customer['name']}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628), // Matches Dashboard Theme
      appBar: AppBar(
        title: const Text("Today's Activity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background graphic
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A2F5A).withOpacity(0.5),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Accounts Opened Today",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.show_chart, color: Color(0xFFFFC107)),
                          const SizedBox(width: 8),
                          Text(
                            "${_todayCustomers.length} Total Applications",
                            style: const TextStyle(color: Color(0xFFFFC107), fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: const BoxDecoration(
                      color: AppColors.bgGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: _todayCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _todayCustomers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showQuickView(customer),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        customer['name'][0],
                                        style: const TextStyle(
                                          color: AppColors.navyAccent,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer['name'],
                                          style: const TextStyle(
                                            color: AppColors.darkNavy,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          customer['accountType'],
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Right Actions
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        customer['time'],
                                        style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.remove_red_eye, color: AppColors.tealAccent, size: 20),
                                            onPressed: () => _showQuickView(customer),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.edit_document, color: Colors.blueGrey, size: 20),
                                            onPressed: () => _handleEdit(customer),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
