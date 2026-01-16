import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'otp_verification_page.dart';

class NagadPage extends StatefulWidget {
  final int amount;
  final String fromStation;
  final String toStation;

  const NagadPage({
    super.key,
    required this.amount,
    required this.fromStation,
    required this.toStation,
  });

  @override
  State<NagadPage> createState() => _NagadPageState();
}

class _NagadPageState extends State<NagadPage> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool isLoading = false;

  final supabase = Supabase.instance.client;
  final firebaseAuth = FirebaseAuth.instance;

  int _generateOtp() {
    return Random().nextInt(90000) + 10000; // 5 digit OTP
  }

  Future<void> _payNow() async {
    if (_phoneController.text.length != 11) {
      _showMessage('Enter a valid Nagad phone number');
      return;
    }

    if (_pinController.text.length != 4) { // Nagad PIN is 4 digits
      _showMessage('PIN must be 4 digits');
      return;
    }

    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null || currentUser.email == null) {
      _showMessage('Authentication error. Please log in again.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final otp = _generateOtp();

      // Using a different column for Nagad phone number
      await supabase.from('payments').insert({
        'user_email': currentUser.email!,
        'from_station': widget.fromStation,
        'to_station': widget.toStation,
        'nagad_phone': _phoneController.text, // Specific column for Nagad
        'amount': widget.amount,
        'otp': otp,
      });
      
      setState(() => isLoading = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
              // Passing phone number to fetch the correct OTP
              bkashPhone: _phoneController.text, 
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Payment failed: ${e.toString()}');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nagad Payment'),
        backgroundColor: const Color(0xFFf7941d),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xfffde3c9),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Nagad Payment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            _infoRow('From', widget.fromStation),
            _infoRow('To', widget.toStation),
            _infoRow('Amount', '${widget.amount} BDT'),

            const SizedBox(height: 25),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nagad Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4, // Nagad PIN is 4 digits
              decoration: const InputDecoration(
                labelText: '4 Digit Nagad PIN',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _payNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf7941d),
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
