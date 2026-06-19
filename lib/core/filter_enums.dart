/// Enums for the advanced filter and sort feature (JP's individual feature).
library filter_enums;

/// Filter items by their checked/purchased status.
enum ItemStatusFilter {
  /// Show all items regardless of status.
  all,

  /// Show only items that have been checked/purchased.
  checked,

  /// Show only items that are still pending (not checked).
  unchecked,
}

/// Sort items by a specific field and direction.
enum ItemSortMode {
  /// No explicit sorting — items appear in their original order from the API.
  none,

  /// Sort by description/name ascending (A → Z).
  nameAsc,

  /// Sort by description/name descending (Z → A).
  nameDesc,

  /// Sort by unit price ascending (cheapest first).
  priceAsc,

  /// Sort by unit price descending (most expensive first).
  priceDesc,

  /// Sort by total value (quantity × price) ascending.
  totalAsc,

  /// Sort by total value (quantity × price) descending.
  totalDesc,
}
