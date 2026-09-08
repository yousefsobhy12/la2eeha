import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_txt_form_field.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(
        AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
      ),
      child: const _RegisterViewBody(),
    );
  }
}

class _RegisterViewBody extends StatefulWidget {
  const _RegisterViewBody();

  @override
  State<_RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<_RegisterViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Column(
        children: [
          const AuthHeader(showSubtitle: true),
          Expanded(
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.mediumSpacing),
                  // ── Main Card ──
                  Container(
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      border: Border.all(
                        color: context.borderColor,
                        width: 1.2,
                      ),
                      borderRadius:
                          BorderRadius.circular(context.extraLargeRadius),
                    ),
                    padding: context.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        'حساب تاجر جديد'.toResponsiveText(
                          context,
                          style:
                              AppTextStyles.cardTitle(context.textPrimary),
                        ),
                        SizedBox(height: context.smallSpacing),
                        'سجّل مكانك عشان أهل المنطقة يلاقوك'
                            .toResponsiveText(
                          context,
                          style: AppTextStyles.bodyRegular13(
                            context.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.mediumSpacing),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextFormField(
                                labelText: 'اسم صاحب المكان',
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'الاسم مطلوب';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.mediumSpacing),
                              CustomTextFormField(
                                labelText: 'الإيميل',
                                controller: _emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'الإيميل مطلوب';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'صيغة الإيميل غير صحيحة';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.mediumSpacing),
                              CustomTextFormField(
                                labelText: 'كلمة السر',
                                controller: _passwordController,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'كلمة السر مطلوبة';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.mediumSpacing),
                              CustomTextFormField(
                                labelText: 'تأكيد كلمة السر',
                                controller:
                                    _confirmPasswordController,
                                obscureText: true,
                                validator: (value) {
                                  if (value !=
                                      _passwordController.text) {
                                    return 'كلمة السر مش متطابقة';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.mediumSpacing),
                        // ── Terms checkbox ──
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              activeColor:
                                  context.colorScheme.primary,
                            ),
                            Expanded(
                              child:
                                  'موافق على شروط الاستخدام وسياسة الخصوصية'
                                      .toResponsiveText(
                                context,
                                style:
                                    AppTextStyles.captionRegular12(
                                  context.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.mediumSpacing),
                        // ── Register button ──
                        BlocConsumer<RegisterCubit, RegisterState>(
                          listener: (context, state) {
                            if (state is RegisterSuccess) {
                              context.push(
                                '/verify-email',
                                extra: state.email,
                              );
                            } else if (state is RegisterError) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.failure.message,
                                  ),
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            final button = CustomElevatedButton(
                              text: 'إنشاء الحساب',
                              backgroundColor: AppColors.primary,
                              textColor: AppColors.onPrimary,
                              height: context.buttonHeight,
                              fontWeight: FontWeight.bold,
                              borderRadius: context.largeRadius,
                              boxShadow: const [
                                BoxShadow(
                                  color:
                                      AppColors.primaryPressedShadow,
                                  offset: Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ],
                              isLoading: state is RegisterLoading,
                              onPressed: () {
                                if (_agreedToTerms &&
                                    _formKey.currentState!
                                        .validate()) {
                                  context
                                      .read<RegisterCubit>()
                                      .register(
                                        _nameController.text.trim(),
                                        _emailController.text
                                            .trim(),
                                        _passwordController.text,
                                      );
                                }
                              },
                            );

                            if (!_agreedToTerms) {
                              return button.disabled();
                            }
                            return button;
                          },
                        ),
                        SizedBox(height: context.mediumSpacing),
                        // ── Login link ──
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            'عندك حساب؟ '.toResponsiveText(
                              context,
                              style: AppTextStyles.bodyRegular13(
                                context.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                'سجّل دخول',
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
