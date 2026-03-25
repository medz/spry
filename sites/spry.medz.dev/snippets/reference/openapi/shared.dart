import 'package:spry/openapi.dart';

final userIdSchema = OpenAPISchema.string(
  description: 'Stable user identifier.',
);

final userSchema = OpenAPISchema.object({
  'id': OpenAPISchema.ref('#/components/schemas/UserId'),
  'name': OpenAPISchema.string(),
});

final userResponse = OpenAPIRef.inline(
  OpenAPIResponse(
    description: 'User payload',
    content: {
      'application/json': OpenAPIMediaType(
        schema: OpenAPISchema.ref('#/components/schemas/User'),
      ),
    },
  ),
);

final bearerSecurity = OpenAPISecurityRequirement({'bearerAuth': []});
