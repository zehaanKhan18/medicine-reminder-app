import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/services/storage_service.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card. dart';
import 'add_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize storage service
    await StorageService().initialize();

    // Load medicines
    if (mounted) {
      await context.read<MedicineProvider>().loadMedicines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        elevation: 0,
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.medicines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medicine,
                    size: 80,
                    color: AppColors.primaryTeal. withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No medicines added yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first medicine to get started',
                    style: Theme.of(context).textTheme.bodyMedium?. copyWith(
                          color: AppColors.mediumGrey,
                        ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton. icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:  (_) => const AddMedicineScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medicine'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.sortedMedicines.length,
            itemBuilder: (context, index) {
              final medicine = provider.sortedMedicines[index];
              return MedicineCard(
                medicine:  medicine,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMedicineScreen(medicine: medicine),
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteDialog(context, provider, medicine. id);
                },
                onTap: () {
                  // Show medicine details
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMedicineScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    MedicineProvider provider,
    String medicineId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: const Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMedicine(medicineId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}