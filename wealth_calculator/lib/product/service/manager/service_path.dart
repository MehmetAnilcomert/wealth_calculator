/// PRoject`s service paths
enum ProductServicePath {
  users('user'),
  posts('posts');

  final String value;
  const ProductServicePath(this.value);

  /// Appends a query parameter to the service path.
  /// Example:
  ///
  /// users/123
  String withQuery(String value) {
    return '${this.value}/$value';
  }
}
