---
title: WebSocket → Peer
---

# Peer

Peer object allows easily interacting with connected clients.

---

Websocket hooks accept a peer instance as their first argument. You can use peer object to get information about each connected client or send a message to them.

## `peer.readyState`

Client connection status (might be `-1`)

::: tip
Read more is [readyState in MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/readyState)
:::

## `peer.protocol`

Returns the websocket selected protocol.

## `peer.extensions`

Returns the websocket cliend-side request extensions.

## `peer.send`

Send a bytes message to the connected client.

## `peer.sendText`

Send a `String` message to the connected client.

## `peer.close`

Close websocket connect.
