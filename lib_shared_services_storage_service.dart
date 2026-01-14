import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/medicine.dart';
import '../models/reminder.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static final logger = Logger();

  late Box<Map> _medicineBox;
  late Box<Map> _reminderBox;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> initialize() async {
    try {
      _medicineBox = await Hive.openBox<Map>('medicines');
      _reminderBox = await Hive.openBox<Map>('reminders');
      logger.i('Storage service initialized');
    } catch (e) {
      logger.e('Failed to initialize storage: $e');
      rethrow;
    }
  }

  // Medicine operations
  Future<void> saveMedicine(Medicine medicine) async {
    try {
      await _medicineBox.put(medicine. id, medicine.toMap());
      logger.i('Medicine saved: ${medicine.name}');
    } catch (e) {
      logger.e('Failed to save medicine: $e');
      rethrow;
    }
  }

  Future<List<Medicine>> getAllMedicines() async {
    try {
      final medicines = _medicineBox.values
          .map((map) => Medicine.fromMap(Map<String, dynamic>.from(map)))
          .toList();
      logger.i('Retrieved ${medicines. length} medicines');
      return medicines;
    } catch (e) {
      logger.e('Failed to get medicines: $e');
      return [];
    }
  }

  Future<Medicine?> getMedicineById(String id) async {
    try {
      final map = _medicineBox.get(id);
      if (map != null) {
        return Medicine. fromMap(Map<String, dynamic>.from(map));
      }
      return null;
    } catch (e) {
      logger.e('Failed to get medicine:  $e');
      return null;
    }
  }

  Future<void> updateMedicine(Medicine medicine) async {
    try {
      await _medicineBox.put(medicine. id, medicine.toMap());
      logger.i('Medicine updated: ${medicine.name}');
    } catch (e) {
      logger.e('Failed to update medicine: $e');
      rethrow;
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      await _medicineBox.delete(id);
      logger.i('Medicine deleted: $id');
    } catch (e) {
      logger.e('Failed to delete medicine: $e');
      rethrow;
    }
  }

  // Reminder operations
  Future<void> saveReminder(Reminder reminder) async {
    try {
      await _reminderBox.put(reminder.id, reminder.toMap());
      logger.i('Reminder saved: ${reminder.medicineName}');
    } catch (e) {
      logger.e('Failed to save reminder: $e');
      rethrow;
    }
  }

  Future<List<Reminder>> getAllReminders() async {
    try {
      final reminders = _reminderBox.values
          .map((map) => Reminder.fromMap(Map<String, dynamic>.from(map)))
          .toList();
      logger.i('Retrieved ${reminders.length} reminders');
      return reminders;
    } catch (e) {
      logger.e('Failed to get reminders: $e');
      return [];
    }
  }

  Future<List<Reminder>> getUpcomingReminders() async {
    try {
      final now = DateTime.now();
      final reminders = _reminderBox.values
          . map((map) => Reminder.fromMap(Map<String, dynamic>. from(map)))
          .where((reminder) =>
              reminder.scheduledTime. isAfter(now) && !reminder.isTaken)
          .toList();
      return reminders;
    } catch (e) {
      logger.e('Failed to get upcoming reminders:  $e');
      return [];
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _reminderBox.put(reminder.id, reminder.toMap());
      logger.i('Reminder updated: ${reminder.medicineName}');
    } catch (e) {
      logger.e('Failed to update reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _reminderBox.delete(id);
      logger.i('Reminder deleted: $id');
    } catch (e) {
      logger.e('Failed to delete reminder: $e');
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _medicineBox.clear();
      await _reminderBox.clear();
      logger.i('All data cleared');
    } catch (e) {
      logger.e('Failed to clear data: $e');
      rethrow;
    }
  }
}