import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/shop_location.dart';
import '../services/shop_service.dart';

class ShopLocationScreen extends StatefulWidget {
  const ShopLocationScreen({super.key});

  @override
  State<ShopLocationScreen> createState() => _ShopLocationScreenState();
}

class _ShopLocationScreenState extends State<ShopLocationScreen> {
  late ShopService _shopService;
  List<ShopLocation> _shops = [];
  bool _isLoading = true;

  // Colors from App
  static const Color _wine = Color(0xFF5B060C);
  static const Color _gold = Color(0xFFD8B78A);
  static const Color backgroundColor = Color(0xFFFFF8F7);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color secondaryColor = Color(0xFF745A35); // Champagne Gold

  @override
  void initState() {
    super.initState();
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    _shopService = ShopService(baseUrl: baseUrl);
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() => _isLoading = true);
    final shops = await _shopService.fetchActiveShops();
    if (mounted) {
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    }
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    // Thử dùng scheme 'geo:' trước (native android), nếu không được dùng https
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      // Trên emulator đôi khi canLaunchUrl trả về false dù vẫn mở được trình duyệt
      // Ta dùng launchUrl với mode externalApplication
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể mở bản đồ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: _wine,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hệ Thống Cửa Hàng',
          style: TextStyle(
            fontFamily: 'serif',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // Đang ở tab Cửa hàng
        backgroundColor: Colors.white,
        indicatorColor: _wine.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/collection');
          if (index == 3) Navigator.pushNamed(context, '/support');
          if (index == 4) Navigator.pushNamed(context, '/profile');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Sản phẩm',
          ),
          NavigationDestination(icon: Icon(Icons.diamond), label: 'Cửa hàng'),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            label: 'Hỗ trợ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Tài khoản',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  const Text(
                    'Cửa Hàng',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _wine,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ghé thăm không gian sang trọng của chúng tôi để trải nghiệm trực tiếp năng lượng từ những viên đá thiên nhiên tuyệt mỹ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      color: Color(0xFF564240),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ..._shops.map((shop) => _buildShopCard(shop)),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildShopCard(ShopLocation shop) {
    bool isFlagship =
        shop.shopName.toLowerCase().contains('flagship') ||
        (_shops.isNotEmpty && shop.id == _shops.first.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _wine.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: ShopMapView(
                    latitude: shop.shopLatitude,
                    longitude: shop.shopLongitude,
                  ),
                ),
              ),
              if (isFlagship)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _wine,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FLAGSHIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.shopName,
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _wine,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_on_outlined, shop.shopAddress),
                _buildInfoRow(Icons.phone_outlined, shop.phoneNumber),
                _buildInfoRow(Icons.access_time, shop.workingHours),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _openGoogleMaps(shop.shopLatitude, shop.shopLongitude),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text(
                      'XEM TRÊN BẢN ĐỒ',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _wine,
                      side: const BorderSide(color: _gold),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: secondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Color(0xFF564240),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShopMapView extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ShopMapView({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ShopMapView> createState() => _ShopMapViewState();
}

class _ShopMapViewState extends State<ShopMapView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller cho webview_flutter
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      );

    // Xây dựng chuỗi HTML chứa Leaflet Map tùy chỉnh
    final double lat = widget.latitude;
    final double lng = widget.longitude;

    final String mapHtml =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    body { margin: 0; padding: 0; background-color: #FFF8F7; }
    #map { width: 100vw; height: 100vh; }
    
    /* Animation ghim sóng lan tỏa sang trọng */
    .custom-pin {
      position: relative;
    }
    .pulse {
      background: #5B060C;
      border-radius: 50%;
      height: 14px;
      width: 14px;
      position: absolute;
      left: 50%;
      top: 50%;
      margin: -7px 0 0 -7px;
      border: 2px solid white;
      box-shadow: 0 0 8px rgba(0,0,0,0.3);
    }
    .pulse::after {
      content: "";
      border-radius: 50%;
      height: 36px;
      width: 36px;
      position: absolute;
      margin: -13px 0 0 -13px;
      animation: pulsate 1.8s ease-out;
      animation-iteration-count: infinite;
      opacity: 0.0;
      box-shadow: 0 0 10px #5B060C;
    }
    @keyframes pulsate {
      0% { transform: scale(0.1, 0.1); opacity: 0.0; }
      50% { opacity: 0.8; }
      100% { transform: scale(1.2, 1.2); opacity: 0.0; }
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    // Khởi tạo bản đồ ẩn attributionControl và zoomControl
    var map = L.map('map', {
      zoomControl: true,
      attributionControl: false
    }).setView([$lat, $lng], 16);

    // Load các ô bản đồ OpenStreetMap
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19
    }).addTo(map);

    // Ghim Custom màu Burgundy khớp phong cách app
    var customIcon = L.divIcon({
      className: 'custom-pin',
      html: "<div class='pulse'></div>",
      iconSize: [40, 40],
      iconAnchor: [20, 20]
    });

    L.marker([$lat, $lng], { icon: customIcon }).addTo(map);
  </script>
</body>
</html>
''';

    _controller.loadHtmlString(mapHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF5B060C)),
          ),
      ],
    );
  }
}
