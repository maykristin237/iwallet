///
/// Date: 2023-07-16

class HttpErrorEvent {
  final int? code;
  final String message;
  final context;

  HttpErrorEvent(this.code, this.message, this.context);
}
