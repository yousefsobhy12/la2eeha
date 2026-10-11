import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_txt_form_field.dart';
import '../../../browse/data/datasource/places_remote_datasource.dart';
import '../../../browse/data/repositories/places_repository_impl.dart';
import '../../data/datasource/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../../domain/entities/sports_pricing_draft.dart';
import '../cubit/sports_pricing_cubit.dart';
import '../cubit/sports_pricing_state.dart';
import '../widgets/approval_banner.dart';
import '../widgets/pending_changes_banner.dart';
import '../widgets/unsaved_changes_bar.dart';
import 'pricing_args.dart';

class SportsPricingView extends StatelessWidget {
  final PricingArgs args;

  const SportsPricingView({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SportsPricingCubit(
        MerchantRepositoryImpl(remoteDataSource: MerchantRemoteDataSource()),
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
        placeId: args.placeId,
        placeName: args.placeName,
      )..loadSportsPricing(),
      child: _SportsPricingViewBody(placeName: args.placeName),
    );
  }
}

class _SportsPricingViewBody extends StatefulWidget {
  final String placeName;

  const _SportsPricingViewBody({required this.placeName});

  @override
  State<_SportsPricingViewBody> createState() => _SportsPricingViewBodyState();
}

class _SportsPricingViewBodyState extends State<_SportsPricingViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _hhMmSs(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final cubit = context.read<SportsPricingCubit>();
    final current =
        cubit.state.newStartTime ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null || !mounted) return;
    cubit.updateStartTime(picked);
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final cubit = context.read<SportsPricingCubit>();
    final current =
        cubit.state.newEndTime ?? const TimeOfDay(hour: 17, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null || !mounted) return;
    cubit.updateEndTime(picked);
  }

  void _confirmPeriod(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<SportsPricingCubit>().confirmPeriod();
    _priceController.clear();
    _descriptionController.clear();
    FocusScope.of(context).unfocus();
  }

  void _startEditing(BuildContext context, SportsPricingDraft period) {
    context.read<SportsPricingCubit>().startEditing(period.localKey);
    _priceController.text = period.price.toPriceString();
    _descriptionController.text = period.description ?? '';
    _scrollToForm();
  }

  void _scrollToForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final formContext = _formKey.currentContext;
      if (formContext == null) return;
      Scrollable.ensureVisible(
        formContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  void _cancelEditing(BuildContext context) {
    context.read<SportsPricingCubit>().cancelEditing();
    _priceController.clear();
    _descriptionController.clear();
  }

  Future<bool> _askLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('لحظة!'),
        content: const Text('عندك تغييرات ما اتحفظتش — تخرج ونسيبهم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('كمّل تعديل'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'اخرج',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _handleBack() async {
    final hasChanges = context
        .read<SportsPricingCubit>()
        .state
        .hasUnsavedChanges;
    if (hasChanges) {
      final leave = await _askLeave();
      if (!mounted) return;
      if (leave) {
        context.canPop() ? context.pop() : context.go('/my-places');
      }
      return;
    }
    context.canPop() ? context.pop() : context.go('/my-places');
  }

  void _onMessage(BuildContext context, SportsPricingState state) {
    final cubit = context.read<SportsPricingCubit>();
    final messenger = ScaffoldMessenger.of(context);
    if (state.errorMessage != null && !state.loadFailed) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      cubit.dismissMessages();
    } else if (state.successMessage != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.successMessage!)));
      cubit.dismissMessages();
      context.canPop() ? context.pop() : context.go('/my-places');
    }
  }

  InputDecoration _dropdownDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: context.isDarkMode ? AppColors.textPrimary : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SportsPricingCubit, SportsPricingState>(
      buildWhen: (previous, current) =>
          previous.hasUnsavedChanges != current.hasUnsavedChanges,
      builder: (context, flagState) => PopScope(
        canPop: !flagState.hasUnsavedChanges,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final leave = await _askLeave();
          if (!mounted) return;
          if (leave) {
            this.context.canPop()
                ? this.context.pop()
                : this.context.go('/my-places');
          }
        },
        child: Scaffold(
          backgroundColor: context.pageBackground,
          body: Column(
            children: [
              ColoredSectionHeader(
                title: 'أسعار الساعة',
                subtitle: widget.placeName,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: context.colorScheme.onPrimary,
                  onPressed: _handleBack,
                ),
              ),
              Expanded(
                child: BlocConsumer<SportsPricingCubit, SportsPricingState>(
                  listenWhen: (previous, current) =>
                      previous.errorMessage != current.errorMessage ||
                      previous.successMessage != current.successMessage,
                  listener: _onMessage,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.loadFailed) {
                      return _buildErrorView(
                        context,
                        state.errorMessage ?? 'حصل خطأ، حاول تاني',
                      );
                    }
                    return _buildForm(context, state);
                  },
                ),
              ),
              BlocBuilder<SportsPricingCubit, SportsPricingState>(
                builder: (context, state) {
                  final reviewMode = state.isApproved != false;
                  return UnsavedChangesBar(
                    visible:
                        state.hasUnsavedChanges &&
                        !state.isLoading &&
                        !state.loadFailed &&
                        !context.isKeyboardOpen,
                    message: reviewMode
                        ? 'تعديلاتك لسه معانا بس… ابعتها للمراجعة 👀'
                        : 'عملت تغييرات… بس لسه ما اتحفظتش 👀',
                    buttonText: reviewMode ? 'ابعت' : 'احفظ',
                    isLoading: state.isSaving,
                    onPressed: () => context.read<SportsPricingCubit>().save(),
                  );
                },
              ),
            ],
          ),
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
              onPressed: () =>
                  context.read<SportsPricingCubit>().loadSportsPricing(),
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

  Widget _buildForm(BuildContext context, SportsPricingState state) {
    final reviewMode = state.isApproved != false;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: context.pagePadding.copyWith(top: context.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isApproved == false) ...[
            const ApprovalBanner(),
            context.mediumSpacing.vSpace,
          ],
          if (state.hasPending) ...[
            const PendingChangesBanner(),
            context.mediumSpacing.vSpace,
          ],
          _buildInfoBanner(context),
          context.mediumSpacing.vSpace,
          if (state.periods.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: state.periods.length,
              onReorderItem: (oldIndex, newIndex) => context
                  .read<SportsPricingCubit>()
                  .reorderPeriod(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final period = state.periods[index];
                return _buildPeriodRow(context, period, index);
              },
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.largeSpacing),
              child: 'مفيش فترات لسه'.toBody(
                context,
                color: context.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          _buildAddEditForm(context, state),
          context.largeSpacing.vSpace,
          if (reviewMode) ...[
            'التعديلات هتتراجع قبل ما تظهر للناس.'.toCaption(
              context,
              color: context.textSecondary,
              textAlign: TextAlign.center,
            ),
            context.smallSpacing.vSpace,
          ],
          _buildSaveButton(context, state),
          context.extraLargeSpacing.vSpace,
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? AppColorsDark.infoBannerBackground
            : AppColors.infoBannerBackground,
        borderRadius: context.mediumRadius.circularRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: context.mediumIconSize,
            color: context.colorScheme.primary,
          ),
          8.hSpace,
          Expanded(
            child:
                'الملاعب مالهاش منيو — بتحدد سعر الساعة لكل فترة (صباحي / ليلي) وبس.'
                    .toBody(context, color: context.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(
    BuildContext context,
    SportsPricingDraft period,
    int index,
  ) {
    final periodLabel = period.startTime.periodLabel;
    final description = period.description;
    return Container(
      key: ValueKey(period.localKey),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.mediumRadius.circularRadius,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: context.iconColor,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(periodLabel.emoji),
                    6.hSpace,
                    periodLabel.label.toBody(
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                4.vSpace,
                '${_hhMmSs(period.startTime).toArabicTime()} – ${_hhMmSs(period.endTime).toArabicTime()}'
                    .toCaption(context, color: context.textSecondary),
                4.vSpace,
                '${period.price.toPriceString()} ج.م / ساعة'.toBody(
                  context,
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
                if (description != null && description.isNotEmpty) ...[
                  4.vSpace,
                  description.toCaption(
                    context,
                    color: context.textSecondary,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _startEditing(context, period),
            icon: const Icon(Icons.edit_outlined),
            color: context.textSecondary,
            tooltip: 'تعديل',
          ),
          IconButton(
            onPressed: () => context.read<SportsPricingCubit>().removePeriod(
              period.localKey,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }

  Widget _buildAddEditForm(BuildContext context, SportsPricingState state) {
    final isEditing = state.editingLocalKey != null;
    return Container(
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.mediumRadius.circularRadius,
        border: Border.all(
          color: isEditing ? context.colorScheme.primary : context.borderColor,
          width: isEditing ? 2 : 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: (isEditing ? 'تعديل فترة' : 'إضافة فترة').toTitle(
                    context,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: () => _cancelEditing(context),
                    child: Text(
                      'إلغاء التعديل',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            context.mediumSpacing.vSpace,
            DropdownButtonFormField<String>(
              key: ValueKey(state.selectedPreset),
              initialValue: state.selectedPreset,
              isExpanded: true,
              decoration: _dropdownDecoration(hint: 'نوع الفترة'),
              items: [
                for (final preset in SportsPricingCubit.presets)
                  DropdownMenuItem(value: preset, child: Text(preset)),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<SportsPricingCubit>().selectPreset(value);
                }
              },
            ),
            context.mediumSpacing.vSpace,
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    key: ValueKey(state.newStartTime),
                    initialValue: state.newStartTime == null
                        ? null
                        : _hhMmSs(state.newStartTime!).toArabicTime(),
                    labelText: 'من',
                    readOnly: true,
                    onTap: () => _pickStartTime(context),
                    suffixIcon: Icon(
                      Icons.schedule_rounded,
                      color: context.textSecondary,
                    ),
                    validator: (_) =>
                        state.newStartTime == null ? 'حدد بداية الفترة' : null,
                  ),
                ),
                context.smallSpacing.hSpace,
                Expanded(
                  child: CustomTextFormField(
                    key: ValueKey(state.newEndTime),
                    initialValue: state.newEndTime == null
                        ? null
                        : _hhMmSs(state.newEndTime!).toArabicTime(),
                    labelText: 'إلى',
                    readOnly: true,
                    onTap: () => _pickEndTime(context),
                    suffixIcon: Icon(
                      Icons.schedule_rounded,
                      color: context.textSecondary,
                    ),
                    validator: (_) =>
                        state.newEndTime == null ? 'حدد نهاية الفترة' : null,
                  ),
                ),
              ],
            ),
            context.mediumSpacing.vSpace,
            CustomTextFormField(
              controller: _priceController,
              labelText: 'السعر (ج.م / ساعة)',
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  context.read<SportsPricingCubit>().updatePrice(value),
              validator: (value) {
                final price = double.tryParse(
                  (value ?? '').trim().toWesternDigits(),
                );
                return (price == null || price <= 0)
                    ? 'السعر لازم يكون رقم أكبر من صفر'
                    : null;
              },
            ),
            context.smallSpacing.vSpace,
            CustomTextFormField(
              controller: _descriptionController,
              labelText: 'وصف الفترة (اختياري)',
              maxLines: 3,
              maxLength: 150,
              onChanged: (value) => context
                  .read<SportsPricingCubit>()
                  .updateNewDescription(value),
            ),
            context.mediumSpacing.vSpace,
            CustomElevatedButton(
              text: isEditing ? 'تحديث الفترة' : 'إضافة الفترة',
              onPressed: () => _confirmPeriod(context),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, SportsPricingState state) {
    return CustomElevatedButton(
      text: state.isApproved != false
          ? 'ابعت التعديلات للمراجعة'
          : 'حفظ الأسعار',
      isLoading: state.isSaving,
      onPressed: () => context.read<SportsPricingCubit>().save(),
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
    );
  }
}
