import 'package:flutter/material.dart';
import 'main.dart';
import 'ai_chat_screen.dart';
import 'pdf_quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('صاحبي'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => supabase.auth.signOut(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أهلاً بيك 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('اختار إيه اللي عايز تعمله دلوقتي',
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 24),
              _FeatureCard(
                title: 'المساعد الذكي',
                subtitle: 'اسأل عن أي حاجة في حياتك أو دراستك أو شغلك',
                icon: Icons.smart_toy_rounded,
                color: const Color(0xFF4A3AFF),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiChatScreen())),
              ),
              const SizedBox(height: 14),
              _FeatureCard(

                title: 'حوّل محاضرتك لأسئلة',
                subtitle: 'ارفع PDF واحصل على اختبار فوري',
                icon: Icons.quiz_rounded,
                color: const Color(0xFF4A3AFF),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PdfQuizScreen())),
             ),
              const SizedBox(height: 14),
              _FeatureCard(
                title: 'فرص الشغل',
                subtitle: 'CV، مقابلات، ومهارات مطلوبة',
                icon: Icons.work_rounded,
                color: Colors.white10,
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                if (enabled) const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}