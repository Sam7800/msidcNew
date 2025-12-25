import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/repositories/category_repository.dart';
import '../../core/database/repositories/project_repository.dart';
import '../../core/database/repositories/dpr_repository.dart';
import '../../core/database/repositories/work_repository.dart';
import '../../core/database/repositories/monitoring_repository.dart';
import '../../core/database/repositories/work_entry_repository.dart';

/// Database Helper Provider (Singleton)
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// Category Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryRepository(dbHelper);
});

/// Project Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return ProjectRepository(dbHelper);
});

/// DPR Repository Provider
final dprRepositoryProvider = Provider<DPRRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return DPRRepository(dbHelper);
});

/// Work Repository Provider
final workRepositoryProvider = Provider<WorkRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkRepository(dbHelper);
});

/// Monitoring Repository Provider
final monitoringRepositoryProvider = Provider<MonitoringRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return MonitoringRepository(dbHelper);
});

/// Work Entry Repository Provider
final workEntryRepositoryProvider = Provider<WorkEntryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkEntryRepository(dbHelper);
});
