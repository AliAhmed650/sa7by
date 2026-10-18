import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'secrets.dart';

class ChatMessage {
  final String text;
  final bool fromUser;
  ChatMessage(this.text, this.fromUser);
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: "gemini-flash-latest",
      apiKey: geminiApiKey,
      systemInstruction: Content.text(
        'إنت "صاحبي"، مساعد ذكاء اصطناعي ودود بيساعد الطلاب والخريجين وأصحاب '
        'المشاريع الصغيرة في حياتهم اليومية. رد دايمًا بالعربي المصري، بشكل '
        'عملي ومختصر، وقدّم خطوات واضحة لما حد يسأل عن حاجة محتاجة خطوات.',
      ),
    );
    _chat = _model.startChat();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(ChatMessage(text, true));
      _controller.clear();
      _loading = true;
    });
    _scrollToBottom();
    try {
      final response = await _chat.sendMessage(Content.text(text));
      setState(() {
        _messages.add(ChatMessage(response.text ?? 'معرفتش أرد على ده، جرب تاني.', false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage('حصل خطأ في الاتصال: $e', false));
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المساعد الذكي 🤖')),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'اسألني أي حاجة، زي:\n"اعمل لي جدول مذاكرة للأسبوع"\n"عايز أبدأ فريلانس ومش عارف أبدأ منين"',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final m = _messages[i];
                        return Align(
                          alignment: m.fromUser
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: m.fromUser
                                  ? Colors.white10
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(m.text,
                                style: TextStyle(
                                    color: m.fromUser
                                        ? Colors.white
                                        : Colors.white)),
                          ),
                        );
                      },
                    ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator()),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'اكتب سؤالك هنا...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24))),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}