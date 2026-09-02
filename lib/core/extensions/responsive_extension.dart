// lib/core/extensions/responsive_extension.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ResponsiveContext on BuildContext {
  // ════════════════════════════════════════════════════════════
  // SCREEN DIMENSIONS
  // ════════════════════════════════════════════════════════════

  /// عرض الشاشة الكامل
  double get screenWidth => MediaQuery.of(this).size.width;

  /// ارتفاع الشاشة الكامل
  double get screenHeight => MediaQuery.of(this).size.height;

  /// عرض الشاشة بدون safe area
  double get usableWidth => screenWidth - safeAreaPadding.horizontal;

  /// ارتفاع الشاشة بدون safe area
  double get usableHeight => screenHeight - safeAreaPadding.vertical;

  // ════════════════════════════════════════════════════════════
  // DEVICE TYPE DETECTION
  // ════════════════════════════════════════════════════════════

  /// موبايل صغير (< 360)
  bool get isSmallPhone => screenWidth < 360;

  /// موبايل عادي (360 - 600)
  bool get isMobile => screenWidth >= 360 && screenWidth < 600;

  /// موبايل كبير أو تابلت صغير (600 - 768)
  bool get isLargeMobile => screenWidth >= 600 && screenWidth < 768;

  /// تابلت (768 - 1024)
  bool get isTablet => screenWidth >= 768 && screenWidth < 1024;

  /// تابلت كبير (1024 - 1200)
  bool get isLargeTablet => screenWidth >= 1024 && screenWidth < 1200;

  /// ديسكتوب (>= 1200)
  bool get isDesktop => screenWidth >= 1200;

  /// موبايل أو تابلت صغير
  bool get isMobileOrSmallTablet => screenWidth < 768;

  // ════════════════════════════════════════════════════════════
  // ORIENTATION
  // ════════════════════════════════════════════════════════════

  /// الشاشة عمودية
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// الشاشة أفقية
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  // ════════════════════════════════════════════════════════════
  // SAFE AREA
  // ════════════════════════════════════════════════════════════

  /// الـ padding الآمن (notch, status bar, navigation bar)
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// المسافة من أعلى (status bar)
  double get topSafeArea => MediaQuery.of(this).padding.top;

  /// المسافة من أسفل (navigation bar)
  double get bottomSafeArea => MediaQuery.of(this).padding.bottom;

  /// المسافة من اليمين
  double get rightSafeArea => MediaQuery.of(this).padding.right;

  /// المسافة من اليسار
  double get leftSafeArea => MediaQuery.of(this).padding.left;

  // ════════════════════════════════════════════════════════════
  // RESPONSIVE PADDING (Design System)
  // ════════════════════════════════════════════════════════════

  /// Padding للصفحات (Pages)
  EdgeInsets get pagePadding {
    if (isSmallPhone) return EdgeInsets.symmetric(horizontal: 12.w);
    if (isMobile) return EdgeInsets.symmetric(horizontal: 16.w);
    if (isTablet) return EdgeInsets.symmetric(horizontal: 24.w);
    return EdgeInsets.symmetric(horizontal: 32.w);
  }

  /// Padding للـ Cards
  EdgeInsets get cardPadding {
    if (isSmallPhone) return EdgeInsets.all(8.r);
    if (isMobile) return EdgeInsets.all(12.r);
    return EdgeInsets.all(16.r);
  }

  /// Padding للـ Dialogs
  EdgeInsets get dialogPadding {
    if (isMobile) return EdgeInsets.all(16.r);
    return EdgeInsets.all(24.r);
  }

  /// Padding للـ Bottom Sheets
  EdgeInsets get bottomSheetPadding {
    return EdgeInsets.only(
      left: pagePadding.left,
      right: pagePadding.right,
      top: 16.h,
      bottom: bottomSafeArea + 16.h,
    );
  }

  // ════════════════════════════════════════════════════════════
  // RESPONSIVE SPACING
  // ════════════════════════════════════════════════════════════

  /// المسافة العمودية بين العناصر
  double get vSpacing {
    if (isSmallPhone) return 12.h;
    if (isMobile) return 16.h;
    return 24.h;
  }

  /// المسافة الأفقية بين العناصر
  double get hSpacing {
    if (isSmallPhone) return 12.w;
    if (isMobile) return 16.w;
    return 24.w;
  }

  /// مسافة صغيرة
  double get smallSpacing => isMobile ? 8.r : 12.r;

  /// مسافة متوسطة
  double get mediumSpacing => isMobile ? 16.r : 24.r;

  /// مسافة كبيرة
  double get largeSpacing => isMobile ? 24.r : 32.r;

  /// مسافة كبيرة جداً
  double get extraLargeSpacing => isMobile ? 32.r : 48.r;

  // ════════════════════════════════════════════════════════════
  // GRID & COLUMNS
  // ════════════════════════════════════════════════════════════

  /// عدد الأعمدة في الـ Grid
  int get gridColumns {
    if (isSmallPhone) return 1;
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }

  /// المسافة بين عناصر الـ Grid
  double get gridSpacing => isMobile ? 12.r : 16.r;

  /// نسبة العرض للارتفاع للـ Grid Items
  double get gridAspectRatio {
    if (isMobile) return 0.75;
    if (isTablet) return 0.85;
    return 1.0;
  }

  /// عدد أعمدة شبكة الكاتيجوري (HomeView)
  int get categoryGridColumns {
    if (isSmallPhone) return 3;
    if (isMobile) return 4;
    if (isLargeMobile) return 5;
    return 6; // tablet, largeTablet, desktop
  }

  /// نسبة العرض للارتفاع لبلاط الكاتيجوري (أيقونة + تسمية)
  double get categoryGridAspectRatio {
    if (isSmallPhone) return 0.80;
    if (isMobile) return 0.85;
    if (isLargeMobile) return 0.90;
    return 0.95; // tablet+
  }

  // ════════════════════════════════════════════════════════════
  // FONT SCALE (للنصوص)
  // ════════════════════════════════════════════════════════════

  /// معامل تكبير/تصغير الخطوط
  double get fontScale {
    if (isSmallPhone) return 0.85;
    if (isMobile) return 1.0;
    if (isTablet) return 1.1;
    return 1.15;
  }

  /// معامل تكبير/تصغير عناصر الـ UI
  double get uiScale {
    if (isSmallPhone) return 0.9;
    if (isMobile) return 1.0;
    return 1.1;
  }

  // ════════════════════════════════════════════════════════════
  // RESPONSIVE SIZES
  // ════════════════════════════════════════════════════════════

  /// حجم الـ Icon الصغير
  double get smallIconSize => (16.r * uiScale).clamp(14, 20);

  /// حجم الـ Icon المتوسط
  double get mediumIconSize => (20.r * uiScale).clamp(18, 24);

  /// حجم الـ Icon الكبير
  double get largeIconSize => (24.r * uiScale).clamp(22, 28);

  /// حجم الـ Avatar الصغير
  double get smallAvatarSize => (32.r * uiScale).clamp(28, 40);

  /// حجم الـ Avatar المتوسط
  double get mediumAvatarSize => (48.r * uiScale).clamp(40, 56);

  /// حجم الـ Avatar الكبير
  double get largeAvatarSize => (64.r * uiScale).clamp(56, 72);

  /// ارتفاع الـ Button
  double get buttonHeight => isMobile ? 48.h : 56.h;

  /// ارتفاع الـ TextField
  double get textFieldHeight => isMobile ? 48.h : 52.h;

  // ════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ════════════════════════════════════════════════════════════

  /// Border radius صغير
  double get smallRadius => 4.r;

  /// Border radius متوسط
  double get mediumRadius => 8.r;

  /// Border radius كبير
  double get largeRadius => 12.r;

  /// Border radius كبير جداً
  double get extraLargeRadius => 16.r;

  /// Border radius دائري
  double get roundRadius => 24.r;

  // ════════════════════════════════════════════════════════════
  // MAX WIDTH (للتحكم في العرض على الشاشات الكبيرة)
  // ════════════════════════════════════════════════════════════

  /// أقصى عرض للمحتوى على التابلت
  double get maxContentWidth => isTablet ? 600.w : double.infinity;

  /// أقصى عرض للـ Dialogs
  double get maxDialogWidth => isMobile ? screenWidth * 0.9 : 400.w;

  /// أقصى عرض للـ Bottom Sheets
  double get maxBottomSheetWidth => isTablet ? 600.w : double.infinity;

  // ════════════════════════════════════════════════════════════
  // KEYBOARD
  // ════════════════════════════════════════════════════════════

  /// الكيبورد مفتوح؟
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  /// ارتفاع الكيبورد
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  // ════════════════════════════════════════════════════════════
  // COMPONENT-SPECIFIC SIZES
  // ════════════════════════════════════════════════════════════

  /// حجم الـ Icon الصغير جداً (13–14px range)
  double get tinyIconSize => (14.r * uiScale).clamp(12, 18);

  /// حجم بادج الترتيب (MostVisitedCard)
  double get rankBadgeSize {
    if (isSmallPhone) return 18.r;
    if (isMobile) return 20.r;
    return 24.r;
  }

  /// حجم حاوية الأيقونة في الكروت (BusinessOwnerCard)
  double get cardIconContainerSize {
    if (isSmallPhone) return 36.r;
    if (isMobile) return 40.r;
    return 48.r;
  }

  /// حجم الأيقونة داخل حاوية الكروت
  double get cardIconSize {
    if (isSmallPhone) return 18.r;
    if (isMobile) return 20.r;
    return 24.r;
  }

  /// عرض كارت الأكثر زيارة (horizontal list)
  double get mostVisitedCardWidth {
    if (isSmallPhone) return 120.w;
    if (isMobile) return 140.w;
    if (isLargeMobile) return 160.w;
    return 180.w; // tablet+
  }

  /// ارتفاع كاروسيل الأكثر زيارة (عشان الـ horizontal ListView يحتاج ارتفاع صريح)
  double get mostVisitedCarouselHeight {
    if (isSmallPhone) return 190.h;
    if (isMobile) return 180.h;
    if (isLargeMobile) return 230.h;
    return 250.h; // tablet+
  }

  /// ارتفاع هيدر كارت الأكثر زيارة
  double get mostVisitedHeaderHeight => (screenHeight * 0.085).clamp(60, 90);

  /// ارتفاع ثابت لعنوان كارت الأكثر زيارة (يحجز مساحة سطرين دايمًا)
  double get mostVisitedTitleHeight {
    final fontSize = (14.sp * fontScale).clamp(12.sp, 16.sp);
    return fontSize * 1.3 * 2; // line-height factor × 2 lines
  }

  // ════════════════════════════════════════════════════════════
  // BOTTOM SHEET
  // ════════════════════════════════════════════════════════════

  /// عرض مقبض السحب في Bottom Sheet
  double get bottomSheetDragHandleWidth {
    if (isSmallPhone) return 32.w;
    if (isMobile) return 36.w;
    return 44.w;
  }

  /// ارتفاع مقبض السحب في Bottom Sheet
  double get bottomSheetDragHandleHeight => 4.h;

  // ════════════════════════════════════════════════════════════
  // SKELETON PLACEHOLDER SIZES
  // ════════════════════════════════════════════════════════════

  /// عرض عظمة عنوان السكيليتون
  double get skeletonTitleWidth {
    if (isSmallPhone) return 90.w;
    if (isMobile) return 110.w;
    return 130.w;
  }

  /// عرض عظمة عنوان السكيليتون القصير
  double get skeletonTitleWidthShort {
    if (isSmallPhone) return 70.w;
    if (isMobile) return 90.w;
    return 110.w;
  }

  /// ارتفاع عظمة النص في السكيليتون
  double get skeletonTextHeight {
    if (isSmallPhone) return 8.r;
    if (isMobile) return 10.r;
    return 14.r;
  }

  /// ارتفاع عظمة كارت المكان في السكيليتون
  double get skeletonPlaceCardHeight {
    if (isSmallPhone) return 80.r;
    if (isMobile) return 90.r;
    return 110.r;
  }
}
