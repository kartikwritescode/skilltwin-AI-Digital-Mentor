import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/core/services/voice_service.dart';
import 'package:skilltwin/core/models/mentor_message.dart';
import 'package:skilltwin/features/mentor/presentation/providers/mentor_recommendation_provider.dart';

void main() {
  group('Mentor Voice & Markdown Stripper Tests', () {
    test('stripMarkdownForSpeech cleanly removes syntax artifacts', () {
      const markdown = '''
# Foundations in ML
Here is why **Vectors** matter!
Look at this code:
```python
def dot(a, b):
    return sum(x*y for x, y in zip(a, b))
```
Also remember `a.dot(b)` is commutative.
Check [Linear Algebra Guide](https://example.com/algebra) for details.
> An invariant is a property that remains unchanged.
- Vector spaces
- Dot products
1. Practice
''';

      final stripped = MentorVoiceService.stripMarkdownForSpeech(markdown);

      // Verify no syntax characters remain that TTS would phonetically read aloud
      expect(stripped.contains('#'), isFalse);
      expect(stripped.contains('**'), isFalse);
      expect(stripped.contains('```'), isFalse);
      expect(stripped.contains('`'), isFalse);
      expect(stripped.contains('[Linear Algebra Guide]'), isFalse);
      expect(stripped.contains('https://'), isFalse);
      expect(stripped.contains('>'), isFalse);

      // Verify human words remain legible
      expect(stripped.contains('Foundations in ML'), isTrue);
      expect(stripped.contains('Here is why Vectors matter!'), isTrue);
      expect(stripped.contains('Linear Algebra Guide'), isTrue);
      expect(stripped.contains('Vector spaces'), isTrue);
    });

    test('MentorMessage deserializes safety and AI flags properly', () {
      final json = {
        'id': 'msg_test_100',
        'role': 'assistant',
        'content': 'I am here to guide your deliberate practice.',
        'is_ai_generated': false,
        'warning_message': 'Pedagogical safety guardrail applied.',
        'created_at': '2026-09-08T15:00:00Z',
      };

      final message = MentorMessage.fromJson(json);
      expect(message.id, equals('msg_test_100'));
      expect(message.sender, equals(MessageSender.mentor));
      expect(message.isAiGenerated, isFalse);
      expect(message.warningMessage, equals('Pedagogical safety guardrail applied.'));
      expect(message.text, contains('deliberate practice'));
    });

    test('currentMentorRecommendationProvider generates dynamic topic recommendation', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rec = await container.read(currentMentorRecommendationProvider.future);
      expect(rec.title, isNotEmpty);
      // Verify no static Backpropagation recommendation is forced!
      expect(rec.title.contains('Backpropagation'), isFalse);
      expect(rec.description?.contains('backpropagation first') ?? false, isFalse);
    });
  });
}
