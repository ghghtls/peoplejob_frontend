import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/resume_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_bar.dart';

class ResumeDetailPage extends StatefulWidget {
  final int resumeId;
  const ResumeDetailPage({super.key, required this.resumeId});

  @override
  State<ResumeDetailPage> createState() => _ResumeDetailPageState();
}

class _ResumeDetailPageState extends State<ResumeDetailPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final ResumeService _resumeService = ResumeService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _resumeDetail;
  bool _isLoading = true;
  String? _userType;
  int? _currentUserNo;
  bool _isMyResume = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getUserInfo();
    if (mounted) {
      setState(() {
        _userType = userInfo['userType'];
        _currentUserNo = int.tryParse(userInfo['userNo'] ?? '0');
      });
    }
    _loadResumeDetail();
  }

  Future<void> _loadResumeDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await _resumeService.getResumeDetail(widget.resumeId);
      if (mounted) {
        setState(() {
          _resumeDetail = detail;
          _isMyResume = _currentUserNo == detail['userNo'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: _red,
              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }

  String _formatDate(String? d) {
    if (d == null) return '';
    try { return DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(d)); }
    catch (_) { return d; }
  }

  void _deleteResume() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('이력서 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('정말로 이 이력서를 삭제하시겠습니까?\n삭제된 이력서는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _resumeService.deleteResume(widget.resumeId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('이력서가 삭제되었습니다'),
                    backgroundColor: _green, behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: _red),
                  );
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _sendScoutOffer() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('스카우트 제안', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('이 지원자에게 스카우트 제안을 보내시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('스카우트 제안이 전송되었습니다'),
                backgroundColor: _green, behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            child: const Text('제안하기', style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '이력서',
        actions: [
          if (_isMyResume) ...[
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/resume-edit', arguments: widget.resumeId),
              icon: const Icon(Icons.edit_outlined, color: _blue, size: 20),
            ),
            IconButton(
              onPressed: _deleteResume,
              icon: const Icon(Icons.delete_outline_rounded, color: _red, size: 20),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
                  : _resumeDetail == null
                      ? const Center(child: Text('이력서를 찾을 수 없습니다', style: TextStyle(color: _secondary)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 프로필 헤더 카드
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_green.withValues(alpha: 0.08), _green.withValues(alpha: 0.04)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64, height: 64,
                                      decoration: BoxDecoration(
                                        color: _resumeDetail!['imagePath'] != null ? Colors.transparent : _green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: _resumeDetail!['imagePath'] != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.network(_resumeDetail!['imagePath'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 32, color: _green)),
                                            )
                                          : const Icon(Icons.person_rounded, size: 32, color: _green),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_resumeDetail!['title'] ?? '',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                                  color: _label, letterSpacing: -0.4)),
                                          const SizedBox(height: 4),
                                          if (_resumeDetail!['regdate'] != null)
                                            Text('등록일: ${_formatDate(_resumeDetail!['regdate'])}',
                                                style: const TextStyle(fontSize: 12, color: _secondary)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 희망 조건
                              _sectionTitle('희망 조건'),
                              const SizedBox(height: 8),
                              _infoCard([
                                _infoRow(Icons.work_outline_rounded, '희망직종', _resumeDetail!['hopeJobtype']),
                                _infoRow(Icons.location_on_outlined, '희망지역', _resumeDetail!['hopeLocation']),
                                _infoRow(Icons.schedule_rounded, '근무형태', _resumeDetail!['workType']),
                                if (_resumeDetail!['salary'] != null && _resumeDetail!['salary'].toString().isNotEmpty)
                                  _infoRow(Icons.attach_money_rounded, '희망연봉', _resumeDetail!['salary']),
                              ]),
                              const SizedBox(height: 16),

                              // 학력 및 경력
                              _sectionTitle('학력 및 경력'),
                              const SizedBox(height: 8),
                              _infoCard([
                                _infoRow(Icons.school_outlined, '학력사항', _resumeDetail!['education']),
                                _infoRow(Icons.business_center_outlined, '경력사항', _resumeDetail!['career']),
                                if (_resumeDetail!['certificate'] != null && _resumeDetail!['certificate'].toString().isNotEmpty)
                                  _infoRow(Icons.verified_outlined, '자격증', _resumeDetail!['certificate']),
                              ]),
                              const SizedBox(height: 16),

                              // 자기소개서
                              _sectionTitle('자기소개서'),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                                ),
                                child: Text(
                                  _resumeDetail!['content'] ?? '자기소개서가 작성되지 않았습니다.',
                                  style: const TextStyle(fontSize: 15, height: 1.7, color: _label, letterSpacing: -0.2),
                                ),
                              ),

                              // 스카우트 제안 버튼 (기업 사용자, 타인 이력서)
                              if (_userType == 'company' && !_isMyResume) ...[
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _sendScoutOffer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _green,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const Text('스카우트 제안',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2));
  }

  Widget _infoCard(List<Widget> children) {
    final nonEmpty = children.where((w) => w is! SizedBox).toList();
    if (nonEmpty.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _secondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _secondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: _label))),
        ],
      ),
    );
  }
}
