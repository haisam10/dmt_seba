import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'bkash.dart';
import 'google_auth_service.dart';
import 'login_page.dart';
import 'main.dart';
import 'nagad.dart';
import 'rocket.dart';

// ------------------- HomePage -------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> logout() async {
    await GoogleAuthService.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset('lib/images/icon.png', height: 30),
            ),
            const SizedBox(width: 10),
            const Text('ঢাকা মেট্রো সেবা'),
          ],
        ),
        backgroundColor: cs.primary,
        titleTextStyle: TextStyle(
          color: cs.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: cs.onPrimary),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: cs.primary),
              accountName: Text(
                user?.displayName ?? "User",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: cs.onPrimary,
                ),
              ),
              accountEmail: Text(
                user?.email ?? "No Email",
                style: TextStyle(color: cs.onPrimary.withAlpha(200)),
              ),
              currentAccountPicture: user?.photoURL != null
                  ? CircleAvatar(backgroundImage: NetworkImage(user!.photoURL!))
                  : CircleAvatar(
                backgroundColor: cs.onPrimary,
                child: Icon(Icons.person, color: cs.primary),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Switch Theme'),
              trailing: Switch(
                value: themeNotifier.value == ThemeMode.dark,
                onChanged: (value) {
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      backgroundColor: cs.surface,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [MetroFareCalculator()],
        ),
      ),
    );
  }
}

// ------------------- Metro Fare Calculator -------------------
class MetroFareCalculator extends StatefulWidget {
  const MetroFareCalculator({super.key});

  @override
  State<MetroFareCalculator> createState() => _MetroFareCalculatorState();
}

class _MetroFareCalculatorState extends State<MetroFareCalculator>
    with SingleTickerProviderStateMixin {
  final List<String> stations = const [
    "Uttara North",
    "Uttara Center",
    "Uttara South",
    "Pallabi",
    "Mirpur 11",
    "Mirpur 10",
    "Kazipara",
    "Shewrapara",
    "Agargaon",
    "Bijoy Sarani",
    "Farmgate",
    "Kawran Bazar",
    "Shahbag",
    "Dhaka University",
    "Bangladesh Secretariat",
    "Motijheel",
  ];

  String? fromStation;
  String? toStation;
  int fare = 0;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void calculateFare() {
    if (fromStation == null || toStation == null) {
      setState(() => fare = 0);
      return;
    }

    final diff =
    (stations.indexOf(toStation!) - stations.indexOf(fromStation!)).abs();

    int calculatedFare;
    if (diff <= 1) {
      calculatedFare = 20;
    } else if (diff <= 3) {
      calculatedFare = 30;
    } else if (diff <= 5) {
      calculatedFare = 40;
    } else if (diff <= 7) {
      calculatedFare = 50;
    } else if (diff <= 9) {
      calculatedFare = 60;
    } else if (diff <= 11) {
      calculatedFare = 70;
    } else if (diff <= 13) {
      calculatedFare = 80;
    } else {
      calculatedFare = 100;
    }

    setState(() {
      fare = calculatedFare;
      _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDropdown(
      String label,
      String? value,
      ValueChanged<String?> onChanged,
      ) {
    final cs = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: cs.surface,
        labelStyle: TextStyle(color: cs.onSurface),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: value,
      items: stations
          .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
          .toList(),
      onChanged: onChanged,
      dropdownColor: cs.surfaceContainerHighest,
      style: TextStyle(color: cs.onSurface),
    );
  }

  void payFare() {
    if (fare <= 0 || fromStation == null || toStation == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodPage(
          amount: fare,
          fromStation: fromStation!,
          toStation: toStation!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(25), // Adjusted for subtle shadow
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Metro Fare Calculator",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildDropdown("From Station", fromStation, (value) {
            setState(() => fromStation = value);
            calculateFare();
          }),
          const SizedBox(height: 15),
          _buildDropdown("To Station", toStation, (value) {
            setState(() => toStation = value);
            calculateFare();
          }),
          const SizedBox(height: 25),
          ScaleTransition(
            scale: _animation,
            child: Center(
              child: Text(
                fare == 0 ? "Select stations" : "Fare: $fare BDT",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: payFare,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Pay Fare", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

// ------------------- Payment Method Selection Page -------------------
class PaymentMethodPage extends StatelessWidget {
  final int amount;
  final String fromStation;
  final String toStation;

  const PaymentMethodPage({
    super.key,
    required this.amount,
    required this.fromStation,
    required this.toStation,
  });

  Widget _buildPaymentOption({
    required BuildContext context,
    required String assetPath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withAlpha(25), // Adjusted for subtle background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Image.asset(assetPath, height: 40),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Payment Method"),
        backgroundColor: cs.primary,
        titleTextStyle: TextStyle(
          color: cs.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: cs.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPaymentOption(
              context: context,
              assetPath: 'lib/images/bkash-logo.png',
              label: 'bKash Payment',
              color: const Color(0xFFe40f6b),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BkashPage(amount: amount, fromStation: fromStation, toStation: toStation)));
              },
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context: context,
              assetPath: 'lib/images/nagad-logo.png',
              label: 'Nagad Payment',
              color: const Color(0xFFf7941d),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NagadPage(amount: amount, fromStation: fromStation, toStation: toStation)));
              },
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context: context,
              assetPath: 'lib/images/rocket-logo.png',
              label: 'Rocket Payment',
              color: const Color(0xFF88278b),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RocketPage(amount: amount, fromStation: fromStation, toStation: toStation)));
              },
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context: context,
              assetPath: 'lib/images/icon.png',
              label: 'Razorpay',
              color: cs.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RazorpayPaymentPage(amount: amount, fromStation: fromStation, toStation: toStation),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Razorpay Payment Page -------------------
class RazorpayPaymentPage extends StatefulWidget {
  final int amount;
  final String fromStation;
  final String toStation;

  const RazorpayPaymentPage({
    super.key, 
    required this.amount,
    required this.fromStation,
    required this.toStation,
  });

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late final Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Success: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void openCheckout() {
    final options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with your key
      'amount': widget.amount * 100, // in paisa
      'name': 'Dhaka Metro Transport',
      'description': 'Metro Fare Payment',
      'prefill': {'contact': '', 'email': ''},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay open error: $e");
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('From: ${widget.fromStation} To: ${widget.toStation}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: openCheckout,
              child: Text("Pay ${widget.amount} BDT"),
            ),
          ],
        ),
      ),
    );
  }
}
