# Responsive Refactor: Home View & More View

Remove all hardcoded/fixed size values from the Home View and More View widget trees and replace them with the project's existing extension system (`responsive_extension.dart`, `spacing_extension.dart`, `text_extension.dart`, `responsive_values.dart`, `widget_extension.dart`).

## Proposed Changes

### Extension Layer (new getters needed)

#### [MODIFY] [responsive_extension.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/core/extensions/responsive_extension.dart)

Add missing responsive getters that several widgets need but don't exist yet:

| New Getter | Purpose | Values |
|---|---|---|
| `rankBadgeSize` | Rank badge circle in `MostVisitedCard` | `isMobile ? 20.r : 24.r` |
| `bottomSheetDragHandleWidth` | Drag handle in `_SheetShell` | `isMobile ? 36.w : 44.w` |
| `bottomSheetDragHandleHeight` | Drag handle height | `4.h` |
| `cardIconContainerSize` | Icon container in `BusinessOwnerCard` | `isMobile ? 40.r : 48.r` |
| `cardIconSize` | Icon inside that container | `isMobile ? 20.r : 24.r` |
| `mostVisitedCardWidth` | Card width in horizontal list | `(screenWidth * 0.34).clamp(120, 160)` |
| `mostVisitedHeaderHeight` | Colored header area of card | `(screenHeight * 0.085).clamp(60, 90)` |
| `skeletonTitleWidth` / `skeletonTitleWidthShort` | Skeleton placeholder | responsive |
| `skeletonTextHeight` | Skeleton text bone height | `isMobile ? 10.r : 14.r` |
| `skeletonPlaceCardHeight` | Skeleton place card height | `isMobile ? 90.r : 110.r` |
| `tinyIconSize` | 13–14px icons (eye icon, arrow icon, medal icon) | `(14.r * uiScale).clamp(12, 18)` |

---

### Home Feature Widgets

#### [MODIFY] [home_header.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/widgets/home_header.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 30 | `fontSize: 24` | `fontSize: ResponsiveValues.headlineLarge(context)` |
| 40 | `const EdgeInsets.symmetric(horizontal: 14, vertical: 8)` | `EdgeInsets.symmetric(horizontal: context.smallSpacing, vertical: ResponsiveValues.spacing8)` |

---

#### [MODIFY] [home_search_bar.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/widgets/home_search_bar.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 23 | `const EdgeInsets.symmetric(horizontal: 16)` | `EdgeInsets.symmetric(horizontal: context.hSpacing)` |
| 32 | `10.hSpace` | `context.smallSpacing.hSpace` |

---

#### [MODIFY] [home_skeleton.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/widgets/home_skeleton.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 44 | `_Bone(width: 40, height: 10)` | `_Bone(width: context.smallAvatarSize, height: context.skeletonTextHeight)` |
| 52 | `_Bone(width: 110, height: 18)` | `_Bone(width: context.skeletonTitleWidth, height: context.mediumSpacing)` |
| 56 | `height: 168` | `height: context.screenHeight * 0.2` (consistent with `most_visited_section.dart`) |
| 61 | `10.hSpace` | `context.smallSpacing.hSpace` |
| 63 | `width: 132, height: 168` | `width: context.mostVisitedCardWidth, height: context.screenHeight * 0.2` |
| 69 | `_Bone(width: 90, height: 18)` | `_Bone(width: context.skeletonTitleWidthShort, height: context.mediumSpacing)` |
| 78 | `height: 96` | `height: context.skeletonPlaceCardHeight` |
| 94 | `_Bone` default `radius: 8` | `radius: context.mediumRadius` (via named param w/ new default) |

---

#### [MODIFY] [most_visited_card.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/widgets/most_visited_card.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 4 | `import flutter_screenutil` | **Remove** — no more direct `.w` calls |
| 56 | `width: 132.w` | `width: context.mostVisitedCardWidth` |
| 77 | `height: 72` | `height: context.mostVisitedHeaderHeight` |
| 101-102 | `top: 6, start: 6` | `top: ResponsiveValues.spacing4, start: ResponsiveValues.spacing4` |
| 108 | `const EdgeInsets.all(8)` | `context.cardPadding` |
| 129 | `size: 13` | `size: context.tinyIconSize` |
| 159 | `width: 22, height: 22` | `width: context.rankBadgeSize, height: context.rankBadgeSize` |
| 167 | `size: 14` (medal icon) | `size: context.tinyIconSize` |
| 171 | `fontSize: 11` | `fontSize: ResponsiveValues.labelLarge(context)` |

