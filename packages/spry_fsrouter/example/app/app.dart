// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:spry_router/spry_router.dart' as _i1;

import 'api/settings/handler.dart' as _i7;
import 'handler.dart' as _i3;
import 'id.middleware.dart' as _i2;
import 'users/[id]/handler.dart' as _i6;
import 'users/(get)/handler.dart' as _i5;
import 'users/handler.dart' as _i4;

final _i1.Router app = _i1.Router(r'')
  ..param(
    r'id',
    _i2.middleware,
  )
  ..all(
    r'',
    _i3.handler,
  )
  ..mount(
    r'users',
    _i1.Router(r'users')
      ..all(
        r'',
        _i4.handler,
      )
      ..route(
        r'get',
        r'',
        _i5.handler,
      )
      ..mount(
        r':id(\d+)',
        _i1.Router(r'users/:id(\d+)')
          ..all(
            r'',
            _i6.handler,
          ),
      ),
  )
  ..mount(
    r'api',
    _i1.Router(r'api')
      ..mount(
        r'settings',
        _i1.Router(r'api/settings')
          ..all(
            r'',
            _i7.handler,
          ),
      ),
  );
