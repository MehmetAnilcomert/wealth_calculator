import 'package:flutter/material.dart';

/// This class defines padding values specific to product-related UI components.
class ProductPadding extends EdgeInsets {
  const ProductPadding._() : super.all(0);

  /// Padding for product cards.
  ///
  /// [ProductPadding.allSmall] is 8.0 on all sides.
  const ProductPadding.allSmall() : super.all(8);

  /// [ProductPadding.allMedium] is 16.0 on all sides.
  const ProductPadding.allMedium() : super.all(16);

  /// [ProductPadding.allNormal] is 24.0 on all sides.
  const ProductPadding.allNormal() : super.all(24);

  /// [ProductPadding.allLarge] is 32.0 on all sides.
  const ProductPadding.allLarge() : super.all(32);

  /// [ProductPadding.symmetricHorizontalSmall] is 8.0 horizontally and 0.0 vertically.
  const ProductPadding.symmetricHorizontalSmall()
      : super.symmetric(horizontal: 8, vertical: 0);

  /// [ProductPadding.symmetricHorizontalMedium] is 16.0 horizontally and 0.0 vertically.
  const ProductPadding.symmetricHorizontalMedium()
      : super.symmetric(horizontal: 16, vertical: 0);

  /// [ProductPadding.symmetricHorizontalNormal] is 24.0 horizontally and 0.0 vertically.
  const ProductPadding.symmetricHorizontalNormal()
      : super.symmetric(horizontal: 24, vertical: 0);

  /// [ProductPadding.symmetricHorizontalLarge] is 32.0 horizontally and 0.0 vertically.
  const ProductPadding.symmetricHorizontalLarge()
      : super.symmetric(horizontal: 32, vertical: 0);

  /// [ProductPadding.symmetricVerticalSmall] is 0.0 horizontally and 8.0 vertically.
  const ProductPadding.symmetricVerticalSmall()
      : super.symmetric(horizontal: 0, vertical: 8);

  /// [ProductPadding.symmetricVerticalMedium] is 0.0 horizontally and 16.0 vertically.
  const ProductPadding.symmetricVerticalMedium()
      : super.symmetric(horizontal: 0, vertical: 16);

  /// [ProductPadding.symmetricVerticalNormal] is 0.0 horizontally and 24.0 vertically.
  const ProductPadding.symmetricVerticalNormal()
      : super.symmetric(horizontal: 0, vertical: 24);

  /// [ProductPadding.symmetricVerticalLarge] is 0.0 horizontally and 32.0 vertically.
  const ProductPadding.symmetricVerticalLarge()
      : super.symmetric(horizontal: 0, vertical: 32);

  /// [ProductPadding.onlyTopNormal] is 24.0 on the top side.
  const ProductPadding.onlyTopNormal() : super.only(top: 24);

  /// [ProductPadding.onlyBottomNormal] is 24.0 on the bottom side.
  const ProductPadding.onlyBottomNormal() : super.only(bottom: 24);

  /// [ProductPadding.onlyLeftNormal] is 24.0 on the left side.
  const ProductPadding.onlyLeftNormal() : super.only(left: 24);

  /// [ProductPadding.onlyRightNormal] is 24.0 on the right side.
  const ProductPadding.onlyRightNormal() : super.only(right: 24);
}
