import 'package:spry/openapi.dart';

import 'response_leaf.dart' as leaf;

final Map<String, OpenAPIRef<OpenAPIResponse>> homeResponses = {
  '200': leaf.okResponse,
};
