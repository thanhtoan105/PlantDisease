import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyADyTiwlCyg9wgd7xgThcampIRkWyRazKU';
  static GenerativeModel? _model;

  /// Initialize the Gemini model (Gemini Flash - free tier)
  static GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-flash-latest',  // Updated to use available model
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    return _model!;
  }

  /// Generate AI-powered disease recommendations
  ///
  /// Parameters:
  /// - [diseaseName]: The detected disease name
  /// - [confidence]: Confidence level of the detection (0.0 - 1.0)
  /// - [locationData]: Location information (city, country, etc.)
  /// - [weatherData]: Current weather conditions
  ///
  /// Returns a formatted recommendation with symptoms, treatment, and prevention
  static Future<String> generateDiseaseRecommendation({
    required String diseaseName,
    required double confidence,
    String? locationData,
    Map<String, dynamic>? weatherData,
  }) async {
    try {
      debugPrint('\n╔═══════════════════════���════════════════════════════════════╗');
      debugPrint('║         GEMINI AI RECOMMENDATION REQUEST                  ║');
      debugPrint('╚═══════════════════════════════════════���════════════════════╝');
      debugPrint('🦠 Disease: $diseaseName');
      debugPrint('📊 Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
      debugPrint('📍 Location: ${locationData ?? "Unknown"}');
      debugPrint('🌤️ Weather: ${weatherData ?? "Not available"}');

      // Extract weather information
      final weatherInfo = _formatWeatherInfo(weatherData);

      // Build the prompt
      final prompt = _buildPrompt(
        diseaseName: diseaseName,
        confidence: confidence,
        locationData: locationData,
        weatherInfo: weatherInfo,
      );

      debugPrint('\n📝 Prompt:\n$prompt\n');

      // Generate content
      final response = await model.generateContent([Content.text(prompt)]);

      String raw = response.text ?? '';

      // Post-process: ensure Detection section exists
      if (!raw.contains('# Detection')) {
        final detectionBlock = '# Detection\n- Disease: ${diseaseName.isEmpty ? 'Unknown' : diseaseName}\n- Confidence: ${(confidence * 100).toStringAsFixed(1)}%\n- Location: ${locationData ?? 'Not specified'}\n- Weather: ${weatherInfo.isEmpty ? 'Not specified' : weatherInfo}\n\n';
        raw = detectionBlock + raw.trim();
      }

      if (raw.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      debugPrint('\n✅ AI Response received (${raw.length} characters)');
      debugPrint('╚═══════════════════════════════════════════════════════���════╝\n');

      return raw;
    } catch (e, stackTrace) {
      debugPrint('\n❌ Error in generateDiseaseRecommendation: $e');
      debugPrint('Stack trace: $stackTrace');

      // Return a user-friendly error message
      return _getFallbackRecommendation(diseaseName);
    }
  }

  /// Format weather information for the prompt
  static String _formatWeatherInfo(Map<String, dynamic>? weatherData) {
    if (weatherData == null) return 'Weather data not available';

    try {
      final temp = weatherData['temperature']?.toString() ?? 'N/A';
      final humidity = weatherData['humidity']?.toString() ?? 'N/A';
      final condition = weatherData['condition']?.toString() ?? 'N/A';
      final description = weatherData['description']?.toString() ?? '';

      return 'Temperature: $temp°C, Humidity: $humidity%, Condition: $condition $description';
    } catch (e) {
      return 'Weather data parsing error';
    }
  }

  /// Build the AI prompt
  static String _buildPrompt({
    required String diseaseName,
    required double confidence,
    String? locationData,
    required String weatherInfo,
  }) {
    return '''
You are an expert plant pathologist.
MUST output EXACTLY these Markdown headings, in order, no extras:

# Detection
- Disease: ${diseaseName.isEmpty ? 'Unknown' : diseaseName}
- Confidence: ${(confidence * 100).toStringAsFixed(1)}%
- Location: ${locationData ?? 'Not specified'}
- Weather: ${weatherInfo.isEmpty ? 'Not specified' : weatherInfo}

## Organic Treatment
(Primary first; then Alternatives list.)
Primary:
- Up to 5 concise bullet steps describing the most effective organic intervention sequence.
Alternatives:
- Two bullets: each (name – when to use / condition suitability).

## Chemical Treatment
(Primary first; then Alternatives list.)
Primary:
- 3–5 bullets covering: active ingredient, timing/interval, application method, safety/PPE, resistance rotation.
Alternatives:
- Two bullets: each (active ingredient – specific scenario / constraint).

Strict rules:
- TOTAL content (excluding headings and Detection list) MUST be between 180 and 210 words; aim ~200 words. Split roughly: Organic ~90–110 words, Chemical ~90–110 words.
- Bullet text only; no paragraphs, no intro/outro sentences outside bullets.
- If disease label contains 'healthy' or 'unknown', replace both sections with general plant vitality & scouting guidance, still respecting headings & word totals.
- Use generic active ingredient names, no brand names.
- No Prevention section. Do not invent additional headings.
- No repeating identical advice between organic and chemical; differentiate roles.
''';
  }

  /// Fallback recommendation when AI fails (matches simplified structure)
  static String _getFallbackRecommendation(String diseaseName) {
    final healthyLike = diseaseName.toLowerCase().contains('healthy') ||
        diseaseName.toLowerCase().contains('unknown');

    final detection = '# Detection\n- Disease: ${diseaseName.isEmpty ? 'Unknown' : diseaseName}\n- Confidence: N/A\n- Location: Not specified\n- Weather: Not specified\n\n';

    if (healthyLike) {
      final organic = '## Organic Treatment\n- Maintain consistent soil moisture (avoid waterlogging).\n- Provide balanced light; adjust shading if leaves yellow.\n- Inspect foliage daily for early spotting or pest presence.\n- Remove senescent / damaged leaves to lower pathogen load.\n- Mulch lightly to stabilize root zone microclimate.\n\nAlternatives:\n- Light compost tea drench during active growth.\n- Seaweed extract foliar spray under stress.\n\n';
      final chemical = '## Chemical Treatment\n- No routine chemical use recommended on healthy / uncertain status.\n- Focus on sanitation & early scouting instead of prophylactic sprays.\n- Maintain resistance stewardship by avoiding unnecessary fungicides.\n\nAlternatives:\n- N/A\n- N/A\n';
      return detection + organic + chemical;
    }

    final organic = '## Organic Treatment\n- Remove infected tissues promptly (pruning shears sanitized).\n- Improve airflow: thin dense growth / adjust spacing.\n- Morning root-zone watering; keep foliage dry.\n- Apply approved biofungicide (e.g. Bacillus-based) on a 7–10 day cycle.\n- Integrate mulch to reduce soil splash dispersal.\n\nAlternatives:\n- Potassium bicarbonate spray for early lesion suppression.\n- Neem or horticultural oil under mild pressure (avoid heat >30°C).\n\n';

    final chemical = '## Chemical Treatment\n- Primary protectant: copper hydroxide (interval 7–10d; avoid overuse & phytotoxicity).\n- Rotate mode of action (alternate with a phosphonate systemic).\n- Target sprays pre-wet/humid periods based on forecast.\n- Use calibrated nozzle for fine coverage; avoid runoff.\n- PPE: gloves, mask, long sleeves; wash equipment post-use.\n\nAlternatives:\n- Mancozeb (broad-spectrum) during extended cool wet cycles.\n- Sulfur (only in dry, moderate temps; avoid with oils).\n';

    return detection + organic + chemical;
  }

  /// Test the Gemini API connection
  static Future<bool> testConnection() async {
    try {
      final response = await model.generateContent([
        Content.text('Hello! Please respond with "OK" if you can hear me.')
      ]);

      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Gemini API test failed: $e');
      return false;
    }
  }
}
