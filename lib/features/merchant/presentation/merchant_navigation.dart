import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/repositories/merchant_repository.dart';

Future<void> navigateToMerchantEntry(
  BuildContext context,
  MerchantRepository repo, {
  bool replaceCurrent = false,
}) async {
  final result = await repo.getMyLatestPlace();
  if (!context.mounted) return;

  result.fold((failure) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('مقدرناش نتأكد من بيزنسك، جرّب تاني')),
      );
    return;
  }, (summary) {
    if (summary == null) {
      replaceCurrent
          ? context.pushReplacement('/add-place')
          : context.go('/add-place');
      return;
    }
    replaceCurrent
        ? context.pushReplacement('/my-places')
        : context.push('/my-places');
  });
}
