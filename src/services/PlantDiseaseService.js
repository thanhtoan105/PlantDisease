import * as FileSystem from 'expo-file-system';

class PlantDiseaseService {
  // Mock disease database for demonstration
  static diseaseDatabase = {
    'tomato': [
      {
        id: 'tomato-late-blight',
        name: 'Late Blight',
        confidence: 0.92,
        severity: 'High',
        description: 'A devastating fungal disease that can destroy entire tomato crops rapidly. Characterized by dark, water-soaked lesions on leaves and fruits.',
        symptoms: [
          'Dark water-soaked lesions on leaves',
          'White mold growth on leaf undersides',
          'Brown spots on stems and fruits',
          'Rapid wilting and plant death'
        ],
        treatment: [
          'Apply copper-based fungicides immediately',
          'Remove and destroy all infected plant parts',
          'Improve air circulation around plants',
          'Avoid overhead watering',
          'Use resistant varieties in future plantings'
        ],
        prevention: [
          'Plant resistant varieties',
          'Ensure proper spacing for air circulation',
          'Water at soil level, not on leaves',
          'Remove plant debris regularly',
          'Apply preventive fungicide sprays'
        ]
      },
      {
        id: 'tomato-early-blight',
        name: 'Early Blight',
        confidence: 0.85,
        severity: 'Moderate',
        description: 'A common fungal disease affecting tomatoes, causing brown spots with concentric rings on older leaves.',
        symptoms: [
          'Brown spots with concentric rings on leaves',
          'Yellowing of affected leaves',
          'Defoliation starting from bottom leaves',
          'Dark lesions on stems and fruits'
        ],
        treatment: [
          'Apply fungicide containing chlorothalonil',
          'Remove affected lower leaves',
          'Improve plant nutrition',
          'Ensure adequate spacing'
        ],
        prevention: [
          'Rotate crops annually',
          'Mulch around plants',
          'Water at soil level',
          'Provide adequate nutrition'
        ]
      }
    ],
    'potato': [
      {
        id: 'potato-late-blight',
        name: 'Late Blight',
        confidence: 0.88,
        severity: 'High',
        description: 'The same pathogen that causes tomato late blight, equally devastating to potato crops.',
        symptoms: [
          'Dark lesions on leaves and stems',
          'White fungal growth on leaf undersides',
          'Brown rot in tubers',
          'Foul smell from infected tubers'
        ],
        treatment: [
          'Apply copper-based fungicides',
          'Harvest tubers before disease spreads',
          'Destroy infected plant material',
          'Improve drainage'
        ],
        prevention: [
          'Plant certified disease-free seed potatoes',
          'Ensure good drainage',
          'Avoid overhead irrigation',
          'Hill soil around plants properly'
        ]
      }
    ],
    'corn': [
      {
        id: 'corn-rust',
        name: 'Corn Rust',
        confidence: 0.79,
        severity: 'Moderate',
        description: 'A fungal disease causing orange-red pustules on corn leaves.',
        symptoms: [
          'Orange-red pustules on leaves',
          'Yellowing of affected areas',
          'Reduced plant vigor',
          'Premature leaf death'
        ],
        treatment: [
          'Apply fungicide if severe',
          'Remove heavily infected leaves',
          'Ensure adequate nutrition',
          'Monitor weather conditions'
        ],
        prevention: [
          'Plant resistant varieties',
          'Ensure proper spacing',
          'Avoid excessive nitrogen',
          'Monitor for early symptoms'
        ]
      }
    ]
  };

  /**
   * Analyze plant image for disease detection
   * @param {string} imageUri - URI of the image to analyze
   * @param {string} plantType - Type of plant (optional)
   * @returns {Promise<Object>} Analysis results
   */
  static async analyzeImage(imageUri, plantType = null) {
    try {
      // Simulate API processing time
      await new Promise(resolve => setTimeout(resolve, 2000));

      // For demo purposes, we'll simulate disease detection based on plant type
      // In a real implementation, this would send the image to an AI service
      
      const results = await this.simulateAIAnalysis(imageUri, plantType);
      
      return {
        success: true,
        data: {
          imageUri,
          plantType: results.plantType,
          diseases: results.diseases,
          healthStatus: results.healthStatus,
          confidence: results.overallConfidence,
          analysisTimestamp: new Date().toISOString(),
          recommendations: results.recommendations
        }
      };
    } catch (error) {
      console.error('Disease analysis error:', error);
      return {
        success: false,
        error: 'Failed to analyze image. Please try again.'
      };
    }
  }

