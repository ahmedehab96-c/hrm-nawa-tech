import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/platform_helper.dart';

// ─── Entry Point ─────────────────────────────────────────────────────────────

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الجوال: splash سريع → تسجيل دخول الموظف
    if (!PlatformHelper.isAdminApp) {
      return const _MobileSplash();
    }
    // الويب: صفحة تسويق كاملة
    return const _LandingPage();
  }
}

// ─── Mobile Splash ────────────────────────────────────────────────────────────

class _MobileSplash extends StatefulWidget {
  const _MobileSplash();

  @override
  State<_MobileSplash> createState() => _MobileSplashState();
}

class _MobileSplashState extends State<_MobileSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_alt_rounded, size: 72, color: Colors.white),
              const SizedBox(height: 16),
              Text('Nawa Tech HRM',
                  style: AppTypography.h1.copyWith(
                      color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('بوابة الموظفين',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Landing Page ─────────────────────────────────────────────────────────────

class _LandingPage extends StatefulWidget {
  const _LandingPage();

  @override
  State<_LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<_LandingPage> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverToBoxAdapter(child: _Navbar(scrollCtrl: _scrollCtrl)),
          const SliverToBoxAdapter(child: _HeroSection()),
          const SliverToBoxAdapter(child: _StatsRow()),
          const SliverToBoxAdapter(child: _FeaturesSection()),
          const SliverToBoxAdapter(child: _ScreenshotSection()),
          const SliverToBoxAdapter(child: _PricingSection()),
          const SliverToBoxAdapter(child: _TestimonialsSection()),
          const SliverToBoxAdapter(child: _CtaSection()),
          const SliverToBoxAdapter(child: _Footer()),
        ],
      ),
    );
  }
}

// ─── Navbar ───────────────────────────────────────────────────────────────────

class _Navbar extends StatelessWidget {
  const _Navbar({required this.scrollCtrl});
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 10),
          Text('Nawa Tech HRM',
              style: AppTypography.h3.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w900)),
          const Spacer(),
          if (isWide) ...[
            _navLink('المميزات'),
            _navLink('الأسعار'),
            _navLink('من نحن'),
            const SizedBox(width: 12),
          ],
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('تسجيل دخول'),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => context.go('/register'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('ابدأ مجاناً'),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String label) {
    return TextButton(
      onPressed: () {},
      child: Text(label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
    );
  }
}

