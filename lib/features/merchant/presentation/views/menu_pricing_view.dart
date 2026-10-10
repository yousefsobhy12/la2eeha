import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/place_pricing_helpers.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_txt_form_field.dart';
import '../../../browse/data/datasource/places_remote_datasource.dart';
import '../../../browse/data/repositories/places_repository_impl.dart';
import '../../data/datasource/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../../domain/entities/menu_item_draft.dart';
import '../cubit/menu_pricing_cubit.dart';
import '../cubit/menu_pricing_state.dart';
import '../widgets/approval_banner.dart';
import '../widgets/pending_changes_banner.dart';
import '../widgets/unsaved_changes_bar.dart';
import 'pricing_args.dart';

class MenuPricingView extends StatelessWidget {
  final PricingArgs args;

  const MenuPricingView({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final labels = pricingLabelsFor(
      categoryId: args.categoryId,
      subCategory: args.subCategory,
    );
    return BlocProvider(
      create: (_) => MenuPricingCubit(
        MerchantRepositoryImpl(remoteDataSource: MerchantRemoteDataSource()),
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
        placeId: args.placeId,
        placeName: args.placeName,
        isDelivery: isDeliveryPricing(args.categoryId),
        saveSuccessMessage: labels.saveSuccess,
      )..loadMenuItems(),
      child: _MenuPricingViewBody(placeName: args.placeName, labels: labels),
    );
  }
}

class _MenuPricingViewBody extends StatefulWidget {
  final String placeName;
  final PricingLabels labels;

  const _MenuPricingViewBody({
    required this.placeName,
    required this.labels,
  });

  @override
  State<_MenuPricingViewBody> createState() => _MenuPricingViewBodyState();
}

class _MenuPricingViewBodyState extends State<_MenuPricingViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _arabicCount(int count) {
    return count
        .toString()
        .split('')
        .map((digit) => _arabicDigits[int.parse(digit)])
        .join();
  }

  void _confirmItem(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<MenuPricingCubit>().confirmItem();
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    FocusScope.of(context).unfocus();
  }

  void _startEditing(BuildContext context, MenuItemDraft item) {
    context.read<MenuPricingCubit>().startEditing(item.localKey);
    _nameController.text = item.name;
    _priceController.text = item.price.toPriceString();
    _descriptionController.text = item.description ?? '';
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
    context.read<MenuPricingCubit>().cancelEditing();
    _nameController.clear();
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
            child: const Text('اخرج', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _handleBack() async {
    final hasChanges = context.read<MenuPricingCubit>().state.hasUnsavedChanges;
    if (hasChanges) {
      final leave = await _askLeave();
      if (!mounted) return;
      if (leave) context.go('/');
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _onMessage(BuildContext context, MenuPricingState state) {
    final cubit = context.read<MenuPricingCubit>();
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
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuPricingCubit, MenuPricingState>(
      buildWhen: (previous, current) =>
          previous.hasUnsavedChanges != current.hasUnsavedChanges,
      builder: (context, flagState) => PopScope(
        canPop: !flagState.hasUnsavedChanges,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final leave = await _askLeave();
          if (!mounted) return;
          if (leave) this.context.go('/');
        },
        child: Scaffold(
          backgroundColor: context.pageBackground,
          body: Column(
            children: [
              ColoredSectionHeader(
                title: widget.labels.screenTitle,
                subtitle: widget.placeName,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: context.colorScheme.onPrimary,
                  onPressed: _handleBack,
                ),
              ),
              Expanded(
                child: BlocConsumer<MenuPricingCubit, MenuPricingState>(
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
              BlocBuilder<MenuPricingCubit, MenuPricingState>(
                builder: (context, state) {
                  final reviewMode = state.isApproved != false;
                  return UnsavedChangesBar(
                    visible: state.hasUnsavedChanges &&
                        !state.isLoading &&
                        !state.loadFailed &&
                        !context.isKeyboardOpen,
                    message: reviewMode
                        ? 'تعديلاتك لسه معانا بس… ابعتها للمراجعة 👀'
                        : 'عملت تغييرات… بس لسه ما اتحفظتش 👀',
                    buttonText: reviewMode ? 'ابعت' : 'احفظ',
                    isLoading: state.isSaving,
                    onPressed: () => context.read<MenuPricingCubit>().save(),
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
              onPressed: () => context.read<MenuPricingCubit>().loadMenuItems(),
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

  Widget _buildForm(BuildContext context, MenuPricingState state) {
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
          if (state.items.isNotEmpty) ...[
            '${_arabicCount(state.items.length)} ${widget.labels.itemNoun}'
                .toBody(
                  context,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
            context.mediumSpacing.vSpace,
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: state.items.length,
              onReorderItem: (oldIndex, newIndex) => context
                  .read<MenuPricingCubit>()
                  .reorderItem(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _buildItemRow(context, item, index);
              },
            ),
            context.smallSpacing.vSpace,
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.largeSpacing),
              child: widget.labels.emptyText.toBody(
                context,
                color: context.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
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

  Widget _buildItemRow(BuildContext context, MenuItemDraft item, int index) {
    final description = item.description;
    return Container(
      key: ValueKey(item.localKey),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                item.name.toBody(context, fontWeight: FontWeight.w600),
                4.vSpace,
                '${item.price.toPriceString()} ج.م'.toCaption(
                  context,
                  color: context.textSecondary,
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
            onPressed: () => _startEditing(context, item),
            icon: const Icon(Icons.edit_outlined),
            color: context.textSecondary,
            tooltip: 'تعديل',
          ),
          IconButton(
            onPressed: () =>
                context.read<MenuPricingCubit>().removeItem(item.localKey),
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }

  Widget _buildAddEditForm(BuildContext context, MenuPricingState state) {
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
                  child: (isEditing
                          ? widget.labels.editTitle
                          : widget.labels.addTitle)
                      .toTitle(context, fontWeight: FontWeight.bold),
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
            CustomTextFormField(
              controller: _nameController,
              labelText: widget.labels.nameLabel,
              hintText: widget.labels.nameHint,
              onChanged: (value) =>
                  context.read<MenuPricingCubit>().updateNewItemName(value),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? widget.labels.nameRequiredError
                  : null,
            ),
            context.smallSpacing.vSpace,
            CustomTextFormField(
              controller: _priceController,
              labelText: 'السعر (ج.م)',
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  context.read<MenuPricingCubit>().updateNewItemPrice(value),
              validator: (value) {
                final price = double.tryParse((value ?? '').trim().toWesternDigits());
                return (price == null || price <= 0)
                    ? 'السعر لازم يكون رقم أكبر من صفر'
                    : null;
              },
            ),
            context.smallSpacing.vSpace,
            CustomTextFormField(
              controller: _descriptionController,
              labelText: 'وصف (اختياري)',
              maxLines: 3,
              maxLength: 150,
              onChanged: (value) => context
                  .read<MenuPricingCubit>()
                  .updateNewItemDescription(value),
            ),
            context.mediumSpacing.vSpace,
            CustomElevatedButton(
              text: isEditing
                  ? widget.labels.updateButton
                  : widget.labels.addButton,
              onPressed: () => _confirmItem(context),
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

  Widget _buildSaveButton(BuildContext context, MenuPricingState state) {
    final reviewMode = state.isApproved != false;
    return CustomElevatedButton(
      text: reviewMode ? 'ابعت التعديلات للمراجعة' : widget.labels.saveButton,
      isLoading: state.isSaving,
      onPressed: () => context.read<MenuPricingCubit>().save(),
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
