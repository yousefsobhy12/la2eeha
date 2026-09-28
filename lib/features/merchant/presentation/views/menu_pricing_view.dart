// lib/features/merchant/presentation/views/menu_pricing_view.dart
//
// شاشة إدارة المنيو (أو أسعار التوصيل للمصادر). نفس البنية بتاعة
// AddPlaceView: هيدر colored + SingleChildScrollView فورم (مش slivers).
// الـ items بتتقرا من PlacesRepository (RLS-safe للمالك)، الترتيب بيتغيّر
// بالسحب (ReorderableListView) والتعديلات محلية لحد ما التاجر بحفظ.

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
import 'pricing_args.dart';

class MenuPricingView extends StatelessWidget {
  final PricingArgs args;

  const MenuPricingView({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuPricingCubit(
        MerchantRepositoryImpl(remoteDataSource: MerchantRemoteDataSource()),
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
        placeId: args.placeId,
        placeName: args.placeName,
        isDelivery: isDeliveryPricing(args.categoryId),
      )..loadMenuItems(),
      child: _MenuPricingViewBody(
        placeName: args.placeName,
        isDelivery: isDeliveryPricing(args.categoryId),
      ),
    );
  }
}

class _MenuPricingViewBody extends StatefulWidget {
  final String placeName;
  final bool isDelivery;

  const _MenuPricingViewBody({
    required this.placeName,
    required this.isDelivery,
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
    _priceController.text = item.price.toString();
    _descriptionController.text = item.description ?? '';
  }

  void _cancelEditing(BuildContext context) {
    context.read<MenuPricingCubit>().cancelEditing();
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
  }

  void _onMessage(BuildContext context, MenuPricingState state) {
    final cubit = context.read<MenuPricingCubit>();
    final messenger = ScaffoldMessenger.of(context);
    if (state.errorMessage != null && state.items.isNotEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      cubit.dismissMessages();
    } else if (state.successMessage != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.successMessage!)));
      cubit.dismissMessages();
      // بعد حفظ ناجح بنروح الرئيسية (مش بنفضل واقفين على الشاشة).
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Column(
        children: [
          ColoredSectionHeader(
            title: widget.isDelivery ? 'أسعار التوصيل' : 'المنيو والأسعار',
            subtitle: widget.placeName,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: context.colorScheme.onPrimary,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
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
                if (state.errorMessage != null && state.items.isEmpty) {
                  return _buildErrorView(context, state.errorMessage!);
                }
                return _buildForm(context, state);
              },
            ),
          ),
        ],
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
          if (state.items.isNotEmpty) ...[
            '${_arabicCount(state.items.length)} ${state.isDelivery ? 'منطقة' : 'صنف'}'
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
              child: (state.isDelivery ? 'مفيش مناطق لسه' : 'مفيش أصناف لسه')
                  .toBody(
                    context,
                    color: context.textSecondary,
                    textAlign: TextAlign.center,
                  ),
            ),
          ],
          _buildAddEditForm(context, state),
          context.largeSpacing.vSpace,
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
                '${item.price.toStringAsFixed(0)} ج.م'.toCaption(
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
        border: Border.all(color: context.borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: (isEditing ? 'تعديل صنف' : 'إضافة صنف').toTitle(
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
            CustomTextFormField(
              controller: _nameController,
              labelText: 'اسم الصنف',
              onChanged: (value) =>
                  context.read<MenuPricingCubit>().updateNewItemName(value),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'اكتب اسم الصنف'
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
                final price = double.tryParse(value ?? '');
                return (price == null || price <= 0)
                    ? 'السعر لازم يكون رقم أكبر من صفر'
                    : null;
              },
            ),
            context.smallSpacing.vSpace,
            CustomTextFormField(
              controller: _descriptionController,
              labelText: 'وصف الصنف (اختياري)',
              maxLines: 3,
              maxLength: 150,
              onChanged: (value) => context
                  .read<MenuPricingCubit>()
                  .updateNewItemDescription(value),
            ),
            context.mediumSpacing.vSpace,
            CustomElevatedButton(
              text: isEditing ? 'تحديث الصنف' : 'إضافة للمنيو',
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
    return CustomElevatedButton(
      text: state.isDelivery ? 'حفظ الأسعار' : 'حفظ المنيو',
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
