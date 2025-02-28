import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // For Timer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Availability Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DoctorAvailabilityPage(),
    );
  }
}

class DoctorAvailabilityPage extends StatefulWidget {
  const DoctorAvailabilityPage({super.key});

  @override
  _DoctorAvailabilityPageState createState() => _DoctorAvailabilityPageState();
}

class _DoctorAvailabilityPageState extends State<DoctorAvailabilityPage> {
  late final ValueNotifier<List<String>> _selectedTimeSlots;
  DateTime _selectedDate = DateTime.now();
  late Timer _timer;
  String _currentTime = '';

  final Map<String, List<String>> availableTimes = {};

  @override
  void initState() {
    super.initState();
    _selectedTimeSlots = ValueNotifier<List<String>>([]);
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _selectedTimeSlots.value = availableTimes[selectedDay.toString()] ?? [];
    });
  }

  Future<void> _selectTimeRange() async {
    bool isConfirmed = false;

    while (!isConfirmed) {
      final TimeOfDay? startPicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (startPicked == null) {
        return;
      }

      final TimeOfDay? endPicked = await showTimePicker(
        context: context,
        initialTime: startPicked,
      );

      if (endPicked == null) {
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Time Range"),
            content: Text(
                "Start Time: ${startPicked.format(context)}\nEnd Time: ${endPicked.format(context)}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        final timeRange =
            '${startPicked.format(context)} to ${endPicked.format(context)}';
        final dateString = _selectedDate.toString();

        setState(() {
          if (availableTimes[dateString] == null) {
            availableTimes[dateString] = [];
          }
          availableTimes[dateString]!.add(timeRange);
          _selectedTimeSlots.value = availableTimes[dateString]!;
        });

        isConfirmed = true;
      }
    }
  }

  void _removeTimeSlot(String time) {
    final dateString = _selectedDate.toString();
    setState(() {
      availableTimes[dateString]!.remove(time);
      if (availableTimes[dateString]!.isEmpty) {
        availableTimes.remove(dateString);
      }
      _selectedTimeSlots.value = availableTimes[dateString] ?? [];
    });
  }

  String _getDuration(String timeSlot) {
    final times = timeSlot.split(' to ');
    final startTime =
        TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(times[0]));
    final endTime =
        TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(times[1]));

    final start = DateTime(0, 0, 0, startTime.hour, startTime.minute);
    final end = DateTime(0, 0, 0, endTime.hour, endTime.minute);
    final duration = end.difference(start);

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '$hours hours ${minutes} minutes';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy/MM/dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Availability Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                _currentTime,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              selectedDayPredicate: (day) {
                return isSameDay(day, _selectedDate);
              },
              onDaySelected: _onDaySelected,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Date: $formattedDate',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<List<String>>(
              valueListenable: _selectedTimeSlots,
              builder: (context, timeSlots, _) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = timeSlots[index];
                      final duration = _getDuration(time);
                      final times = time.split(' to ');
                      return Card(
                        color: const Color(0xFFCAD6FF),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time: ${times[0]}'),
                              Text('End Time: ${times[1]}'),
                              Text('Duration: $duration'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTimeSlot(time),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectTimeRange,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
