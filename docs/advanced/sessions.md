---
title: Advanced → Sessions
---

# Sessions

Sessions allow you to persist a user's data between multiple requests. Sessions work by creating and returning a unique cookie alongside the HTTP response when a new session is initialized. Browsers will automatically detect this cookie and include it in future requests. This allows Vapor to automatically restore a specific user's session in your request handler.

Sessions are great for front-end web applications built in Spry that serve HTML directly to web browsers. For APIs, we recommend using stateless, token-based authentication to persist user data between requests.

## Overview

Spry does not encapsulate `Cookie` and `Session`, but directly uses the settings of `dart:io`

- `request.cookies` - Get all cookies in the request
- `request.response.cookies` - Set cookies in the response (`set-cookie`)
- `request.session` - Manage Session

::: warning

Currently Spry does not allow you to customize the session driver, but we will support it in a future version.

:::
