---
title: Getting Started
---

# Getting Started

This chapter will help you build a Spry-based web application from scratch. If you already have a Dart web app, start at step 2.

## 1. Create a new project

We recommend that you use the `dart create` command to create a new project. This command will create a new project with a `pubspec.yaml` file, a `bin` directory, a `lib` directory, and a `test` directory.

```bash
$ dart create hello_spry
```

You can then use the `cd` command to move into the newly created project directory.

```bash
$ cd hello_spry
```

## 2. Install Spry

You can manually add the Spry dependency to the `pubspec.yaml` file:

```yaml
dependencies:
   spry: any
```

Alternatively, you can use the `dart pub add` command to add a Spry dependency:

```bash
$ dart pub add spray
```

## 3. Create a Spry application

Now, you can create a Spry application. Create a file called `server.dart` in the `bin` directory and copy the code below into the file.

```dart
import 'package:spry/spry.dart';

void handler(Context context) {
   context.response.send('Hello, Spry!');
}

void main() async {
   final Spry spray = Spry();

   await spry. listen(handler, port: 3000);

   print('Spry is listening http://localhost:3000');
}
```

## 4. Run the Spry application

We use the `dart run` command to run the Spry application.

```bash
$ dart run bin/server.dart
```

The Spry application will listen for requests on `http://localhost:3000`, which you can access using a browser or the `curl` command.

```bash
$ curl http://localhost:3000
```

## What's next?

So far, you have a Spry-based application. Now, you can start learning how to use Spry to build a more complex application.