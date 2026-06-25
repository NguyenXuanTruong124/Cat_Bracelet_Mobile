/// Model gom toàn bộ dữ liệu dùng cho các bộ lọc trên màn hình bộ sưu tập.
///
/// Trước đây các danh sách này được khai báo rời rạc trực tiếp trong
/// `_CollectionScreenState`. Gom vào một model giúp dễ truyền dữ liệu giữa
/// service và UI, đồng thời dễ mở rộng khi có thêm tiêu chí lọc mới.
class FilterOptions {
  final List<String> colors;
  final List<String> sizes;
  final List<String> stoneColors;
  final List<String> stoneTypes;
  final List<String> categories;
  final List<String> materials;

  /// Map id danh mục -> tên danh mục, dùng để lọc sản phẩm theo danh mục
  /// đã chọn ở phía client.
  final Map<String, String> categoryNamesById;

  const FilterOptions({
    required this.colors,
    required this.sizes,
    required this.stoneColors,
    required this.stoneTypes,
    required this.categories,
    required this.materials,
    required this.categoryNamesById,
  });

  factory FilterOptions.empty() {
    return const FilterOptions(
      colors: [],
      sizes: [],
      stoneColors: [],
      stoneTypes: [],
      categories: [],
      materials: [],
      categoryNamesById: {},
    );
  }
}
