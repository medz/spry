import 'package:spry/openapi.dart';

import 'response_defs.dart' as responses;
import 'tag_defs.dart' as tags;

final homeSummary = 'Home';
final homeDeprecated = false;

final homeOpenApi = OpenAPI(
  summary: homeSummary,
  deprecated: homeDeprecated,
  tags: tags.homeTags,
  responses: responses.homeResponses,
);
