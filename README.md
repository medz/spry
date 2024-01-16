# Spry

Spry is an HTTP middleware framework for Dart to make web applications and APIs server more enjoyable to write.

```dart
import 'package:spry/spry.dart';

final app = Application.late();

main() async {
  app.get("hello", (request) => "Hello, Spry!");

  await app.run(port: 3000);
}
```

👉 [**Learn more about Spry at Spry Documentation.**](https://spry.fun/)

## Philosophy

Spry is a framework for building web applications and APIs. It is designed to be minimal and flexible.

## Sponsors

Spry framework is an [MIT licensed](LICENSE) open source project with its ongoing development made possible entirely by the support of these awesome backers. If you'd like to join them, please consider [sponsoring Odroe development](https://github.com/sponsors/odroe).

<p align="center">
  <a target="_blank" href="https://github.com/sponsors/odroe#sponsors">
    <img alt="sponsors" src="https://github.com/odroe/.github/raw/main/sponsors.svg">
  </a>
</p>

## Contributing

We welcome contributions! Please read our [contributing guide](CONTRIBUTING.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to Prisma.

Thank you to all the people who already contributed to Odroe!

[![Contributors](https://opencollective.com/openodroe/contributors.svg?width=890)](https://github.com/odroe/prisma-dart/graphs/contributors)

## Code of Conduct

This project has adopted the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). For more information see the [Code of Conduct FAQ](https://www.contributor-covenant.org/faq) or contact [hello@odroe.com](mailto:hello@odroe.com) with any additional questions or comments.
