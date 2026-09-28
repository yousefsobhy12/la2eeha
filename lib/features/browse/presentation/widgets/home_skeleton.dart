// lib/features/browse/presentation/widgets/home_skeleton.dart
//
// ✅ بديل الـ CircularProgressIndicator العادي — شكل هيكلي (skeleton) بيلمع
// وقت التحميل، بيستخدم shimmerLoop() الجاهزة أصلاً في animation_extension.dart
// (مفيش package جديد). مبيغطيش الهيدر — الهيدر الملون (ColoredSectionHeader)
// ثابت برّه الـ BlocBuilder وبيبان فورًا.

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: context.pagePadding.copyWith(top: context.vSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(
            width: double.infinity,
            height: context.textFieldHeight,
            radius: 999,
          ),
          context.largeSpacing.vSpace,
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: context.smallSpacing,
            crossAxisSpacing: context.smallSpacing,
            childAspectRatio: context.categoryGridAspectRatio,
            children: List.generate(
              8,
              (_) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Bone(
                    width: context.largeAvatarSize,
                    height: context.largeAvatarSize,
                    radius: context.largeRadius,
                  ),
                  6.vSpace,
                  _Bone(
                    width: context.smallAvatarSize,
                    height: context.skeletonTextHeight,
                  ),
                ],
              ),
            ),
          ),
          context.largeSpacing.vSpace,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _Bone(
              width: context.skeletonTitleWidth,
              height: context.mediumSpacing,
            ),
          ),
          context.smallSpacing.vSpace,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) context.smallSpacing.hSpace,
                  _Bone(
                    width: context.mostVisitedCardWidth,
                    height:
                        context.mostVisitedHeaderHeight +
                        context.cardPadding.vertical +
                        context.mediumSpacing * 3,
                    radius: context.mediumRadius,
                  ),
                ],
              ],
            ),
          ),
          context.largeSpacing.vSpace,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _Bone(
              width: context.skeletonTitleWidthShort,
              height: context.mediumSpacing,
            ),
          ),
          context.smallSpacing.vSpace,
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: context.smallSpacing),
              child: _Bone(
                width: double.infinity,
                height: context.skeletonPlaceCardHeight,
                radius: context.mediumRadius,
              ),
            ),
          ),
        ],
      ),
    ).shimmerLoop();
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Bone({
    required this.width,
    required this.height,
    this.radius = 8,
  }); // radius default is overridden at call sites

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.borderColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
