import 'package:flutter/material.dart';
import 'oder_tracking.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text("Payment Method", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _paymentOption("Cash On Pickup"),
            _paymentOption("Mobile Money", recommended: true),
            _paymentOption("Meal plan"),

            const Spacer(),

            _priceRow("Sub total", "₵70.00"),
            _priceRow("Taxes & fees", "₵10.00"),
            _priceRow("Delivery Fee", "₵5.00"),

            const Divider(),

            _priceRow("Total Price", "₵46.00", bold: true),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderTrackingPage()),
                );
              },
              child: const Text("Payment"),
            )
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String title, {bool recommended = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (recommended)
            const Text("Recommended", style: TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String price, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(price,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}