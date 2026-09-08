/// Utility extension for consistent, error-free mastery score formatting across SkillTwin.
/// Backend stores mastery scores and delta on a 0.0 to 100.0 scale (e.g. 70.0 for 70%).
/// This extension safely handles both 0.0 - 1.0 fractions and 0.0 - 100.0 percentages.
extension MasteryScoreFormat on num? {
  /// Converts a mastery or confidence score to a clean percentage integer (0 - 100).
  /// E.g.:
  ///   70.0 -> 70%
  ///   0.70 -> 70%
  ///   93.2 -> 93%
  ///   100.0 -> 100%
  ///   7000.0 -> 100% (safely clamped)
  int get toMasteryPercentage {
    if (this == null || this! <= 0) return 0;
    final val = this!;
    if (val <= 1.0) return (val * 100).round().clamp(0, 100);
    return val.round().clamp(0, 100);
  }

  /// Converts a mastery or confidence score to a 0.0 - 1.0 fraction for ProgressIndicators.
  /// E.g.:
  ///   70.0 -> 0.7
  ///   0.70 -> 0.7
  ///   100.0 -> 1.0
  double get toMasteryFraction {
    if (this == null || this! <= 0) return 0.0;
    final val = this!;
    if (val <= 1.0) return val.toDouble().clamp(0.0, 1.0);
    return (val / 100.0).clamp(0.0, 1.0);
  }

  /// Formats a mastery delta change string with sign and clean decimals.
  /// E.g.:
  ///   7.5  -> "+7.5%"
  ///   0.12 -> "+12%"
  ///   -3.0 -> "-3%"
  ///   0.0  -> "+0%"
  String get toMasteryDeltaString {
    if (this == null) return '+0%';
    final val = this!;
    final double deltaVal =
        val.abs() <= 1.0 && val != 0 ? val * 100 : val.toDouble();
    final sign = deltaVal > 0 ? '+' : (deltaVal < 0 ? '-' : '+');
    final absVal = deltaVal.abs();
    final formattedNum =
        absVal.toStringAsFixed(absVal % 1 == 0 ? 0 : 1);
    return '$sign$formattedNum%';
  }
}
