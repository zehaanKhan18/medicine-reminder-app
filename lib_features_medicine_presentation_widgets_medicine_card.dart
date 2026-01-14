import 'package:flutter/material. dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MedicineCard({
    Key? key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryTeal. withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.medical_services,
            color: AppColors. primaryTeal,
            size: 24,
          ),
        ),
        title: Text(
          medicine.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Dosage: ${medicine.dosage}'),
            Text('Frequency: ${medicine.frequency}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children:  medicine.times
                  .map((time) => Chip(
                        label: Text(
                          time,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.accentOrange. withOpacity(0.2),
                        labelStyle: const TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: onEdit,
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}