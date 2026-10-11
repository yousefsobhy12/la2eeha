import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/place_pricing_helpers.dart';
import '../../../../core/constants/weekday_names.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_txt_form_field.dart';
import '../../../browse/data/datasource/places_remote_datasource.dart';
import '../../../browse/data/repositories/places_repository_impl.dart';
import '../../../more/presentation/widgets/contact_bottom_sheet.dart';
import '../../data/datasource/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../cubit/add_place_cubit.dart';
import '../cubit/add_place_state.dart';
import 'pricing_args.dart';

class AddPlaceView extends StatelessWidget {
  const AddPlaceView({super.key, this.placeId});

  final int? placeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = AddPlaceCubit(
          MerchantRepositoryImpl(remoteDataSource: MerchantRemoteDataSource()),
          PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
          LocalStorageService(),
        );
        if (placeId == null) {
          cubit.loadFormData();
        } else {
          cubit.loadForEdit(placeId!);
        }
        return cubit;
      },
      child: const _AddPlaceViewBody(),
    );
  }
}

class _AddPlaceViewBody extends StatefulWidget {
  const _AddPlaceViewBody();

  @override
  State<_AddPlaceViewBody> createState() => _AddPlaceViewBodyState();
}

class _AddPlaceViewBodyState extends State<_AddPlaceViewBody> {
  bool _showingSuccessDialog = false;
  final _formKey = GlobalKey<FormState>();

  static const Map<int, List<String>> _subCategoryOptions = {
    22: ['مطعم', 'كافيه', 'حلواني'],
    26: ['بقالة', 'فراخ', 'جزارة'],
  };

  static const Map<String, String> _sportsSubCategories = {
    'football': 'ملاعب كورة',
    'padel': 'ملاعب بادل',
    'boxing': 'ملاكمة',
    'kungfu': 'كونغ فو',
    'playstation': 'بلايستيشن',
  };

  static const String _otherSubCategoryMarker = '__OTHER__';
  static const int _otherAreaMarker = -1;
  static const String _phonePattern = r'^01[0125][0-9]{8}$';

