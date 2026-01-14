import 'package:flutter/material.dart';
import 'package:provider/provider. dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/custom_time_picker.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine?  medicine;

  const AddMedicineScreen({Key? key, this.medicine}) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _descriptionController;
  String _frequency = 'Once Daily';
  List<String> _times = [];
  final _formKey = GlobalKey<FormState>();

  final List<String> _frequencyOptions = [
    'Once Daily',
    'Twice Daily',
    'Thrice Daily',
    'Every 4 Hours',
    'Every 6 Hours',
    'Every 8 Hours',
    'Every 12 Hours',
    'As Needed',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController = TextEditingController(text: widget.medicine!.name);
      _dosageController = TextEditingController(text: widget.medicine!.dosage);
      _descriptionController =
          TextEditingController(text: widget.medicine!.description ??  '');
      _frequency = widget.medicine!.frequency;
      _times = List.from(widget.medicine!.times);
    } else {
      _nameController = TextEditingController();
      _dosageController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTime(String time) {
    setState(() {
      if (! _times.contains(time)) {
        _times.add(time);
        _times.sort();
      }
    });
  }

  void _removeTime(String time) {
    setState(() {
      _times.remove(time);
    });
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate() && _times.isNotEmpty) {
      final provider = context.read<MedicineProvider>();

      if (widget.medicine != null) {
        provider.updateMedicine(
          id: widget.medicine!.id,
          name: _nameController.text,
          dosage: _dosageController.text,
          frequency: _frequency,
          times: _times,
          description: _descriptionController.text. isEmpty
              ? null
              : _descriptionController.text,
        );
      } else {
        provider.addMedicine(
          name: _nameController.text,
          dosage: _dosageController.text,
          frequency: _frequency,
          times: _times,
          description: _descriptionController.text. isEmpty
              ? null
              :  _descriptionController.text,
        );
      }

      Navigator.pop(context);
    } else if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one reminder time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine != null ? 'Edit Medicine' :  'Add Medicine'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g., Aspirin',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value?. isEmpty ?? true) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height:  16),

              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration:  const InputDecoration(
                  labelText: 'Dosage',
                  hintText:  'e.g., 500mg',
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Frequency Dropdown
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.schedule),
                ),
                items:  _frequencyOptions
                    .map((freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(freq),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Reminder Times
              Text(
                'Reminder Times',
                style: Theme.of(context).textTheme.titleMedium?. copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height:  12),

              if (_times.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _times
                      .map((time) => Chip(
                            label: Text(time),
                            onDeleted: () => _removeTime(time),
                            backgroundColor: 
                                AppColors.accentOrange.withOpacity(0.2),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            deleteIconColor: AppColors.accentOrange,
                          ))
                      .toList(),
                ),
              const SizedBox(height: 12),

              // Add Time Button
              ElevatedButton. icon(
                onPressed: () {
                  _showAddTimeDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Time'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                ),
              ),
              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration:  const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText:  'Any special notes about this medicine',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines:  3,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  child: Text(
                    widget.medicine != null ?  'Update Medicine' : 'Add Medicine',
                    style:  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder Time'),
        content: CustomTimePicker(
          onTimeSelected: (time) {
            _addTime(time);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}