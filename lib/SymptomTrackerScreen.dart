// main.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MaterialApp(
    home: SymptomTrackerScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class SymptomEntry {
  final String symptom;

  SymptomEntry({required this.symptom});
}

class SymptomData {
  DateTime date;
  double severity;

  SymptomData({required this.date, required this.severity});
}

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({Key? key}) : super(key: key);

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final List<String> _presetSymptoms = [
    'Headache', 'Fever', 'Cough', 'Fatigue', 'Anxiety', 'Migrane', 'Constipation', 'Diarrhea'
  ];
  final List<SymptomEntry> _savedSymptoms = [];
  final Map<String, List<SymptomData>> _symptomDataMap = {};

  final TextEditingController _symptomController = TextEditingController();
  String _selectedSymptom = '';

  final Color primaryColor = const Color(0xFF4A90E2);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color textColor = const Color(0xFF333333);
  final Color saveButtonColor = Colors.redAccent;

  void _saveSymptom() {
    if (_selectedSymptom.isEmpty) return;
    if (_savedSymptoms.any((entry) => entry.symptom == _selectedSymptom)) return;
    setState(() {
      _savedSymptoms.add(SymptomEntry(symptom: _selectedSymptom));
      _symptomDataMap[_selectedSymptom] = [];
    });
    _symptomController.clear();
    _selectedSymptom = '';
  }

  void _deleteSymptom(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Symptom'),
        content: const Text('Are you sure you want to delete this symptom?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        final removed = _savedSymptoms.removeAt(index);
        _symptomDataMap.remove(removed.symptom);
      });
    }
  }

  void _openSymptomDetails(SymptomEntry entry) async {
    final updatedData = await Navigator.push<List<SymptomData>>(
      context,
      MaterialPageRoute(
        builder: (context) => SymptomDetailScreen(
          symptom: entry.symptom,
          initialData: _symptomDataMap[entry.symptom] ?? [],
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _symptomDataMap[entry.symptom] = updatedData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Symptom Tracker'),
      ),
      body: Padding(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              onChanged: (value) {
                setState(() {
                  _selectedSymptom = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: saveButtonColor),
                  onPressed: _saveSymptom,
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _savedSymptoms.isEmpty
                  ? Center(
                child: Text('No saved symptoms yet.', style: TextStyle(color: textColor.withOpacity(0.6))),
              )
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
                      onTap: () => _openSymptomDetails(entry),
                      leading: Icon(Icons.favorite_border, color: primaryColor),
                      title: Text(entry.symptom, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      subtitle: const Text('Tap to view history'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSymptom(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomDetailScreen extends StatefulWidget {
  final String symptom;
  final List<SymptomData> initialData;

  const SymptomDetailScreen({
    Key? key,
    required this.symptom,
    required this.initialData,
  }) : super(key: key);

  @override
  State<SymptomDetailScreen> createState() => _SymptomDetailScreenState();
}

class _SymptomDetailScreenState extends State<SymptomDetailScreen> {
  late List<SymptomData> _data;
  DateTime _selectedDate = DateTime.now();
  double _severity = 1.0;
  List<DateTime> _chartDates = [];

  @override
  void initState() {
    super.initState();
    _data = List.from(widget.initialData);
  }

  void _addEntry() {
    setState(() {
      _data.add(SymptomData(date: _selectedDate, severity: _severity));
      _selectedDate = DateTime.now();
      _severity = 1.0;
    });
  }

  void _editEntry(int index) async {
    final original = _data[index];
    DateTime editedDate = original.date;
    double editedSeverity = original.severity;

    await showDialog(
      context: context,
      builder: (context) {
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
                    setState(() {
                      editedDate = picked;
                    });
                  }
                },
                child: Text("Change Date: ${editedDate.toLocal().toString().split(' ')[0]}"),
              ),
              Slider(
                value: editedSeverity,
                min: 1,
                max: 10,
                divisions: 90,
                label: editedSeverity.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    editedSeverity = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() {
                  _data[index] = SymptomData(date: editedDate, severity: editedSeverity);
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(int index) {
    setState(() {
      _data.removeAt(index);
    });
  }

  List<FlSpot> _getChartSpots() {
    final sorted = _data
        .where((e) => e.date.month == DateTime.now().month && e.date.year == DateTime.now().year)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _chartDates = sorted.map((e) => e.date).toList();

    return List.generate(_chartDates.length, (index) {
      return FlSpot(index.toDouble(), sorted[index].severity);
    });
  }

  @override
  void dispose() {
    Navigator.pop(context, _data);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4A90E2);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symptom),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            Slider(
              value: _severity,
              min: 1,
              max: 10,
              divisions: 90,
              label: _severity.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _severity = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _addEntry,
              child: const Text('Add Entry'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _data.isEmpty
                        ? const Center(child: Text('No data for this month'))
                        : LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index >= 0 && index < _chartDates.length) {
                                  final date = _chartDates[index];
                                  final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
                                  return Text('$weekday\n${date.month}/${date.day}', style: TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                              interval: 1,
                              reservedSize: 32,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) => Text(value.toStringAsFixed(1)),
                              interval: 1,
                              reservedSize: 32,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getChartSpots(),
                            isCurved: true,
                            color: primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_data.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          final entry = _data[index];
                          return Card(
                            child: ListTile(
                              title: Text('${entry.date.toLocal().toString().split(' ')[0]} - Severity: ${entry.severity.toStringAsFixed(1)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editEntry(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEntry(index),
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
            ),
          ],
        ),
      ),
    );
  }
}