  TimeOfDay? _parseHhMmSs(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _timeToHhMmSs(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _pickTime(bool isOpenTime) async {
    final cubit = context.read<AddPlaceCubit>();
    final raw = isOpenTime ? cubit.state.openTime : cubit.state.closeTime;
    final parsed = (raw == null || raw.isEmpty)
        ? const TimeOfDay(hour: 9, minute: 0)
        : _parseHhMmSs(raw) ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: parsed);
    if (picked == null) return;
    if (!mounted) return;
    final formatted = _timeToHhMmSs(picked);
    if (isOpenTime) {
      cubit.updateOpenTime(formatted);
    } else {
      cubit.updateCloseTime(formatted);
    }
  }

  void _showContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.extraLargeRadius),
        ),
      ),
      builder: (sheetContext) => const ContactSheet(),
    );
  }

  void _showSuccessDialog(BuildContext context, AddPlaceState state) {
    if (_showingSuccessDialog) return;
    _showingSuccessDialog = true;

    if (state.isEditing) {
      var message = state.isApprovedPlace
          ? 'اتبعتت تعديلاتك للمراجعة — البيانات الحالية هتفضل ظاهرة لحد الموافقة'
          : 'تم حفظ التعديلات — بيزنسك قيد المراجعة';
      if (state.imageUploadFailed) {
        message =
            '$message\n⚠️ الصورة مقدرناش نرفعها — جرّب تعدّلها تاني';
      }

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              'تمام!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  _showingSuccessDialog = false;
                  Navigator.of(dialogContext).pop();
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/my-places');
                  }
                },
                child: const Text('تمام'),
              ),
            ],
          );
        },
      );
      return;
    }

    final message = state.imageUploadFailed
        ? 'تمت الإضافة! بيزنسك دلوقتي قيد المراجعة ⚠️ الصورة مقدرناش نرفعها — هتقدر تضيفها بعدين من صفحة أعمالي'
        : 'تمت الإضافة! بيزنسك دلوقتي قيد المراجعة';

    final categoryId = state.categoryId;
    final screenType = categoryId == null
        ? PlacePricingScreenType.none
        : pricingScreenTypeFor(
            categoryId: categoryId,
            subCategory: state.subCategory,
          );

    final placeId = state.submittedPlaceId;
    final nextAction =
        (placeId != null && screenType != PlacePricingScreenType.none)
        ? screenType == PlacePricingScreenType.sportsPricing
              ? (
                  label: 'أضف أسعار الساعة دلوقتي',
                  path: '/place/$placeId/pricing',
                )
              : (
                  label: pricingLabelsFor(
                    categoryId: categoryId!,
                    subCategory: state.subCategory,
                  ).dialogButton,
                  path: '/place/$placeId/menu',
                )
        : null;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'تمام!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                _showingSuccessDialog = false;
                Navigator.of(dialogContext).pop();
                context.go('/my-places');
              },
              child: const Text('تمام'),
            ),
            if (nextAction != null)
              ElevatedButton(
                onPressed: () {
                  _showingSuccessDialog = false;
                  Navigator.of(dialogContext).pop();
                  context.pushReplacement(
                    nextAction.path,
                    extra: PricingArgs(
                      placeId: placeId!,
                      placeName: state.name.trim(),
                      categoryId: state.categoryId!,
                      subCategory: state.subCategory,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                ),
                child: Text(nextAction.label),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddPlaceCubit, AddPlaceState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case AddPlaceStatus.success:
            _showSuccessDialog(context, state);
          case AddPlaceStatus.error:
            if (state.errorMessage != null &&
                (state.categories.isNotEmpty || state.areas.isNotEmpty)) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          case AddPlaceStatus.initial:
          case AddPlaceStatus.loadingFormData:
          case AddPlaceStatus.ready:
          case AddPlaceStatus.submitting:
            break;
        }
      },
      builder: (context, state) {
        final hasFormData =
            state.categories.isNotEmpty || state.areas.isNotEmpty;
        final isEditing = state.isEditing;

        return Scaffold(
          backgroundColor: context.pageBackground,
          body: Column(
            children: [
              ColoredSectionHeader(
                title: isEditing ? 'تعديل البيانات' : 'إضافة بيزنس جديد',
                subtitle: isEditing
                    ? 'عدّل بيانات مكانك وابعتها'
                    : 'اضبط بيانات المكان واحنا هنتواصل معاك قريب',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: context.colorScheme.onPrimary,
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: hasFormData
                    ? _buildForm(context, state)
                    : _buildStatusView(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusView(BuildContext context, AddPlaceState state) {
    if (state.status == AddPlaceStatus.error && state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: context.iconColor),
              context.smallSpacing.vSpace,
              state.errorMessage!.toBody(
                context,
                color: context.textSecondary,
                textAlign: TextAlign.center,
              ),
              context.smallSpacing.vSpace,
              ElevatedButton(
                onPressed: () {
                  final cubit = context.read<AddPlaceCubit>();
                  if (state.isEditing) {
                    cubit.loadForEdit(state.editingPlaceId!);
                  } else {
                    cubit.loadFormData();
                  }
                },
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

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildForm(BuildContext context, AddPlaceState state) {
    final locked = state.isEditing && state.isApprovedPlace;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: context.pagePadding.copyWith(top: context.mediumSpacing),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (locked && state.hasPendingChanges) ...[
              _buildPendingReviewBanner(context),
              context.mediumSpacing.vSpace,
            ],
            _buildNameField(context, state),
            context.mediumSpacing.vSpace,
            _buildCategoryField(context, state),
            if (AddPlaceCubit.subCategoryCategories.contains(
              state.categoryId,
            )) ...[
              context.mediumSpacing.vSpace,
              _buildSubCategorySection(context, state),
            ],
            context.mediumSpacing.vSpace,
            _buildAreaField(context, state),
            context.mediumSpacing.vSpace,
            _buildAddressField(context, state),
            context.mediumSpacing.vSpace,
            _buildPhoneField(context, state),
            context.mediumSpacing.vSpace,
            _buildWhatsappField(context, state),
            context.mediumSpacing.vSpace,
            _buildGoogleMapsField(context, state),
            context.mediumSpacing.vSpace,
            _buildDescriptionField(context, state),
            context.mediumSpacing.vSpace,
            _buildTimesSection(context, state),
            context.mediumSpacing.vSpace,
            _buildClosedDaysSection(context, state),
            if (AddPlaceCubit.deliveryCategories.contains(
              state.categoryId,
            )) ...[
              context.mediumSpacing.vSpace,
              _buildDeliverySection(context, state),
            ],
            context.mediumSpacing.vSpace,
            _buildCoverPhoto(context, state),
            context.largeSpacing.vSpace,
            _buildSubmitButton(context),
            context.extraLargeSpacing.vSpace,
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.smallSpacing),
      child: text.toResponsiveText(
        context,
        style: AppTextStyles.bodyBold14(context.textPrimary),
      ),
    );
  }

  Widget _buildPendingReviewBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.smallSpacing,
        vertical: context.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: context.roundRadius.circularRadius,
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: context.smallIconSize,
            color: context.colorScheme.primary,
          ),
          6.hSpace,
          Expanded(
            child:
                'عندك تعديلات قيد المراجعة — الحقول تحت فيها آخر قيمة بعتّها'
                    .toCaption(
                      context,
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, label),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.mediumSpacing,
            vertical: context.mediumSpacing,
          ),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: context.mediumRadius.circularRadius,
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: value.toBody(context, fontWeight: FontWeight.w600),
              ),
              context.smallSpacing.hSpace,
              Icon(
                Icons.lock_outline,
                size: context.smallIconSize,
                color: context.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _buildNameField(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'اسم المكان *'),
        CustomTextFormField(
          initialValue: state.name,
          labelText: 'مثال: مطعم أبو علي',
          onChanged: (value) => context.read<AddPlaceCubit>().updateName(value),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'اكتب اسم البيزنس'
              : null,
        ),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context, AddPlaceState state) {
    if (state.isEditing && state.isApprovedPlace) {
      final matches = state.categories
          .where((category) => category.id == state.categoryId)
          .toList();
      final name = matches.isEmpty ? '—' : matches.first.nameAr;
      return _buildLockedField(context, 'الكاتيجوري', name);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'الكاتيجوري *'),
        DropdownButtonFormField<int>(
          initialValue: state.categoryId,
          isExpanded: true,
          decoration: _dropdownDecoration(hint: 'مثال: مطعم'),
          items: [
            for (final category in state.categories)
              DropdownMenuItem(
                value: category.id,
                child: Text(category.nameAr),
              ),
          ],
          onChanged: (value) =>
              context.read<AddPlaceCubit>().updateCategory(value),
          validator: (_) =>
              state.categoryId == null ? 'اختار الكاتيجوري' : null,
        ),
        context.smallSpacing.vSpace,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: _showContactSheet,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'مش لاقي الكاتيجوري المناسبة؟ تواصل معانا',
              style: AppTextStyles.captionRegular12(
                context.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategorySection(BuildContext context, AddPlaceState state) {
    final categoryId = state.categoryId!;
    final isSports = categoryId == 27;
    if (state.isEditing && state.isApprovedPlace) {
      final raw = state.subCategory;
      final value = raw == null
          ? '—'
          : (isSports ? (_sportsSubCategories[raw] ?? raw) : raw);
      return _buildLockedField(context, 'النوع الفرعي', value);
    }
    final fixedOptions = isSports
        ? _sportsSubCategories.keys.toList()
        : (_subCategoryOptions[categoryId] ?? const []);
    final isOtherSelected =
        state.subCategory != null && !fixedOptions.contains(state.subCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'النوع الفرعي *'),
        DropdownButtonFormField<String>(
          initialValue: isOtherSelected
              ? _otherSubCategoryMarker
              : state.subCategory,
          isExpanded: true,
          decoration: _dropdownDecoration(hint: 'حدد النوع الفرعي'),
          items: [
            for (final option in fixedOptions)
              DropdownMenuItem(
                value: option,
                child: Text(isSports ? _sportsSubCategories[option]! : option),
              ),
            const DropdownMenuItem(
              value: _otherSubCategoryMarker,
              child: Text('أخرى — اكتبها'),
            ),
          ],
          onChanged: (value) {
            final cubit = context.read<AddPlaceCubit>();
            if (value == _otherSubCategoryMarker) {
              cubit.updateSubCategory('');
            } else {
              cubit.updateSubCategory(value);
            }
          },
          validator: (_) {
            if (isOtherSelected) return null;
            if (state.subCategory == null ||
                state.subCategory!.trim().isEmpty) {
              return 'اختار النوع الفرعي أو اكتبه';
            }
            return null;
          },
        ),
        if (isOtherSelected) ...[
          context.smallSpacing.vSpace,
          CustomTextFormField(
            initialValue: state.subCategory ?? '',
            labelText: 'اكتب النوع',
            onChanged: (value) =>
                context.read<AddPlaceCubit>().updateSubCategory(value),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'اكتب النوع' : null,
          ),
        ],
      ],
    );
  }

  Widget _buildAreaField(BuildContext context, AddPlaceState state) {
    if (state.isEditing && state.isApprovedPlace) {
      final String name;
      if (state.isOtherAreaSelected) {
        name = state.otherAreaName;
      } else {
        final matches = state.areas
            .where((area) => area.id == state.areaId)
            .toList();
        name = matches.isEmpty ? '—' : matches.first.nameAr;
      }
      return _buildLockedField(context, 'المنطقة', name);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'المنطقة *'),
        DropdownButtonFormField<int>(
          initialValue: state.isOtherAreaSelected
              ? _otherAreaMarker
              : state.areaId,
          isExpanded: true,
          decoration: _dropdownDecoration(hint: 'اختار المنطقة'),
          items: [
            for (final area in state.areas)
              DropdownMenuItem(value: area.id, child: Text(area.nameAr)),
            const DropdownMenuItem(
              value: _otherAreaMarker,
              child: Text('أخرى — اكتب اسم منطقتك'),
            ),
          ],
          onChanged: (value) {
            final cubit = context.read<AddPlaceCubit>();
            if (value == _otherAreaMarker) {
              cubit.selectOtherArea();
            } else if (value != null) {
              cubit.selectExistingArea(value);
            }
          },
          validator: (_) {
            if (state.isOtherAreaSelected) return null;
            return state.areaId == null
                ? 'اختار المنطقة أو اكتب اسم منطقتك'
                : null;
          },
        ),
        if (state.isOtherAreaSelected) ...[
          context.smallSpacing.vSpace,
          CustomTextFormField(
            initialValue: state.otherAreaName,
            labelText: 'اكتب اسم منطقتك',
            onChanged: (value) =>
                context.read<AddPlaceCubit>().updateOtherAreaName(value),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'اكتب اسم منطقتك'
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildAddressField(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'العنوان *'),
        CustomTextFormField(
          initialValue: state.address,
          labelText: 'كتب العنوان بالتفصيل',
          maxLines: 3,
          onChanged: (value) =>
              context.read<AddPlaceCubit>().updateAddress(value),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'اكتب العنوان' : null,
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'رقم الموبايل *'),
        CustomTextFormField(
          initialValue: state.phone,
          labelText: 'مثال: 01012345678',
          keyboardType: TextInputType.phone,
          onChanged: (value) =>
              context.read<AddPlaceCubit>().updatePhone(value),
          validator: (value) {
            final phone = value?.trim() ?? '';
            if (phone.isEmpty) return 'اكتب رقم الهاتف';
            if (!RegExp(_phonePattern).hasMatch(phone)) {
              return 'رقم الموبايل غير صحيح (مثال: 01012345678)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWhatsappField(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'رقم الواتساب (اختياري)'),
        CustomTextFormField(
          initialValue: state.whatsapp ?? '',
          labelText: 'نفس صيغة الموبايل لو موجود',
          keyboardType: TextInputType.phone,
          onChanged: (value) =>
              context.read<AddPlaceCubit>().updateWhatsapp(value),
          validator: (value) {
            final whatsapp = value?.trim() ?? '';
            if (whatsapp.isNotEmpty &&
                !RegExp(_phonePattern).hasMatch(whatsapp)) {
              return 'رقم الواتساب غير صحيح';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGoogleMapsField(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'لينك خرائط جوجل (اختياري)'),
        CustomTextFormField(
          initialValue: state.googleMapsUrl ?? '',
          labelText: 'https://maps.google.com/...',
          keyboardType: TextInputType.url,
          onChanged: (value) =>
              context.read<AddPlaceCubit>().updateGoogleMapsUrl(value),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'وصف المكان (اختياري)'),
        CustomTextFormField(
          initialValue: state.description ?? '',
          labelText: 'اكتب وصف مختصر عن المكان',
          maxLines: 4,
          maxLength: 250,
          onChanged: (value) =>
              context.read<AddPlaceCubit>().updateDescription(value),
        ),
      ],
    );
  }

  Widget _buildTimesSection(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(
          context,
          state.is24Hours ? 'ساعات العمل' : 'ساعات العمل *',
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.mediumSpacing),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: context.mediumRadius.circularRadius,
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: 'يعمل ٢٤ ساعة'.toBody(
                  context,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: state.is24Hours,
                activeThumbColor: context.colorScheme.onPrimary,
                activeTrackColor: context.colorScheme.primary,
                onChanged: (value) =>
                    context.read<AddPlaceCubit>().setIs24Hours(value),
              ),
            ],
          ),
        ),
        if (!state.is24Hours) ...[
          context.smallSpacing.vSpace,
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  key: ValueKey(state.openTime),
                  initialValue: state.openTime?.toArabicTime(),
                  labelText: 'الفتح',
                  readOnly: true,
                  onTap: () => _pickTime(true),
                  suffixIcon: Icon(
                    Icons.schedule_rounded,
                    color: context.textSecondary,
                  ),
                  validator: (_) {
                    if (state.openTime == null) return 'حدد ميعاد الفتح';
                    return null;
                  },
                ),
              ),
              context.smallSpacing.hSpace,
              Expanded(
                child: CustomTextFormField(
                  key: ValueKey(state.closeTime),
                  initialValue: state.closeTime?.toArabicTime(),
                  labelText: 'القفل',
                  readOnly: true,
                  onTap: () => _pickTime(false),
                  suffixIcon: Icon(
                    Icons.schedule_rounded,
                    color: context.textSecondary,
                  ),
                  validator: (_) {
                    if (state.closeTime == null) return 'حدد ميعاد القفل';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildClosedDaysSection(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'أيام الإجازة الأسبوعية (اختياري)'),
        Wrap(
          spacing: context.smallSpacing,
          runSpacing: context.smallSpacing,
          children: [
            for (final day in arabicWeekdayDisplayOrder)
              FilterChip(
                label: Text(arabicWeekdayNames[day]!),
                selected: state.closedDays.contains(day),
                onSelected: (_) =>
                    context.read<AddPlaceCubit>().toggleClosedDay(day),
                selectedColor: context.colorScheme.primary,
                backgroundColor: context.colorScheme.primary.withValues(
                  alpha: 0.08,
                ),
                labelStyle: TextStyle(
                  color: state.closedDays.contains(day)
                      ? context.colorScheme.onPrimary
                      : context.textPrimary,
                  fontWeight: state.closedDays.contains(day)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: state.closedDays.contains(day)
                      ? context.colorScheme.primary
                      : context.borderColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: context.roundRadius.circularRadius,
                ),
                showCheckmark: false,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliverySection(BuildContext context, AddPlaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'التوصيل (اختياري)'),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.mediumSpacing),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: context.mediumRadius.circularRadius,
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: 'متاح توصيل'.toBody(
                  context,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: state.isDelivery,
                activeThumbColor: context.colorScheme.onPrimary,
                activeTrackColor: context.colorScheme.primary,
                onChanged: (value) =>
                    context.read<AddPlaceCubit>().setIsDelivery(value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPhoto(BuildContext context, AddPlaceState state) {
    final image = state.imageFile;
    final existingUrl = state.existingImageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'صورة الغلاف (اختياري)'),
        if (image == null && existingUrl != null && existingUrl.isNotEmpty)
          _buildExistingPhoto(context, existingUrl)
        else if (image == null)
          InkWell(
            onTap: () => context.read<AddPlaceCubit>().pickImage(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.borderColor, width: 1.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 32,
                    color: context.iconColor,
                  ),
                  context.smallSpacing.vSpace,
                  'اضغط لإضافة صورة'.toBody(
                    context,
                    color: context.textSecondary,
                  ),
                ],
              ),
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  image,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              PositionedDirectional(
                top: 8,
                start: 8,
                child: InkWell(
                  onTap: () => context.read<AddPlaceCubit>().removeImage(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildExistingPhoto(BuildContext context, String url) {
    return InkWell(
      onTap: () => context.read<AddPlaceCubit>().pickImage(),
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: url,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) => _photoPlaceholder(context),
              errorWidget: (_, _, _) => _photoPlaceholder(context),
            ),
          ),
          PositionedDirectional(
            bottom: 8,
            start: 8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallSpacing,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: context.roundRadius.circularRadius,
              ),
              child: 'اضغط لتغيير الصورة'.toCaption(
                context,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor, width: 1.2),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<AddPlaceCubit, AddPlaceState>(
      builder: (context, state) {
        final text = state.isEditing
            ? (state.isApprovedPlace
                  ? 'ابعت التعديلات للمراجعة'
                  : 'احفظ التعديلات')
            : 'احفظ البيزنس';
        return CustomElevatedButton(
          text: text,
          isLoading: state.status == AddPlaceStatus.submitting,
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            context.read<AddPlaceCubit>().submit();
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
        );
      },
    );
  }
}
