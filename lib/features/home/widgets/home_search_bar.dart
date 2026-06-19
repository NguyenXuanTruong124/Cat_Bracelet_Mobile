import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});
  static const Color _wine = AppColors.wine;
  static const Color _gold = AppColors.gold;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Container(
      color: _wine,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 32,
        8,
        isMobile ? 16 : 32,
        18,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withValues(alpha: 0.55)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: _wine),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tìm vòng tay, đá, chất liệu...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFF7B6664), fontSize: 15),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: _wine),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
