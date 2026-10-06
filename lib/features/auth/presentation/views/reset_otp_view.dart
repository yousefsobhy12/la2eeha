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
import '../cubit/reset_otp_cubit.dart';
import '../cubit/reset_otp_state.dart';

class ResetOtpView extends StatelessWidget {
  final String email;
  const ResetOtpView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetOtpCubit>(
      create: (_) => ResetOtpCubit(
        AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
      ),
      child: _ResetOtpViewBody(email: email),
    );
  }
}

class _ResetOtpViewBody extends StatefulWidget {
  final String email;
  const _ResetOtpViewBody({required this.email});

  @override
  State<_ResetOtpViewBody> createState() => _ResetOtpViewBodyState();
}

class _ResetOtpViewBodyState extends State<_ResetOtpViewBody> {
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
                  'تأكيد الكود'.toResponsiveText(
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
                  BlocConsumer<ResetOtpCubit, ResetOtpState>(
                    listenWhen: (previous, current) =>
                        previous.status != current.status,
                    listener: (context, state) {
                      if (state.status == ResetOtpStatus.success) {
                        context.go('/reset-password');
                      } else if (state.status == ResetOtpStatus.error) {
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
                        isLoading: state.status == ResetOtpStatus.loading,
                        onPressed: _isComplete
                            ? () => context.read<ResetOtpCubit>().verify(
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
                  BlocBuilder<ResetOtpCubit, ResetOtpState>(
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
                                .read<ResetOtpCubit>()
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
                        'الإيميل غلط؟ ارجع للخطوة اللي قبلها وغيّره — بعد التأكيد هتقدر تحط كلمة سر جديدة.'
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
