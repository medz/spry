# Spry

[![Test](https://github.com/medz/spry/actions/workflows/test.yml/badge.svg)](https://github.com/medz/spry/actions/workflows/test.yml)
[![Pub Version](https://img.shields.io/pub/v/spry.svg)](https://pub.dev/packages/spry)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/medz/spry/blob/main/LICENSE)
[![X (twitter)](https://img.shields.io/badge/twitter-%40shiweidu-blue.svg)](https://twitter.com/shiweidu)
[![Documentation](https://img.shields.io/badge/docs-spry.fun-brightgreen.svg)](https://spry.fun/)

Spry is a lightweight, composable Dart web framework designed to work collaboratively with various runtime platforms.

```dart
import 'package:spry/spry.dart';

main() async {
  final app = Spry();

  app.get("hello", (request) => "Hello, Spry!");
}
```

👉 [**Learn more about Spry at Spry Documentation.**](https://spry.fun/)

## Sponsors

Spry framework is an [MIT licensed](https://github.com/medz/spry/blob/main/LICENSE) open source project with its ongoing development made possible entirely by the support of these awesome backers. If you'd like to join them, please consider [sponsoring Seven(@medz)](https://github.com/sponsors/odroe) development.

<p align="center">
  <a target="_blank" href="https://github.com/sponsors/odroe#sponsors">
    <img alt="sponsors" src="https://github.com/odroe/.github/raw/main/sponsors.svg">
  </a>
</p>

## Contributing

We welcome contributions! Please read our [contributing guide](CONTRIBUTING.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to Prisma.

Thank you to all the people who already contributed to Odroe!

[![Contributors](https://opencollective.com/openodroe/contributors.svg?width=890)](https://github.com/odroe/prisma-dart/graphs/contributors)
