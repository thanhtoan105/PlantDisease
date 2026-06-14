import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_config.dart';

class GeminiService {
  // Get API key from environment configuration (SECURE - not hardcoded)
  static String get _apiKey => EnvConfig.geminiApiKey;
  static GenerativeModel? _model;

  /// Initialize the Gemini model (Gemini Flash - free tier)
  static GenerativeModel get model {
    // Validate API key first
    if (_apiKey.isEmpty) {
      throw Exception('AI_TIPS_NOT_AVAILABLE');  // Special error code for UI handling
    }

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
  /// - [confidence]: Confidence level of the detection (0.0 - 1.0) - used internally, not displayed
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
    // Extract weather information early so it's available in catch block
    final weatherInfo = _formatWeatherInfo(weatherData);

    try {
      if (kDebugMode) {
        debugPrint('\n╔═════ GEMINI AI REQUEST ═════╗');
        debugPrint('🦠 Disease: $diseaseName');
        debugPrint('📊 Confidence: ${(confidence * 100).toStringAsFixed(1)}% (not displayed to user)');
        debugPrint('📍 Location: ${locationData ?? "Unknown"}');
        debugPrint('🌤️ Weather: ${weatherData != null ? "Available" : "Not available"}');
      }

      // Build the prompt
      final prompt = _buildPrompt(
        diseaseName: diseaseName,
        locationData: locationData,
        weatherInfo: weatherInfo,
      );

      // Generate content
      final response = await model.generateContent([Content.text(prompt)]);

      String raw = response.text ?? '';

      // Post-process: ensure Detection section exists
      if (!raw.contains('# Detection')) {
        final detectionBlock = '# Detection\n- Disease: ${diseaseName.isEmpty ? 'Unknown' : diseaseName}\n- Location: ${locationData != null && locationData.isNotEmpty ? locationData : 'Not specified'}\n- Weather: ${weatherInfo.isEmpty ? 'Not specified' : weatherInfo}\n\n';
        raw = detectionBlock + raw.trim();
      }

      // CRITICAL: Validate both treatment sections are present
      final hasOrganicTreatment = raw.contains('## Organic Treatment');
      final hasChemicalTreatment = raw.contains('## Chemical Treatment');

      if (!hasOrganicTreatment || !hasChemicalTreatment) {
        if (kDebugMode) {
          debugPrint('⚠️ WARNING: AI response missing treatment sections!');
          debugPrint('  Has Organic: $hasOrganicTreatment');
          debugPrint('  Has Chemical: $hasChemicalTreatment');
          debugPrint('  Using fallback recommendation...');
        }
        // Use fallback if either section is missing
        return _getFallbackRecommendation(diseaseName, locationData, weatherInfo);
      }

      if (raw.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      if (kDebugMode) {
        debugPrint('✅ AI Response received (${raw.length} characters)');
        debugPrint('✅ Both treatment sections validated');
        debugPrint('╚════════════════════════════╝\n');
      }

      return raw;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('\n❌ Error in generateDiseaseRecommendation: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      // Check if it's an API key error
      if (e.toString().contains('AI_TIPS_NOT_AVAILABLE')) {
        return _getUnavailableMessage();
      }

      // Return a user-friendly error message
      return _getFallbackRecommendation(diseaseName, locationData, weatherInfo);
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
    String? locationData,
    required String weatherInfo,
  }) {
    return '''
You are an expert plant pathologist. Generate treatment recommendations.

CRITICAL REQUIREMENTS:
1. MUST include ## Organic Treatment section with EXACTLY 3 bullet points
2. MUST include ## Chemical Treatment section with EXACTLY 3 bullet points
3. NO subsections (no "Primary:", no "Alternatives:")
4. Each bullet: 20-30 words, specific and actionable

OUTPUT FORMAT:

# Detection
- Disease: ${diseaseName.isEmpty ? 'Unknown' : diseaseName}
- Location: ${locationData != null && locationData.isNotEmpty ? locationData : 'Not specified'}
- Weather: ${weatherInfo.isNotEmpty ? weatherInfo : 'Not specified'}

## Organic Treatment
- [First organic treatment step with timing and method]
- [Second organic treatment step with timing and method]
- [Third organic treatment step with timing and method]

## Chemical Treatment
- [First chemical treatment with active ingredient and application]
- [Second chemical treatment with active ingredient and application]
- [Third chemical treatment with active ingredient and application]

RULES:
- Generic names only (no brand names)
- Organic: Cultural practices, biofungicides, natural methods
- Chemical: Active ingredients, dosages, safety measures
- For healthy plants: provide maintenance tips in both sections
- Total: 120-180 words (60-90 per section)
''';
  }

  /// Fallback recommendation when AI fails (matches simplified structure)
  static String _getFallbackRecommendation(String diseaseName, [String? locationData, String? weatherInfo]) {
    final healthyLike = diseaseName.toLowerCase().contains('healthy') ||
        diseaseName.toLowerCase().contains('unknown');

    final location = locationData != null && locationData.isNotEmpty ? locationData : 'Not specified';
    final weather = weatherInfo != null && weatherInfo.isNotEmpty ? weatherInfo : 'Not specified';

    final detection = '# Detection\n- Disease: ${diseaseName.isEmpty ? 'Unknown' : diseaseName}\n- Location: $location\n- Weather: $weather\n\n';

    if (healthyLike) {
      final organic = '## Organic Treatment\n- Maintain consistent soil moisture by watering deeply but infrequently to encourage strong root development\n- Inspect foliage weekly for early signs of pests or diseases and remove affected leaves promptly\n- Apply organic mulch around the base to regulate soil temperature and suppress weeds\n\n';
      final chemical = '## Chemical Treatment\n- No routine chemical applications recommended for healthy plants to preserve beneficial organisms\n- Monitor plant health regularly and reserve treatments only for confirmed pest or disease issues\n- Practice integrated pest management focusing on prevention rather than reactive chemical use\n\n';
      return detection + organic + chemical;
    }

    final organic = '## Organic Treatment\n- Remove all infected plant tissues using sterilized pruning tools and dispose of debris away from garden\n- Improve air circulation by spacing plants 60-90cm apart and pruning dense foliage\n- Apply copper-based organic fungicide every 7-10 days following label instructions for application rate\n\n';

    final chemical = '## Chemical Treatment\n- Use chlorothalonil or mancozeb fungicide at recommended dosage rotating between products to prevent resistance\n- Apply treatments early morning or late evening targeting all leaf surfaces including undersides\n- Wear protective equipment including gloves mask and long sleeves during application and storage\n\n';

    return detection + organic + chemical;
  }

  /// Return unavailable message when API key is not configured
  static String _getUnavailableMessage() {
    return '''# AI Tips Not Available

This function is currently not available. Please contact support or try again later.

The AI-powered recommendations feature requires additional configuration to function properly.''';
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
