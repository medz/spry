# Spry

[![Test](https://github.com/medz/spry/actions/workflows/test.yml/badge.svg)](https://github.com/medz/spry/actions/workflows/test.yml)
[![Pub Version](https://img.shields.io/pub/v/spry.svg)](https://pub.dev/packages/spry)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/medz/spry/blob/main/LICENSE)
[![X (twitter)](https://img.shields.io/badge/twitter-%40shiweidu-blue.svg)](https://twitter.com/shiweidu)
[![Documentation](https://img.shields.io/badge/docs-spry.fun-brightgreen.svg)](https://spry.fun/)

Spry is an HTTP middleware framework for Dart to make web applications and APIs server more enjoyable to write.

```dart
import 'package:spry/spry.dart';

main() async {
  final app = Application.late();

  app.get("hello", (request) => "Hello, Spry!");

  await app.run(port: 3000);
}
```

👉 [**Learn more about Spry at Spry Documentation.**](https://spry.fun/)

## Philosophy

Spry is a framework for building web applications and APIs. It's designed around dart:io, no boring creations, just lots of magic.

## Sponsors

Spry framework is an [MIT licensed](https://github.com/medz/spry/blob/main/LICENSE) open source project with its ongoing development made possible entirely by the support of these awesome backers. If you'd like to join them, please consider [sponsoring Seven(@medz)](https://github.com/sponsors/odroe) or [sponsor us on OpenCollective](https://opencollective.com/openodroe) development.

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
