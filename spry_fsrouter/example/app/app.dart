// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:spry/router.dart' as _i1;

import 'api/settings/handler.dart' as _i9;
import 'handler.dart' as _i3;
import 'id.middleware.dart' as _i2;
import 'users/[id]/handler.dart' as _i8;
import 'users/(get)/handler.dart' as _i5;
import 'users/(get)/id.middleware.dart' as _i7;
import 'users/(get)/middleware.dart' as _i6;
import 'users/handler.dart' as _i4;

final _i1.Router app = _i1.Router()
  ..param(
    r'id',
    _i2.middleware,
  )
  ..all(
    r'/',
    _i3.handler,
  )
  ..mount(
    r'users',
    router: _i1.Router()
      ..all(
        r'/',
        _i4.handler,
      )
      ..route(
        r'get',
        r'/',
        _i5.handler.use(_i6.middleware).param(
              r'id',
              _i7.middleware,
            ),
      )
      ..mount(
        r':id(\d+)',
        router: _i1.Router()
          ..all(
            r'/',
            _i8.handler,
          ),
      ),
  )
  ..mount(
    r'api',
    router: _i1.Router()
      ..mount(
        r'settings',
        router: _i1.Router()
          ..all(
            r'/',
            _i9.handler,
          ),
      ),
  );
