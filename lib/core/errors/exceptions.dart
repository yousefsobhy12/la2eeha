// lib/core/errors/exceptions.dart
//
// دول بيترموا من الـ data layer بس (RemoteDataSource) — مبيوصلوش للـ Cubit خالص.
// الـ Repository (طبقة نص) هو اللي بيمسكهم ويحولهم لـ Failure المناسب من
// failures.dart. الفرق بين الاتنين:
//   - Exception  → تفصيلة تقنية جوه الـ data layer (إيه اللي حصل بالظبط)
//   - Failure    → حاجة الـ presentation layer (الـ Cubit/UI) تفهمها وتتعامل معاها

class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}