  /**
   * Simulate AI analysis (replace with real AI service in production)
   * @param {string} imageUri - Image URI
   * @param {string} plantType - Plant type hint
   * @returns {Object} Simulated analysis results
   */
  static async simulateAIAnalysis(imageUri, plantType) {
    // Simulate plant type detection if not provided
    const detectedPlantType = plantType || this.simulatePlantTypeDetection();
    
    // Get potential diseases for this plant type
    const plantDiseases = this.diseaseDatabase[detectedPlantType] || [];
    
    // Simulate disease detection (randomly select 0-2 diseases)
    const numDiseases = Math.floor(Math.random() * 3); // 0, 1, or 2 diseases
    const detectedDiseases = [];
    
    if (numDiseases > 0 && plantDiseases.length > 0) {
      // Randomly select diseases and adjust confidence
      const shuffled = [...plantDiseases].sort(() => 0.5 - Math.random());
      
      for (let i = 0; i < Math.min(numDiseases, shuffled.length); i++) {
        const disease = { ...shuffled[i] };
        // Add some randomness to confidence
        disease.confidence = Math.max(0.6, disease.confidence + (Math.random() - 0.5) * 0.2);
        detectedDiseases.push(disease);
      }
    }
    
    // Determine health status
    let healthStatus = 'Healthy';
    let overallConfidence = 0.95;
    
    if (detectedDiseases.length > 0) {
      const highSeverityDiseases = detectedDiseases.filter(d => d.severity === 'High');
      if (highSeverityDiseases.length > 0) {
        healthStatus = 'Critical';
        overallConfidence = Math.max(...detectedDiseases.map(d => d.confidence));
      } else {
        healthStatus = 'Diseased';
        overallConfidence = Math.max(...detectedDiseases.map(d => d.confidence));
      }
    }
    
    // Generate recommendations
    const recommendations = this.generateRecommendations(detectedDiseases, healthStatus);
    
    return {
      plantType: detectedPlantType,
      diseases: detectedDiseases,
      healthStatus,
      overallConfidence,
      recommendations
    };
  }

  /**
   * Simulate plant type detection
   * @returns {string} Detected plant type
   */
  static simulatePlantTypeDetection() {
    const plantTypes = ['tomato', 'potato', 'corn'];
    return plantTypes[Math.floor(Math.random() * plantTypes.length)];
  }

  /**
   * Generate recommendations based on detected diseases
   * @param {Array} diseases - Detected diseases
   * @param {string} healthStatus - Overall health status
   * @returns {Array} Recommendations
   */
  static generateRecommendations(diseases, healthStatus) {
    const recommendations = [];
    
    if (healthStatus === 'Healthy') {
      recommendations.push({
        type: 'prevention',
        title: 'Maintain Plant Health',
        description: 'Continue current care practices. Monitor regularly for early signs of disease.',
        priority: 'low'
      });
    } else {
      // Add treatment recommendations for each disease
      diseases.forEach(disease => {
        if (disease.severity === 'High') {
          recommendations.push({
            type: 'urgent',
            title: `Immediate Treatment for ${disease.name}`,
            description: disease.treatment[0] || 'Seek immediate treatment',
            priority: 'high'
          });
        } else {
          recommendations.push({
            type: 'treatment',
            title: `Treatment for ${disease.name}`,
            description: disease.treatment[0] || 'Apply appropriate treatment',
            priority: 'medium'
          });
        }
      });
      
      // Add general care recommendation
      recommendations.push({
        type: 'care',
        title: 'Improve Plant Care',
        description: 'Ensure proper watering, nutrition, and spacing to prevent disease spread.',
        priority: 'medium'
      });
    }
    
    return recommendations;
  }

  /**
   * Get detailed information about a specific disease
   * @param {string} diseaseId - Disease identifier
   * @returns {Object|null} Disease information
   */
  static getDiseaseInfo(diseaseId) {
    for (const plantType in this.diseaseDatabase) {
      const disease = this.diseaseDatabase[plantType].find(d => d.id === diseaseId);
      if (disease) {
        return disease;
      }
    }
    return null;
  }

  /**
   * Get all diseases for a specific plant type
   * @param {string} plantType - Plant type
   * @returns {Array} List of diseases
   */
  static getDiseasesForPlant(plantType) {
    return this.diseaseDatabase[plantType] || [];
  }

  /**
   * Save analysis result to local storage
   * @param {Object} analysisResult - Analysis result to save
   * @returns {Promise<boolean>} Success status
   */
  static async saveAnalysisResult(analysisResult) {
    try {
      const savedResults = await this.getSavedResults();
      const newResult = {
        id: Date.now().toString(),
        ...analysisResult,
        savedAt: new Date().toISOString()
      };
      
      savedResults.unshift(newResult);
      
      // Keep only last 50 results
      const trimmedResults = savedResults.slice(0, 50);
      
      await FileSystem.writeAsStringAsync(
        FileSystem.documentDirectory + 'plant_analysis_results.json',
        JSON.stringify(trimmedResults)
      );
      
      return true;
    } catch (error) {
      console.error('Error saving analysis result:', error);
      return false;
    }
  }

  /**
   * Get saved analysis results
   * @returns {Promise<Array>} Saved results
   */
  static async getSavedResults() {
    try {
      const fileUri = FileSystem.documentDirectory + 'plant_analysis_results.json';
      const fileExists = await FileSystem.getInfoAsync(fileUri);
      
      if (fileExists.exists) {
        const content = await FileSystem.readAsStringAsync(fileUri);
        return JSON.parse(content);
      }
      
      return [];
    } catch (error) {
      console.error('Error reading saved results:', error);
      return [];
    }
  }
}

export default PlantDiseaseService;
