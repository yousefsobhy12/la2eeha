import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  double get usableWidth => screenWidth - safeAreaPadding.horizontal;

  double get usableHeight => screenHeight - safeAreaPadding.vertical;

  bool get isSmallPhone => screenWidth < 360;

  bool get isMobile => screenWidth >= 360 && screenWidth < 600;

  bool get isLargeMobile => screenWidth >= 600 && screenWidth < 768;

  bool get isTablet => screenWidth >= 768 && screenWidth < 1024;

  bool get isLargeTablet => screenWidth >= 1024 && screenWidth < 1200;

  bool get isDesktop => screenWidth >= 1200;

  bool get isMobileOrSmallTablet => screenWidth < 768;

  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  double get topSafeArea => MediaQuery.of(this).padding.top;

  double get bottomSafeArea => MediaQuery.of(this).padding.bottom;

  double get rightSafeArea => MediaQuery.of(this).padding.right;

  double get leftSafeArea => MediaQuery.of(this).padding.left;

  EdgeInsets get pagePadding {
    if (isSmallPhone) return EdgeInsets.symmetric(horizontal: 12.w);
    if (isMobile) return EdgeInsets.symmetric(horizontal: 16.w);
    if (isTablet) return EdgeInsets.symmetric(horizontal: 24.w);
    return EdgeInsets.symmetric(horizontal: 32.w);
  }

  EdgeInsets get cardPadding {
    if (isSmallPhone) return EdgeInsets.all(8.r);
    if (isMobile) return EdgeInsets.all(12.r);
    return EdgeInsets.all(16.r);
  }

  EdgeInsets get dialogPadding {
    if (isMobile) return EdgeInsets.all(16.r);
    return EdgeInsets.all(24.r);
  }

  EdgeInsets get bottomSheetPadding {
    return EdgeInsets.only(
      left: pagePadding.left,
      right: pagePadding.right,
      top: 16.h,
      bottom: bottomSafeArea + 16.h,
    );
  }

  double get vSpacing {
    if (isSmallPhone) return 12.h;
    if (isMobile) return 16.h;
    return 24.h;
  }

  double get hSpacing {
    if (isSmallPhone) return 12.w;
    if (isMobile) return 16.w;
    return 24.w;
  }

  double get smallSpacing => isMobile ? 8.r : 12.r;

  double get mediumSpacing => isMobile ? 16.r : 24.r;

  double get largeSpacing => isMobile ? 24.r : 32.r;

  double get extraLargeSpacing => isMobile ? 32.r : 48.r;

  int get gridColumns {
    if (isSmallPhone) return 1;
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }

  double get gridSpacing => isMobile ? 12.r : 16.r;

  double get gridAspectRatio {
    if (isMobile) return 0.75;
    if (isTablet) return 0.85;
    return 1.0;
  }

  int get categoryGridColumns {
    if (isSmallPhone) return 3;
    if (isMobile) return 4;
    if (isLargeMobile) return 5;
    return 6;
  }

  double get categoryGridAspectRatio {
    if (isSmallPhone) return 0.80;
    if (isMobile) return 0.85;
    if (isLargeMobile) return 0.90;
    return 0.95;
  }

  double get fontScale {
    if (isSmallPhone) return 0.85;
    if (isMobile) return 1.0;
    if (isTablet) return 1.1;
    return 1.15;
  }

  double get uiScale {
    if (isSmallPhone) return 0.9;
    if (isMobile) return 1.0;
    return 1.1;
  }

  double get smallIconSize => (16.r * uiScale).clamp(14, 20);

  double get mediumIconSize => (20.r * uiScale).clamp(18, 24);

  double get largeIconSize => (24.r * uiScale).clamp(22, 28);

  double get smallAvatarSize => (32.r * uiScale).clamp(28, 40);

  double get mediumAvatarSize => (48.r * uiScale).clamp(40, 56);

  double get largeAvatarSize => (64.r * uiScale).clamp(56, 72);

  double get buttonHeight => isMobile ? 48.h : 56.h;

  double get textFieldHeight => isMobile ? 48.h : 52.h;

  double get smallRadius => 4.r;

  double get mediumRadius => 8.r;

  double get largeRadius => 12.r;

  double get extraLargeRadius => 16.r;

  double get roundRadius => 24.r;

  double get maxContentWidth => isTablet ? 600.w : double.infinity;

  double get maxDialogWidth => isMobile ? screenWidth * 0.9 : 400.w;

  double get maxBottomSheetWidth => isTablet ? 600.w : double.infinity;

  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  double get tinyIconSize => (14.r * uiScale).clamp(12, 18);

  double get rankBadgeSize {
    if (isSmallPhone) return 18.r;
    if (isMobile) return 20.r;
    return 24.r;
  }

  double get cardIconContainerSize {
    if (isSmallPhone) return 36.r;
    if (isMobile) return 40.r;
    return 48.r;
  }

  double get cardIconSize {
    if (isSmallPhone) return 18.r;
    if (isMobile) return 20.r;
    return 24.r;
  }

  double get mostVisitedCardWidth {
    if (isSmallPhone) return 120.w;
    if (isMobile) return 140.w;
    if (isLargeMobile) return 160.w;
    return 180.w;
  }

  double get mostVisitedCarouselHeight {
    if (isSmallPhone) return 190.h;
    if (isMobile) return 180.h;
    if (isLargeMobile) return 230.h;
    return 250.h;
  }

  double get mostVisitedHeaderHeight => (screenHeight * 0.085).clamp(60, 90);

  double get mostVisitedTitleHeight {
    final fontSize = (14.sp * fontScale).clamp(12.sp, 16.sp);
    return fontSize * 1.3 * 2;
  }

  double get bottomSheetDragHandleWidth {
    if (isSmallPhone) return 32.w;
    if (isMobile) return 36.w;
    return 44.w;
  }

  double get bottomSheetDragHandleHeight => 4.h;

  double get skeletonTitleWidth {
    if (isSmallPhone) return 90.w;
    if (isMobile) return 110.w;
    return 130.w;
  }

  double get skeletonTitleWidthShort {
    if (isSmallPhone) return 70.w;
    if (isMobile) return 90.w;
    return 110.w;
  }

  double get skeletonTextHeight {
    if (isSmallPhone) return 8.r;
    if (isMobile) return 10.r;
    return 14.r;
  }

  double get skeletonPlaceCardHeight {
    if (isSmallPhone) return 80.r;
    if (isMobile) return 90.r;
    return 110.r;
  }
}
