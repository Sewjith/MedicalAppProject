import 'package:supabase_flutter/supabase_flutter.dart';

class OverviewDB {
  final SupabaseClient _supabase = Supabase.instance.client;


  Future<int> getNewAppointments() async {
    final response = await _supabase
        .from('appointments')
        .select()
        .count(CountOption.exact);
    return response.count;
  }


  Future<int> getTotalPatients() async {
    final response = await _supabase
        .from('patients')
        .select()
        .count(CountOption.exact);
    return response.count;
  }


  Future<double> getTotalEarnings() async {
    final response = await _supabase
        .from('earnings')
        .select('total_earnings');

    if (response.isEmpty) return 0.0;

    return response.fold<double>(
      0.0,
          (sum, item) => sum + (item['total_earnings'] as num).toDouble(),
    );
  }


  Future<List<double>> getPatientRegistrations() async {
    final response = await _supabase
        .from('patients')
        .select('created_at');

    return _processDailyCount(response, 'created_at');
  }


  Future<List<double>> getAppointmentBookings() async {
    final response = await _supabase
        .from('appointments')
        .select('booking_date');

    return _processDailyCount(response, 'booking_date');
  }


  List<double> _processDailyCount(List<dynamic> data, String dateField) {
    final now = DateTime.now();
    final dailyCounts = List<double>.filled(7, 0);

    for (var item in data) {
      final date = DateTime.parse(item[dateField] as String);
      final daysAgo = now.difference(date).inDays;
      if (daysAgo < 7) dailyCounts[6 - daysAgo] += 1;
    }

    return dailyCounts;
  }
}