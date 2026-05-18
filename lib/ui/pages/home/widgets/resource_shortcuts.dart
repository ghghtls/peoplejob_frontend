import 'package:flutter/material.dart';

class ResourceShortcuts extends StatelessWidget {
  const ResourceShortcuts({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);
  static const _shortcuts = [
    {'icon': Icons.folder_open_rounded, 'label': '자료실', 'route': '/resources/list', 'color': _green},
    {'icon': Icons.text_fields_rounded, 'label': '글자수 세기', 'route': '/tools/wordcount', 'color': _blue},
    {'icon': Icons.newspaper_rounded, 'label': '취업 뉴스', 'route': '/resources/news', 'color': _orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('자료 & 도구',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_shortcuts.length, (i) {
              final s = _shortcuts[i];
              final color = s['color'] as Color;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < _shortcuts.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, s['route'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(s['icon'] as IconData, size: 20, color: color),
                          ),
                          const SizedBox(height: 8),
                          Text(s['label'] as String,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _label),
                              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
