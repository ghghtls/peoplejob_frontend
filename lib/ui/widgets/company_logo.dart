import 'package:flutter/material.dart';

/// 회사 이름 키워드 기반으로 그라디언트 + 아이콘을 결정하는 로고 위젯
class CompanyLogo extends StatelessWidget {
  final String company;
  final double size;
  final double borderRadius;

  const CompanyLogo({
    super.key,
    required this.company,
    this.size = 48,
    this.borderRadius = 12,
  });

  static const List<List<Color>> _fallbackGradients = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    [Color(0xFF4776E6), Color(0xFF8E54E9)],
    [Color(0xFFFC5C7D), Color(0xFF6A3093)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    [Color(0xFFF953C6), Color(0xFFB91D73)],
  ];

  static CompanyTheme resolveTheme(String name) {
    final n = name;

    // 핀테크·금융·은행
    if (_has(n, ['핀테크', '뱅크', '금융', '은행', '페이', '캐피탈', '증권', '보험'])) {
      return CompanyTheme(
        gradient: const [Color(0xFFF7971E), Color(0xFFFFD200)],
        icon: Icons.account_balance_rounded,
      );
    }
    // 스타트업 (테크 계열보다 먼저 체크)
    if (_has(n, ['스타트', 'startup'])) {
      return CompanyTheme(
        gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
        icon: Icons.rocket_launch_rounded,
      );
    }
    // IT·테크·소프트웨어·개발·AI
    if (_has(n, ['테크', 'tech', 'IT', '소프트', '개발', 'AI', '인공지능', '클라우드', '디지털', '코드', '시스템'])) {
      return CompanyTheme(
        gradient: const [Color(0xFF4776E6), Color(0xFF6C63FF)],
        icon: Icons.computer_rounded,
      );
    }
    // 글로벌·종합·코퍼레이션
    if (_has(n, ['글로벌', 'global', '코퍼레이션', '종합', '인터내셔널'])) {
      return CompanyTheme(
        gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
        icon: Icons.language_rounded,
      );
    }
    // 건설·부동산·인테리어
    if (_has(n, ['건설', '부동산', '인테리어', '시공', '개발사'])) {
      return CompanyTheme(
        gradient: const [Color(0xFFB06AB3), Color(0xFF4568DC)],
        icon: Icons.domain_rounded,
      );
    }
    // 의료·헬스·병원
    if (_has(n, ['의료', '헬스', '병원', '바이오', '제약', '메디'])) {
      return CompanyTheme(
        gradient: const [Color(0xFF56CCF2), Color(0xFF2F80ED)],
        icon: Icons.local_hospital_rounded,
      );
    }
    // 유통·물류·배송
    if (_has(n, ['유통', '물류', '배송', '운송', '택배', '커머스'])) {
      return CompanyTheme(
        gradient: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
        icon: Icons.local_shipping_rounded,
      );
    }
    // 교육·학원·에듀
    if (_has(n, ['교육', '학원', '에듀', '학교', '아카데미'])) {
      return CompanyTheme(
        gradient: const [Color(0xFFF953C6), Color(0xFFB91D73)],
        icon: Icons.school_rounded,
      );
    }
    // 미디어·콘텐츠·엔터
    if (_has(n, ['미디어', '콘텐츠', '엔터', '방송', '광고', '크리에이티브'])) {
      return CompanyTheme(
        gradient: const [Color(0xFFFC5C7D), Color(0xFF6A3093)],
        icon: Icons.play_circle_rounded,
      );
    }
    // 식품·외식·푸드
    if (_has(n, ['식품', '푸드', '외식', '카페', '레스토랑'])) {
      return CompanyTheme(
        gradient: const [Color(0xFFFF9966), Color(0xFFFF5E62)],
        icon: Icons.restaurant_rounded,
      );
    }

    // 해시 기반 fallback
    int hash = 0;
    for (final c in name.codeUnits) {
      hash = (hash * 31 + c) & 0x7FFFFFFF;
    }
    final gradient = _fallbackGradients[hash % _fallbackGradients.length];
    return CompanyTheme(gradient: gradient, icon: Icons.business_center_rounded);
  }

  static bool _has(String name, List<String> keywords) {
    final lower = name.toLowerCase();
    return keywords.any((k) => lower.contains(k.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = resolveTheme(company);
    final iconSize = size * 0.46;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.gradient.first.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(theme.icon, color: Colors.white, size: iconSize),
    );
  }
}

class CompanyTheme {
  final List<Color> gradient;
  final IconData icon;
  const CompanyTheme({required this.gradient, required this.icon});
}
