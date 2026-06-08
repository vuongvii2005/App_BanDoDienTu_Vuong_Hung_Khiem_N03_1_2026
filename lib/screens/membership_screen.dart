import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();

    final user = auth.userModel;
    final name = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'Khách';
    final email = user?.email.trim().isNotEmpty == true
        ? user!.email.trim()
        : (auth.currentUser?.email ?? '');

    final rewardPoints = orders.orders.fold<int>(
      0,
      (total, order) => total + (order.total ~/ 100000),
    );
    final tier = _tier(auth, rewardPoints);
    final nextTier = _nextTier(tier);
    final nextThreshold = _nextThreshold(tier);
    final progress = _progress(rewardPoints, tier);

    return Scaffold(
      backgroundColor: AppTheme.greyLight,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: AppTheme.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thành viên Tech Store',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMemberCard(
                name: name, email: email, tier: tier, points: rewardPoints),
            const SizedBox(height: 14),
            _buildStatsRow(rewardPoints: rewardPoints),
            const SizedBox(height: 14),
            if (nextTier != null)
              _buildProgressCard(
                tier: tier,
                nextTier: nextTier,
                nextThreshold: nextThreshold,
                points: rewardPoints,
                progress: progress,
              ),
            if (nextTier != null) const SizedBox(height: 14),
            _buildBenefitsCard(),
            const SizedBox(height: 14),
            _buildTiersCard(currentTier: tier),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Card thẻ thành viên ──────────────────────────────────────────────────

  Widget _buildMemberCard({
    required String name,
    required String email,
    required String tier,
    required int points,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.workspace_premium,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tech Store',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Membership Card',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white54),
                ),
                child: Text(
                  tier.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(email,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                '$points điểm tích lũy',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Điểm & Voucher ───────────────────────────────────────────────────────

  Widget _buildStatsRow({required int rewardPoints}) {
    final voucherCount = rewardPoints ~/ 500;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.stars_outlined,
            label: 'Điểm thưởng',
            value: rewardPoints == 0 ? '0 điểm' : '$rewardPoints điểm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_offer_outlined,
            label: 'Voucher của tôi',
            value: '$voucherCount',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
        ],
      ),
    );
  }

  // ── Tiến độ nâng hạng ────────────────────────────────────────────────────

  Widget _buildProgressCard({
    required String tier,
    required String nextTier,
    required int nextThreshold,
    required int points,
    required double progress,
  }) {
    final remaining = nextThreshold - points;
    return _surface(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up,
                    color: AppTheme.primary, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Tiến độ nâng hạng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tier,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  nextTier,
                  style: const TextStyle(fontSize: 13, color: AppTheme.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.greyLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              remaining > 0
                  ? 'Cần thêm ${_formatVnd(remaining)} để lên hạng $nextTier'
                  : 'Bạn đã đủ điều kiện lên hạng $nextTier!',
              style: const TextStyle(fontSize: 12, color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quyền lợi ────────────────────────────────────────────────────────────

  Widget _buildBenefitsCard() {
    final benefits = [
      _Benefit(Icons.local_shipping_outlined, 'Miễn phí vận chuyển',
          'Đơn hàng từ 500.000đ'),
      _Benefit(Icons.percent_outlined, 'Ưu đãi sinh nhật',
          'Giảm 10% vào ngày sinh nhật'),
      _Benefit(Icons.stars_outlined, 'Tích điểm đổi quà',
          '100.000đ = 1 điểm thưởng'),
      _Benefit(Icons.support_agent_outlined, 'Hỗ trợ ưu tiên',
          'Tư vấn & xử lý nhanh hơn'),
    ];

    return _surface(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quyền lợi thành viên',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 14),
            ...benefits.asMap().entries.map((entry) {
              final isLast = entry.key == benefits.length - 1;
              final b = entry.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(b.icon, color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.black,
                            ),
                          ),
                          Text(
                            b.subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!isLast)
                    const Divider(
                        height: 20, thickness: 1, color: AppTheme.greyLight),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Các hạng thành viên ──────────────────────────────────────────────────

  Widget _buildTiersCard({required String currentTier}) {
    final tiers = [
      _Tier('Member', '0 - 7.9M', const Color(0xFFE8622A)),
      _Tier('Silver', '8M - 19.9M', const Color(0xFF9E9E9E)),
      _Tier('Gold', '20M - 99.9M', const Color(0xFFFFC107)),
      _Tier('Admin', '100M+', const Color(0xFF5C6BC0)),
    ];

    return _surface(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Các hạng thành viên',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 14),
            ...tiers.map((t) {
              final isActive = t.name == currentTier;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary.withValues(alpha: 0.07)
                      : const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? AppTheme.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: t.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      t.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive ? AppTheme.primary : AppTheme.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      t.range,
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.grey),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Hiện tại',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _surface({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  String _tier(AuthProvider auth, int points) {
    if (auth.canManageShop) return 'Admin';
    if (points >= 2000) return 'Gold';
    if (points >= 800) return 'Silver';
    return 'Member';
  }

  String? _nextTier(String tier) {
    const next = {'Member': 'Silver', 'Silver': 'Gold', 'Gold': 'Admin'};
    return next[tier];
  }

  int _nextThreshold(String tier) {
    const thresholds = {'Member': 800, 'Silver': 2000, 'Gold': 10000};
    return thresholds[tier] ?? 0;
  }

  double _progress(int points, String tier) {
    if (tier == 'Admin') return 1.0;
    final current = {'Member': 0, 'Silver': 800, 'Gold': 2000}[tier] ?? 0;
    final next = _nextThreshold(tier);
    if (next <= current) return 1.0;
    return ((points - current) / (next - current)).clamp(0.0, 1.0);
  }

  String _formatVnd(int points) {
    // 1 point = 100.000đ
    final vnd = points * 100000;
    if (vnd >= 1000000) return '${(vnd / 1000000).toStringAsFixed(1)}M';
    return '${(vnd / 1000).round()}K';
  }
}

class _Benefit {
  final IconData icon;
  final String title;
  final String subtitle;
  _Benefit(this.icon, this.title, this.subtitle);
}

class _Tier {
  final String name;
  final String range;
  final Color color;
  _Tier(this.name, this.range, this.color);
}
