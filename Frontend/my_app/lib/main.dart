import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/room_page.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color brandMint = Color.fromRGBO(146, 202, 170, 1);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.nunitoTextTheme();

    final base = ThemeData(useMaterial3: true, textTheme: textTheme);
    final colorScheme = base.colorScheme.copyWith(
      primary: brandMint,
      secondary: brandMint,
    );

    return MaterialApp(
      title: 'Wellspace',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        colorScheme: colorScheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: textTheme.bodyMedium,
          hintStyle: textTheme.bodyMedium,
          floatingLabelStyle: textTheme.bodyMedium?.copyWith(
            color: Colors.black.withOpacity(0.75),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const AuthChoicePage(title: 'Wellspace'),
    );
  }
}

// =========================
// Background assets + chooser
// =========================

const String kDayRoomBackgroundAssetPath =
    'assets/images/rooms/daylight_room.png';
const String kNightRoomBackgroundAssetPath =
    'assets/images/rooms/night_room.png';

String roomBackgroundFor(DateTime t) {
  final h = t.hour;
  final isNight = (h >= 20 || h < 6); // Night: 20:00–05:59
  return isNight ? kNightRoomBackgroundAssetPath : kDayRoomBackgroundAssetPath;
}

/// Fade
PageRouteBuilder<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final fade =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final scale = Tween<double>(begin: 0.99, end: 1.0).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

class RoomLoadingPage extends StatelessWidget {
  const RoomLoadingPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgAsset = roomBackgroundFor(DateTime.now());

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(bgAsset, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: const SizedBox.expand(),
          ),
          Container(color: Colors.black.withOpacity(0.40)),
          Positioned(
            top: 24,
            left: 24,
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.88),
                shadows: [
                  Shadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.35),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F0E8).withOpacity(0.92),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.22),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MyApp.brandMint.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Preparing your room…',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared card background + breathing effect wrapper
class CozyAuthShell extends StatefulWidget {
  const CozyAuthShell({
    super.key,
    required this.title,
    required this.child,
    this.showTopTitle = true,
  });

  final String title;
  final Widget child;
  final bool showTopTitle;

  @override
  State<CozyAuthShell> createState() => _CozyAuthShellState();
}

class _CozyAuthShellState extends State<CozyAuthShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleCtrl;
  late final Animation<double> _dimOpacity;
  late final Animation<double> _shadowBlur;
  late final Animation<double> _shadowYOffset;

  @override
  void initState() {
    super.initState();
    _idleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..repeat(reverse: true);

    _dimOpacity = Tween<double>(begin: 0.34, end: 0.38).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut),
    );

    _shadowBlur = Tween<double>(begin: 22, end: 28).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut),
    );

    _shadowYOffset = Tween<double>(begin: 10, end: 14).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgAsset = roomBackgroundFor(DateTime.now());

    return Scaffold(
      body: AnimatedBuilder(
        animation: _idleCtrl,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(bgAsset, fit: BoxFit.cover),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const SizedBox.expand(),
              ),
              Container(color: Colors.black.withOpacity(_dimOpacity.value)),
              if (widget.showTopTitle)
                Positioned(
                  top: 24,
                  left: 24,
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.88),
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black.withOpacity(0.35),
                        ),
                      ],
                    ),
                  ),
                ),
              Center(
                child: _BreathingCard(
                  maxWidth:
                      MediaQuery.of(context).size.width.clamp(320.0, 480.0),
                  blurRadius: _shadowBlur.value,
                  yOffset: _shadowYOffset.value,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BreathingCard extends StatelessWidget {
  const _BreathingCard({
    required this.maxWidth,
    required this.blurRadius,
    required this.yOffset,
    required this.child,
  });

  final double maxWidth;
  final double blurRadius;
  final double yOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F0E8).withOpacity(0.93),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: blurRadius,
                offset: Offset(0, yOffset),
                color: Colors.black.withOpacity(0.22),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Landing screen: 2 buttons (Login / Register)
class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CozyAuthShell(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome',
            style:
                theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how you want to enter.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  fadeRoute(LoginPage(title: title)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyApp.brandMint,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Log in',
                style:
                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  fadeRoute(RegisterPage(title: title)),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black.withOpacity(0.85),
                side: BorderSide(color: Colors.black.withOpacity(0.18), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white.withOpacity(0.50),
              ),
              child: Text(
                'Create account',
                style:
                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            'Tip: you can always make a new account later.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared textfield decoration (cozy focus ring)
InputDecoration cozyFieldDecoration({
  required String label,
  Widget? suffixIcon,
}) {
  final baseBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.18), width: 1.2),
  );

  final focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(
      color: MyApp.brandMint.withOpacity(0.85),
      width: 2.0,
    ),
  );

  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white.withOpacity(0.78),
    border: baseBorder,
    enabledBorder: baseBorder,
    focusedBorder: focusedBorder,
    suffixIcon: suffixIcon,
  );
}

/// Login page (uses ApiService().login)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enterRoomWithUserId(int userId) async {
   
    Navigator.of(context).push(fadeRoute(RoomLoadingPage(title: widget.title)));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        fadeRoute(MyRoomPage(userId: userId)),
      );
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    try {
      final res = await ApiService().login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (res["success"] == true) {
        final user = res["user"];
        final id = user?["id"];
        if (id is int) {
          await _enterRoomWithUserId(id);
        } else if (id is num) {
          await _enterRoomWithUserId(id.toInt());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login succeeded but user id was missing.")),
          );
        }
      } else {
        final msg = res["error"] ?? "Login failed";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CozyAuthShell(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style:
                theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your space',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration: cozyFieldDecoration(label: 'Username'),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword, // dots/*-style
            enableSuggestions: false,
            autocorrect: false,
            onSubmitted: (_) => _submit(),
            decoration: cozyFieldDecoration(
              label: 'Password',
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyApp.brandMint,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Enter',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No account?",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black.withOpacity(0.60),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    fadeRoute(RegisterPage(title: widget.title)),
                  );
                },
                child: const Text("Create one"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Register page 
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});
  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _enterRoomWithUserId(int userId) async {
    Navigator.of(context).push(fadeRoute(RoomLoadingPage(title: widget.title)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        fadeRoute(MyRoomPage(userId: userId)),
      );
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final pass = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a username and password.")),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService().register(username, pass);

      if (!mounted) return;

      if (res["success"] == true) {
        final user = res["user"];
        final id = user?["id"];
        if (id is int) {
          await _enterRoomWithUserId(id);
        } else if (id is num) {
          await _enterRoomWithUserId(id.toInt());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registered, but user id was missing.")),
          );
        }
      } else {
        final msg = res["error"] ?? "Register failed";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CozyAuthShell(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create your space',
            style:
                theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a username and password.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration: cozyFieldDecoration(label: 'Username'),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: cozyFieldDecoration(
              label: 'Password',
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            enableSuggestions: false,
            autocorrect: false,
            onSubmitted: (_) => _submit(),
            decoration: cozyFieldDecoration(
              label: 'Confirm password',
              suffixIcon: IconButton(
                tooltip:
                    _obscureConfirm ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyApp.brandMint,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Create account',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black.withOpacity(0.60),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    fadeRoute(LoginPage(title: widget.title)),
                  );
                },
                child: const Text("Log in"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