// ─── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 900;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: isWide ? 100 : 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFEFF6FF), Colors.white, Color(0xFFF0FDF4)],
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 5, child: _heroText(context)),
                const SizedBox(width: 60),
                Expanded(flex: 4, child: _heroDashboard()),
              ],
            )
          : Column(
              children: [
                _heroText(context),
                const SizedBox(height: 40),
                _heroDashboard(),
              ],
            ),
    );
  }

  Widget _heroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text('نظام إدارة الموارد البشرية #1',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'إدارة فريقك\nبكفاءة استثنائية',
          style: AppTypography.h1.copyWith(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'منصة SaaS متكاملة لإدارة الموظفين، الحضور، الإجازات، والرواتب.\nمصممة للشركات العربية، تعمل على الويب والجوال.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/register'),
              icon: const Icon(Icons.rocket_launch_rounded, size: 20),
              label: const Text('ابدأ تجربة مجانية 14 يوم'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                textStyle: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: const Text('شاهد العرض التجريبي'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _avatarStack(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    ...List.generate(5,
                        (_) => const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16)),
                  ]),
                  const SizedBox(height: 2),
                  Text('يثق بنا 500+ شركة عربية',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroDashboard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: const Color(0xFF1E293B),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fake browser bar
              Row(
                children: [
                  ...['#EF4444', '#FBBF24', '#10B981'].map((c) => Container(
                        width: 10, height: 10,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                            color: Color(int.parse('FF${c.substring(1)}', radix: 16)),
                            shape: BoxShape.circle),
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text('nawatechhrm.app/admin',
                            style: AppTypography.caption
                                .copyWith(color: Colors.white38, fontSize: 10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Fake dashboard stats
              Row(
                children: [
                  _dashCard('الموظفين', '128', Icons.people, AppColors.primary),
                  const SizedBox(width: 8),
                  _dashCard('الحضور', '94%', Icons.check_circle, AppColors.success),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _dashCard('الإجازات', '7 معلقة', Icons.event_note, AppColors.warning),
                  const SizedBox(width: 8),
                  _dashCard('الرواتب', 'معالَجة', Icons.payments, AppColors.secondary),
                ],
              ),
              const SizedBox(height: 12),
              // Fake table header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(child: Text('الموظف',
                        style: AppTypography.caption
                            .copyWith(color: Colors.white54, fontSize: 10))),
                    Text('الحالة',
                        style: AppTypography.caption
                            .copyWith(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              ...['محمد أحمد', 'سارة علي', 'خالد حسن'].map((name) => Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text(name[0],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(name,
                                style: AppTypography.caption.copyWith(
                                    color: Colors.white70, fontSize: 11))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text('حاضر',
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.success, fontSize: 9)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Text(label,
                      style: AppTypography.caption
                          .copyWith(color: Colors.white54, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarStack() {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      AppColors.error,
    ];
    return SizedBox(
      width: 80,
      height: 32,
      child: Stack(
        children: List.generate(4, (i) {
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text('${i + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _stats(),
            )
          : Wrap(
              spacing: 24,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _stats(),
            ),
    );
  }

  List<Widget> _stats() => [
        _Stat('500+', 'شركة تستخدم المنصة'),
        _divider(),
        _Stat('50,000+', 'موظف مُدار'),
        _divider(),
        _Stat('99.9%', 'وقت التشغيل'),
        _divider(),
        _Stat('24/7', 'دعم فني'),
      ];

  Widget _divider() => Container(
      height: 40, width: 1, color: Colors.white24);
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.h2.copyWith(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTypography.caption
                .copyWith(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

// ─── Features ─────────────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const _features = [
    (Icons.people_alt_rounded, 'إدارة الموظفين',
        'ملفات شاملة، بيانات التعاقد، التأمين، الراتب — كل شيء في مكان واحد'),
    (Icons.access_time_rounded, 'الحضور والانصراف',
        'تسجيل ذكي عبر WiFi الشركة، تقارير يومية فورية للإدارة'),
    (Icons.event_note_rounded, 'إدارة الإجازات',
        'طلبات رقمية، موافقة بنقرة، رصيد محدّث تلقائياً لكل موظف'),
    (Icons.payments_rounded, 'الرواتب والمستحقات',
        'توليد قسيمة الراتب تلقائياً، تنزيل PDF احترافي في ثوانٍ'),
    (Icons.work_rounded, 'التوظيف',
        'إعلانات الوظائف، قنوات المرشحين، تحويل المرشح لموظف بنقرة'),
    (Icons.notifications_active_rounded, 'الإشعارات الفورية',
        'تنبيهات الموافقة والرفض والرواتب — لا شيء يفوتك'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        children: [
          _sectionBadge('المميزات'),
          const SizedBox(height: 16),
          Text('كل ما تحتاجه في منصة واحدة',
              textAlign: TextAlign.center,
              style: AppTypography.h1
                  .copyWith(fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(
            'لا تحتاج لأدوات متعددة — Nawa Tech HRM يغطي كل دورة حياة الموظف',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 900 ? 3 : c.maxWidth > 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
              ),
              itemCount: _features.length,
              itemBuilder: (_, i) {
                final (icon, title, desc) = _features[i];
                return _FeatureCard(icon: icon, title: title, desc: desc);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.icon, required this.title, required this.desc});
  final IconData icon;
  final String title, desc;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _hovered ? AppColors.primary : AppColors.border),
          boxShadow: _hovered
              ? [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8))]
              : [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _hovered
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon,
                  color: _hovered ? Colors.white : AppColors.primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(widget.title,
                style: AppTypography.h4.copyWith(
                    color: _hovered ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(
              child: Text(widget.desc,
                  style: AppTypography.bodySmall.copyWith(
                      color: _hovered ? Colors.white70 : AppColors.textSecondary,
                      height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Screenshot Section ───────────────────────────────────────────────────────

class _ScreenshotSection extends StatelessWidget {
  const _ScreenshotSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 80),
      color: AppColors.background,
      child: Column(
        children: [
          _sectionBadge('كيف يعمل'),
          const SizedBox(height: 16),
          Text('واجهة بسيطة وقوية',
              textAlign: TextAlign.center,
              style: AppTypography.h1
                  .copyWith(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 48),
          isWide
              ? Row(
                  children: [
                    Expanded(child: _stepsList()),
                    const SizedBox(width: 60),
                    Expanded(child: _mockPhone()),
                  ],
                )
              : Column(
                  children: [
                    _mockPhone(),
                    const SizedBox(height: 40),
                    _stepsList(),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _stepsList() {
    final steps = [
      (Icons.app_registration_rounded, 'سجّل شركتك', 'أنشئ حساب في دقيقة واحدة واضبط إعدادات الشركة'),
      (Icons.person_add_rounded, 'أضف الموظفين', 'أدخل بيانات الفريق وفعّل حساباتهم على الجوال'),
      (Icons.auto_awesome_rounded, 'يعمل تلقائياً', 'حضور، إجازات، رواتب — كلها تُدار تلقائياً'),
    ];
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final (icon, title, desc) = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _mockPhone() {
    return Center(
      child: Container(
        width: 280,
        height: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFF334155), width: 6),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text('مرحباً، محمد 👋',
                    style: AppTypography.bodyMedium
                        .copyWith(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('الحضور اليوم',
                    style: AppTypography.h4.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                // Fake wifi status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.4))),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_rounded,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text('متصل بشبكة الشركة',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.success, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _phoneBtn('تسجيل الدخول', AppColors.primary),
                const SizedBox(height: 8),
                _phoneBtn('تسجيل الخروج', AppColors.surfaceVariant,
                    textColor: AppColors.textSecondary),
                const SizedBox(height: 20),
                // Quick actions
                Row(children: [
                  _phoneAction(Icons.event_note_rounded, 'إجازة'),
                  const SizedBox(width: 8),
                  _phoneAction(Icons.payments_rounded, 'راتب'),
                  const SizedBox(width: 8),
                  _phoneAction(Icons.person_rounded, 'ملفي'),
                ]),
                const SizedBox(height: 20),
                // Recent notifications
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('تمت الموافقة على إجازتك',
                            style: AppTypography.caption.copyWith(
                                color: Colors.white70, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneBtn(String label, Color bg, {Color textColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(label,
            style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _phoneAction(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: Colors.white54, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ─── Pricing ─────────────────────────────────────────────────────────────────

class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        children: [
          _sectionBadge('الأسعار'),
          const SizedBox(height: 16),
          Text('خطط تناسب كل شركة',
              textAlign: TextAlign.center,
              style: AppTypography.h1
                  .copyWith(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text('ابدأ مجاناً لمدة 14 يوماً، لا يتطلب بطاقة ائتمانية',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 56),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 900 ? 3 : 1;
            return cols == 3
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _plans(context),
                  )
                : Column(children: _plans(context));
          }),
        ],
      ),
    );
  }

  List<Widget> _plans(BuildContext context) => [
        _PlanCard(
          name: 'Starter',
          nameAr: 'الأساسية',
          price: '149',
          desc: 'للشركات الناشئة',
          employees: '25',
          features: ['إدارة الموظفين', 'الحضور (WiFi)', 'الإجازات', 'الرواتب', 'الإشعارات'],
          isPopular: false,
          onTap: () => context.go('/register'),
        ),
        _PlanCard(
          name: 'Growth',
          nameAr: 'النمو',
          price: '299',
          desc: 'الأكثر شعبية',
          employees: '50',
          features: ['كل مميزات Starter', 'التوظيف والمرشحين', 'تقارير متقدمة', 'دعم بالبريد', 'PDF للرواتب'],
          isPopular: true,
          onTap: () => context.go('/register'),
        ),
        _PlanCard(
          name: 'Enterprise',
          nameAr: 'المؤسسات',
          price: '599',
          desc: 'للمؤسسات الكبيرة',
          employees: '200',
          features: ['كل مميزات Growth', 'AI مساعد ذكي', 'API مفتوح', 'مدير حساب مخصص', 'SLA 99.9%'],
          isPopular: false,
          onTap: () => context.go('/register'),
        ),
      ];
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.nameAr,
    required this.price,
    required this.desc,
    required this.employees,
    required this.features,
    required this.isPopular,
    required this.onTap,
  });

  final String name, nameAr, price, desc, employees;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isPopular ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isPopular ? AppColors.primary : AppColors.border,
              width: isPopular ? 2 : 1),
          boxShadow: isPopular
              ? [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('⭐ الأكثر شعبية',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            Text(nameAr,
                style: AppTypography.bodyLarge.copyWith(
                    color: isPopular ? Colors.white70 : AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: AppTypography.h1.copyWith(
                        color: isPopular ? Colors.white : AppColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w900)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('ر.س/شهر',
                      style: AppTypography.caption.copyWith(
                          color: isPopular ? Colors.white60 : AppColors.textMuted)),
                ),
              ],
            ),
            Text('حتى $employees موظف',
                style: AppTypography.caption.copyWith(
                    color: isPopular ? Colors.white60 : AppColors.textMuted)),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: isPopular ? Colors.white70 : AppColors.success,
                          size: 18),
                      const SizedBox(width: 10),
                      Text(f,
                          style: AppTypography.bodySmall.copyWith(
                              color: isPopular ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary)),
                    ],
                  ),
                )),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: isPopular
                  ? FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('ابدأ الآن',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    )
                  : OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('ابدأ مجاناً'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Testimonials ─────────────────────────────────────────────────────────────

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      ('وفّر علينا ساعات يومياً في إدارة الحضور والرواتب. النظام سهل جداً وأثّر إيجابياً على فريق HR بأكمله.',
       'أحمد المطيري', 'مدير الموارد البشرية — شركة التقنيات المتقدمة'),
      ('أفضل منصة Nawa Tech HRM جربتها. التقارير الفورية والإشعارات التلقائية غيّرت طريقة عملنا كلياً.',
       'سارة الغامدي', 'مديرة العمليات — مجموعة النخبة التجارية'),
      ('التكامل بين لوحة الأدمن وتطبيق الجوال للموظفين مذهل. عميل للأبد!',
       'خالد العتيبي', 'الرئيس التنفيذي — شركة ريادة'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      color: AppColors.background,
      child: Column(
        children: [
          _sectionBadge('آراء العملاء'),
          const SizedBox(height: 16),
          Text('ماذا يقول عملاؤنا',
              textAlign: TextAlign.center,
              style: AppTypography.h1
                  .copyWith(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 900 ? 3 : c.maxWidth > 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.6,
              ),
              itemCount: testimonials.length,
              itemBuilder: (_, i) {
                final (text, name, role) = testimonials[i];
                return _TestimonialCard(text: text, name: name, role: role);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.text, required this.name, required this.role});
  final String text, name, role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ...List.generate(5,
                (_) => const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16)),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: Text('"$text"',
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary, height: 1.6)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(name[0],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700)),
                    Text(role,
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── CTA Section ──────────────────────────────────────────────────────────────

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('جاهز لتحويل إدارة فريقك؟',
              textAlign: TextAlign.center,
              style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text(
            'انضم لـ 500+ شركة تثق في Nawa Tech HRM\nابدأ تجربتك المجانية اليوم — لا تحتاج لبطاقة ائتمانية',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge
                .copyWith(color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () => context.go('/register'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  textStyle: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                child: const Text('ابدأ مجاناً الآن'),
              ),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                ),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      color: AppColors.textPrimary,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _brand()),
              Expanded(child: _links('المنتج', ['المميزات', 'الأسعار', 'العملاء', 'التوثيق'])),
              Expanded(child: _links('الشركة', ['من نحن', 'الوظائف', 'المدونة', 'اتصل بنا'])),
              Expanded(child: _links('الدعم', ['مركز المساعدة', 'سياسة الخصوصية', 'شروط الخدمة', 'الأمان'])),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('© 2025 Nawa Tech HRM. جميع الحقوق محفوظة.',
                  style: AppTypography.caption.copyWith(color: Colors.white38)),
              Row(children: [
                _socialIcon(Icons.telegram),
                const SizedBox(width: 12),
                _socialIcon(Icons.language_rounded),
                const SizedBox(width: 12),
                _socialIcon(Icons.flutter_dash_rounded),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          Text('Nawa Tech HRM',
              style: AppTypography.h3.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 12),
        Text('منصة إدارة الموارد البشرية\nالأذكى للشركات العربية',
            style: AppTypography.bodySmall.copyWith(
                color: Colors.white38, height: 1.6)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, color: AppColors.success, size: 8),
              const SizedBox(width: 6),
              Text('جميع الأنظمة تعمل',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.success, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _links(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTypography.bodySmall.copyWith(
                color: Colors.white70, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...links.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l,
                  style: AppTypography.caption.copyWith(
                      color: Colors.white38)),
            )),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Colors.white54, size: 18),
    );
  }
}

// ─── Shared helper ────────────────────────────────────────────────────────────

Widget _sectionBadge(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Text(label,
        style: AppTypography.caption.copyWith(
            color: AppColors.primary, fontWeight: FontWeight.w600)),
  );
}
