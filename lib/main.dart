import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const QFlowApp());
}

class QFlowApp extends StatelessWidget {
  const QFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q-Flow Hospital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D7CBA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED GRADIENT BACKGROUND
// ─────────────────────────────────────────────
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  const GradientScaffold({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D7CBA), Color(0xFF12B886)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 1. LOGIN SCREEN
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController(text: 'PMJAY-MH-2024-887654');
  late AnimationController _btnController;
  late Animation<double> _scaleAnim;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _btnController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    setState(() => _loading = true);
    await _btnController.forward();
    await _btnController.reverse();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).push(_slideRoute(const OtpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                size: 72,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'Q-Flow',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'Hospital Smart Queue',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 44),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ayushman ID',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D7CBA),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.credit_card,
                          color: Color(0xFF0D7CBA),
                        ),
                        hintText: 'PMJAY-XX-XXXX-XXXXXX',
                        filled: true,
                        fillColor: const Color(0xFFF0F8FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D7CBA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Send OTP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Powered by Ayushman Bharat',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2. OTP SCREEN
// ─────────────────────────────────────────────
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _verifying = false;
  bool _success = false;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _autoFillOtp();
  }

  void _autoFillOtp() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final digits = ['4', '2', '7', '8', '9', '1'];
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _otpControllers[i].text = digits[i]);
    }
  }

  void _verify() async {
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _verifying = false;
      _success = true;
    });
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushAndRemoveUntil(_fadeRoute(const DashboardScreen()), (r) => false);
  }

  @override
  void dispose() {
    _checkController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _glassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.phone_android,
                  size: 48,
                  color: Color(0xFF0D7CBA),
                ),
                const SizedBox(height: 12),
                const Text(
                  'OTP Verification',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'OTP sent to registered mobile number',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                if (_success)
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFF12B886),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: 40,
                        child: TextField(
                          controller: _otpControllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF0F8FF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (v) {
                            if (v.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: 24),
                if (!_success)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D7CBA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 3. DASHBOARD SCREEN
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnims = List.generate(3, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeOut),
        ),
      );
    });
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  final _cards = [
    {
      'icon': Icons.local_hospital_rounded,
      'title': 'Book by Hospital',
      'subtitle': 'Find & book from nearby hospitals',
      'color': Color(0xFF0D7CBA),
    },
    {
      'icon': Icons.person_search_rounded,
      'title': 'Nearby Doctors',
      'subtitle': 'Browse specialists near you',
      'color': Color(0xFF12B886),
    },
    {
      'icon': Icons.queue_rounded,
      'title': 'My Queue Status',
      'subtitle': 'Track your current token',
      'color': Color(0xFF845EF7),
    },
  ];

  void _onCardTap(int idx, BuildContext context) {
    if (idx == 0) {
      Navigator.push(context, _slideRoute(const HospitalListScreen()));
    } else if (idx == 1) {
      Navigator.push(
        context,
        _slideRoute(const BookAppointmentScreen(initialTab: 1)),
      );
    } else {
      Navigator.push(context, _slideRoute(const QueueStatusScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome back,',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      'Ramesh Kumar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'What would you like to do?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (ctx, i) {
                  final card = _cards[i];
                  return SlideTransition(
                    position: _slideAnims[i],
                    child: FadeTransition(
                      opacity: _animController,
                      child: _DashCard(
                        icon: card['icon'] as IconData,
                        title: card['title'] as String,
                        subtitle: card['subtitle'] as String,
                        color: card['color'] as Color,
                        onTap: () => _onCardTap(i, context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<_DashCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tap;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _tap, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _tap.forward(),
        onTapUp: (_) async {
          await _tap.reverse();
          widget.onTap();
        },
        onTapCancel: () => _tap.reverse(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: widget.color, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────
const List<Map<String, dynamic>> hospitalsData = [
  {
    'name': 'City Care Hospital',
    'distance': '4.2 km',
    'rating': '4.6',
    'specialities': 'Cardiology, Ortho',
    'doctors': [
      {
        'name': 'Dr. Sharma',
        'spec': 'Cardiology',
        'exp': '14 yrs',
        'rating': '4.8',
        'avail': 'Available Today',
      },
      {
        'name': 'Dr. Kapoor',
        'spec': 'Orthopedic',
        'exp': '9 yrs',
        'rating': '4.5',
        'avail': 'Limited Slots',
      },
    ],
  },
  {
    'name': 'Apollo Clinic',
    'distance': '2.8 km',
    'rating': '4.8',
    'specialities': 'Neurology, ENT',
    'doctors': [
      {
        'name': 'Dr. Mehta',
        'spec': 'Neurology',
        'exp': '12 yrs',
        'rating': '4.9',
        'avail': 'Available Today',
      },
      {
        'name': 'Dr. Bose',
        'spec': 'ENT',
        'exp': '7 yrs',
        'rating': '4.6',
        'avail': 'Available Today',
      },
    ],
  },
  {
    'name': 'Metro Health Center',
    'distance': '6.1 km',
    'rating': '4.4',
    'specialities': 'General Medicine, Pediatrics',
    'doctors': [
      {
        'name': 'Dr. Iyer',
        'spec': 'General Medicine',
        'exp': '8 yrs',
        'rating': '4.9',
        'avail': 'Limited Slots',
      },
      {
        'name': 'Dr. Rao',
        'spec': 'Pediatrics',
        'exp': '11 yrs',
        'rating': '4.7',
        'avail': 'Available Today',
      },
    ],
  },
  {
    'name': 'Sunrise Hospital',
    'distance': '3.5 km',
    'rating': '4.7',
    'specialities': 'Dermatology, Gynecology',
    'doctors': [
      {
        'name': 'Dr. Nair',
        'spec': 'Dermatology',
        'exp': '6 yrs',
        'rating': '4.8',
        'avail': 'Available Today',
      },
      {
        'name': 'Dr. Singh',
        'spec': 'Gynecology',
        'exp': '15 yrs',
        'rating': '4.9',
        'avail': 'Limited Slots',
      },
    ],
  },
  {
    'name': 'LifeLine Medical',
    'distance': '5.0 km',
    'rating': '4.3',
    'specialities': 'Ophthalmology, Urology',
    'doctors': [
      {
        'name': 'Dr. Ghosh',
        'spec': 'Ophthalmology',
        'exp': '10 yrs',
        'rating': '4.4',
        'avail': 'Available Today',
      },
      {
        'name': 'Dr. Verma',
        'spec': 'Urology',
        'exp': '13 yrs',
        'rating': '4.6',
        'avail': 'Limited Slots',
      },
    ],
  },
  {
    'name': 'Wellness Hub',
    'distance': '1.9 km',
    'rating': '4.5',
    'specialities': 'Psychiatry, Physiotherapy',
    'doctors': [
      {
        'name': 'Dr. Pillai',
        'spec': 'Psychiatry',
        'exp': '8 yrs',
        'rating': '4.5',
        'avail': 'Available Today',
      },
      {
        'name': 'Dr. Khan',
        'spec': 'Physiotherapy',
        'exp': '5 yrs',
        'rating': '4.3',
        'avail': 'Available Today',
      },
    ],
  },
];

const _doctors = [
  {
    'name': 'Dr. Sharma',
    'spec': 'Cardiology',
    'exp': '14 yrs',
    'rating': '4.8',
  },
  {'name': 'Dr. Mehta', 'spec': 'Neurology', 'exp': '12 yrs', 'rating': '4.9'},
  {
    'name': 'Dr. Iyer',
    'spec': 'General Medicine',
    'exp': '8 yrs',
    'rating': '4.9',
  },
];

// ─────────────────────────────────────────────
// 4. BOOK APPOINTMENT SCREEN
// ─────────────────────────────────────────────

class BookAppointmentScreen extends StatefulWidget {
  final int initialTab;
  const BookAppointmentScreen({super.key, this.initialTab = 0});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openBookingSheet(Map<String, String> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(doctor: doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D7CBA), Color(0xFF12B886)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Book Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: const Color(0xFF0D7CBA),
                  unselectedLabelColor: Colors.white,
                  tabs: const [
                    Tab(text: 'Hospitals'),
                    Tab(text: 'Doctors'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _HospitalList(
                      onSelect: (h) {
                        _openBookingSheet({
                          'name': 'Dr. Sharma',
                          'spec': 'Cardiology',
                        });
                      },
                    ),
                    _DoctorList(onSelect: _openBookingSheet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HospitalList extends StatelessWidget {
  final Function(String) onSelect;
  const _HospitalList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: hospitalsData.length,
      itemBuilder: (ctx, i) {
        final h = hospitalsData[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0D7CBA).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF0D7CBA),
              ),
            ),
            title: Text(
              h['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${h['distance']}  ⭐ ${h['rating']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: ElevatedButton(
              onPressed: () => onSelect(h['name'] as String),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7CBA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text('Book', style: TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}

class _DoctorList extends StatelessWidget {
  final Function(Map<String, String>) onSelect;
  const _DoctorList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _doctors.length,
      itemBuilder: (ctx, i) {
        final doc = _doctors[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF12B886).withOpacity(0.15),
              child: Text(
                doc['name']!.split(' ').last[0],
                style: const TextStyle(
                  color: Color(0xFF12B886),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              doc['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['spec']!,
                  style: const TextStyle(
                    color: Color(0xFF0D7CBA),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${doc['exp']}  ⭐ ${doc['rating']}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () =>
                  onSelect({'name': doc['name']!, 'spec': doc['spec']!}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12B886),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text('Book', style: TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// HOSPITAL LIST SCREEN
// ─────────────────────────────────────────────
class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<Offset>> _slides;
  late List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slides = List.generate(hospitalsData.length, (i) {
      return Tween<Offset>(
        begin: const Offset(0.4, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            i * 0.08,
            (i * 0.08 + 0.5).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    _fades = List.generate(hospitalsData.length, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            i * 0.08,
            (i * 0.08 + 0.5).clamp(0, 1),
            curve: Curves.easeOut,
          ),
        ),
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D7CBA), Color(0xFF12B886)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Hospitals Near You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: hospitalsData.length,
                  itemBuilder: (ctx, i) {
                    final h = hospitalsData[i];
                    return SlideTransition(
                      position: _slides[i],
                      child: FadeTransition(
                        opacity: _fades[i],
                        child: _HospitalCard(
                          hospital: h,
                          onTap: () => Navigator.push(
                            context,
                            _slideRoute(HospitalDetailScreen(hospital: h)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HospitalCard extends StatefulWidget {
  final Map<String, dynamic> hospital;
  final VoidCallback onTap;
  const _HospitalCard({required this.hospital, required this.onTap});

  @override
  State<_HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<_HospitalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tap;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _tap, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.hospital;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _tap.forward(),
        onTapUp: (_) async {
          await _tap.reverse();
          widget.onTap();
        },
        onTapCancel: () => _tap.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D7CBA).withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D7CBA).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Color(0xFF0D7CBA),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      h['specialities'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D7CBA),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          h['distance'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          h['rating'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF0D7CBA),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOSPITAL DETAIL SCREEN
// ─────────────────────────────────────────────
class HospitalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;
  const HospitalDetailScreen({super.key, required this.hospital});

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<Offset>> _slides;

  void _openBookingSheet(Map<String, String> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(doctor: doctor),
    );
  }

  @override
  void initState() {
    super.initState();
    final docs = widget.hospital['doctors'] as List;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slides = List.generate(docs.length, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            i * 0.15,
            (i * 0.15 + 0.55).clamp(0, 1),
            curve: Curves.easeOut,
          ),
        ),
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.hospital;
    final docs = h['doctors'] as List<dynamic>;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D7CBA), Color(0xFF12B886)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        h['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      h['distance'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      h['rating'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        h['specialities'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Doctors at ${h['name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final doc = docs[i] as Map<String, dynamic>;
                    final isAvail = doc['avail'] == 'Available Today';
                    return SlideTransition(
                      position: _slides[i],
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(
                                    0xFF12B886,
                                  ).withOpacity(0.15),
                                  child: Text(
                                    (doc['name'] as String).split(' ').last[0],
                                    style: const TextStyle(
                                      color: Color(0xFF12B886),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc['name'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        doc['spec'] as String,
                                        style: const TextStyle(
                                          color: Color(0xFF0D7CBA),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAvail
                                        ? const Color(
                                            0xFF12B886,
                                          ).withOpacity(0.12)
                                        : Colors.orange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    doc['avail'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isAvail
                                          ? const Color(0xFF12B886)
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.work_outline,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  doc['exp'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  doc['rating'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () => _openBookingSheet({
                                  'name': doc['name'] as String,
                                  'spec': doc['spec'] as String,
                                }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D7CBA),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Book Appointment',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOOKING BOTTOM SHEET
// ─────────────────────────────────────────────
class _BookingSheet extends StatefulWidget {
  final Map<String, String> doctor;
  const _BookingSheet({required this.doctor});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String _selectedTime = '10:00 AM';
  String _selectedDept = 'Cardiology';
  String _selectedSeverity = 'Medium';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _confirming = false;

  final _times = ['09:00 AM', '10:00 AM', '11:30 AM', '02:00 PM', '04:00 PM'];
  final _depts = [
    'Cardiology',
    'Orthopedic',
    'General Medicine',
    'ENT',
    'Neurology',
  ];
  final _severities = ['Low', 'Medium', 'High'];

  void _confirm() async {
    setState(() => _confirming = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => _SuccessDialog(severity: _selectedSeverity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Book with ${widget.doctor['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.doctor['spec'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 28),
            _label('Date'),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: _fieldBox(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF0D7CBA),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _label('Time Slot'),
            _dropdownField(
              value: _selectedTime,
              items: _times,
              onChanged: (v) => setState(() => _selectedTime = v!),
            ),
            const SizedBox(height: 14),
            _label('Department'),
            _dropdownField(
              value: _selectedDept,
              items: _depts,
              onChanged: (v) => setState(() => _selectedDept = v!),
            ),
            const SizedBox(height: 14),
            _label('Severity'),
            Row(
              children: _severities.map((s) {
                final selected = _selectedSeverity == s;
                final color = s == 'High'
                    ? Colors.red
                    : s == 'Medium'
                    ? Colors.orange
                    : Colors.green;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSeverity = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(0.15)
                            : Colors.grey.shade100,
                        border: Border.all(
                          color: selected ? color : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          s,
                          style: TextStyle(
                            color: selected ? color : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _label('Reason for Visit'),
            TextFormField(
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Brief description...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _confirming ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7CBA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: _confirming
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Confirm Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.black87,
      ),
    ),
  );

  Widget _fieldBox({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUCCESS DIALOG
// ─────────────────────────────────────────────
class _SuccessDialog extends StatefulWidget {
  final String severity;
  const _SuccessDialog({required this.severity});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFF12B886),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Appointment Booked!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your token has been generated.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    _slideRoute(QueueStatusScreen(severity: widget.severity)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7CBA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Queue Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 5. QUEUE STATUS SCREEN
// ─────────────────────────────────────────────
class QueueStatusScreen extends StatefulWidget {
  final String severity;
  const QueueStatusScreen({super.key, this.severity = 'Medium'});

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _fadeCtrl;

  final int _myToken = 47;
  final int _currentServing = 44;
  late int _peopleAhead;
  late int _waitTime;

  @override
  void initState() {
    super.initState();
    _peopleAhead = _myToken - _currentServing;
    _waitTime = _peopleAhead * 7;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Color get _severityColor => widget.severity == 'High'
      ? Colors.red
      : widget.severity == 'Medium'
      ? Colors.orange
      : Colors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D7CBA), Color(0xFF12B886)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Queue Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (widget.severity == 'High')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Priority',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'YOUR TOKEN',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  '$_myToken',
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D7CBA),
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _glassCard(
                          child: Column(
                            children: [
                              _queueRow(
                                Icons.play_circle_outline_rounded,
                                'Currently Serving',
                                '$_currentServing',
                                Colors.green,
                              ),
                              const Divider(height: 20),
                              _queueRow(
                                Icons.people_outline_rounded,
                                'People Ahead',
                                '$_peopleAhead',
                                Colors.orange,
                              ),
                              const Divider(height: 20),
                              _queueRow(
                                Icons.timer_outlined,
                                'Estimated Wait',
                                '$_waitTime min',
                                const Color(0xFF0D7CBA),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: LinearProgressIndicator(
                            value: _currentServing / _myToken,
                            minHeight: 10,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Start',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'Token $_myToken',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _statusMessageCard(),
                        const SizedBox(height: 16),
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.psychology_outlined,
                                    color: Color(0xFF0D7CBA),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'AI Wait Estimate',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Based on ${"$_peopleAhead people × 7 min avg"}, estimated wait is $_waitTime minutes.',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusMessageCard() {
    final isHigh = widget.severity == 'High';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHigh
            ? Colors.red.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        border: Border.all(
          color: isHigh ? Colors.red.shade300 : Colors.orange.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isHigh ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: isHigh ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isHigh
                  ? 'You have been prioritized due to high severity.'
                  : 'Emergency case arrived. Your token shifted.',
              style: TextStyle(
                color: isHigh ? Colors.red.shade800 : Colors.orange.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _queueRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
Widget _glassCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

PageRoute _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, anim, __) => page,
    transitionsBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

PageRoute _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, anim, __) => page,
    transitionsBuilder: (_, anim, __, child) {
      return FadeTransition(opacity: anim, child: child);
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}
