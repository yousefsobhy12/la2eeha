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
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _Bone(
              width: double.infinity,
              height: double.infinity,
              radius: context.largeRadius,
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
