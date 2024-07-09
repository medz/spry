/// Spry constants
///
/// This library exports [Spry] internal content keys stored in [Locals].
library spry.constants;

/// Store the key of the [Spry] application instance in [Locals].
const kAppInstance = #spry.app;

/// The key stored in [Locals] for instances implemented on the [Platform].
const kPlatform = #spry.platform;

/// This constant is the key stored in [Locals] for the RAW request
const kRawRequest = #spry.event.request.raw;

/// The key stored in [Locals] for routing [Params].
const kEventParams = #spry.event.params;

/// This is the key stored in [Locals] for storing matching route.
const kEventRoute = #spry.event.route;
