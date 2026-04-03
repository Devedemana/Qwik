import 'package:flutter/material.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Order Tracking", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1604908176997-431dc2e8f1b2",
              ),
            ),

            const SizedBox(height: 30),

            _trackingStep("Order Received", "9:00 AM, 9 May 2025", true),
            _trackingStep("On the Way", "11:00 AM, 9 May 2025", false),
            _trackingStep("Pickup", "", false),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Confirm Pickup"),
            )
          ],
        ),
      ),
    );
  }

  Widget _trackingStep(String title, String time, bool completed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.radio_button_checked,
              color: completed ? Colors.green : Colors.orange,
            ),
            Container(
              height: 40,
              width: 2,
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (time.isNotEmpty)
              Text(time, style: const TextStyle(color: Colors.orange)),
          ],
        )
      ],
    );
  }
}