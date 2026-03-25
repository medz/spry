import 'package:spry/openapi.dart';

final acceptedResponse = OpenAPIRef.inline(
  OpenAPIResponse(description: 'Accepted'),
);

final callbackTarget = OpenAPIPathItem(
  post: OpenAPIOperation(responses: {'202': acceptedResponse}),
);

final callbacks = {
  'userCreated': OpenAPIRef.inline(<String, OpenAPIPathItem>{
    r'{$request.body#/callbackUrl}': callbackTarget,
  }),
};
