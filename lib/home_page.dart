import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'login_page.dart';
import 'main.dart';

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
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/images/icon.png',
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text("ঢাকা মেট্রো সেবা"),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20, 
          fontWeight: FontWeight.w600, 
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              accountName: Text(
                user?.displayName ?? "User",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              accountEmail: Text(
                user?.email ?? "No Email",
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
              ),
              currentAccountPicture: user?.photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL!),
                    )
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                    ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Switch Theme'),
              trailing: Switch(
                value: themeNotifier.value == ThemeMode.dark,
                onChanged: (value) {
                  themeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            MetroFareCalculator(),
          ],
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
  final List<String> stations = [
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

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void calculateFare() {
    if (fromStation == null || toStation == null) {
      setState(() => fare = 0);
      return;
    }

    int diff = (stations.indexOf(toStation!) - stations.indexOf(fromStation!)).abs();
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

  Widget _buildDropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: value,
      items: stations.map((station) {
        return DropdownMenuItem(value: station, child: Text(station));
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Theme.of(context).colorScheme.surfaceVariant,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }

  void payFare() {
    if (fare <= 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentPage(amount: fare)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildDropdown("From Station", fromStation, (value) {
            fromStation = value;
            calculateFare();
          }),
          const SizedBox(height: 15),
          _buildDropdown("To Station", toStation, (value) {
            toStation = value;
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
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: payFare,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Pay Fare",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- Razorpay Payment Page -------------------
class PaymentPage extends StatefulWidget {
  final int amount;
  const PaymentPage({super.key, required this.amount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

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
    var options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with your key
      'amount': widget.amount * 100,
      'name': 'Dhaka Metro Transport',
      'description': 'Metro Fare Payment',
      'prefill': {'contact': '', 'email': ''},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
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
        child: ElevatedButton(
          onPressed: openCheckout,
          child: Text("Pay ${widget.amount} BDT"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
