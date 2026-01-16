import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OtpVerificationPage extends StatefulWidget {
  final String bkashPhone;

  const OtpVerificationPage({
    super.key,
    required this.bkashPhone,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  String? _fetchedOtp;
  String? _errorMessage;
  bool isLoading = true;

  final supabase = Supabase.instance.client;
  final firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchOtp();
  }

  Future<void> _fetchOtp() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('Authentication error. Please log in again.');
      }

      // Fetch the latest OTP for the user and phone number
      final response = await supabase
          .from('payments')
          .select('otp')
          .eq('user_email', currentUser.email!)
          .eq('bkash_phone', widget.bkashPhone)
          .order('created_at', ascending: false) // Get the most recent one
          .limit(1)
          .maybeSingle();

      if (response == null || response['otp'] == null) {
        throw Exception('Could not find a valid ticket. Please try again.');
      }

      setState(() {
        _fetchedOtp = response['otp'].toString();
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'Failed to fetch ticket: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket'),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _fetchOtp, child: const Text('Retry'))
        ],
      );
    }

    if (_fetchedOtp != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Payment Successful!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          const Text(
            'Show this QR code at the counter',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // QR Code
          QrImageView(
            data: _fetchedOtp!,
            version: QrVersions.auto,
            size: 200.0,
          ),

          const SizedBox(height: 40),

          // OTP Display
          const Text(
            'Your Ticket Number is:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            _fetchedOtp!,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
        ],
      );
    }

    return const Text('Something went wrong.'); // Should not be reached
  }
}
