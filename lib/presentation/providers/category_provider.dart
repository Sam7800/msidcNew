import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../core/database/repositories/category_repository.dart';
import 'repository_providers.dart';

/// Category State
class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Category Notifier
class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(const CategoryState());

  /// Load all categories
  Future<void> loadAllCategories({bool includeInactive = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _repository.getAllCategories(
        includeInactive: includeInactive,
      );
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      return await _repository.getCategoryById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Add category
  Future<bool> addCategory(Category category) async {
    try {
      await _repository.insertCategory(category);
      await loadAllCategories(); // Reload
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update category
  Future<bool> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);
      await loadAllCategories(); // Reload
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete category (soft delete)
  Future<bool> deleteCategory(int id) async {
    try {
      await _repository.deleteCategory(id);
      await loadAllCategories(); // Reload
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Category Provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

/// Categories with project counts provider
final categoriesWithCountsProvider = FutureProvider<Map<Category, int>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategoriesWithCounts();
});

/// Single category provider (by ID)
final singleCategoryProvider = FutureProvider.family<Category?, int>((ref, id) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategoryById(id);
});
