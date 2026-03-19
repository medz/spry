import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spry/osrv.dart';
import 'package:spry/osrv/dart.dart';
import 'package:spry/spry.dart';
import 'package:test/test.dart';

void main() {
  group('websocket runtime boundaries', () {
    test(
      'handshake-time upgrade failures still flow through Spry error handlers',
      () async {
        var handled = false;
        final app = Spry(
          routes: {
            '/chat': {
              HttpMethod.get: (event) => event.ws.upgrade((ws) async {}),
            },
          },
          errors: [
            ErrorRoute(
              path: '/**',
              handler: (error, stackTrace, event) {
                handled = true;
                expect(error, isA<HTTPError>());
                expect((error as HTTPError).status, 426);
                return Response('handled');
              },
            ),
          ],
        );
        final server = Server(fetch: app.fetch);
        final runtime = await serve(server, host: '127.0.0.1', port: 0);

        addTearDown(() async {
          await runtime.close();
          await runtime.closed;
        });

        final client = HttpClient();
        addTearDown(client.close);

        final request = await client.getUrl(runtime.url!.resolve('/chat'));
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();

        expect(response.statusCode, 200);
        expect(body, 'handled');
        expect(handled, isTrue);
      },
    );

    test(
      'post-upgrade session failures do not re-enter Spry error handlers',
      () async {
        final uncaughtError = Completer<Object>();
        await runZonedGuarded(
          () async {
            var handled = false;
            final app = Spry(
              routes: {
                '/chat': {
                  HttpMethod.get: (event) => event.ws.upgrade((ws) async {
                    ws.sendText('connected');
                    throw StateError('session failed');
                  }),
                },
              },
              errors: [
                ErrorRoute(
                  path: '/**',
                  handler: (error, stackTrace, event) {
                    handled = true;
                    return Response('handled');
                  },
                ),
              ],
            );
            final server = Server(fetch: app.fetch);
            final runtime = await serve(server, host: '127.0.0.1', port: 0);

            try {
              final webSocket = await WebSocket.connect(
                runtime.url!
                    .replace(
                      scheme: 'ws',
                      path: '/chat',
                      query: '',
                      fragment: '',
                    )
                    .toString(),
              );
              final events = StreamIterator<Object?>(webSocket);

              expect(
                await events.moveNext().timeout(const Duration(seconds: 5)),
                isTrue,
              );
              expect(events.current, 'connected');
              expect(
                await events.moveNext().timeout(const Duration(seconds: 5)),
                isFalse,
              );

              expect(handled, isFalse);
              expect(webSocket.closeCode, WebSocketStatus.internalServerError);
              expect(
                await uncaughtError.future.timeout(const Duration(seconds: 5)),
                isA<StateError>(),
              );
            } finally {
              await runtime.close();
              await runtime.closed;
            }
          },
          (error, stackTrace) {
            if (!uncaughtError.isCompleted) {
              uncaughtError.complete(error);
            }
          },
        );
      },
    );
  });
}
