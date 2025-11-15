// Test Gemini API integration
// Run with: dart test_gemini.dart

import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║         GEMINI API CONNECTION TEST                        ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  const apiKey = 'REDACTED_GEMINI_API_KEY';

  // Test 1: Simple connection test
  print('Test 1: Testing model connection...');
  try {
    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
    );

    final response = await model.generateContent([
      Content.text('Respond with only "OK" if you can read this message.')
    ]);

    if (response.text != null && response.text!.isNotEmpty) {
      print('✅ Model connection successful!');
      print('   Response: ${response.text}\n');
    } else {
      print('❌ Model returned empty response\n');
      return;
    }
  } catch (e) {
    print('❌ Connection test failed: $e\n');
    return;
  }

  // Test 2: Disease recommendation test (similar to actual app usage)
  print('Test 2: Testing disease recommendation generation...');
  try {
    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );

    final prompt = '''
You are an expert plant pathologist. Analyze this plant disease detection:

**Detection Result:**
- Disease: Tomato___Late_blight
- Confidence: 92.5%
- Location: California, USA
- Weather: Temperature: 18°C, Humidity: 85%, Condition: Overcast

Provide brief recommendations covering:
1. **Symptoms**: Key visual symptoms
2. **Treatment**: Treatment options
3. **Prevention**: Prevention strategies
4. **Environmental Factors**: How weather affects this disease

Keep response under 300 words, professional and actionable.
''';

    final response = await model.generateContent([Content.text(prompt)]);

    if (response.text != null && response.text!.isNotEmpty) {
      print('✅ Disease recommendation generated successfully!');
      print('\n' + '='*60);
      print('GENERATED RECOMMENDATION:');
      print('='*60);
      print(response.text);
      print('='*60 + '\n');
    } else {
      print('❌ Recommendation generation returned empty response\n');
    }
  } catch (e) {
    print('❌ Recommendation generation failed: $e\n');
  }

  print('╔════════════════════════════════════════════════════════════╗');
  print('║         TEST COMPLETE ✅                                   ║');
  print('╚════════════════════════════════════════════════════════════╝\n');
}

