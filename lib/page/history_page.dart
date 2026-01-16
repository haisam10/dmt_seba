import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _payments = [];
  bool _isLoading = true;
  String? _errorMessage;

  final supabase = Supabase.instance.client;
  final firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('You are not logged in.');
      }

      final response = await supabase
          .from('payments')
          .select()
          .eq('user_email', currentUser.email!)
          .order('created_at', ascending: false);

      setState(() {
        _payments = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch history: ${e.toString()}';
      });
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      // Simple format: DD/MM/YYYY at HH:MM
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString; // Fallback to original string
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _fetchHistory, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_payments.isEmpty) {
      return const Center(
        child: Text(
          'No payment history found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          final fromStation = payment['from_station'] ?? 'N/A';
          final toStation = payment['to_station'] ?? 'N/A';
          final amount = payment['amount']?.toString() ?? 'N/A';
          final createdAt = _formatDateTime(payment['created_at'] ?? '');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: const Icon(Icons.receipt_long, color: Colors.green, size: 40),
              title: Text(
                'From: $fromStation\nTo:       $toStation',
                style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(createdAt, style: const TextStyle(color: Colors.black54)),
              ),
              trailing: Text(
                '$amount BDT',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }
}
