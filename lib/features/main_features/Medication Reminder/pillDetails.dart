import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/Medication%20reminder/medication_reminder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PillDetails extends StatefulWidget {
  final String id;
  final String name;
  final String details;
  final int duration;
  final int takenDays;
  final String frequency;
  final bool isPrescription;

  PillDetails({
    required this.id,
    required this.name,
    required this.details,
    required this.duration,
    required this.takenDays,
    this.frequency = '',
    this.isPrescription = false,
    Key? key,
  }) : super(key: key);

  @override
  _PillDetailsState createState() => _PillDetailsState();
}

class _PillDetailsState extends State<PillDetails> {
  late int _progressCount;
  late int _totalDays;
  DateTime? _lastTakenDate;
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>> _dataFuture;
  bool _isTakenToday = false;
  TimeOfDay? _reminderTime;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _progressCount = widget.takenDays;
    _totalDays = widget.duration;
    _dataFuture = _fetchMedicationDetails();
  }

  Future<Map<String, dynamic>> _fetchMedicationDetails() async {
    try {
      if (widget.isPrescription) {
        final prescriptionData =
            await _supabase.from('prescription_medicines').select('''
              taken_days, 
              frequency, 
              last_taken_date,
              start_date,
              time_of_day,
              duration
            ''').eq('id', widget.id).maybeSingle();

        if (prescriptionData != null) {
          _startDate = DateTime.parse(prescriptionData['start_date']);
          _totalDays = prescriptionData['duration'] ?? widget.duration;
          _endDate = _startDate!.add(Duration(days: _totalDays));

          if (prescriptionData['last_taken_date'] != null) {
            _lastTakenDate =
                DateTime.parse(prescriptionData['last_taken_date']);
            _isTakenToday = _isDateToday(_lastTakenDate!);
          }

          if (prescriptionData['time_of_day'] != null) {
            final timeParts = prescriptionData['time_of_day'].split(':');
            _reminderTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }

          // Update the progress count from database
          setState(() {
            _progressCount = prescriptionData['taken_days'] ?? widget.takenDays;
          });

          return {
            'frequency': prescriptionData['frequency'] ?? '',
            'last_taken_date': _lastTakenDate,
            'time_of_day': _reminderTime,
            'start_date': _startDate,
            'end_date': _endDate,
            'taken_days': prescriptionData['taken_days'] ?? 0,
          };
        }
      } else {
        final reminderData =
            await _supabase.from('medication_reminders').select('''
              frequency, 
              start_date,
              time_of_day,
              duration_days,
              taken_days,
              last_taken_date
            ''').eq('id', widget.id).maybeSingle();

        if (reminderData != null) {
          _startDate = DateTime.parse(reminderData['start_date']);
          _totalDays = reminderData['duration_days'] ?? widget.duration;
          _endDate = _startDate!.add(Duration(days: _totalDays));

          if (reminderData['time_of_day'] != null) {
            final timeParts = reminderData['time_of_day'].split(':');
            _reminderTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }

          if (reminderData['last_taken_date'] != null) {
            _lastTakenDate = DateTime.parse(reminderData['last_taken_date']);
            _isTakenToday = _isDateToday(_lastTakenDate!);
          }

          // Update the progress count from database
          setState(() {
            _progressCount = reminderData['taken_days'] ?? widget.takenDays;
          });

          return {
            'frequency': reminderData['frequency'] ?? '',
            'time_of_day': _reminderTime,
            'start_date': _startDate,
            'end_date': _endDate,
            'taken_days': reminderData['taken_days'] ?? 0,
          };
        }
      }

      throw Exception('Medication details not found');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: ${e.toString()}')),
      );
      return {};
    }
  }

  bool _isDateToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _markAsTaken() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      if (_isTakenToday) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You have already taken this medication today')),
        );
        return;
      }

      // Update database first
      if (widget.isPrescription) {
        await _supabase.from('prescription_medicines').update({
          'taken_days': _progressCount + 1,
          'last_taken_date': now.toIso8601String(),
        }).eq('id', widget.id);
      } else {
        await _supabase.from('medication_reminders').update({
          'taken_days': _progressCount + 1,
          'last_taken_date': now.toIso8601String(),
        }).eq('id', widget.id);
      }

      // Update local state after successful database update
      setState(() {
        _progressCount++;
        _lastTakenDate = now;
        _isTakenToday = true;
      });

      _showConfirmationDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating progress: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Medication Taken'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.name} has been marked as taken.'),
              SizedBox(height: 10),
              Text('Taken at: ${DateFormat.jm().format(DateTime.now())}'),
              SizedBox(height: 10),
              Text('Progress: $_progressCount/$_totalDays days'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReminder() async {
    try {
      if (widget.isPrescription) {
        await _supabase
            .from('prescription_medicines')
            .delete()
            .eq('id', widget.id);
      } else {
        await _supabase
            .from('medication_reminders')
            .delete()
            .eq('id', widget.id);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Medication_Reminder()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting reminder: ${e.toString()}')),
      );
    }
  }

  Widget _buildStatusIndicator() {
    if (_endDate == null || _startDate == null) return SizedBox();

    final now = DateTime.now();
    final isCompleted = _progressCount >= _totalDays;
    final isActive = !isCompleted && now.isBefore(_endDate!);
    final isUpcoming = now.isBefore(_startDate!);
    final isExpired = now.isAfter(_endDate!);

    Color statusColor;
    String statusText;

    if (isCompleted) {
      statusColor = Colors.green;
      statusText = 'Completed';
    } else if (isExpired) {
      statusColor = Colors.orange;
      statusText = 'Expired';
    } else if (isUpcoming) {
      statusColor = Colors.blue;
      statusText = 'Upcoming';
    } else {
      statusColor = AppPallete.headings;
      statusText = 'Active';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            fontSize: 16,
            color: AppPallete.textColor.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _totalDays > 0 ? _progressCount / _totalDays : 0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppPallete.headings),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(width: 10),
            Text(
              '$_progressCount/$_totalDays days',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppPallete.headings,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: AppPallete.headings),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPallete.textColor.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.headings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  'Failed to load medication details',
                  style: TextStyle(color: AppPallete.errorColor),
                ),
              );
            }

            final data = snapshot.data!;
            final frequency = data['frequency'] ?? 'As needed';
            final timeOfDay = _reminderTime;
            final startDate = _startDate;
            final endDate = _endDate;

            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.headings,
                        ),
                      ),
                      _buildStatusIndicator(),
                    ],
                  ),
                  SizedBox(height: 5),
                  if (widget.details.isNotEmpty)
                    Text(
                      widget.details,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppPallete.textColor.withOpacity(0.7),
                      ),
                    ),
                  SizedBox(height: 30),

                  // Medication Details Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: AppPallete.lightBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medication Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppPallete.headings,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Frequency
                          Row(
                            children: [
                              Icon(Icons.repeat, color: AppPallete.headings),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Frequency',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          AppPallete.textColor.withOpacity(0.6),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    frequency,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppPallete.headings,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Time and Date Information
                          if (timeOfDay != null ||
                              startDate != null ||
                              endDate != null)
                            Column(
                              children: [
                                if (timeOfDay != null)
                                  _buildTimeCard(
                                    'Reminder Time',
                                    timeOfDay.format(context),
                                    Icons.access_time,
                                  ),
                                SizedBox(height: 12),
                                if (startDate != null)
                                  _buildTimeCard(
                                    'Start Date',
                                    DateFormat('MMM d, y').format(startDate!),
                                    Icons.calendar_today,
                                  ),
                                SizedBox(height: 12),
                                if (endDate != null)
                                  _buildTimeCard(
                                    'End Date',
                                    DateFormat('MMM d, y').format(endDate!),
                                    Icons.event_available,
                                  ),
                                SizedBox(height: 12),
                              ],
                            ),

                          // Progress Indicator
                          _buildProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Mark as Taken Button
                  if (!_isTakenToday &&
                      endDate != null &&
                      startDate != null &&
                      DateTime.now().isAfter(startDate!) &&
                      DateTime.now().isBefore(endDate!))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _markAsTaken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.headings,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Mark as Taken Today',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                  // Already Taken Today Indicator
                  if (_isTakenToday && _lastTakenDate != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Taken Today',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Marked as taken at ${DateFormat.jm().format(_lastTakenDate!)}',
                                  style: TextStyle(
                                    color:
                                        AppPallete.textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Reminder'),
          content: Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReminder();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
