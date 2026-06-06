import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _wine = Color(0xFF902021);
  static const Color _roseBorder = Color(0xFFF1DADA);
  static const Color _softRose = Color(0xFFFFF8F7);
  static const Color _taupe = Color(0xFF8D7B79);
  static const Color _gold = Color(0xFFDAB47D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3EE), Color(0xFFFFFAF8)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 380
                  ? 22.0
                  : 34.0;
              final panelRadius = constraints.maxWidth < 380 ? 34.0 : 48.0;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        constraints.maxWidth < 380 ? 28 : 56,
                        56,
                        constraints.maxWidth < 380 ? 28 : 56,
                        42,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(panelRadius),
                        border: Border.all(color: const Color(0xFFFFE8E1)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LoginHeader(),
                          SizedBox(height: 58),
                          _LoginForm(),
                          SizedBox(height: 36),
                          _PrimaryButton(),
                          SizedBox(height: 42),
                          _RegisterPrompt(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Cat Bracelet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: HomeScreen._wine,
            fontFamily: 'serif',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Năng lượng tinh khiết, phong\ncách tinh tế',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFA08E8C),
            fontSize: 21,
            fontWeight: FontWeight.w600,
            height: 1.42,
          ),
        ),
        SizedBox(height: 34),
        _GemDivider(),
      ],
    );
  }
}

class _GemDivider extends StatelessWidget {
  const _GemDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 46,
          child: Divider(color: HomeScreen._gold, thickness: 1.7),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.diamond_outlined,
            color: HomeScreen._gold,
            size: 19,
          ),
        ),
        SizedBox(
          width: 46,
          child: Divider(color: HomeScreen._gold, thickness: 1.7),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('EMAIL'),
        const SizedBox(height: 13),
        const _InputBox(
          icon: Icons.mail_outline_rounded,
          hintText: 'Nhập địa chỉ email',
        ),
        const SizedBox(height: 34),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _FieldLabel('MẬT KHẨU'),
            SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Color(0xFFA38C69),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        _InputBox(
          icon: Icons.lock_outline_rounded,
          hintText: 'Nhập mật khẩu',
          trailing: Icon(
            Icons.visibility_outlined,
            color: HomeScreen._roseBorder.withValues(alpha: 0.95),
            size: 30,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: HomeScreen._taupe,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.icon, required this.hintText, this.trailing});

  final IconData icon;
  final String hintText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: HomeScreen._softRose,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HomeScreen._roseBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: HomeScreen._roseBorder, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              hintText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: HomeScreen._roseBorder.withValues(alpha: 0.92),
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: HomeScreen._wine,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HomeScreen._wine.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ĐĂNG NHẬP',
              style: TextStyle(
                color: HomeScreen._gold,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.1,
              ),
            ),
            SizedBox(width: 16),
            Icon(
              Icons.arrow_forward_rounded,
              color: HomeScreen._gold,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            text: 'Chưa có tài khoản? ',
            style: TextStyle(
              color: HomeScreen._taupe,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: 'Đăng ký ngay',
                style: TextStyle(
                  color: Color(0xFF80684A),
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFD5C2AB),
                  decorationThickness: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
