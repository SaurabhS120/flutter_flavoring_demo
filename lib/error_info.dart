class ErrorInfo {
  final String message;
  final int? code;
  final String description;
  final ErrorColor? color;

  ErrorInfo({required this.message, this.code, this.description: '',this.color});

}
enum ErrorColor{
  RED,ORANGE;
}