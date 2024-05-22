class PushNotificationError {
  final String message;
  PushNotificationError({
    required this.message,
    required int pushNotificationError,
    required Exception cause,
  });

  @override
  String getFriendlyMessage() {
    return "${message}";
  }
}
