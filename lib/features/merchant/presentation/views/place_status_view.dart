import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/datasource/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../../domain/repositories/merchant_repository.dart';
import 'pricing_args.dart';

class PlaceStatusView extends StatefulWidget {
  final PricingArgs args;

  const PlaceStatusView({super.key, required this.args});

  @override
  State<PlaceStatusView> createState() => _PlaceStatusViewState();
}

class _PlaceStatusViewState extends State<PlaceStatusView> {
  late final MerchantRepository _repository;

  bool _loading = true;
  bool? _isApproved;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = MerchantRepositoryImpl(
      remoteDataSource: MerchantRemoteDataSource(),
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repository.isPlaceApproved(
      placeId: widget.args.placeId,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (approved) => setState(() {
        _loading = false;
        _isApproved = approved;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            ColoredSectionHeader(
              title: 'حالة البيزنس',
              subtitle: widget.args.placeName,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: context.colorScheme.onPrimary,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: context.iconColor),
              context.smallSpacing.vSpace,
              _error!.toBody(
                context,
                color: context.textSecondary,
                textAlign: TextAlign.center,
              ),
              context.smallSpacing.vSpace,
              ElevatedButton(
                onPressed: _load,
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

    final approved = _isApproved ?? false;
    final icon = approved
        ? Icons.check_circle_rounded
        : Icons.hourglass_empty_rounded;
    final iconColor = approved
        ? const Color(0xFF2F6B3A)
        : context.colorScheme.primary;
    final title = approved ? 'بيزنسك متاح دلوقتي ✅' : 'بيزنسك قيد المراجعة';
    final subtitle = approved
        ? 'إدارة بياناتك وإضافة فروع هتتاح قريبًا'
        : 'هنراجع البيانات ونوافق عليه في أقرب وقت';

    return Center(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72.r, color: iconColor),
            context.mediumSpacing.vSpace,
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            context.smallSpacing.vSpace,
            subtitle.toBody(
              context,
              color: context.textSecondary,
              textAlign: TextAlign.center,
            ),
            context.largeSpacing.vSpace,
            CustomElevatedButton(
              text: 'الرئيسية',
              onPressed: () => context.go('/'),
              backgroundColor: context.colorScheme.primary,
              textColor: context.colorScheme.onPrimary,
              height: context.buttonHeight,
              fontWeight: FontWeight.bold,
              borderRadius: context.largeRadius,
            ),
          ],
        ),
      ),
    );
  }
}
