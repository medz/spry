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

  String? get routerToken => switch (this) {
    HttpMethod.any => null,
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    HttpMethod.put => 'PUT',
    HttpMethod.patch => 'PATCH',
    HttpMethod.delete => 'DELETE',
    HttpMethod.head => 'HEAD',
    HttpMethod.options => 'OPTIONS',
  };
}
