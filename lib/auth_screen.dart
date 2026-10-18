import 'package:flutter/material.dart';
import 'main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool isLogin = true;
  bool loading = false;
  String? error;

  Future<void> _submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      } else {
        final res = await supabase.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = 'حصل خطأ: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('صاحبي',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('مساعدك الذكي في حياتك اليومية',
                        style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 32),
                    if (!isLogin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'الاسم', border: OutlineInputBorder()),
                        ),
                      ),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'الإيميل', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'كلمة السر', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading ? null : _submit,
                        child: Text(loading
                            ? '...'
                            : (isLogin ? 'تسجيل الدخول' : 'إنشاء حساب')),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(isLogin
                          ? 'لسه معملتش حساب؟ سجّل دلوقتي'
                          : 'عندك حساب؟ سجّل دخول'),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(error!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}