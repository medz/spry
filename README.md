# Spry

Spry is an HTTP middleware framework for Dart to make web applications and APIs server more enjoyable to write.

```dart
import 'package:spry/spry.dart';

main() {
  final Spry spry = Spry();

  handler(Context context) {
    context.response.text('Hello Spry!');
  }

  spry.listen(port: 3000, handler);
}
```

> **Starter**: You can clone the [Spry starter](https://github.com/odroe/spry-starter) to get started with a basic Spry application.

## Philosophy

Spry is a framework for building web applications and APIs. It is designed to be minimal and flexible.

## Sponsors

Spry framework is an [MIT licensed](LICENSE) open source project with its ongoing development made possible entirely by the support of these awesome backers. If you'd like to join them, please consider [sponsoring Odroe development](https://github.com/sponsors/odroe).

<p align="center">
  <a target="_blank" href="https://github.com/sponsors/odroe#sponsors">
    <img alt="sponsors" src="https://github.com/odroe/.github/raw/main/sponsors.svg">
  </a>
</p>

## Ecosystem

| Package                                        | Version                                                                                                        | Description                                                                                                                                                                                                   |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [spry](packages/spry)                          | [![pub package](https://img.shields.io/pub/v/spry.svg)](https://pub.dev/packages/spry)                         | Spry is an HTTP middleware framework for Dart to make web applications and APIs more enjoyable to write.                                                                                                      |
| [spry_router](packages/spry_router/)           | [![pub package](https://img.shields.io/pub/v/spry_router.svg)](https://pub.dev/packages/spry_router)           | A request router for the Spry web framework that supports matching handlers from path expressions.                                                                                                            |
| [spry_session](packages/spry_session/)         | [![pub package](https://img.shields.io/pub/v/spry_session.svg)](https://pub.dev/packages/spry_session)         | A session extension for the Spry web framework that supports cookie-based and memory-based sessions.                                                                                                          |
| [spry_json](packages/spry_json/)               | [![pub package](https://img.shields.io/pub/v/spry_json.svg)](https://pub.dev/packages/spry_json)               | Spry JSON middleware and request/response extension, used to convert request body to JSON object or set response body to JSON object.                                                                         |
| [spry_interceptor](packages/spry_interceptor/) | [![pub package](https://img.shields.io/pub/v/spry_interceptor.svg)](https://pub.dev/packages/spry_interceptor) | Exception interceptor for Spry, which intercepts exceptions and errors and writes response to prevent unexpected application interruption.                                                                    |
| [spry_static](packages/spry_static/)           | [![pub package](https://img.shields.io/pub/v/spry_static.svg)](https://pub.dev/packages/spry_static)           | A static file server for the Spry web framework that supports serving static files from a directory.                                                                                                          |
| [spry_fsrouter](packages/spry_fsrouter/)       | [![pub package](https://img.shields.io/pub/v/spry_fsrouter.svg)](https://pub.dev/packages/spry_fsrouter)       | Define Spry router in the way of filesystem router layout, it builds on top of [spry_router](https://pub.dev/packages/spry_router), supports group route mount, nested route, handler mount, middleware, etc. |
| [spry_urlencoded](packages/spry_urlencoded/)   | [![pub package](https://img.shields.io/pub/v/spry_urlencoded.svg)](https://pub.dev/packages/spry_urlencoded)   | Spry URL-encoded middleware and request extension, used to convert request body to URL-encoded object.                                                                                                        |
| [spry_multer](packages/spry_multer/)           | [![pub package](https://img.shields.io/pub/v/spry_multer.svg)](https://pub.dev/packages/spry_multer)           | Spry multer is a Spry framework middleware & extension for handling `multipart/form-data`, which is primarily used for uploading files.                                                                       |

## Contributing

We welcome contributions! Please read our [contributing guide](CONTRIBUTING.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to Prisma.

Thank you to all the people who already contributed to Odroe!

[![Contributors](https://opencollective.com/openodroe/contributors.svg?width=890)](https://github.com/odroe/prisma-dart/graphs/contributors)

## Code of Conduct

This project has adopted the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). For more information see the [Code of Conduct FAQ](https://www.contributor-covenant.org/faq) or contact [hello@odroe.com](mailto:hello@odroe.com) with any additional questions or comments.

## Stay in touch

- [Website](https://prisma.pub)
- [Twitter](https://twitter.com/odroeinc)
- [Discord](https://discord.gg/r27AjtUUbV)
