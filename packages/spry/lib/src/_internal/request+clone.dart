// ignore_for_file: file_names

import 'request.dart';
import 'stream+clone.dart';

extension SpryRequest$Clone on SpryRequest {
  SpryRequest clone() {
    final (stream1, stream2) = stream.clone();

    // Replace the original stream with the clone.
    stream = stream1;

    // Create a new request with the cloned stream.
    return SpryRequest(
      application: application,
      request: request,
      response: response,
      stream: stream2,
      locals: locals,
    );
  }
}
