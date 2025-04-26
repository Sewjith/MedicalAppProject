import 'package:flutter/material.dart';
import '../../data/models/medicine_models.dart';

class AvailableMedicinesList extends StatelessWidget {
  final bool isLoading;
  final bool isProcessing; // For check if an add/edit/delete happening
  final List<SupabaseMedicine> availableMedicines;
  final Future<void> Function() onRefresh;
  final Function(SupabaseMedicine) onSelectMedicine;
  final Function(SupabaseMedicine) onEditMedicine;
  final Function(SupabaseMedicine) onDeleteMedicine;

  const AvailableMedicinesList({
    super.key,
    required this.isLoading,
    required this.isProcessing,
    required this.availableMedicines,
    required this.onRefresh,
    required this.onSelectMedicine,
    required this.onEditMedicine,
    required this.onDeleteMedicine,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : availableMedicines.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No medicines found.'),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tap to Retry'),
                        onPressed: onRefresh, // Use callback
                      )
                    ],
                  ))
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: availableMedicines.length,
                      itemBuilder: (context, index) {
                        final medicine = availableMedicines[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 0),
                          title: Text(medicine.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: (medicine.type != null &&
                                  medicine.type!.isNotEmpty)
                              ? Text('Type: ${medicine.type}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13))
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                color: Colors.blueGrey,
                                tooltip: 'Edit ${medicine.name}',
                                // Disable if loading or processing other items
                                onPressed: (isLoading || isProcessing)
                                    ? null
                                    : () => onEditMedicine(medicine),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                color: Colors.redAccent,
                                tooltip: 'Delete ${medicine.name}',
                                // Disable if loading or processing other items
                                onPressed: (isLoading || isProcessing)
                                    ? null
                                    : () => onDeleteMedicine(medicine),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, size: 20),
                                color: Colors.green.shade600,
                                tooltip: 'Add ${medicine.name} to prescription',
                                // Disable if loading or processing other items
                                onPressed: (isLoading || isProcessing)
                                    ? null
                                    : () => onSelectMedicine(medicine),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
