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
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(
        AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
      ),
      child: const _ForgotPasswordViewBody(),
    );
  }
}

class _ForgotPasswordViewBody extends StatefulWidget {
  const _ForgotPasswordViewBody();

  @override
  State<_ForgotPasswordViewBody> createState() =>
      _ForgotPasswordViewBodyState();
}

class _ForgotPasswordViewBodyState extends State<_ForgotPasswordViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
                  SizedBox(height: context.mediumSpacing),
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
                        'استعادة كلمة السر'.toResponsiveText(
                          context,
                          style: AppTextStyles.cardTitle(context.textPrimary),
                        ),
                        SizedBox(height: context.smallSpacing),
                        'اكتب إيميلك وهنبعتلك كود لتغيير كلمة السر'
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
                              BlocConsumer<
                                ForgotPasswordCubit,
                                ForgotPasswordState
                              >(
                                listenWhen: (previous, current) =>
                                    previous.runtimeType != current.runtimeType,
                                listener: (context, state) {
                                  if (state is ForgotPasswordSuccess) {
                                    context.push(
                                      '/reset-otp',
                                      extra: _emailController.text.trim(),
                                    );
                                  } else if (state is ForgotPasswordError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.failure.message),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return CustomElevatedButton(
                                    text: 'إرسال الكود',
                                    isLoading: state is ForgotPasswordLoading,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<ForgotPasswordCubit>()
                                            .sendResetCode(
                                              _emailController.text.trim(),
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
                      ],
                    ),
                  ),
                  SizedBox(height: context.mediumSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
