// lib/features/browse/presentation/widgets/home_skeleton.dart
//
// ✅ بديل الـ CircularProgressIndicator العادي — شكل هيكلي (skeleton) بيلمع
// وقت التحميل، بيستخدم shimmerLoop() الجاهزة أصلاً في animation_extension.dart
// (مفيش package جديد). مبيغطيش الهيدر — الهيدر الملون (ColoredSectionHeader)
// ثابت برّه الـ BlocBuilder وبيبان فورًا.

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';

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
          _Bone(width: double.infinity, height: context.textFieldHeight, radius: 999),
          context.largeSpacing.vSpace,
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: context.smallSpacing,
            crossAxisSpacing: context.smallSpacing,
            childAspectRatio: 0.85,
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
                  _Bone(width: 40, height: 10),
                ],
              ),
            ),
          ),
          context.largeSpacing.vSpace,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _Bone(width: 110, height: 18),
          ),
          context.smallSpacing.vSpace,
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => 10.hSpace,
              itemBuilder: (_, __) =>
                  _Bone(width: 132, height: 168, radius: context.mediumRadius),
            ),
          ),
          context.largeSpacing.vSpace,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _Bone(width: 90, height: 18),
          ),
          context.smallSpacing.vSpace,
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: context.smallSpacing),
              child: _Bone(
                width: double.infinity,
                height: 96,
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

  const _Bone({required this.width, required this.height, this.radius = 8});

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
