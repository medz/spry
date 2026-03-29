/// Public runtime surface for generated Spry clients.
library;

/// Re-exported Fetch-style headers type used by generated clients.
export 'package:ht/ht.dart'
    show
        BodyInit,
        Headers,
        HttpMethod,
        Request,
        RequestInit,
        Response,
        URLSearchParams;
export 'package:oxy/oxy.dart' show Oxy, OxyConfig;

/// Base runtime types for generated Spry clients.
export 'src/client/base_client.dart';

/// Shared base type for generated route helpers.
export 'src/client/client_routes.dart';
