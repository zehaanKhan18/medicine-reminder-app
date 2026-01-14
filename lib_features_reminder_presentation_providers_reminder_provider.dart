import 'package:flutter/material. dart';
import 'package: uuid/uuid.dart';
import '../../../../shared/models/reminder. dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    return _reminders
        .where((r) => r.scheduledTime. isAfter(now) && !r.isTaken)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<Reminder> get completedReminders {
    return _reminders. where((r) => r.isTaken).toList();
  }

  Future<void> loadReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reminders = await _storageService.getAllReminders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReminder({
    required String medicineId,
    required String medicineName,
    required DateTime scheduledTime,
    required String dosage,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reminder = Reminder(
        id: const Uuid().v4(),
        medicineId: medicineId,
        medicineName: medicineName,
        scheduledTime: scheduledTime,
        createdAt: DateTime.now(),
        notes: notes,
      );

      await _storageService. saveReminder(reminder);
      
      // Schedule notification
      await _notificationService.scheduleMedicineReminder(
        id: reminder.id. hashCode,
        medicineName:  medicineName,
        dosage: dosage,
        scheduledTime: scheduledTime,
      );

      _reminders.add(reminder);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsTaken(String reminderId) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        final updated = _reminders[index].copyWith(isTaken: true);
        await _storageService. updateReminder(updated);
        _reminders[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _storageService.deleteReminder(reminderId);
      await _notificationService.cancelNotification(reminderId. hashCode);
      _reminders.removeWhere((r) => r.id == reminderId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> scheduleReminderForToday({
    required String medicineId,
    required String medicineName,
    required String time, // HH:mm format
    required String dosage,
  }) async {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time is in the past, schedule for tomorrow
      final finalTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

      await createReminder(
        medicineId: medicineId,
        medicineName: medicineName,
        scheduledTime: finalTime,
        dosage: dosage,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}