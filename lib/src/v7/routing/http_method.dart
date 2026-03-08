enum HttpMethod { any, get, post, put, patch, delete, head, options }

extension HttpMethodLookup on HttpMethod {
  static HttpMethod fromRequestMethod(String method) {
    return switch (method.toUpperCase()) {
      'GET' => HttpMethod.get,
      'POST' => HttpMethod.post,
      'PUT' => HttpMethod.put,
      'PATCH' => HttpMethod.patch,
      'DELETE' => HttpMethod.delete,
      'HEAD' => HttpMethod.head,
      'OPTIONS' => HttpMethod.options,
      _ => throw ArgumentError.value(
        method,
        'method',
        'Unsupported HTTP method',
      ),
    };
  }
}
