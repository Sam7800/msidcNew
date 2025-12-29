import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/review_section.dart';

/// Provider for managing which cards are currently expanded in the Review screen
///
/// Stores a Set of component IDs (strings) that are currently in expanded state
/// Example: {'aa', 'dpr', 'milestone_1'}
final reviewExpandedCardsProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for managing the currently selected section filter
///
/// Determines which components are visible in the grid
/// - ReviewSection.all: Show all components
/// - ReviewSection.dpr: Show only DPR components
/// - ReviewSection.work: Show only Work components
/// - ReviewSection.pms: Show only PMS components
final reviewSectionFilterProvider =
    StateProvider<ReviewSection>((ref) => ReviewSection.all);

/// Provider for tracking which card is currently being hovered
///
/// Stores the component ID of the hovered card, or null if no card is hovered
/// Used to show hover preview tooltip
final reviewHoverCardProvider = StateProvider<String?>((ref) => null);

/// Helper function to toggle a card's expansion state
///
/// Usage in widget:
/// ```dart
/// onTap: () => toggleCardExpansion(ref, cardId);
/// ```
void toggleCardExpansion(WidgetRef ref, String cardId) {
  final current = ref.read(reviewExpandedCardsProvider);
  final updated = Set<String>.from(current);

  if (updated.contains(cardId)) {
    updated.remove(cardId);
  } else {
    updated.add(cardId);
  }

  ref.read(reviewExpandedCardsProvider.notifier).state = updated;
}

/// Helper function to collapse all cards
///
/// Usage in widget:
/// ```dart
/// onPressed: () => collapseAllCards(ref);
/// ```
void collapseAllCards(WidgetRef ref) {
  ref.read(reviewExpandedCardsProvider.notifier).state = {};
}

/// Helper function to check if a card is expanded
///
/// Usage in widget:
/// ```dart
/// final isExpanded = isCardExpanded(ref, cardId);
/// ```
bool isCardExpanded(WidgetRef ref, String cardId) {
  final expandedCards = ref.watch(reviewExpandedCardsProvider);
  return expandedCards.contains(cardId);
}
