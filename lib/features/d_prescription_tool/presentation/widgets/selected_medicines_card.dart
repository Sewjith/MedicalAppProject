import 'package:flutter/material.dart';
import '../../data/models/medicine_models.dart';

class SelectedMedicinesCard extends StatelessWidget {
  final List<SelectedMedicine> selectedMedicines;
  final bool isSubmitting; // To disable buttons during submission
  final Function(int) onEdit; // Callback when edit is pressed
  final Function(int) onDelete; // Callback when delete is pressed

  const SelectedMedicinesCard({
    super.key,
    required this.selectedMedicines,
    required this.isSubmitting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMedicines.isEmpty) {
      return const SizedBox.shrink(); // Not to show anything if empty
    }

    return Expanded(
      flex: 2,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: selectedMedicines.length,
          itemBuilder: (context, index) {
            final item = selectedMedicines[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.shade100,
                child: Text(item.medicineName[0],
                    style: const TextStyle(color: Colors.blueAccent)),
              ),
              title: Text(item.medicineName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${item.dosage}, ${item.frequency}, for ${item.duration} days.\nNotes: ${item.instructions}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 22),
                    color: Colors.blueGrey,
                    tooltip: 'Edit Details',
                    onPressed:
                        isSubmitting ? null : () => onEdit(index), // Pass index
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 22),
                    color: Colors.redAccent,
                    tooltip: 'Remove Item',
                    onPressed: isSubmitting
                        ? null
                        : () => onDelete(index), // Pass index
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
