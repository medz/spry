---
title: Basics → Request
---

# Request

Spry's request object is the `HttpRequest` object from `dart:io`. We assume that you are already familiar with it. If you are not familiar with it, you can check out [dart:io → HTTP Request](https://api.dart.dev/stable/dart-io/HttpRequest-class.html) documentation.

Next, let’s take a look at the magic Spry adds to `HttpRequest`:

[[toc]]

## Application

On any request, you have access to the Spry `Application` instance.

::: warning

You can modify the runtime configuration to a limited extent. Of course, modifications such as `routes`, `middleware`, etc. will be invalid after your Spry application has been started.

:::

```dart
app.get('/config', (request) {
    return {
        "encoding": request.application.encoding.name,
    };
});
```

## Clone

Theoretically, `dart:io`'s `HttpRequest` is designed based on `Stream`. Once you read the stream data, you cannot read it again.

```dart
request.listen((event) { ... }); // ✅
request.listen((event) { ... }); // ❌ Error: Stream has already been listened to.
```

But we usually have to read data in some special Handler or middleware, but do not expect to affect subsequent Handlers or middleware. At this time, we can use the `clone` method to clone a new `HttpRequest ` Object.

```dart
final request2 = request.clone();

request2.listen((event) { ... }); // ✅
request.listen((event) { ... });  // ✅
```

## Form Data

Spry adds a `formData` method to `HttpRequest` for parsing data in `application/x-www-form-urlencoded` and `multipart/form-data` formats.

```dart
final formData = await request.formData();

for (final (name, _) in formData.entries()) {
    print("Form Data: $name");
}
```

::: tip

`FormData` is exported by `Spry`, but the implementation comes from [`package:webfetch`](https://pub.dev/packages/webfetch), which is based on [MDN FormData](https://developer.mozilla.org /en-US/docs/Web/API/FormData).

:::

## JSON

Spry adds a `json` method to `HttpRequest` for parsing data in `application/json` format.

```dart
final json = await request.json();
```

::: warning

The `json` method usually treats the incoming data as text, and then uses the `jsonDecode` method in `dart:convert` to parse the data, so if your data is not in `application/json` format, then you can use `text ` method to parse the data.

:::

### JSON performance

The performance of Dart's built-in json parser is not good. You can use middleware to implement custom JSON data parsing.

You can configure `#spry.json.codec` to tell Spry what `JsonCodec` should be used to parse JSON data.

```dart
app.locals[#spry.json.codec] = convert.json; // This is default.
```

::: tip

`spry.json.codec` also works with `request.locals`, but is useful with specifying `JsonCodec` for a single use.

:::

::: warning

Your custom JSON parser must implement the `JsonCodec` interface.

For more information about `JsonCodec`, check out the [dart:convert → JsonCodec](https://api.dart.dev/stable/dart-convert/JsonCodec-class.html) documentation.

:::

## Text

Spry adds `text` to `HttpRequest` to help you read the body as text.

```dart
final text = await request.text();
```

## URL Search Params

In addition to accessing URL information through `request.url`, Spry adds a `searchParams` attribute for parsing query parameters in the URL.

```dart
print(request.searchParams.get('name'));
```

::: tip

`searchParams` returns a `URLSearchParams` object, which is exported by `Spry`, but the implementation comes from [`package:webfetch`](https://pub.dev/packages/webfetch), which is based on [MDN URLSearchParams](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams).

:::

## Route

You can access the routing information of the current request through `request.route`.

```dart
print(request.route.path);
```

::: tip

For routing parameters, you can check out the [Basics → Routing](/basics/routing.md#route-parameters) documentation.

:::
