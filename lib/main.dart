import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
    TimeOfDay? startPicked;
    TimeOfDay? endPicked;

    while (!isConfirmed) {
      // Ask for Start Time first
      startPicked = await _selectStartTime();
      if (startPicked == null) return;

      endPicked = await _selectEndTime(startPicked);
      if (endPicked == null) return;

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

  Future<TimeOfDay?> _selectStartTime() async {
    TimeOfDay? startPicked;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Start Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please select the start time:'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  startPicked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Select Start Time'),
              ),
            ],
          ),
        );
      },
    );
    return startPicked;
  }

  Future<TimeOfDay?> _selectEndTime(TimeOfDay startTime) async {
    TimeOfDay? endPicked;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select End Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please select the end time:'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  endPicked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Select End Time'),
              ),
            ],
          ),
        );
      },
    );
    return endPicked;
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

  Future<void> _confirmDeleteTimeSlot(String time) async {
    final confirmation = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Time Slot'),
              content:
                  const Text('Are you sure you want to delete this time slot?'),
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
        ) ??
        false;

    if (confirmation) {
      _removeTimeSlot(time);
    }
  }

  Future<void> _editTimeSlot(String oldTime) async {
    final times = oldTime.split(' to ');
    final startTime =
        TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(times[0]));
    final endTime =
        TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(times[1]));

    TimeOfDay? startPicked;
    TimeOfDay? endPicked;

    startPicked = await _selectStartTime();
    if (startPicked == null) {
      return;
    }

    endPicked = await _selectEndTime(startPicked);
    if (endPicked == null) {
      return;
    }

    final timeRange =
        '${startPicked.format(context)} to ${endPicked.format(context)}';
    final dateString = _selectedDate.toString();

    setState(() {
      final index = availableTimes[dateString]!.indexOf(oldTime);
      availableTimes[dateString]![index] = timeRange;
      _selectedTimeSlots.value = availableTimes[dateString]!;
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

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');

    return '$hours:$minutes';
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
        backgroundColor: const Color(0xFF2260FF),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(
                            Icons.access_time,
                            color: Colors.blue,
                            size: 36, // Increased icon size
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time: ${times[0]}'),
                              Text('End Time: ${times[1]}'),
                              Text('Duration: $duration'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editTimeSlot(time),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteTimeSlot(time),
                              ),
                            ],
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
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
