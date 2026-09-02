// lib/core/network/network_info.dart
//
// بيغلف connectivity_plus ويوفر طريقة بسيطة لمعرفة لو الجهاز متصل بالنت ولا لأ.
// بنستخدمه في safeSupabaseCall عشان نفحص الاتصال قبل أي request.

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// بيرجع true لو الجهاز متصل بأي نوع اتصال (wifi أو mobile data).
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}

/// Singleton عام — نفس نمط supabase_client_provider.dart
final NetworkInfo networkInfo = NetworkInfo(Connectivity());
