import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLHelper {
  static final GraphQLHelper _instance = GraphQLHelper._privateConstructor();
  static String accessToken = "";
  factory GraphQLHelper() => _instance;
  GraphQLHelper._privateConstructor();

  GraphQLClient? _client;

  Future<GraphQLClient> get client async {
    // TODO: There is a bug here where if the accessToken changes between the client being instantiated and when this is called, we'll never update it.
    // FIXME: There is a bug here where if the accessToken changes between the client being instantiated and when this is called, we'll never update it.
    if (_client != null) return _client!;

    final HttpLink httpLink = HttpLink(
      'https://api.start.gg/gql/alpha',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $accessToken',
    );
    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );

    return _client!;
  }
}
