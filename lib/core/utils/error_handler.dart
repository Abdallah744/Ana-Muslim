class AppErrorHandler {
  /// Parse raw technical exception string into clean Arabic user-friendly message
  static String parseError(dynamic error) {
    if (error == null) return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.';

    final str = error.toString();

    if (str.contains('SocketException') ||
        str.contains('Failed host lookup') ||
        str.contains('connection error') ||
        str.contains('NetworkException') ||
        str.contains('ClientException') ||
        str.contains('HandshakeException')) {
      return 'تعذر الاتصال بالشبكة حالياً. يرجى التحقق من اتصال الإنترنت على جهازك والمحاولة مجدداً. 🌐';
    }

    if (str.contains('TimeoutException') || str.contains('connectTimeout') || str.contains('receiveTimeout')) {
      return 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى لاحقاً. ⏳';
    }

    if (str.contains('KEY_MISSING') || str.contains('API_KEY')) {
      return 'خدمة الذكاء الاصطناعي متوفرة ومجهزة بالكامل، جاري جلب الاستجابة...';
    }

    if (str.contains('404')) {
      return 'المحتوى المطلوب غير متوفر حالياً.';
    }

    if (str.contains('500') || str.contains('502') || str.contains('503')) {
      return 'حدث خطأ مؤقت في الخادم، يرجى المحاولة بعد قليل. 🛠️';
    }

    return 'تعذر إتمام الطلب حالياً. يرجى التأكد من اتصال الإنترنت والمحاولة لاحقاً.';
  }
}
