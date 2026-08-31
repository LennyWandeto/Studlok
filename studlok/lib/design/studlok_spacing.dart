/// Spacing scale — formalizes the values already used ad hoc throughout the
/// app (SizedBox(height: 8/12/16/24/32), EdgeInsets.all(24)) rather than
/// inventing a new one. New screens should reach for these tokens instead
/// of magic numbers.
class StudlokSpacing {
  StudlokSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}
