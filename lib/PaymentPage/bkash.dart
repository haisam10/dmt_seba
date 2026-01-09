import 'package:flutter/material.dart';

class BkashPage extends StatelessWidget {
  final int amount;
  final String fromStation;
  final String toStation;

  const BkashPage({
    super.key,
    required this.amount,
    required this.fromStation,
    required this.toStation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bKash Payment'),
        backgroundColor: const Color(0xFFe40f6b),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xfffab9de),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to bKash',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:Colors.black),
              ),
              const SizedBox(height: 30),
              Text(
                'From: $fromStation',
                style: const TextStyle(fontSize: 18, color:Colors.black),
              ),
              const SizedBox(height: 10),
              Text(
                'To: $toStation',
                style: const TextStyle(fontSize: 18, color:Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                'Amount to pay: $amount BDT',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
