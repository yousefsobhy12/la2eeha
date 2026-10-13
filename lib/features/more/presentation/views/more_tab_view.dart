import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_view.dart';
import 'more_view.dart';

class MoreTabView extends StatelessWidget {
  const MoreTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, _) {
        final loggedIn = Supabase.instance.client.auth.currentSession != null;
        return loggedIn ? const AccountView() : const MoreView();
      },
    );
  }
}
