class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'AppException: $message\nDetails: $details';
    }
    return 'AppException: $message';
  }
}