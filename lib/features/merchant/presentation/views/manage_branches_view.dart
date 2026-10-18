import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/datasource/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../../domain/entities/merchant_branch.dart';
import '../cubit/manage_branches_cubit.dart';
import '../cubit/manage_branches_state.dart';
import '../widgets/branch_form_sheet.dart';
import 'branches_args.dart';

class ManageBranchesView extends StatelessWidget {
  final BranchesArgs args;

  const ManageBranchesView({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManageBranchesCubit(
        MerchantRepositoryImpl(remoteDataSource: MerchantRemoteDataSource()),
        placeId: args.placeId,
      )..load(),
      child: Scaffold(
        backgroundColor: context.pageBackground,
        body: Column(
          children: [
            ColoredSectionHeader(
              title: 'فروع المكان',
              subtitle: args.placeName,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: context.colorScheme.onPrimary,
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: BlocConsumer<ManageBranchesCubit, ManageBranchesState>(
                listenWhen: (previous, current) =>
                    current is ManageBranchesLoaded &&
                    current.actionError != null,
                listener: (context, state) {
                  if (state is ManageBranchesLoaded &&
                      state.actionError != null) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(state.actionError!)));
                    context.read<ManageBranchesCubit>().clearActionError();
                  }
                },
                builder: (context, state) {
                  if (state is ManageBranchesLoaded) {
                    return _buildLoaded(context, state);
                  }
                  if (state is ManageBranchesError) {
                    return _buildErrorView(context, state.message);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: context.iconColor),
            context.smallSpacing.vSpace,
            message.toBody(
              context,
              color: context.textSecondary,
              textAlign: TextAlign.center,
            ),
            context.smallSpacing.vSpace,
            ElevatedButton(
              onPressed: () => context.read<ManageBranchesCubit>().load(),
              child: 'حاول تاني'.toBody(
                context,
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, ManageBranchesLoaded state) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<ManageBranchesCubit>().load(silent: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: context.pagePadding.copyWith(top: context.mediumSpacing),
            sliver: state.branches.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyBranchesState())
                : SliverList.separated(
                    itemCount: state.branches.length,
                    itemBuilder: (context, index) => _BranchCard(
                      branch: state.branches[index],
                      isSaving: state.isSaving,
                    ),
                    separatorBuilder: (_, _) => context.mediumSpacing.vSpace,
                  ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: context.pagePadding.copyWith(
                top: context.mediumSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomElevatedButton(
                    text: 'إضافة فرع جديد',
                    isLoading: state.isSaving,
                    onPressed: () {
                      if (state.branches.length >=
                          ManageBranchesCubit.maxBranches) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'وصلت للحد الأقصى: ١٠ فروع للمكان',
                              ),
                            ),
                          );
                        return;
                      }
                      showBranchFormSheet(context);
                    },
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.onPrimary,
                    height: context.buttonHeight,
                    fontWeight: FontWeight.bold,
                    borderRadius: context.largeRadius,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryPressedShadow,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  context.extraLargeSpacing.vSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final MerchantBranch branch;
  final bool isSaving;

  const _BranchCard({required this.branch, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    final phone = branch.phone;
    final googleMapsLink = branch.googleMapsLink;
    final title = branch.title;
    final description = branch.description;

    return Container(
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.mediumRadius.circularRadius,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_BranchStatusBadge(isApproved: branch.isApproved)],
          ),
          context.smallSpacing.vSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      title.toBody(
                        context,
                        fontWeight: FontWeight.w600,
                        textAlign: title.isMostlyArabic
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    if (description != null) ...[
                      if (title != null) context.smallSpacing.vSpace,
                      description.toCaption(
                        context,
                        color: context.textSecondary,
                        maxLines: 3,
                        textAlign: description.isMostlyArabic
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ],
                    if (title != null || description != null)
                      context.smallSpacing.vSpace,
                    branch.address.toBody(
                      context,
                      textAlign: branch.address.isMostlyArabic
                          ? TextAlign.right
                          : TextAlign.left,
                      maxLines: 3,
                    ),
                    if (phone != null) ...[
                      context.smallSpacing.vSpace,
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: context.smallIconSize,
                            color: context.textSecondary,
                          ),
                          context.smallSpacing.hSpace,
                          Expanded(
                            child: phone.toCaption(
                              context,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (googleMapsLink != null) ...[
                      4.vSpace,
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: context.smallIconSize,
                            color: context.textSecondary,
                          ),
                          context.smallSpacing.hSpace,
                          'خريطة'.toCaption(
                            context,
                            color: context.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              context.smallSpacing.hSpace,
              _BranchActionButton(
                icon: Icons.edit_outlined,
                semanticsLabel: 'تعديل الفرع',
                onPressed: isSaving
                    ? null
                    : () => showBranchFormSheet(context, branch: branch),
              ),
              _BranchActionButton(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                semanticsLabel: 'مسح الفرع',
                onPressed: isSaving ? null : () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<ManageBranchesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح الفرع؟'),
        content: Text(branch.address),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'مسح',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await cubit.remove(branch.id);
    }
  }
}

class _BranchStatusBadge extends StatelessWidget {
  final bool isApproved;

  const _BranchStatusBadge({required this.isApproved});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = isApproved
        ? (
            context.isDarkMode
                ? const Color(0xFF6FCF83)
                : const Color(0xFF2F6B3A),
            Icons.check_circle_rounded,
            'منشور',
          )
        : (
            context.colorScheme.primary,
            Icons.hourglass_empty_rounded,
            'قيد المراجعة',
          );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.smallSpacing,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: context.roundRadius.circularRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.smallIconSize, color: color),
          4.hSpace,
          label.toCaption(context, color: color, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}

class _BranchActionButton extends StatelessWidget {
  final IconData icon;
  final String semanticsLabel;
  final Color? color;
  final VoidCallback? onPressed;

  const _BranchActionButton({
    required this.icon,
    required this.semanticsLabel,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: IconButton(
        icon: Icon(icon, size: context.mediumIconSize),
        color: color ?? context.textSecondary,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}

class _EmptyBranchesState extends StatelessWidget {
  const _EmptyBranchesState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.extraLargeSpacing),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 48,
            color: context.iconColor,
          ),
          context.smallSpacing.vSpace,
          'لسه مفيش فروع — ضيف أول فرع'.toBody(
            context,
            color: context.textSecondary,
            textAlign: TextAlign.center,
          ),
          context.smallSpacing.vSpace,
          'الفرع بيظهر للناس بعد ما نراجعه ونوافق عليه'.toCaption(
            context,
            color: context.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
