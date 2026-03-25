import 'package:spry/openapi.dart';

final bearerSecurity = OpenAPISecurityRequirement({'bearerAuth': []});

final security = [bearerSecurity];
