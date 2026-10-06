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
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(
        AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
      ),
      child: const _ResetPasswordViewBody(),
    );
  }
}

class _ResetPasswordViewBody extends StatefulWidget {
  const _ResetPasswordViewBody();

  @override
  State<_ResetPasswordViewBody> createState() => _ResetPasswordViewBodyState();
}

class _ResetPasswordViewBodyState extends State<_ResetPasswordViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
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
          const AuthHeader(showSubtitle: false),
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
                        'كلمة سر جديدة'.toResponsiveText(
                          context,
                          style: AppTextStyles.cardTitle(context.textPrimary),
                        ),
                        SizedBox(height: context.smallSpacing),
                        'اختار كلمة سر جديدة لحسابك'.toResponsiveText(
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
                                controller: _passwordController,
                                labelText: 'كلمة السر الجديدة',
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'برجاء إدخال كلمة السر الجديدة';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة السر لازم تكون 6 حروف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.mediumSpacing),
                              CustomTextFormField(
                                controller: _confirmPasswordController,
                                labelText: 'تأكيد كلمة السر',
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'برجاء تأكيد كلمة السر';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'كلمتا السر مش متطابقتين';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.mediumSpacing),
                              BlocConsumer<
                                ResetPasswordCubit,
                                ResetPasswordState
                              >(
                                listenWhen: (previous, current) =>
                                    previous.runtimeType != current.runtimeType,
                                listener: (context, state) {
                                  if (state is ResetPasswordSuccess) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تم تغيير كلمة السر بنجاح',
                                        ),
                                      ),
                                    );
                                    context.go('/login');
                                  } else if (state is ResetPasswordError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.failure.message),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return CustomElevatedButton(
                                    text: 'تحديث كلمة السر',
                                    isLoading: state is ResetPasswordLoading,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<ResetPasswordCubit>()
                                            .updatePassword(
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
