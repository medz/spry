import 'package:spry/openapi.dart';

import 'schema_leaf.dart' as schemas;

final idDescription = 'User identifier.';

final userIdParameter = OpenAPIRef.inline(
  OpenAPIParameter.path(
    'id',
    schema: schemas.userIdSchema,
    description: idDescription,
  ),
);

final parameters = [userIdParameter];
