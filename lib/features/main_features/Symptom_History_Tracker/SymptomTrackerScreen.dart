import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  bool isLoading = false;
  bool viewingDetail = false;

  String selectedSymptomId = '';
  String selectedSymptomName = '';
  List<Map<String, dynamic>> symptomEntries = [];
  DateTime _selectedDate = DateTime.now();
  double _severity = 1.0;
  List<DateTime> _chartDates = [];

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('symptoms')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _savedSymptoms.clear();
        _savedSymptoms.addAll(List<Map<String, dynamic>>.from(data));
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
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
    final confirm = await _confirmDialog('Delete Symptom', 'Are you sure you want to delete this symptom?');
    if (!confirm) return;

    try {
      await supabase.from('symptoms').delete().eq('id', id);
      await _loadSymptoms();
    } catch (e) {
      _showError('Could not delete symptom.\n$e');
    }
  }

  Future<void> _openSymptomDetail(Map<String, dynamic> symptom) async {
    setState(() {
      selectedSymptomId = symptom['id'];
      selectedSymptomName = symptom['name'];
      viewingDetail = true;
    });
    await _loadSymptomEntries();
  }

  Future<void> _loadSymptomEntries() async {
    try {
      final entries = await supabase
          .from('symptom_data')
          .select()
          .eq('symptom_id', selectedSymptomId)
          .order('date');

      setState(() {
        symptomEntries = List<Map<String, dynamic>>.from(entries);
      });
    } catch (e) {
      _showError('Could not load entries.\n$e');
    }
  }

  Future<void> _addSymptomEntry() async {
    try {
      await supabase.from('symptom_data').insert({
        'symptom_id': selectedSymptomId,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'severity': _severity,
      });
      await _loadSymptomEntries();
      setState(() {
        _selectedDate = DateTime.now();
        _severity = 1.0;
      });
    } catch (e) {
      _showError('Failed to add entry.\n$e');
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    final confirm = await _confirmDialog('Delete Entry', 'Are you sure you want to delete this entry?');
    if (!confirm) return;

    try {
      await supabase.from('symptom_data').delete().eq('id', entryId);
      await _loadSymptomEntries();
    } catch (e) {
      _showError('Failed to delete entry.\n$e');
    }
  }

  Future<void> _editEntry(Map<String, dynamic> entry) async {
    DateTime editedDate = DateTime.parse(entry['date']);
    double editedSeverity = entry['severity'].toDouble();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await supabase.from('symptom_data').update({
                  'date': editedDate.toIso8601String().split('T')[0],
                  'severity': editedSeverity,
                }).eq('id', entry['id']);

                await _loadSymptomEntries();
              } catch (e) {
                _showError('Failed to update entry.\n$e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartSpots() {
    final sorted = symptomEntries
        .where((e) => DateTime.parse(e['date']).month == DateTime.now().month)
        .toList()
      ..sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

    _chartDates = sorted.map((e) => DateTime.parse(e['date'])).toList();

    return List.generate(_chartDates.length, (index) {
      return FlSpot(index.toDouble(), sorted[index]['severity'] * 1.0);
    });
  }

  void _showError(String message) {
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
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4A90E2);
    final backgroundColor = const Color(0xFFF5F7FA);
    final textColor = const Color(0xFF333333);
    final saveButtonColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(viewingDetail ? selectedSymptomName : 'Symptom Tracker'),
        backgroundColor: primaryColor,
        leading: viewingDetail
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => viewingDetail = false),
        )
            : null,
      ),
      body: isLoading
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
                    leading: Icon(Icons.favorite_border, color: primaryColor),
                    title: Text(entry['name'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    subtitle: const Text('Tap to view history'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
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
            onPressed: _addSymptomEntry,
            child: const Text('Add Entry'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: symptomEntries.isEmpty
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
                          return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10));
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
          Expanded(
            child: ListView.builder(
              itemCount: symptomEntries.length,
              itemBuilder: (context, index) {
                final entry = symptomEntries[index];
                final date = DateTime.parse(entry['date']);
                final severity = entry['severity'];
                return Card(
                  child: ListTile(
                    title: Text('${date.toLocal().toString().split(' ')[0]} - Severity: ${severity.toStringAsFixed(1)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editEntry(entry),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
