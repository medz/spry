# Spry interceptor

Exception interceptor for Spry, which intercepts exceptions and errors and writes response to prevent unexpected application interruption.

## Example

```dart
import 'package:spry/spry.dart';
import 'package:spry_interceptor/spry_interceptor.dart';

void main() {
  final Spry spry = Spry();
  final Interceptor interceptor = Interceptor(
    handler: ExceptionHandler.json(),
  );

  handler(Context context) {
    throw HttpException.forbidden();
  }

  spry.use(interceptor);
  spry.listen(handler, port: 3000);

  print('Listening om http://localhost:3000');
}
```

## Documentation

Read the [documentation site](https://spry.fun).

