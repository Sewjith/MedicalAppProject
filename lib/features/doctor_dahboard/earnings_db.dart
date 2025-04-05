import 'package:supabase_flutter/supabase_flutter.dart';

class EarningsDB {
  final SupabaseClient _supabase = Supabase.instance.client;


  Future<int> getPendingPaymentsCount() async {
    final response = await _supabase
        .from('payments')
        .select()
        .eq('is_paid', false);
    return response.length;
  }


  Future<List<double>> getWeeklyRevenue() async {
    final response = await _supabase
        .from('payments')
        .select('amount, payment_date')
        .eq('is_paid', true)
        .gte('payment_date', _getDateSevenDaysAgo());

    return _processWeeklyData(response);
  }


  String _getDateSevenDaysAgo() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return sevenDaysAgo.toIso8601String();
  }


  List<double> _processWeeklyData(List<dynamic> data) {
    final now = DateTime.now();
    final weeklyRevenue = List<double>.filled(7, 0);

    for (final payment in data) {
      final date = DateTime.parse(payment['payment_date'] as String);
      final daysAgo = now.difference(date).inDays;
      if (daysAgo < 7) {
        weeklyRevenue[6 - daysAgo] += (payment['amount'] as num).toDouble();
      }
    }

    return weeklyRevenue;
  }
}