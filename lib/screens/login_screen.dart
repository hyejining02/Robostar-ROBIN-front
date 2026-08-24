import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/robin_theme.dart';
import '../widgets/user_profile.dart';
import 'app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  String? _errorMessage;

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '아이디와 비밀번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      activateRobinAccount(
        result['username']?.toString() ?? _usernameController.text.trim(),
        role: result['role']?.toString(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      setState(() {
        _errorMessage = result['message'] ?? '로그인에 실패했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RobinTheme.sidebarBg,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: RobinTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 로고영역 ---
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: RobinTheme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('R',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('ROBIN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: RobinTheme.primary,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Center(
                child: Text(
                  'ROBIN 포털 로그인',
                  style:
                      RobinTheme.bodySm.copyWith(color: RobinTheme.textMuted),
                ),
              ),
              const SizedBox(height: 32),

              // --- 아이디 입력 ---
              Text('아이디', style: RobinTheme.headingSm.copyWith(fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,

                // 엔터누르면 비밀번호 입력창으로 포커스 이동
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hint: '아이디를 입력하세요',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),

              // --- 비밀번호 입력 ---
              Text('비밀번호', style: RobinTheme.headingSm.copyWith(fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,

                //obscureText = true면 비밀번호를 ****으로 처리
                obscureText: _obscurePassword,

                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),

                decoration: _inputDecoration(
                  hint: '비밀번호를 입력하세요',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: RobinTheme.textMuted,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- 에러메세지 ---
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: RobinTheme.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: RobinTheme.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 16, color: RobinTheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: RobinTheme.bodySm
                              .copyWith(color: RobinTheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: RobinTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: RobinTheme.border),
                ),
                child: Text(
                  '관리자  admin / 1234\n직원  staff / 1234\n대리점  kimdealer / 1234',
                  style: RobinTheme.bodySm.copyWith(height: 1.6),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RobinTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      // 로딩중이 아니면 텍스트 표시
                      : const Text('로그인',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    activateRobinAccount('admin', role: 'ADMIN');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AppShell()),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('로그인없이 둘러보기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 입력창 스타일(반복되는 디자인 -> 함수로) ---
  // 아이디 입력창이랑 비밀번호 입력창이 같은 스타일 = 함수재사용
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: RobinTheme.bodySm.copyWith(color: RobinTheme.textMuted),
      prefixIcon: Icon(icon, size: 18, color: RobinTheme.textMuted),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RobinTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RobinTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RobinTheme.accent, width: 1.5),
      ),
      filled: true,
      fillColor: RobinTheme.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
