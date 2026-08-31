/// Deterministic effort estimate, compared within the same technique tier.
/// Search cost measures scarce single-placement choices, not human solve time.
final class const DifficultyRating({
  final int techniqueCost = 0,
  final int searchCost = 0,
  final int bottlenecks = 0,
  final int steps = 0,
}) {
  int get score => techniqueCost + searchCost;

  Map<String, Object?> toJson() => {
    'version': 1,
    'techniqueCost': techniqueCost,
    'searchCost': searchCost,
    'bottlenecks': bottlenecks,
    'steps': steps,
  };

  factory fromJson(Map<String, Object?> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unsupported difficulty rating');
    }
    int read(String key) {
      final value = json[key];
      if (value is! int || value < 0) {
        throw const FormatException('Invalid difficulty rating');
      }
      return value;
    }

    return DifficultyRating(
      techniqueCost: read('techniqueCost'),
      searchCost: read('searchCost'),
      bottlenecks: read('bottlenecks'),
      steps: read('steps'),
    );
  }
}
