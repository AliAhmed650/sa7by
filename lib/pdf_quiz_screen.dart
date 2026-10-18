import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'secrets.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;
  QuizQuestion({required this.question, required this.options, required this.answerIndex});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answerIndex: json['answer_index'] as int,
    );
  }
}

class PdfQuizScreen extends StatefulWidget {
  const PdfQuizScreen({super.key});
  @override
  State<PdfQuizScreen> createState() => _PdfQuizScreenState();
}

class _PdfQuizScreenState extends State<PdfQuizScreen> {
  bool _loading = false;
  String? _error;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _finished = false;

  Future<void> _pickAndGenerate() async {
    setState(() {
      _loading = true;
      _error = null;
      _questions = [];
      _currentIndex = 0;
      _score = 0;
      _finished = false;
    });

    try {
      const typeGroup = XTypeGroup(label: 'PDF', extensions: ['pdf']);
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) {
       setState(() => _loading = false);
       return;
}

final bytes = await file.readAsBytes();
      
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      String text = extractor.extractText();
      document.dispose();

      if (text.trim().isEmpty) {
        setState(() {
          _error = 'معرفتش أقرا نص من الملف ده. جرب ملف PDF فيه نص حقيقي (مش صور ممسوحة).';
          _loading = false;
        });
        return;
      }

      if (text.length > 15000) {
        text = text.substring(0, 15000);
      }

      final model = GenerativeModel(model: 'gemini-flash-latest', apiKey: geminiApiKey);
      final prompt = '''
انت مساعد بيحوّل محتوى محاضرات لأسئلة اختيار من متعدد (MCQ).
اقرا النص ده واطلع منه 5 أسئلة اختيار من متعدد بالعربي، كل سؤال ليه 4 اختيارات واختيار واحد صح بس.
رجعلي الرد بصيغة JSON فقط، من غير أي كلام تاني قبله أو بعده، بالشكل ده بالظبط:
[
  {"question": "نص السؤال", "options": ["اختيار1","اختيار2","اختيار3","اختيار4"], "answer_index": 0}
]
answer_index هو رقم الاختيار الصح (0 لحد 3).

النص:
$text
''';

      final response = await model.generateContent([Content.text(prompt)]);
      String raw = response.text ?? '';
      raw = raw.trim();
      if (raw.startsWith('```')) {
        raw = raw.replaceAll(RegExp(r'^```json'), '').replaceAll(RegExp(r'^```'), '').replaceAll(RegExp(r'```$'), '').trim();
      }

      final List<dynamic> parsed = jsonDecode(raw);
      final questions = parsed.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>)).toList();

      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'حصل خطأ أثناء توليد الأسئلة: $e';
        _loading = false;
      });
    }
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _questions[_currentIndex].answerIndex) {
        _score++;
      }
    });
  }

  void _next() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حوّل محاضرتك لأسئلة')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('بنولّد الأسئلة من الملف...'),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 60, color: Colors.white54),
            const SizedBox(height: 16),
            const Text('اختار ملف PDF لمحاضرتك وهنحوّله لاختبار فوري', textAlign: TextAlign.center),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _pickAndGenerate,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('اختر ملف PDF'),
            ),
          ],
        ),
      );
    }

    if (_finished) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            Text('نتيجتك: $_score من ${_questions.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _pickAndGenerate,
              child: const Text('جرب ملف تاني'),
            ),
          ],
        ),
      );
    }

    final q = _questions[_currentIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('سؤال ${_currentIndex + 1} من ${_questions.length}', style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 12),
        Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          final isSelected = _selectedOption == i;
          final isCorrect = i == q.answerIndex;
          Color? color;
          if (_answered) {
            if (isCorrect) {
              color = Colors.green.withOpacity(0.3);
            } else if (isSelected) {
              color = Colors.red.withOpacity(0.3);
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: color ?? Colors.white10,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _selectOption(i),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(q.options[i]),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        if (_answered)
          FilledButton(
            onPressed: _next,
            child: Text(_currentIndex + 1 < _questions.length ? 'التالي' : 'عرض النتيجة'),
          ),
      ],
    );
  }
}