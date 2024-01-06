// Because we're using generated code, this needs to be a function that is accessible in the generated mixin, and thus cannot be a mixin itself
String idFromJson(dynamic json) {
  if (json is int) {
    return json.toString();
  } else if (json is String) {
    return json;
  }
  throw Exception('Invalid input to fromJson: $json');
}

// Extensions cannot define constructors, so we need to use a function instead - https://github.com/dart-lang/language/issues/723
DateTime? datetimeFromTimestamp(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

// Due to the missing support for nullables with constructors in json serializer, this is a workaround to have a default null
// See: https://github.com/google/json_serializable.dart/issues/1356
DateTime? datetimeNull() {
  return null;
}
