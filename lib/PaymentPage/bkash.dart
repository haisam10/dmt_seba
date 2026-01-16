import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'otp_verification_page.dart';

class BkashPage extends StatefulWidget {
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
  State<BkashPage> createState() => _BkashPageState();
}

class _BkashPageState extends State<BkashPage> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  int _generateOtp() {
    return Random().nextInt(90000) + 10000; // 5 digit OTP
  }

  Future<void> _payNow() async {
    if (_phoneController.text.length != 11) {
      _showMessage('Enter valid bKash phone number');
      return;
    }

    if (_pinController.text.length != 5) {
      _showMessage('PIN must be 5 digits');
      return;
    }

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null || currentUser.email == null) {
      _showMessage('Authentication error. Please log in again.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final otp = _generateOtp();

      await supabase.from('payments').insert({
        'user_email': currentUser.email!,
        'from_station': widget.fromStation,
        'to_station': widget.toStation,
        'bkash_phone': _phoneController.text,
        'amount': widget.amount,
        'otp': otp,
      });
      
      setState(() => isLoading = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
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
        title: const Text('bKash Payment'),
        backgroundColor: const Color(0xFFe40f6b),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xfffab9de),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'bKash Payment',
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
                labelText: 'bKash Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 5,
              decoration: const InputDecoration(
                labelText: '5 Digit bKash PIN',
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
                  backgroundColor: const Color(0xFFe40f6b),
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
