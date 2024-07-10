---
title: WebSocket → Peer
---

# Message

On message [hook](/guide/websocket/hooks), you receive a message object containing an incoming message from the client.

## `message.text()`

Get stringified `String` version of the message.

## `message.bytes()`

Get stringified `Uint8List` version of the message.

## `message.raw`

Message raw data, Types: `Uint8List` or `String`.