---

#### [MODIFY] [most_visited_section.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/widgets/most_visited_section.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 33 | `10.hSpace` | `context.smallSpacing.hSpace` |

---

#### [MODIFY] [category_grid.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/widgets/category_grid.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 91 | `6.vSpace` | Keep as-is — genuinely small fixed-purpose gap (icon-to-label) |

> No other hardcoded values found — already uses `context.largeAvatarSize`, `context.largeIconSize`, `context.smallSpacing`, `context.largeRadius`, etc.

---

### More Feature Widgets

#### [MODIFY] [business_owner_card.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/more/presentation/widgets/business_owner_card.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 2 | `import flutter_screenutil` | **Remove** |
| 26–27 | `width: 44.r, height: 44.r` | `width: context.cardIconContainerSize, height: context.cardIconContainerSize` |
| 35 | `size: 22.r` | `size: context.cardIconSize` |
| 43 | `SizedBox(height: 8.h)` | `SizedBox(height: context.smallSpacing)` (8 maps to smallSpacing on mobile) |
| 62 | `height: 52.h` | `height: context.buttonHeight` |
| 63 | `fontSize: 16.sp` | `fontSize: ResponsiveValues.titleMedium(context)` |
| 65 | `borderRadius: 12.r` | `borderRadius: context.largeRadius` |

---

#### [MODIFY] [contact_bottom_sheet.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/more/presentation/widgets/contact_bottom_sheet.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 2 | `import flutter_screenutil` | **Remove** |
| 109 | `size: 14.r` (arrow icon) | `size: context.tinyIconSize` |
| 141 | `width: 40.w` | `width: context.bottomSheetDragHandleWidth` |
| 142 | `height: 4.h` | `height: context.bottomSheetDragHandleHeight` |
| 182 | `minHeight: 44.h` | `minHeight: context.buttonHeight` |

---

#### [MODIFY] [contact_card.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/more/presentation/widgets/contact_card.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 2 | `import flutter_screenutil` | **Remove** |
| 29 | `size: 21.r` | `size: context.mediumIconSize` |
| 53 | `size: 16.r` | `size: context.smallIconSize` |

---

#### [MODIFY] [dark_mode_toggle_card.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/more/presentation/widgets/dark_mode_toggle_card.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 2 | `import flutter_screenutil` | **Remove** |
| 31 | `size: 20.r` | `size: context.mediumIconSize` |

---

#### [MODIFY] [footer.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/more/presentation/widgets/footer.dart)

| Line | Old Value | New Approach |
|---|---|---|
| 2 | `import flutter_screenutil` | **Remove** |
| 18 | `SizedBox(height: 4.h)` | `SizedBox(height: ResponsiveValues.spacing4)` |

---

### Files with no changes needed

| File | Reason |
|---|---|
| [home_view.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/views/home_view.dart) | Already fully using extension system |
| [all_places_section.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/browse/presentation/widgets/all_places_section.dart) | Already fully using extension system |
| [more_view.dart](file:///d:/Flutter/Products/La2eeha/la2eeha/lib/features/more/presentation/views/more_view.dart) | Already fully using extension system |

---

## Open Questions

> [!IMPORTANT]
> **`home_header.dart` — is this file still in use?** The `HomeView` uses `ColoredSectionHeader` directly and doesn't import `HomeHeader`. If it's dead code, should I skip it or refactor it anyway for when it's re-used?

> [!NOTE]
> **`category_grid.dart` `6.vSpace` and similar tiny gaps (2.vSpace, 4.hSpace, 6.vSpace)** — per your instructions, genuinely small fixed-purpose gaps (4–8px) that shouldn't scale are left as-is. I'll keep these unchanged.

> [!NOTE]
> **`AppTextStyles` uses `flutter_screenutil` `.sp` directly** (e.g. `14.sp`, `17.sp`) — these are in the theme layer, not in the widget files, so they're out of scope. The widget files that consume `AppTextStyles` are fine.

## Verification Plan

### Automated Tests
```bash
cd d:\Flutter\Products\La2eeha\la2eeha
flutter analyze --no-fatal-infos
```

### Manual Verification
- Visual comparison: the refactored screens should look identical on a standard phone device.
- The only observable difference should be better scaling on very small / tablet screens.
