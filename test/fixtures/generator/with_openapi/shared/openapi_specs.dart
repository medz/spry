import 'package:spry/openapi.dart';

import 'response_defs.dart' as responses;
import 'tag_defs.dart' as tags;

final homeOpenApi = OpenAPI(
  summary: 'Home',
  tags: tags.homeTags,
  responses: responses.homeResponses,
);
