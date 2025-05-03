// @@@@@-FILE MODIFICATION START-@@@@@
// File: lib/features/main_features/Symptom_History_Tracker/SymptomTrackerScreen.dart
// Reason: Correct SideTitleWidget calls in chart titlesData: add missing 'meta' parameter and remove incorrect 'axisSide' parameter.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({Key? key}) : super(key: key);

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final List<String> _presetSymptoms = [
    'Headache', 'Fever', 'Cough', 'Fatigue', 'Anxiety', 'Migraine', 'Constipation', 'Diarrhea'
  ];

  final List<Map<String, dynamic>> _savedSymptoms = [];
  final TextEditingController _symptomController = TextEditingController();
  String _selectedSymptom = '';
  bool isLoadingSymptoms = true;
  bool isLoadingEntries = false;
  bool viewingDetail = false;
  String? _patientId;
  String? _initializationError;

  String selectedSymptomId = '';
  String selectedSymptomName = '';
  List<Map<String, dynamic>> symptomEntries = [];
  DateTime _selectedDate = DateTime.now();
  double _severity = 1.0;
  List<DateTime> _chartDates = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializePatientIdAndLoadSymptoms();
  }

   void _initializePatientIdAndLoadSymptoms() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
        final userState = context.read<AppUserCubit>().state;
        if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
          _patientId = userState.user.uid;
          if (_patientId != null && _patientId!.isNotEmpty) {
            _loadSymptoms();
          } else {
             if (mounted) {
               setState(() {
                  isLoadingSymptoms = false;
                  _initializationError = "Could not get patient ID.";
               });
             }
          }
        } else {
           if (mounted) {
             setState(() {
                isLoadingSymptoms = false;
                _initializationError = "Please log in as a patient to track symptoms.";
             });

           }
        }
     });
   }

  Future<void> _loadSymptoms() async {
    if (!mounted) return;
    setState(() => isLoadingSymptoms = true);
    _initializationError = null;
    try {
      final data = await supabase
          .from('symptoms')
          .select()
          .order('created_at', ascending: false);

       if (!mounted) return;
      setState(() {
        _savedSymptoms.clear();
        _savedSymptoms.addAll(List<Map<String, dynamic>>.from(data));
        isLoadingSymptoms = false;
      });
    } catch (e) {
       if (!mounted) return;
      setState(() => isLoadingSymptoms = false);
      _showError('Could not load symptoms.\n$e');
    }
  }

  Future<void> _saveSymptom() async {
    if (_selectedSymptom.isEmpty) return;
    if (_savedSymptoms.any((s) => s['name'] == _selectedSymptom)) return;

    try {
      await supabase.from('symptoms').insert({
        'name': _selectedSymptom,
      });

      _symptomController.clear();
      _selectedSymptom = '';
      await _loadSymptoms();
    } catch (e) {
      _showError('Failed to save symptom.\n$e');
    }
  }

  Future<void> _deleteSymptom(String id) async {
    final confirm = await _confirmDialog('Delete Symptom', 'Are you sure you want to delete this symptom? This will also delete all associated entries.');
    if (!confirm) return;

    try {

      await supabase.from('symptoms').delete().eq('id', id);
      await _loadSymptoms();

      if (viewingDetail && selectedSymptomId == id) {
          setState(() => viewingDetail = false);
      }
    } catch (e) {
      _showError('Could not delete symptom.\n$e');
    }
  }

  Future<void> _openSymptomDetail(Map<String, dynamic> symptom) async {
    if (_patientId == null) {
        _showError("Patient ID not found.");
        return;
    }
    setState(() {
      selectedSymptomId = symptom['id'];
      selectedSymptomName = symptom['name'];
      viewingDetail = true;
      isLoadingEntries = true;
    });
    await _loadSymptomEntries();
  }

  Future<void> _loadSymptomEntries() async {
    if (!viewingDetail || _patientId == null || selectedSymptomId.isEmpty || !mounted) {
      if (mounted) setState(() => isLoadingEntries = false);
      return;
    }

    if (!isLoadingEntries) setState(() => isLoadingEntries = true);

    try {
      final entries = await supabase
          .from('symptom_data')
          .select()
          .eq('symptom_id', selectedSymptomId)
          .eq('patient_id', _patientId!)
          .order('date', ascending: true);

       if (!mounted) return;
      setState(() {
        symptomEntries = List<Map<String, dynamic>>.from(entries);
        isLoadingEntries = false;
      });
      _scrollToBottom();
    } catch (e) {
       if (!mounted) return;
      setState(() => isLoadingEntries = false);
      _showError('Could not load entries.\n$e');
    }
  }


  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }


  Future<void> _addSymptomEntry() async {
    if (_patientId == null || selectedSymptomId.isEmpty) return;


    try {
      await supabase.from('symptom_data').insert({
        'symptom_id': selectedSymptomId,
        'patient_id': _patientId!,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'severity': _severity,
      });
      await _loadSymptomEntries();
      if (mounted) {
          setState(() {
             _selectedDate = DateTime.now();
             _severity = 1.0;
          });
      }
    } catch (e) {
      _showError('Failed to add entry.\n$e');
    }
  }

  Future<void> _deleteEntry(String entryId) async {
     if (_patientId == null) return;
    final confirm = await _confirmDialog('Delete Entry', 'Are you sure you want to delete this entry?');
    if (!confirm) return;

    try {
      await supabase.from('symptom_data')
          .delete()
          .eq('id', entryId)
          .eq('patient_id', _patientId!);
      await _loadSymptomEntries();
    } catch (e) {
      _showError('Failed to delete entry.\n$e');
    }
  }

  Future<void> _editEntry(Map<String, dynamic> entry) async {
     if (_patientId == null) return;
    DateTime editedDate = DateTime.parse(entry['date']);
    double editedSeverity = entry['severity'].toDouble();
    bool dateChanged = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: editedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                       setDialogState(() {
                          editedDate = picked;
                          dateChanged = true;
                       });
                    }
                  },
                  child: Text('Pick Date: ${editedDate.toLocal().toString().split(' ')[0]}'),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: editedSeverity,
                  min: 1,
                  max: 10,
                  divisions: 90,
                  label: editedSeverity.toStringAsFixed(1),
                  onChanged: (value) {
                     setDialogState(() {
                       editedSeverity = value;
                     });
                  },
                ),
                 Text('Severity: ${editedSeverity.toStringAsFixed(1)}'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {


                    await supabase.from('symptom_data').update({
                      'date': editedDate.toIso8601String().split('T')[0],
                      'severity': editedSeverity,
                    })
                    .eq('id', entry['id'])
                    .eq('patient_id', _patientId!);

                    await _loadSymptomEntries();
                  } catch (e) {
                    _showError('Failed to update entry.\n$e');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }


  List<FlSpot> _getChartSpots() {

     final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
     final recentEntries = symptomEntries
         .where((e) => DateTime.parse(e['date']).isAfter(thirtyDaysAgo))
         .toList();


     recentEntries.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));


    _chartDates = recentEntries.map((e) => DateTime.parse(e['date'])).toList();

    if (_chartDates.isEmpty) return [];

    return List.generate(_chartDates.length, (index) {

      return FlSpot(index.toDouble(), recentEntries[index]['severity'] * 1.0);
    });
  }

  void _showError(String message) {
     if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDialog(String title, String message) async {
    if (!mounted) return false;
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    ) ??
        false;
  }

   @override
  void dispose() {
    _scrollController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppPallete.primaryColor;
    final backgroundColor = AppPallete.backgroundColor;
    final textColor = AppPallete.textColor;
    final saveButtonColor = Colors.redAccent;


    if (_initializationError != null) {
       return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
             title: const Text('Symptom Tracker'),
             backgroundColor: primaryColor,
             leading: viewingDetail
                 ? IconButton(
               icon: const Icon(Icons.arrow_back),
               onPressed: () => setState(() => viewingDetail = false),
             ) : (context.canPop() ? BackButton(onPressed: () => context.pop()) : null),
          ),
          body: Center(child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text(_initializationError!, style: TextStyle(color: Colors.red, fontSize: 16)),
          ))
       );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(viewingDetail ? selectedSymptomName : 'Symptom Tracker'),
        backgroundColor: primaryColor,
         foregroundColor: Colors.white,
        leading: viewingDetail
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
             viewingDetail = false;
             symptomEntries.clear();
             _chartDates.clear();
          }),
        ) : (context.canPop() ? BackButton(onPressed: () => context.pop()) : null),
      ),
      body: isLoadingSymptoms
          ? const Center(child: CircularProgressIndicator())
          : viewingDetail
          ? _buildSymptomDetailView(primaryColor)
          : _buildMainSymptomListView(textColor, saveButtonColor, primaryColor),
    );
  }

  Widget _buildMainSymptomListView(Color textColor, Color saveButtonColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _symptomController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Symptom',
              labelStyle: TextStyle(color: textColor),
              hintText: 'Start typing or select...',
              hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: (value) {
                  _symptomController.text = value;
                  setState(() {
                    _selectedSymptom = value;
                  });
                },
                itemBuilder: (context) => _presetSymptoms
                    .map((symptom) => PopupMenuItem(value: symptom, child: Text(symptom)))
                    .toList(),
              ),
            ),
            onChanged: (value) => setState(() => _selectedSymptom = value),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: saveButtonColor),
            onPressed: _saveSymptom,
            child: const Text('Save Symptom'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _savedSymptoms.isEmpty
                ? Center(child: Text('No saved symptoms yet.', style: TextStyle(color: textColor.withOpacity(0.6))))
                : ListView.builder(
              itemCount: _savedSymptoms.length,
              itemBuilder: (context, index) {
                final entry = _savedSymptoms[index];
                return Card(
                  color: Colors.lightBlue[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    onTap: () => _openSymptomDetail(entry),
                    leading: Icon(Icons.thermostat_outlined, color: primaryColor),
                    title: Text(entry['name'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    subtitle: const Text('Tap to view/add entries'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Symptom Type',
                      onPressed: () => _deleteSymptom(entry['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomDetailView(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add Entry for: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && mounted) {
                            setState(() { _selectedDate = picked; });
                          }
                        },
                        child: const Text('Change Date'),
                      ),
                    ],
                  ),
                   const SizedBox(height: 8),
                   Text('Severity: ${_severity.toStringAsFixed(1)} / 10'),
                  Slider(
                    value: _severity,
                    min: 1,
                    max: 10,
                    divisions: 90,
                    label: _severity.toStringAsFixed(1),
                    onChanged: (value) {
                      if (mounted) setState(() { _severity = value; });
                    },
                  ),
                  ElevatedButton(
                    onPressed: _addSymptomEntry,
                    child: const Text('Add Entry'),
                  ),
                ],
              ),
            ),
          ),

          const Text("History (Last 30 Days)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

           SizedBox(
             height: 200,
             child: isLoadingEntries
                 ? const Center(child: CircularProgressIndicator())
                 : symptomEntries.isEmpty
                 ? const Center(child: Text('No data recorded yet.'))
                 : LineChart(
                      LineChartData(
                         minY: 0,
                         maxY: 11,
                         titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                               sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: _chartDates.length > 7 ? (_chartDates.length / 7).ceilToDouble() : 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < _chartDates.length) {

                                       if (index % (_chartDates.length > 7 ? (_chartDates.length / 7).ceil().toInt() : 1) == 0) {
                                          final date = _chartDates[index];
                                          // Corrected: Pass meta to SideTitleWidget, remove axisSide
                                          return SideTitleWidget(meta: meta, child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10)));
                                       }
                                    }
                                    return const Text('');
                                  },
                               ),
                            ),
                           leftTitles: AxisTitles(
                             sideTitles: SideTitles(
                               showTitles: true,
                               interval: 2,
                               reservedSize: 28,
                               // Corrected: Wrap Text in SideTitleWidget and pass meta
                               getTitlesWidget: (value, meta) => SideTitleWidget(meta: meta, child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10))),
                             ),
                           ),
                         ),
                         gridData: FlGridData( show: true, drawVerticalLine: true, horizontalInterval: 2, verticalInterval: (_chartDates.length > 7 ? (_chartDates.length / 7).ceilToDouble() : 1), ),
                         borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                         lineBarsData: [
                            LineChartBarData(
                               spots: _getChartSpots(),
                               isCurved: true,
                               color: primaryColor,
                               barWidth: 3,
                               isStrokeCapRound: true,
                               dotData: const FlDotData(show: true),
                               belowBarData: BarAreaData(show: true, color: primaryColor.withOpacity(0.2)),
                            ),
                         ],
                      ),
                   ),
           ),
          const SizedBox(height: 16),

          Expanded(
            child: isLoadingEntries
                ? const SizedBox.shrink()
                : symptomEntries.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                   controller: _scrollController,
                   itemCount: symptomEntries.length,
                   itemBuilder: (context, index) {

                     final entryIndex = symptomEntries.length - 1 - index;
                     final entry = symptomEntries[entryIndex];
                     final date = DateTime.parse(entry['date']);
                     final severity = entry['severity'];
                     return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                           title: Text('${date.toLocal().toString().split(' ')[0]} - Severity: ${severity.toStringAsFixed(1)}'),
                           trailing: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               IconButton(
                                 icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                 tooltip: 'Edit Entry',
                                 onPressed: () => _editEntry(entry),
                               ),
                               IconButton(
                                 icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  tooltip: 'Delete Entry',
                                 onPressed: () => _deleteEntry(entry['id']),
                               ),
                             ],
                           ),
                        ),
                     );
                   },
                 ),
          ),
        ],
      ),
    );
  }
}
// @@@@@-FILE MODIFICATION END-@@@@@