# Spry Multer

Spry multer is a Spry framework middleware & extension for handling multipart/form-data, which is primarily used for uploading files.

[![pub version](https://img.shields.io/pub/v/spry_multer.svg)](https://pub.dev/packages/spry_multer)

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  spry_multer: any
```

Or install via command line:

```bash
$ dart pub add spry_multer
```

## Getting Started

Spry multer is zero-configuration and only needs to be imported to use:

```dart
import 'package:spry/spry.dart';
import 'package:spry_multer/spry_multer.dart';

handler(Context context) async {
  final multipart = await context.request.multipart();

  //...
}
```

Basic usage example:

> **Note**: Don't forget to add `enctype="multipart/form-data"` to your form.

```html
<form action="/upload" method="post" enctype="multipart/form-data">
  <input type="file" name="file" />
</form>
```

```dart
import 'package:spry/spry.dart';
import 'package:spry_multer/spry_multer.dart';

handler(Context context) async {
  final multipart = await context.request.multipart();

  final file = multipart.files.first;

  //...
}
```

## Configuration

Spry multer can be configured with the following options:

```dart
final multer = Multer(encoding: utf8); // default

spry.use(multer);
```

> **Note**: Multer allow you to configure the encoding of the incoming form data. By default, Multer uses `Spry` encoding.
>
> The `Spry` encoding defaults to `utf8` and can be changed by setting the `Spry.encoding` property.

## API

### Multer

Options:
| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `encoding` | `Encoding` | `Spry.encoding` | The encoding of the incoming form data. |

Static methods:
| Name | Description |
| --- | --- |
| `of(context)` | Get the `Multer` instance from the `Context`. |
| `createMultipart(request)` | Create a `Multipart` instance from the `Request`. |

methods:
| Name | Description |
| --- | --- |
| `call(context, next)` | The middleware handler. |

### Multipart

Properties:
| Name | Type | Description |
| --- | --- | --- |
| `files` | `Iterable<File>` | The list of uploaded files. |
| `fields` | `Iterable<String>` | The list of uploaded fields. |

### File

Properties:
| Name | Type | Description |
| --- | --- | --- |
| `filename` | `String` | The name of the file on the user's computer. |
| `contentType` | `ContentType` | The content type of the file. |

> **Note**: The `File` class extends `Stream<List<int>>` and can be used as a `Stream` of bytes.

### Extension on `Request`

| Name | Description |
| --- | --- |
| `multipart()` | Find or parsed create a `Multipart` instance from the `Request`. |