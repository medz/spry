---
title: Guide → Event Object
description: Event object carries an incoming request and context.
---

# Event Object

{{ $frontmatter.description }}

---

Every time a new HTTP request comes, Spry internally creates an Event object and passes it though event handlers until sending the response.

An event is passed through all the lifecycle hooks and composable utils to use it as context.

**Example**:

```dart
app.use((event) {
    final params = useParams(event);
    final uri = useRequestURI(event);

    print('Request URI: $uri, Params: $params');
});
```

## Sets a value to event.

```dart
app.use((event) {
    event.set('hello', 'Spry');
});
```

## Gets a set value

```dart
app.use((event) {
    final hello = event.get('hello');

    print(hello);
});
```

## Remove a value

```dart
app.use((event) {
    event.remove('hello');
});
```
