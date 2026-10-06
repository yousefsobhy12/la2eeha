import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../cubit/verify_email_cubit.dart';
import '../cubit/verify_email_state.dart';

class VerifyEmailView extends StatelessWidget {
  final String email;
  const VerifyEmailView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyEmailCubit>(
      create: (_) => VerifyEmailCubit(
        AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
      ),
      child: _VerifyEmailViewBody(email: email),
    );
  }
}

class _VerifyEmailViewBody extends StatefulWidget {
  final String email;
  const _VerifyEmailViewBody({required this.email});

  @override
  State<_VerifyEmailViewBody> createState() => _VerifyEmailViewBodyState();
}

class _VerifyEmailViewBodyState extends State<_VerifyEmailViewBody> {
  late final TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  String get _otpCode => _pinController.text;
  bool get _isComplete => _otpCode.length == 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Column(
        children: [
          AuthHeader(showSubtitle: false, onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                children: [
                  SizedBox(height: context.largeSpacing),
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 64.r,
                    color: context.colorScheme.primary,
                  ),
                  SizedBox(height: context.mediumSpacing),
                  'تأكيد الإيميل'.toResponsiveText(
                    context,
                    style: AppTextStyles.cardTitle(context.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.smallSpacing),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'بعتنا كود من 6 أرقام على ',
                          style: AppTextStyles.bodyRegular13(
                            context.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: widget.email,
                          style: AppTextStyles.bodyBold14(context.textPrimary),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: context.largeSpacing),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final gapWidth = 8.w;
                      final totalGaps = gapWidth * 5;
                      final boxWidth = (constraints.maxWidth - totalGaps) / 6;

                      final defaultPinTheme = PinTheme(
                        width: boxWidth,
                        height: 56.h,
                        textStyle: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: context.borderColor),
                        ),
                      );

                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          length: 6,
                          controller: _pinController,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(
                                color: context.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          separatorBuilder: (index) =>
                              SizedBox(width: gapWidth),
                          onChanged: (value) => setState(() {}),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: context.largeSpacing),
                  BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
                    listenWhen: (previous, current) =>
                        previous.status != current.status,
                    listener: (context, state) {
                      if (state.status == VerifyEmailStatus.success) {
                        context.go('/add-place');
                      } else if (state.status == VerifyEmailStatus.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.failure?.message ?? 'حصل خطأ'),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final button = CustomElevatedButton(
                        text: 'تأكيد',
                        isLoading: state.status == VerifyEmailStatus.loading,
                        onPressed: _isComplete
                            ? () => context.read<VerifyEmailCubit>().verify(
                                widget.email,
                                _otpCode,
                              )
                            : () {},
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

                      if (!_isComplete) return button.disabled();
                      return button;
                    },
                  ),
                  SizedBox(height: context.mediumSpacing),
                  BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
                    builder: (context, state) {
                      if (state.secondsRemaining > 0) {
                        return Center(
                          child:
                              'ممكن تعيد الإرسال بعد 00:${state.secondsRemaining.toString().padLeft(2, '0')}'
                                  .toResponsiveText(
                                    context,
                                    style: AppTextStyles.captionRegular12(
                                      context.textSecondary,
                                    ),
                                  ),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          'لم يصلك الكود؟ '.toResponsiveText(
                            context,
                            style: AppTextStyles.captionRegular12(
                              context.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context
                                .read<VerifyEmailCubit>()
                                .resend(widget.email),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'إعادة الإرسال',
                              style: AppTextStyles.captionRegular12(
                                context.colorScheme.primary,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: context.extraLargeSpacing),
                  Padding(
                    padding: context.cardPadding,
                    child:
                        'الإيميل غلط؟ ارجع للخطوة اللي قبلها وغيّره — بعد التأكيد هتروح على طول لصفحة إضافة مكان جديد.'
                            .toResponsiveText(
                              context,
                              style: AppTextStyles.captionRegular12(
                                context.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                  ),
                  SizedBox(height: context.extraLargeSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
