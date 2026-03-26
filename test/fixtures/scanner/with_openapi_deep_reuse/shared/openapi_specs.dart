import 'package:spry/openapi.dart';

import 'callback_defs.dart' as callbacks;
import 'component_defs.dart' as components;
import 'docs_defs.dart' as docs;
import 'parameter_defs.dart' as parameters;
import 'request_defs.dart' as requests;
import 'response_defs.dart' as responses;
import 'security_defs.dart' as security;
import 'server_defs.dart' as servers;

final routeOpenApi = OpenAPI(
  summary: 'Create a user',
  description: 'Deeply reusable OpenAPI metadata.',
  operationId: 'createUser',
  externalDocs: docs.externalDocs,
  parameters: parameters.parameters,
  requestBody: requests.createUserRequestBody,
  responses: responses.responses,
  callbacks: callbacks.callbacks,
  security: security.security,
  servers: servers.servers,
  globalComponents: components.components,
);
