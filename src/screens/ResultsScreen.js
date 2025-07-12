import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  Image,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard, CustomButton, ButtonType } from '../components/shared';
import PlantDiseaseService from '../services/PlantDiseaseService';

const ResultCard = ({ disease, confidence, severity, description, treatment }) => {
  const getSeverityColor = (severity) => {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.errorRed;
      case 'moderate':
        return AppColors.accentOrange;
      case 'low':
        return AppColors.secondaryGreen;
      default:
        return AppColors.primaryGreen;
    }
  };

  const severityColor = getSeverityColor(severity);

  return (
    <CustomCard style={styles.resultCard}>
      <View style={styles.resultHeader}>
        <Text style={styles.diseaseName}>{disease}</Text>
        <View style={[styles.severityBadge, { backgroundColor: `${severityColor}20` }]}>
          <Text style={[styles.severityText, { color: severityColor }]}>
            {severity}
          </Text>
        </View>
      </View>

      <View style={styles.confidenceContainer}>
        <Text style={styles.confidenceLabel}>Confidence: </Text>
        <Text style={styles.confidenceValue}>{(confidence * 100).toFixed(0)}%</Text>
      </View>

      <View style={styles.confidenceBar}>
        <View 
          style={[
            styles.confidenceProgress, 
            { 
              width: `${confidence * 100}%`,
              backgroundColor: severityColor 
            }
          ]} 
        />
      </View>

      <View style={styles.descriptionSection}>
        <Text style={styles.sectionTitle}>Description</Text>
        <Text style={styles.descriptionText}>{description}</Text>
      </View>

      <View style={styles.treatmentSection}>
        <Text style={styles.sectionTitle}>Recommended Treatment</Text>
        <View style={[styles.treatmentBox, { backgroundColor: `${AppColors.accentOrange}20` }]}>
          <Text style={styles.treatmentText}>{treatment}</Text>
        </View>
      </View>
    </CustomCard>
  );
};

const ResultsScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const { imageUri, source, timestamp, plantType } = route.params || {};

  const [isAnalyzing, setIsAnalyzing] = useState(true);
  const [analysisResults, setAnalysisResults] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const analyzeImage = async () => {
      try {
        setIsAnalyzing(true);
        setError(null);

        // Use the PlantDiseaseService for real analysis
        const result = await PlantDiseaseService.analyzeImage(imageUri, plantType);

        if (result.success) {
          setAnalysisResults(result.data);
        } else {
          setError(result.error);
          Alert.alert('Analysis Failed', result.error);
        }
      } catch (error) {
        console.error('Analysis error:', error);
        setError('Failed to analyze image. Please try again.');
        Alert.alert('Error', 'Failed to analyze image. Please try again.');
      } finally {
        setIsAnalyzing(false);
      }
    };

    if (imageUri) {
      analyzeImage();
    }
  }, [imageUri, plantType]);

  const handleSaveResult = async () => {
    if (analysisResults) {
      try {
        const saved = await PlantDiseaseService.saveAnalysisResult(analysisResults);
        if (saved) {
          Alert.alert('Saved', 'Analysis result has been saved to your history.');
        } else {
          Alert.alert('Error', 'Failed to save analysis result.');
        }
      } catch (error) {
        console.error('Save error:', error);
        Alert.alert('Error', 'Failed to save analysis result.');
      }
    }
  };

  const handleScanAgain = () => {
    navigation.goBack();
  };

  const handleViewTreatmentGuide = () => {
    Alert.alert('Treatment Guide', 'This would open a detailed treatment guide.');
  };

  const renderAnalysisStatus = () => (
    <CustomCard style={styles.statusCard}>
      <View style={styles.statusContainer}>
        <View style={[styles.statusIndicator, { 
          backgroundColor: isAnalyzing ? AppColors.accentOrange : AppColors.primaryGreen 
        }]} />
        <Text style={styles.statusText}>
          {isAnalyzing ? 'Analyzing image...' : 'Analysis Complete'}
        </Text>
        {!isAnalyzing && (
          <Text style={styles.processingTime}>Processed in 2.3s</Text>
        )}
      </View>
    </CustomCard>
  );

  const renderImageDisplay = () => (
    <CustomCard style={styles.imageCard}>
      <View style={styles.imageContainer}>
        {imageUri ? (
          <Image source={{ uri: imageUri }} style={styles.capturedImage} />
        ) : (
          <View style={styles.placeholderImage}>
            <Icon name="image" size={48} color={AppColors.mediumGray} />
            <Text style={styles.placeholderText}>No image selected</Text>
          </View>
        )}
        <View style={styles.analysisOverlay}>
          <Text style={styles.overlayText}>Analyzed</Text>
        </View>
      </View>
    </CustomCard>
  );

  const renderResults = () => {
    if (isAnalyzing) {
      return (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={AppColors.primaryGreen} />
          <Text style={styles.loadingText}>Analyzing your plant...</Text>
          <Text style={styles.loadingSubtext}>
            Our AI is examining the image for signs of disease
          </Text>
        </View>
      );
    }

    if (!analysisResults) {
      return (
        <View style={styles.errorContainer}>
          <Icon name="error-outline" size={48} color={AppColors.errorRed} />
          <Text style={styles.errorText}>Analysis failed</Text>
          <Text style={styles.errorSubtext}>Please try scanning again</Text>
        </View>
      );
    }

    return (
      <View style={styles.resultsContainer}>
        <View style={styles.healthStatusContainer}>
          <Text style={styles.resultsTitle}>Detection Results</Text>
          <View style={[
            styles.healthStatusBadge,
            { backgroundColor: analysisResults.healthStatus === 'Healthy' ? AppColors.primaryGreen :
              analysisResults.healthStatus === 'Critical' ? AppColors.errorRed : AppColors.accentOrange }
          ]}>
            <Text style={styles.healthStatusText}>{analysisResults.healthStatus}</Text>
          </View>
        </View>

        <Text style={styles.plantTypeText}>
          Plant Type: {analysisResults.plantType.charAt(0).toUpperCase() + analysisResults.plantType.slice(1)}
        </Text>

        {analysisResults.diseases && analysisResults.diseases.length > 0 ? (
          analysisResults.diseases.map((disease, index) => (
            <ResultCard
              key={index}
              disease={disease.name}
              confidence={disease.confidence}
              severity={disease.severity}
              description={disease.description}
              treatment={disease.treatment ? disease.treatment[0] : 'No specific treatment available'}
            />
          ))
        ) : (
          <CustomCard style={styles.healthyCard}>
            <Icon name="eco" size={48} color={AppColors.primaryGreen} />
            <Text style={styles.healthyTitle}>Plant Appears Healthy!</Text>
            <Text style={styles.healthySubtitle}>
              No diseases detected. Continue with regular care routine.
            </Text>
          </CustomCard>
        )}

        {analysisResults.recommendations && analysisResults.recommendations.length > 0 && (
          <View style={styles.recommendationsContainer}>
            <Text style={styles.recommendationsTitle}>Recommendations</Text>
            {analysisResults.recommendations.map((rec, index) => (
              <CustomCard key={index} style={styles.recommendationCard}>
                <View style={styles.recommendationHeader}>
                  <Icon
                    name={rec.type === 'urgent' ? 'warning' : rec.type === 'treatment' ? 'medical-services' : 'lightbulb'}
                    size={20}
                    color={rec.priority === 'high' ? AppColors.errorRed : rec.priority === 'medium' ? AppColors.accentOrange : AppColors.primaryGreen}
                  />
                  <Text style={styles.recommendationTitle}>{rec.title}</Text>
                </View>
                <Text style={styles.recommendationDescription}>{rec.description}</Text>
              </CustomCard>
            ))}
          </View>
        )}
      </View>
    );
  };

  const renderActionButtons = () => (
    <View style={styles.actionButtonsContainer}>
      <CustomButton
        text="View Treatment Guide"
        type={ButtonType.ACCENT}
        icon={({ size, color }) => (
          <Icon name="medical-services" size={size} color={color} />
        )}
        onPress={handleViewTreatmentGuide}
        style={styles.fullWidthButton}
      />
      
      <View style={styles.buttonRow}>
        <CustomButton
          text="Save Result"
          type={ButtonType.SECONDARY}
          icon={({ size, color }) => (
            <Icon name="bookmark-border" size={size} color={color} />
          )}
          onPress={handleSaveResult}
          style={styles.halfButton}
        />
        
        <CustomButton
          text="Scan Again"
          type={ButtonType.PRIMARY}
          icon={({ size, color }) => (
            <Icon name="camera-alt" size={size} color={color} />
          )}
          onPress={handleScanAgain}
          style={styles.halfButton}
        />
      </View>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Icon name="arrow-back" size={24} color={AppColors.darkNavy} />
        </TouchableOpacity>
        
        <Text style={styles.headerTitle}>Analysis Results</Text>
        
        <TouchableOpacity style={styles.shareButton}>
          <Icon name="share" size={24} color={AppColors.darkNavy} />
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {renderImageDisplay()}
        {renderAnalysisStatus()}
        {renderResults()}
        {!isAnalyzing && analysisResults && renderActionButtons()}
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
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    backgroundColor: AppColors.white,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.lightGray,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.medium,
    backgroundColor: AppColors.lightGray,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerTitle: {
    ...Typography.headlineMedium,
    flex: 1,
    textAlign: 'center',
  },
  shareButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.medium,
    backgroundColor: AppColors.lightGray,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.lg,
  },
  imageCard: {
    marginBottom: Spacing.lg,
  },
  imageContainer: {
    position: 'relative',
    alignItems: 'center',
  },
  capturedImage: {
    width: '100%',
    height: 200,
    borderRadius: BorderRadius.medium,
    resizeMode: 'cover',
  },
  placeholderImage: {
    width: '100%',
    height: 200,
    borderRadius: BorderRadius.medium,
    backgroundColor: AppColors.lightGray,
    alignItems: 'center',
    justifyContent: 'center',
  },
  placeholderText: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginTop: Spacing.sm,
  },
  analysisOverlay: {
    position: 'absolute',
    top: Spacing.md,
    right: Spacing.md,
    backgroundColor: AppColors.primaryGreen,
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: Spacing.sm,
  },
  overlayText: {
    color: AppColors.white,
    fontSize: 10,
    fontWeight: '600',
  },
  statusCard: {
    marginBottom: Spacing.lg,
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusIndicator: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: Spacing.md,
  },
  statusText: {
    ...Typography.labelMedium,
    flex: 1,
  },
  processingTime: {
    ...Typography.bodySmall,
    color: AppColors.mediumGray,
  },
  loadingContainer: {
    alignItems: 'center',
    paddingVertical: Spacing.xxl,
  },
  loadingText: {
    ...Typography.headlineSmall,
    marginTop: Spacing.lg,
    textAlign: 'center',
  },
  loadingSubtext: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginTop: Spacing.sm,
    textAlign: 'center',
  },
  errorContainer: {
    alignItems: 'center',
    paddingVertical: Spacing.xxl,
  },
  errorText: {
    ...Typography.headlineSmall,
    marginTop: Spacing.lg,
    textAlign: 'center',
  },
  errorSubtext: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginTop: Spacing.sm,
    textAlign: 'center',
  },
  resultsContainer: {
    marginBottom: Spacing.lg,
  },
  resultsTitle: {
    ...Typography.headlineMedium,
    marginBottom: Spacing.lg,
  },
  healthStatusContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.md,
  },
  healthStatusBadge: {
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.xs,
    borderRadius: BorderRadius.medium,
  },
  healthStatusText: {
    ...Typography.labelMedium,
    color: AppColors.white,
    fontWeight: '600',
  },
  plantTypeText: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginBottom: Spacing.lg,
    fontStyle: 'italic',
  },
  healthyCard: {
    alignItems: 'center',
    padding: Spacing.xl,
    marginBottom: Spacing.lg,
  },
  healthyTitle: {
    ...Typography.headlineMedium,
    color: AppColors.primaryGreen,
    marginTop: Spacing.md,
    marginBottom: Spacing.xs,
  },
  healthySubtitle: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    textAlign: 'center',
  },
  recommendationsContainer: {
    marginTop: Spacing.lg,
  },
  recommendationsTitle: {
    ...Typography.headlineMedium,
    marginBottom: Spacing.md,
  },
  recommendationCard: {
    marginBottom: Spacing.md,
  },
  recommendationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.xs,
  },
  recommendationTitle: {
    ...Typography.labelMedium,
    marginLeft: Spacing.sm,
    flex: 1,
  },
  recommendationDescription: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    lineHeight: 20,
  },
  resultCard: {
    marginBottom: Spacing.md,
  },
  resultHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: Spacing.md,
  },
  diseaseName: {
    ...Typography.labelLarge,
    flex: 1,
  },
  severityBadge: {
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: Spacing.sm,
  },
  severityText: {
    fontSize: 10,
    fontWeight: '600',
  },
  confidenceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  confidenceLabel: {
    ...Typography.labelMedium,
  },
  confidenceValue: {
    ...Typography.labelMedium,
    color: AppColors.primaryGreen,
  },
  confidenceBar: {
    height: 8,
    backgroundColor: AppColors.lightGray,
    borderRadius: 4,
    marginBottom: Spacing.lg,
    overflow: 'hidden',
  },
  confidenceProgress: {
    height: '100%',
    borderRadius: 4,
  },
  descriptionSection: {
    marginBottom: Spacing.md,
  },
  sectionTitle: {
    ...Typography.labelSmall,
    marginBottom: Spacing.xs,
  },
  descriptionText: {
    ...Typography.bodySmall,
  },
  treatmentSection: {
    marginBottom: Spacing.sm,
  },
  treatmentBox: {
    padding: Spacing.md,
    borderRadius: Spacing.sm,
  },
  treatmentText: {
    ...Typography.bodySmall,
  },
  actionButtonsContainer: {
    paddingBottom: Spacing.xxl,
  },
  fullWidthButton: {
    marginBottom: Spacing.md,
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  halfButton: {
    flex: 0.48,
  },
});

export default ResultsScreen; 