import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EarningsDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getPendingPaymentsCount(String doctorId) async {
    try {
      // *** FIX: Correct count syntax ***
      final response = await _supabase
          .from('payments')
          .select() // Select something
          .eq('doctor_id', doctorId)
          .eq('status', 'pending')
          .count(CountOption.exact); // Chain .count()

      return response.count ?? 0;
    } catch (e) {
       print('Error getting pending payments count: $e');
       throw Exception('Failed to get pending payments count');
    }
  }

  Future<List<double>> getWeeklyRevenue(String doctorId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('amount, payment_date')
          .eq('doctor_id', doctorId)
          .eq('status', 'completed')
          .gte('payment_date', _getDateSevenDaysAgo());

      return _processWeeklyData(response);
    } catch (e) {
       print('Error getting weekly revenue: $e');
       throw Exception('Failed to get weekly revenue');
    }
  }

  String _getDateSevenDaysAgo() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
  }

  List<double> _processWeeklyData(List<dynamic> data) {
    final now = DateTime.now();
    final weeklyRevenue = List<double>.filled(7, 0.0);

    for (final payment in data) {
       final dateValue = payment['payment_date'];
       final amountValue = payment['amount'];

       if (dateValue != null && amountValue != null && amountValue is num) {
         try {
           final date = DateTime.parse(dateValue as String).toLocal();
           final daysAgo = now.difference(DateTime(date.year, date.month, date.day)).inDays;

           if (daysAgo >= 0 && daysAgo < 7) {
             weeklyRevenue[6 - daysAgo] += amountValue.toDouble();
           }
         } catch (e) {
           print("Error processing payment date '$dateValue': $e");
         }
       }
    }
     print("Weekly Revenue: $weeklyRevenue");
    return weeklyRevenue;
  }
}