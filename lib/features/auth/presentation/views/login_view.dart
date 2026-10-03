import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/core/constants/app_icons.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_txt_form_field.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../../../merchant/data/datasource/merchant_remote_datasource.dart';
import '../../../merchant/data/repositories/merchant_repository_impl.dart';
import '../../../merchant/presentation/merchant_navigation.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
      ),
      child: const _LoginViewBody(),
    );
  }
}

class _LoginViewBody extends StatefulWidget {
  const _LoginViewBody();

  @override
  State<_LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<_LoginViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Column(
        children: [
          AuthHeader(showSubtitle: true, onBack: context.pop),
          Expanded(
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                children: [
                  SizedBox(height: context.mediumSpacing),
                  // ── Main Card ──
                  Container(
                    padding: context.cardPadding,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(
                        context.extraLargeRadius,
                      ),
                      border: Border.all(
                        color: context.borderColor,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        'دخول التجار'.toResponsiveText(
                          context,
                          style: AppTextStyles.cardTitle(context.textPrimary),
                        ),
                        SizedBox(height: context.smallSpacing),
                        'ادخل ببيانات حسابك'.toResponsiveText(
                          context,
                          style: AppTextStyles.bodyRegular13(
                            context.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.mediumSpacing),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextFormField(
                                controller: _emailController,
                                labelText: 'الإيميل',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'برجاء إدخال الإيميل';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'برجاء إدخال إيميل صحيح';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.mediumSpacing),
                              CustomTextFormField(
                                controller: _passwordController,
                                labelText: 'كلمة السر',
                                obscureText: obscureText,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'برجاء إدخال كلمة السر';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    obscureText = !obscureText;
                                    setState(() {});
                                  },
                                  icon: obscureText == true
                                      ? SvgPicture.asset(
                                          'assets/svg/eye-opened-icon.svg',
                                          height: context.smallIconSize,
                                        ).iconSwap(
                                          key: const ValueKey('eye_opened'),
                                          flip: false,
                                        )
                                      : SvgPicture.asset(
                                          'assets/svg/eye-closed-icon.svg',
                                          height: context.smallIconSize * 1.1,
                                        ).iconSwap(
                                          key: const ValueKey('eye_closed'),
                                        ),
                                ),
                              ),
                              SizedBox(height: context.smallSpacing),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton(
                                  onPressed: () =>
                                      // showComingSoon(context),
                                      context.push('/forgot-password'),
                                  child: Text(
                                    'نسيت كلمة السر؟',
                                    style: AppTextStyles.captionRegular12(
                                      context.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.mediumSpacing),
                              BlocConsumer<LoginCubit, LoginState>(
                                listener: (context, state) {
                                  if (state is LoginSuccess) {
                                    navigateToMerchantEntry(
                                      context,
                                      MerchantRepositoryImpl(
                                        remoteDataSource:
                                            MerchantRemoteDataSource(),
                                      ),
                                    );
                                  } else if (state is LoginError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.failure.message),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return CustomElevatedButton(
                                    text: 'دخول',
                                    isLoading: state is LoginLoading,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<LoginCubit>().login(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        );
                                      }
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
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.mediumSpacing),
                        // ── "أو" Divider ──
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                'أو',
                                style: AppTextStyles.captionRegular12(
                                  context.textSecondary,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: context.mediumSpacing),
                        // ── Google ──
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            return CustomElevatedButton(
                              text: 'المتابعة بحساب Google',
                              isOutlined: true,
                              borderColor: AppColors.primary,
                              textColor: context.textPrimary,
                              isLoading: state is LoginLoading,
                              onPressed: () =>
                                  context.read<LoginCubit>().signInWithGoogle(),
                              icon: SvgPicture.asset(
                                AppIcons.googleIcon,
                                height: context.smallIconSize,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: context.smallSpacing),
                        // ── Apple (disabled) ──
                        CustomElevatedButton(
                          text: 'المتابعة بحساب Apple',
                          isOutlined: true,
                          borderColor: context.textPrimary,
                          textColor: context.textPrimary,
                          onPressed: () => showComingSoon(context),
                          icon: SvgPicture.asset(
                            'assets/svg/apple-icon.svg',
                            height: context.smallIconSize,
                          ),
                        ),
                        SizedBox(height: context.mediumSpacing),
                        // ── Register link ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            'لسه معندكش حساب؟ '.toResponsiveText(
                              context,
                              style: AppTextStyles.bodyRegular13(
                                context.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: Text(
                                'سجّل مكانك',
                                style: AppTextStyles.bodyBold14(
                                  context.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.mediumSpacing),
                  // ── Info box ──
                  Container(
                    padding: context.cardPadding,
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(context.largeRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              'التسجيل للتجار وأصحاب الأماكن فقط — لو بتدور على مكان، استخدم البحث في الصفحة الرئيسية.'
                                  .toResponsiveText(
                                    context,
                                    style: AppTextStyles.captionRegular12(
                                      context.textSecondary,
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.mediumSpacing),
                  // ── Footer ──
                  Center(
                    child: '🔒 بياناتك محفوظة ومش بنشاركها مع أي طرف تالت'
                        .toResponsiveText(
                          context,
                          style: AppTextStyles.captionRegular12(
                            context.textSecondary,
                          ),
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
