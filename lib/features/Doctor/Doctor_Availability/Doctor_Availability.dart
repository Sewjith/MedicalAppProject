import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'D_Availability_Backend.dart';


class DoctorAvailabilityPage extends StatefulWidget {
  const DoctorAvailabilityPage({super.key});

  @override
  _DoctorAvailabilityPageState createState() => _DoctorAvailabilityPageState();
}

class _DoctorAvailabilityPageState extends State<DoctorAvailabilityPage> {
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedTimeSlots;
  DateTime _selectedDate = DateTime.now();
  String? _currentDoctorId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTimeSlots = ValueNotifier<List<Map<String, dynamic>>>([]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDoctorIdAndFetchAvailability();
    });
  }

  void _initializeDoctorIdAndFetchAvailability() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      setState(() {
        _currentDoctorId = userState.user.uid;
        _isLoading = true;
        _errorMessage = null;
      });
      if (_currentDoctorId != null) {
        _fetchAvailability();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Could not retrieve doctor ID.";
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "User is not logged in as a doctor.";
      });
    }
  }

  Future<void> _fetchAvailability() async {
    if (_currentDoctorId == null || !mounted) return;
    if (!_isLoading) setState(() => _isLoading = true);

    try {
      final times = await Backend.getAvailability(_currentDoctorId!, _selectedDate);
       if (!mounted) return;
      _selectedTimeSlots.value = times;
      setState(() => _isLoading = false);
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load availability: ${e.toString()}";
        _selectedTimeSlots.value = [];
      });
    }
  }

  Future<void> _addTimeSlot() async {
    if (_currentDoctorId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor ID not available.')),
      );
      return;
    }

    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (endTime == null) return;

    bool success = await Backend.addAvailability(
      _currentDoctorId!,
      _selectedDate,
      startTime,
      endTime,
    );

    if (success) {
      _fetchAvailability();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add availability')),
      );
    }
  }

  Future<void> _deleteTimeSlot(String availabilityId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this time slot?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      bool success = await Backend.deleteAvailability(availabilityId);
      if (success) {
        _fetchAvailability();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot deleted successfully')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete time slot')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy/MM/dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton( // Added explicit leading with correct logic
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback to doctor dashboard
            }
          },
          // Add color if needed based on AppBar theme
        ),
        title: const Text('Manage Your Availability'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, _) {
              if (!isSameDay(selectedDay, _selectedDate)) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                _fetchAvailability();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Selected Date: $formattedDate',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _selectedTimeSlots,
                    builder: (context, slots, _) {
                       if (_currentDoctorId == null && _errorMessage == null) {
                          return const Center(child: Text("Fetching doctor information..."));
                       }
                      return ListView.builder(
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          var slot = slots[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${slot['start_time']} - ${slot['end_time']} (Status: ${slot['status']})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _deleteTimeSlot(slot['availability_id']),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentDoctorId == null ? null : _addTimeSlot,
        backgroundColor: _currentDoctorId == null ? Colors.grey : Colors.blueAccent,
        tooltip: _currentDoctorId == null ? 'Loading doctor info...' : 'Add Availability',
        child: const Icon(Icons.add),
      ),
    );
  }
}