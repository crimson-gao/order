class PageQuery {
  static const pageLimit = 20;
  final int offset;
  final int limit;
  const PageQuery({this.offset = 0, this.limit = pageLimit});
}
