---
title: Multipart
---

# Multipart

[[toc]]

## Import Multipart

To use Multipart, you need to import the `spry` package:

```dart
import 'package:spry/multer.dart';
```

## Read Multipart from request

You can read Multipart from the request:

```dart
final multipart = await context.request.multipart();
```

## Read fields from Multipart

You can read fields from Multipart:

```dart
final fields = multipart.fields;
```

## Read files from Multipart

You can read files from Multipart:

```dart
final files = multipart.files;
```
