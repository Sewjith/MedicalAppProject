import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/Medication reminder/medication_reminder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PillDetails extends StatefulWidget {
  final String id;
  final String name;
  final String details;
  final int duration;
  final int takenDays;
  late String frequency;

  PillDetails({
    required this.id,
    required this.name,
    required this.details,
    required this.duration,
    required this.takenDays,
    Key? key,
  }) : super(key: key);

  @override
  _PillDetailsState createState() => _PillDetailsState();
}

class _PillDetailsState extends State<PillDetails> {
  late int _progressCount;
  late int _totalDays;
  late DateTime _lastTakenDate;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _totalDays = widget.duration;
    _fetchLatestTakenDays();
  }

  Future<void> _fetchLatestTakenDays() async {
    try {
      final data = await _supabase
          .from('prescription_medicines')
          .select('taken_days, frequency, last_taken_date')
          .eq('id', widget.id)
          .single();

      setState(() {
        _progressCount = data['taken_days'] ?? 0;
        widget.frequency = data['frequency'] ?? '';
        _lastTakenDate = DateTime.parse(data['last_taken_date'] ?? '1970-01-01');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: ${e.toString()}')),
      );
      setState(() {
        _progressCount = widget.takenDays;
      });
    }
  }

  Future<void> _updateTakenDays(int newTakenDays) async {
    try {
      if (newTakenDays > _totalDays) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already completed the medication course.')),
        );
        return;
      }

      final response = await _supabase
          .from('prescription_medicines')
          .update({'taken_days': newTakenDays})
          .eq('id', widget.id)
          .select();

      if (response == null || response.isEmpty) {
        throw Exception('Failed to update taken days');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating progress: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateLastTakenDate(DateTime date) async {
    try {
      await _supabase
          .from('prescription_medicines')
          .update({'last_taken_date': date.toIso8601String()})
          .eq('id', widget.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating last taken date: ${e.toString()}')),
      );
    }
  }

  void _incrementProgress() {
    final currentDate = DateTime.now();

    if (_lastTakenDate.year == currentDate.year &&
        _lastTakenDate.month == currentDate.month &&
        _lastTakenDate.day == currentDate.day) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already taken this pill today!')),
      );
      return;
    }

    if (_progressCount < _totalDays) {
      setState(() {
        _progressCount++;
        _lastTakenDate = currentDate;
      });
      _updateTakenDays(_progressCount);
      _updateLastTakenDate(currentDate);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication already completed!')),
      );
    }
  }

  void _editTotalDays() {
    TextEditingController _controller = TextEditingController(text: _totalDays.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Total Days"),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Total Days"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newDuration = int.tryParse(_controller.text) ?? _totalDays;
                setState(() {
                  _totalDays = newDuration;
                });
                await _updateDuration(newDuration);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDuration(int newDuration) async {
    try {
      await _supabase
          .from('prescription_medicines')
          .update({'duration': newDuration})
          .eq('id', widget.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating duration: ${e.toString()}')),
      );
    }
  }

  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Skipped'),
          content: const Text('You have skipped this pill.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showDoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Completed'),
          content: const Text('You have taken this pill.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.headings),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Medication_Reminder()),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: _editTotalDays,
            child: Text(
              'Edit',
              style: TextStyle(
                color: AppPallete.headings,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/pills.png',
                width: 200,
              ),
              SizedBox(height: 10),
              Text(
                widget.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: AppPallete.headings,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppPallete.lightBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppPallete.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Frequency: ${widget.frequency}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppPallete.lightBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppPallete.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$_progressCount/$_totalDays days done',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black45,
                      ),
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: _totalDays > 0 ? _progressCount / _totalDays : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppPallete.headings),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _showSkipDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.lightBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppPallete.headings,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _incrementProgress();
                      _showDoneDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.headings,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: AppPallete.lightBackground,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
