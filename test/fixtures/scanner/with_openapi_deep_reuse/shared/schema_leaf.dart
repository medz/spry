import 'package:spry/openapi.dart';

final userIdSchema = OpenAPISchema.string(
  description: 'Stable user identifier.',
);

final createUserSchema = OpenAPISchema.object({'name': OpenAPISchema.string()});

final userSchema = OpenAPISchema.object({
  'id': OpenAPISchema.ref('#/components/schemas/UserId'),
  'name': OpenAPISchema.string(),
});
