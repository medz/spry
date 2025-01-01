---
title: Guide → Event Object
description: Event object carries an incoming request and context.
---

# Event Object

{{ $frontmatter.description }}

---

Every time a new HTTP request comes, Spry internally creates an Event object and passes it though event handlers until sending the response.

An event is passed through all the lifecycle hooks and composable utils to use it as context.

APIs:

- `event.app`: Gets the spry app instance.
- `event.locals`: The event shared data.
- `event.request`: request instance.
- `event.params`: Request event matched route params.
- `event.address`: Remote address.
- `event.headers`: Gets the request headers, this is the `event.request.headers` alias.
