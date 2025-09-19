import 'package:prestige_pos/model/error/problem_detail.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;
  final ProblemDetail? body;

  ApiResponse.success(this.data) : error = null, success = true, body = null;

  ApiResponse.error(this.error) : data = null, success = false, body = null;
  ApiResponse.withProblemDetail(this.body)
      : data = null,
        error = body?.detail ?? 'Erreur inconnue',
        success = false;

}
