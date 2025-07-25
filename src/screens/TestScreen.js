import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import TensorFlowService from '../services/TensorFlowService';

// Test images from assets/images/disease folder
const TEST_IMAGES = [
  'apple-scab_02a.jpg',
  'test1.jpg', 
  'test2.jpg',
  'test3.jpg',
  'image_3.jpg',
  'image_8.jpg',
  'Untitled.jpg'
];

const TestScreen = ({ navigation }) => {
  const [isLoading, setIsLoading] = useState(false);
  const [modelLoaded, setModelLoaded] = useState(false);
  const [testResults, setTestResults] = useState([]);
  const [currentTest, setCurrentTest] = useState('');
  const [errors, setErrors] = useState([]);

  useEffect(() => {
    loadModel();
  }, []);

  const loadModel = async () => {
    try {
      console.log('🔄 Loading TensorFlow model for testing...');
      setIsLoading(true);
      setCurrentTest('Loading AI Model...');
      
      const loaded = await TensorFlowService.loadModel();
      setModelLoaded(loaded);
      
      if (loaded) {
        console.log('✅ Model loaded successfully for testing');
        Alert.alert('Success', 'AI Model loaded successfully!');
      } else {
        Alert.alert('Error', 'Failed to load AI model');
      }
    } catch (error) {
      console.error('❌ Failed to load model:', error);
      Alert.alert('Error', `Failed to load model: ${error.message}`);
    } finally {
      setIsLoading(false);
      setCurrentTest('');
    }
  };

  const getImagePath = (imageName) => {
    // For React Native, use the bundled asset path
    return `file:///android_asset/images/disease/${imageName}`;
  };

  const testSingleImage = async (imageName) => {
    try {
      console.log(`🔬 Testing image: ${imageName}`);
      setCurrentTest(`Testing ${imageName}...`);
      
      const imagePath = getImagePath(imageName);
      const startTime = Date.now();
      
      const result = await TensorFlowService.analyzeImage(imagePath);
      
      const endTime = Date.now();
      const processingTime = endTime - startTime;
      
      if (result.success) {
        const testResult = {
          image: imageName,
          success: true,
          processingTime,
          plantType: result.data.plantType,
          healthStatus: result.data.healthStatus,
          confidence: result.data.overallConfidence,
          prediction: result.data.prediction.displayName,
          predictionConfidence: result.data.prediction.confidence
        };
        
        console.log('✅ Test successful:', testResult);
        return testResult;
      } else {
        console.log('❌ Test failed:', result.error);
        return {
          image: imageName,
          success: false,
          error: result.error
        };
      }
    } catch (error) {
      console.error(`❌ Error testing ${imageName}:`, error);
      return {
        image: imageName,
        success: false,
        error: error.message
      };
    }
  };

  const runAllTests = async () => {
    if (!modelLoaded) {
      Alert.alert('Error', 'Please load the model first');
      return;
    }

    setIsLoading(true);
    setTestResults([]);
    setErrors([]);
    
    const results = [];
    const errorList = [];
    
    try {
      for (const imageName of TEST_IMAGES) {
        const result = await testSingleImage(imageName);
        
        if (result.success) {
          results.push(result);
        } else {
          errorList.push(`${imageName}: ${result.error}`);
        }
        
        // Add small delay between tests
        await new Promise(resolve => setTimeout(resolve, 500));
      }
      
      setTestResults(results);
      setErrors(errorList);
      
      Alert.alert(
        'Tests Complete', 
        `Successfully processed ${results.length}/${TEST_IMAGES.length} images`
      );
      
    } catch (error) {
      Alert.alert('Test Error', error.message);
    } finally {
      setIsLoading(false);
      setCurrentTest('');
    }
  };

  const renderTestResult = (result, index) => (
    <View key={index} style={styles.resultCard}>
      <View style={styles.resultHeader}>
        <Icon 
          name={result.success ? 'check-circle' : 'error'} 
          size={20} 
          color={result.success ? AppColors.primaryGreen : AppColors.error} 
        />
        <Text style={styles.resultTitle}>{result.image}</Text>
      </View>
      
      {result.success ? (
        <View style={styles.resultDetails}>
          <Text style={styles.resultText}>Plant: {result.plantType}</Text>
          <Text style={styles.resultText}>Status: {result.healthStatus}</Text>
          <Text style={styles.resultText}>Prediction: {result.prediction}</Text>
          <Text style={styles.resultText}>
            Confidence: {(result.confidence * 100).toFixed(1)}%
          </Text>
          <Text style={styles.resultText}>
            Processing Time: {result.processingTime}ms
          </Text>
        </View>
      ) : (
        <Text style={styles.errorText}>Error: {result.error}</Text>
      )}
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Icon name="arrow-back" size={24} color={AppColors.white} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Implementation Test</Text>
      </View>

      <ScrollView style={styles.content}>
        <View style={styles.statusCard}>
          <Text style={styles.statusTitle}>AI Model Status</Text>
          <View style={styles.statusRow}>
            <Icon 
              name={modelLoaded ? 'check-circle' : 'error'} 
              size={20} 
              color={modelLoaded ? AppColors.primaryGreen : AppColors.error} 
            />
            <Text style={styles.statusText}>
              {modelLoaded ? 'Model Loaded' : 'Model Not Loaded'}
            </Text>
          </View>
        </View>

        <View style={styles.buttonContainer}>
          <TouchableOpacity 
            style={[styles.button, !modelLoaded && styles.buttonDisabled]}
            onPress={runAllTests}
            disabled={isLoading || !modelLoaded}
          >
            <Icon name="play-arrow" size={20} color={AppColors.white} />
            <Text style={styles.buttonText}>Run All Tests</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.button}
            onPress={loadModel}
            disabled={isLoading}
          >
            <Icon name="refresh" size={20} color={AppColors.white} />
            <Text style={styles.buttonText}>Reload Model</Text>
          </TouchableOpacity>
        </View>

        {isLoading && (
          <View style={styles.loadingCard}>
            <ActivityIndicator size="large" color={AppColors.primaryGreen} />
            <Text style={styles.loadingText}>{currentTest || 'Processing...'}</Text>
          </View>
        )}

        {testResults.length > 0 && (
          <View style={styles.resultsSection}>
            <Text style={styles.sectionTitle}>Test Results</Text>
            {testResults.map(renderTestResult)}
          </View>
        )}

        {errors.length > 0 && (
          <View style={styles.errorsSection}>
            <Text style={styles.sectionTitle}>Errors</Text>
            {errors.map((error, index) => (
              <Text key={index} style={styles.errorText}>{error}</Text>
            ))}
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.lightGray,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.primaryGreen,
    padding: Spacing.medium,
  },
  backButton: {
    marginRight: Spacing.medium,
  },
  headerTitle: {
    ...Typography.headlineMedium,
    color: AppColors.white,
    fontWeight: 'bold',
  },
  content: {
    flex: 1,
    padding: Spacing.medium,
  },
  statusCard: {
    backgroundColor: AppColors.white,
    padding: Spacing.medium,
    borderRadius: BorderRadius.medium,
    marginBottom: Spacing.medium,
  },
  statusTitle: {
    ...Typography.bodyLarge,
    fontWeight: 'bold',
    marginBottom: Spacing.small,
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusText: {
    ...Typography.bodyMedium,
    marginLeft: Spacing.small,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: Spacing.medium,
  },
  button: {
    backgroundColor: AppColors.primaryGreen,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: Spacing.medium,
    borderRadius: BorderRadius.medium,
    flex: 0.48,
  },
  buttonDisabled: {
    backgroundColor: AppColors.gray,
  },
  buttonText: {
    ...Typography.bodyMedium,
    color: AppColors.white,
    fontWeight: 'bold',
    marginLeft: Spacing.small,
  },
  loadingCard: {
    backgroundColor: AppColors.white,
    padding: Spacing.large,
    borderRadius: BorderRadius.medium,
    alignItems: 'center',
    marginBottom: Spacing.medium,
  },
  loadingText: {
    ...Typography.bodyMedium,
    marginTop: Spacing.small,
    textAlign: 'center',
  },
  resultsSection: {
    marginBottom: Spacing.medium,
  },
  sectionTitle: {
    ...Typography.headlineSmall,
    fontWeight: 'bold',
    marginBottom: Spacing.medium,
  },
  resultCard: {
    backgroundColor: AppColors.white,
    padding: Spacing.medium,
    borderRadius: BorderRadius.medium,
    marginBottom: Spacing.small,
  },
  resultHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.small,
  },
  resultTitle: {
    ...Typography.bodyLarge,
    fontWeight: 'bold',
    marginLeft: Spacing.small,
  },
  resultDetails: {
    paddingLeft: Spacing.large,
  },
  resultText: {
    ...Typography.bodyMedium,
    marginBottom: 2,
  },
  errorsSection: {
    marginBottom: Spacing.medium,
  },
  errorText: {
    ...Typography.bodyMedium,
    color: AppColors.error,
    backgroundColor: AppColors.white,
    padding: Spacing.small,
    borderRadius: BorderRadius.small,
    marginBottom: Spacing.small,
  },
});

export default TestScreen;
