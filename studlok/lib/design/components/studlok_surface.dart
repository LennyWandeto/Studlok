import 'package:flutter/material.dart';

import '../studlok_colors.dart';
import '../studlok_radius.dart';

enum StudlokSurfaceTier { card, elevated }

/// The app's layered-elevation surface — depth via a stepped-lighter fill
/// rather than shadows, which barely read against a dark background anyway.
///
/// Backed by [Material], not a plain [Container]: a ListTile/InkWell child
/// paints its background and ink splashes on the nearest Material ancestor,
/// so a colored, non-Material box in between (as a Container would be)
/// silently swallows those effects.
class StudlokSurface extends StatelessWidget {
  const StudlokSurface({
    super.key,
    required this.child,
    this.tier = StudlokSurfaceTier.card,
    this.padding = const EdgeInsets.all(16),
    this.radius,
  });

  final Widget child;
  final StudlokSurfaceTier tier;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tier == StudlokSurfaceTier.card ? StudlokColors.surface : StudlokColors.surfaceElevated,
      borderRadius: radius ?? StudlokRadius.cardRadius,
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}
