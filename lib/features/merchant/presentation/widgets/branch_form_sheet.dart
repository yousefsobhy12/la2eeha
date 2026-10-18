import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_txt_form_field.dart';
import '../../domain/entities/branch_draft.dart';
import '../../domain/entities/merchant_branch.dart';
import '../cubit/manage_branches_cubit.dart';

Future<void> showBranchFormSheet(
  BuildContext context, {
  MerchantBranch? branch,
}) {
  final cubit = context.read<ManageBranchesCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.extraLargeRadius),
      ),
    ),
    builder: (sheetContext) => _BranchFormSheet(cubit: cubit, branch: branch),
  );
}

class _BranchFormSheet extends StatefulWidget {
  final ManageBranchesCubit cubit;
  final MerchantBranch? branch;

  const _BranchFormSheet({required this.cubit, this.branch});

  @override
  State<_BranchFormSheet> createState() => _BranchFormSheetState();
}

class _BranchFormSheetState extends State<_BranchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mapsLinkController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final branch = widget.branch;
    _titleController = TextEditingController(text: branch?.title ?? '');
    _descriptionController = TextEditingController(
      text: branch?.description ?? '',
    );
    _addressController = TextEditingController(text: branch?.address ?? '');
    _phoneController = TextEditingController(text: branch?.phone ?? '');
    _mapsLinkController = TextEditingController(
      text: branch?.googleMapsLink ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _mapsLinkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final address = _addressController.text.trim();
    final phone = _phoneController.text.toWesternDigits().trim();
    final mapsLink = _mapsLinkController.text.trim();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final draft = BranchDraft(
      address: address,
      googleMapsLink: mapsLink.isEmpty ? null : mapsLink,
      phone: phone.isEmpty ? null : phone,
      title: title.isEmpty ? null : title,
      description: description.isEmpty ? null : description,
    );

    final branch = widget.branch;
    final success = branch == null
        ? await widget.cubit.add(draft)
        : await widget.cubit.update(branch.id, draft);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.branch != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: context.bottomSheetPadding,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'تعديل الفرع' : 'إضافة فرع',
                    style: AppTextStyles.cardTitle(context.textPrimary),
                  ),
                  context.mediumSpacing.vSpace,
                  CustomTextFormField(
                    controller: _titleController,
                    labelText: 'عنوان الفرع (اختياري)',
                    hintText: 'لو سيبته فاضي هيظهر اسم المكان',
                    maxLength: 60,
                    validator: (value) {
                      final title = value?.trim() ?? '';
                      if (title.isEmpty) return null;
                      if (title.length < 2) {
                        return 'العنوان قصير جداً (حرفين على الأقل)';
                      }
                      return null;
                    },
                  ),
                  context.smallSpacing.vSpace,
                  CustomTextFormField(
                    controller: _descriptionController,
                    labelText: 'وصف الفرع (اختياري)',
                    maxLines: 3,
                    maxLength: 150,
                  ),
                  context.smallSpacing.vSpace,
                  CustomTextFormField(
                    controller: _addressController,
                    labelText: 'عنوان الفرع بالتفصيل *',
                    maxLines: 3,
                    maxLength: 200,
                    validator: (value) {
                      final address = value?.trim() ?? '';
                      if (address.isEmpty) return 'اكتب عنوان الفرع';
                      if (address.length < 3) {
                        return 'العنوان قصير جداً (٣ حروف على الأقل)';
                      }
                      return null;
                    },
                  ),
                  context.smallSpacing.vSpace,
                  CustomTextFormField(
                    controller: _phoneController,
                    labelText: 'تليفون الفرع (اختياري)',
                    hintText: '01234567890',
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    validator: (value) {
                      final phone = (value ?? '').toWesternDigits().trim();
                      if (phone.isEmpty) return null;
                      final valid =
                          RegExp(r'^01[0125][0-9]{8}$').hasMatch(phone) ||
                          RegExp(r'^013[0-9]{7}$').hasMatch(phone) ||
                          RegExp(r'^0[2-9][0-9]{7,8}$').hasMatch(phone) ||
                          RegExp(r'^1[0-9]{4}$').hasMatch(phone);
                      if (!valid) return 'رقم التليفون غير صحيح';
                      return null;
                    },
                  ),
                  context.smallSpacing.vSpace,
                  CustomTextFormField(
                    controller: _mapsLinkController,
                    labelText: 'لينك الخريطة (اختياري)',
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      final link = value?.trim() ?? '';
                      if (link.isEmpty) return null;
                      final valid =
                          RegExp(r'^https://[^\s]+$').hasMatch(link) &&
                          link.length <= 2000;
                      if (!valid) {
                        return 'اللينك لازم يبدأ بـ https:// من غير مسافات';
                      }
                      return null;
                    },
                  ),
                  context.mediumSpacing.vSpace,
                  Text(
                    isEditing
                        ? 'أي تعديل هيرجّع الفرع للمراجعة لحد ما نوافق عليه تاني'
                        : 'الفرع هيظهر للناس بعد ما نراجعه',
                    style: AppTextStyles.captionRegular12(
                      context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  context.smallSpacing.vSpace,
                  CustomElevatedButton(
                    text: isEditing ? 'حفظ التعديلات' : 'حفظ',
                    isLoading: _saving,
                    onPressed: _save,
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
          ),
        ),
      ),
    );
  }
}
