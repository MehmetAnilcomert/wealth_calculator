import 'package:envied/envied.dart';
import 'package:gen/src/environment/prod_configuration.dart';

part 'env_prod.g.dart';

@Envied(
  obfuscate: true,
  path: 'assets/env/.prod.env',
)
final class ProdEnv implements ProductConfiguration {
  @EnviedField(varName: 'BASE_URL')
  final String _baseUrl = _ProdEnv._baseUrl;

  @EnviedField(varName: 'API_KEY')
  final String _apiKey = _ProdEnv._apiKey;

  @override
  String get baseUrl => _baseUrl;

  @override
  String get apiKey => _apiKey;
}
