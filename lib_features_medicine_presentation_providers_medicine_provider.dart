import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/models/medicine.dart';
import '../../../../shared/services/storage_service.dart';

class MedicineProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String?  get error => _error;

  List<Medicine> get sortedMedicines {
    final sorted = List<Medicine>.from(_medicines);
    sorted.sort((a, b) {
      if (a.times.isEmpty || b.times.isEmpty) return 0;
      final aTime = a.times.first;
      final bTime = b. times.first;
      return aTime.compareTo(bTime);
    });
    return sorted;
  }

  Future<void> loadMedicines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _medicines = await _storageService. getAllMedicines();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> times,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final medicine = Medicine(
        id: const Uuid().v4(),
        name: name,
        dosage: dosage,
        frequency:  frequency,
        description: description,
        times: times,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _storageService.saveMedicine(medicine);
      _medicines.add(medicine);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMedicine({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required List<String> times,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final medicine = Medicine(
        id: id,
        name: name,
        dosage: dosage,
        frequency: frequency,
        description: description,
        times: times,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _storageService.updateMedicine(medicine);
      final index = _medicines.indexWhere((m) => m.id == id);
      if (index != -1) {
        _medicines[index] = medicine;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedicine(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _storageService. deleteMedicine(id);
      _medicines.removeWhere((m) => m.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleMedicineActive(String id) async {
    try {
      final index = _medicines.indexWhere((m) => m.id == id);
      if (index != -1) {
        final medicine = _medicines[index];
        final updated = medicine.copyWith(isActive: !medicine.isActive);
        await _storageService.updateMedicine(updated);
        _medicines[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}