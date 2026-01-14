import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';

class CustomTimePicker extends StatefulWidget {
  final String?  initialTime;
  final Function(String) onTimeSelected;

  const CustomTimePicker({
    Key? key,
    this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialTime != null) {
      final parts = widget.initialTime!.split(':');
      _selectedTime = TimeOfDay(
        hour:  int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:  const ColorScheme.light(
              primary: AppColors. primaryTeal,
              onPrimary: Colors.white,
            ),
          ),
          child: child! ,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      final timeString =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute. toString().padLeft(2, '0')}';
      widget.onTimeSelected(timeString);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${_selectedTime. hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical:  12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryTeal, width: 1. 5),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeString,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryTeal,
              ),
            ),
            const Icon(Icons.access_time, color: AppColors.accentOrange),
          ],
        ),
      ),
    );
  }
}