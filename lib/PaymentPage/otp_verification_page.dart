import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _otpController = TextEditingController();
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 5) {
      _showMessage('Enter valid 5 digit OTP');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('payments')
          .select()
          .eq('bkash_phone', widget.bkashPhone)
          .eq('otp', int.parse(_otpController.text))
          .maybeSingle();

      if (response == null) {
        setState(() => isLoading = false);
        _showMessage('Invalid or Expired OTP');
        return;
      }

      // OTP Valid
      setState(() => isLoading = false);
      _showMessage('Payment Successful ✅');

      // Optional: delete OTP after success
      await supabase.from('payments').delete().eq('id', response['id']);

      // Navigate to home page after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });

    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Verification failed: ${e.toString()}');
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
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: const Color(0xFFe40f6b),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'An OTP has been sent to your (imaginary) phone.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: const InputDecoration(
                labelText: '5 Digit OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe40f6b),
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify OTP', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
