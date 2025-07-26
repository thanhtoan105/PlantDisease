import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  FlatList,
  ImageBackground,
  Dimensions,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { LinearGradient } from 'expo-linear-gradient';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard, CustomButton, ButtonType } from '../components/shared';
import DiseaseCard from '../components/DiseaseCard';

const { width: screenWidth } = Dimensions.get('window');

// Helper function to get crop background images
const getCropImage = (cropName) => {
  // For now, we'll use a placeholder. In a real app, you'd have actual crop images
  const cropImages = {
    tomato: 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=800&h=600&fit=crop',
    potato: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800&h=600&fit=crop',
    corn: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=800&h=600&fit=crop',
    apple: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800&h=600&fit=crop',
  };

  return cropImages[cropName?.toLowerCase()] || cropImages.tomato;
};

const CropDetailsScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const { crop } = route.params || {};

  const [activeTab, setActiveTab] = useState('overview');

  // Mock data for the crop details
  const cropDetails = {
    tomato: {
      name: 'Tomato',
      emoji: '🍅',
      scientificName: 'Solanum lycopersicum',
      family: 'Solanaceae',
      description: 'Tomatoes are one of the most popular vegetables grown worldwide. They are rich in vitamins C and K, potassium, and lycopene, a powerful antioxidant.',
      growingConditions: {
        climate: 'Warm temperate to tropical',
        soil: 'Well-drained, slightly acidic (pH 6.0-6.8)',
        sunlight: 'Full sun (6-8 hours daily)',
        water: 'Regular, consistent watering',
        temperature: '18-24°C (65-75°F)',
      },
      seasons: {
        planting: 'Spring to early summer',
        harvest: 'Summer to early fall',
        duration: '70-85 days from transplant',
      },
      diseases: [
        {
          id: 'early-blight',
          name: 'Early Blight',
          severity: 'Moderate',
          description: 'Fungal disease causing dark spots on leaves',
          symptoms: ['Dark spots with concentric rings', 'Yellowing leaves', 'Defoliation'],
        },
        {
          id: 'late-blight',
          name: 'Late Blight',
          severity: 'High',
          description: 'Devastating fungal disease',
          symptoms: ['Dark water-soaked lesions', 'White mold on leaf undersides', 'Fruit rot'],
        },
        {
          id: 'bacterial-spot',
          name: 'Bacterial Spot',
          severity: 'Moderate',
          description: 'Bacterial infection affecting leaves and fruit',
          symptoms: ['Small dark spots on leaves', 'Raised spots on fruit', 'Yellowing'],
        },
        {
          id: 'mosaic-virus',
          name: 'Tomato Mosaic Virus',
          severity: 'High',
          description: 'Viral disease causing mottled patterns',
          symptoms: ['Mottled light and dark green patterns', 'Stunted growth', 'Reduced fruit quality'],
        },
      ],
      tips: [
        'Provide support with cages or stakes',
        'Remove suckers for better fruit development',
        'Mulch around plants to retain moisture',
        'Rotate crops to prevent disease buildup',
        'Water at soil level to prevent leaf diseases',
      ],
    },
    potato: {
      name: 'Potato',
      emoji: '🥔',
      scientificName: 'Solanum tuberosum',
      family: 'Solanaceae',
      description: 'Potatoes are versatile root vegetables that are a staple food in many cultures. They are rich in carbohydrates, vitamin C, and potassium.',
      growingConditions: {
        climate: 'Cool temperate',
        soil: 'Well-drained, loose soil (pH 5.0-6.0)',
        sunlight: 'Full sun (6-8 hours daily)',
        water: 'Moderate, consistent moisture',
        temperature: '15-20°C (60-70°F)',
      },
      seasons: {
        planting: 'Early spring',
        harvest: 'Late summer to fall',
        duration: '70-120 days from planting',
      },
      diseases: [
        {
          id: 'late-blight',
          name: 'Late Blight',
          severity: 'High',
          description: 'Devastating disease affecting leaves and tubers',
          symptoms: ['Dark lesions on leaves', 'White fungal growth', 'Tuber rot'],
        },
        {
          id: 'early-blight',
          name: 'Early Blight',
          severity: 'Moderate',
          description: 'Common fungal disease',
          symptoms: ['Brown spots on leaves', 'Target-like lesions', 'Defoliation'],
        },
      ],
      tips: [
        'Hill soil around plants as they grow',
        'Plant certified seed potatoes',
        'Harvest before first frost',
        'Store in cool, dark place',
        'Rotate crops to prevent disease',
      ],
    },
    corn: {
      name: 'Corn',
      emoji: '🌽',
      scientificName: 'Zea mays',
      family: 'Poaceae',
      description: 'Corn is a major grain crop and staple food worldwide. It is rich in carbohydrates, fiber, and various vitamins and minerals.',
      growingConditions: {
        climate: 'Warm temperate to tropical',
        soil: 'Well-drained, fertile soil (pH 6.0-7.0)',
        sunlight: 'Full sun (6-8 hours daily)',
        water: 'Regular watering, especially during tasseling',
        temperature: '20-30°C (70-85°F)',
      },
      seasons: {
        planting: 'Late spring after last frost',
        harvest: 'Late summer to early fall',
        duration: '60-100 days from planting',
      },
      diseases: [
        {
          id: 'corn-smut',
          name: 'Corn Smut',
          severity: 'Moderate',
          description: 'Fungal disease causing galls on ears and stalks',
          symptoms: ['Large galls on ears', 'Distorted kernels', 'Black spore masses'],
        },
        {
          id: 'northern-leaf-blight',
          name: 'Northern Leaf Blight',
          severity: 'High',
          description: 'Fungal disease affecting leaves',
          symptoms: ['Long gray-green lesions', 'Leaf death', 'Reduced yield'],
        },
      ],
      tips: [
        'Plant in blocks for better pollination',
        'Provide adequate spacing between plants',
        'Water deeply but less frequently',
        'Side-dress with nitrogen fertilizer',
        'Harvest when kernels are milky',
      ],
    },
    apple: {
      name: 'Apple',
      emoji: '🍎',
      scientificName: 'Malus domestica',
      family: 'Rosaceae',
      description: 'Apples are popular fruit trees that produce nutritious fruits rich in fiber, vitamins, and antioxidants.',
      growingConditions: {
        climate: 'Temperate with cold winters',
        soil: 'Well-drained, slightly acidic (pH 6.0-7.0)',
        sunlight: 'Full sun (6-8 hours daily)',
        water: 'Regular watering, especially during fruit development',
        temperature: '15-25°C (60-75°F) growing season',
      },
      seasons: {
        planting: 'Fall or early spring',
        harvest: 'Late summer to fall',
        duration: '2-4 years to fruit production',
      },
      diseases: [
        {
          id: 'apple-scab',
          name: 'Apple Scab',
          severity: 'High',
          description: 'Fungal disease affecting leaves and fruit',
          symptoms: ['Dark spots on leaves', 'Scabby fruit lesions', 'Premature leaf drop'],
        },
        {
          id: 'fire-blight',
          name: 'Fire Blight',
          severity: 'High',
          description: 'Bacterial disease causing branch dieback',
          symptoms: ['Blackened shoots', 'Cankers on branches', 'Oozing bacteria'],
        },
      ],
      tips: [
        'Prune annually for good air circulation',
        'Thin fruits for better quality',
        'Apply dormant oil in late winter',
        'Choose disease-resistant varieties',
        'Mulch around base but not touching trunk',
      ],
    },
  };

  const currentCrop = cropDetails[crop?.id] || {
    name: crop?.name || 'Unknown Crop',
    emoji: crop?.emoji || '🌱',
    scientificName: crop?.scientificName || 'Not available',
    family: crop?.family || 'Not available',
    description: crop?.description || 'Detailed information not available for this crop.',
    growingConditions: {},
    seasons: {},
    diseases: [],
    tips: [],
  };

  const tabs = [
    { id: 'overview', label: 'Overview', icon: 'info' },
    { id: 'diseases', label: 'Diseases', icon: 'bug-report' },
    { id: 'tips', label: 'Growing Tips', icon: 'eco' },
  ];

  const renderHeader = () => (
    <View style={styles.headerContainer}>
      <ImageBackground
        source={{ uri: getCropImage(crop?.id || crop?.name) }}
        style={styles.headerImage}
        resizeMode="cover"
      >
        <LinearGradient
          colors={['rgba(0,0,0,0.3)', 'rgba(0,0,0,0.7)']}
          style={styles.headerGradient}
        >
          {/* Navigation buttons */}
          <View style={styles.headerNavigation}>
            <TouchableOpacity
              style={styles.navButton}
              onPress={() => navigation.goBack()}
            >
              <Icon name="arrow-back" size={24} color={AppColors.white} />
            </TouchableOpacity>

            <TouchableOpacity style={styles.navButton}>
              <Icon name="favorite-border" size={24} color={AppColors.white} />
            </TouchableOpacity>
          </View>

          {/* Crop information overlay */}
          <View style={styles.headerContent}>
            <Text style={styles.headerTitle}>{currentCrop.name}</Text>
            <Text style={styles.headerSubtitle}>{currentCrop.scientificName}</Text>
          </View>
        </LinearGradient>
      </ImageBackground>
    </View>
  );

  const renderTabs = () => (
    <View style={styles.tabsContainer}>
      {tabs.map((tab) => (
        <TouchableOpacity
          key={tab.id}
          style={[
            styles.tab,
            activeTab === tab.id && styles.activeTab,
          ]}
          onPress={() => setActiveTab(tab.id)}
        >
          <Icon
            name={tab.icon}
            size={18}
            color={activeTab === tab.id ? AppColors.primaryGreen : AppColors.mediumGray}
          />
          <Text
            style={[
              styles.tabLabel,
              activeTab === tab.id && styles.activeTabLabel,
            ]}
          >
            {tab.label}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );

  const renderOverview = () => (
    <View style={styles.tabContent}>
      <CustomCard style={styles.infoCard}>
        <Text style={styles.cardTitle}>Description</Text>
        <Text style={styles.description}>{currentCrop.description}</Text>
      </CustomCard>

      <CustomCard style={styles.infoCard}>
        <Text style={styles.cardTitle}>Basic Information</Text>
        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}>Scientific Name:</Text>
          <Text style={styles.infoValue}>{currentCrop.scientificName}</Text>
        </View>
        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}>Family:</Text>
          <Text style={styles.infoValue}>{currentCrop.family}</Text>
        </View>
      </CustomCard>

      {currentCrop.growingConditions && Object.keys(currentCrop.growingConditions).length > 0 && (
        <CustomCard style={styles.infoCard}>
          <Text style={styles.cardTitle}>Growing Conditions</Text>
          {Object.entries(currentCrop.growingConditions).map(([key, value]) => (
            <View key={key} style={styles.infoRow}>
              <Text style={styles.infoLabel}>{key.charAt(0).toUpperCase() + key.slice(1)}:</Text>
              <Text style={styles.infoValue}>{value}</Text>
            </View>
          ))}
        </CustomCard>
      )}

      {currentCrop.seasons && Object.keys(currentCrop.seasons).length > 0 && (
        <CustomCard style={styles.infoCard}>
          <Text style={styles.cardTitle}>Growing Season</Text>
          {Object.entries(currentCrop.seasons).map(([key, value]) => (
            <View key={key} style={styles.infoRow}>
              <Text style={styles.infoLabel}>{key.charAt(0).toUpperCase() + key.slice(1)}:</Text>
              <Text style={styles.infoValue}>{value}</Text>
            </View>
          ))}
        </CustomCard>
      )}
    </View>
  );

  const renderDiseases = () => (
    <View style={styles.tabContent}>
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Common Diseases</Text>
        <Text style={styles.sectionSubtitle}>
          {currentCrop.diseases.length} disease{currentCrop.diseases.length !== 1 ? 's' : ''} identified
        </Text>
      </View>

      {currentCrop.diseases.length > 0 ? (
        currentCrop.diseases.map((disease, index) => (
          <DiseaseCard
            key={disease.id}
            title={disease.name}
            severity={disease.severity}
            description={disease.description}
            symptoms={disease.symptoms}
            onPress={() => {
              // Navigate to disease details or show more info
              console.log('Disease pressed:', disease.name);
            }}
            style={index < currentCrop.diseases.length - 1 ? styles.diseaseCard : null}
          />
        ))
      ) : (
        <CustomCard style={styles.emptyCard}>
          <Icon name="bug-report" size={48} color={AppColors.mediumGray} />
          <Text style={styles.emptyTitle}>No disease data available</Text>
          <Text style={styles.emptySubtitle}>
            Disease information for this crop is not yet available.
          </Text>
        </CustomCard>
      )}
    </View>
  );

  const renderTips = () => (
    <View style={styles.tabContent}>
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Growing Tips</Text>
        <Text style={styles.sectionSubtitle}>
          Expert advice for successful cultivation
        </Text>
      </View>

      {currentCrop.tips.length > 0 ? (
        <CustomCard style={styles.tipsCard}>
          {currentCrop.tips.map((tip, index) => (
            <View key={index} style={styles.tipItem}>
              <View style={styles.tipBullet}>
                <Icon name="eco" size={16} color={AppColors.primaryGreen} />
              </View>
              <Text style={styles.tipText}>{tip}</Text>
            </View>
          ))}
        </CustomCard>
      ) : (
        <CustomCard style={styles.emptyCard}>
          <Icon name="eco" size={48} color={AppColors.mediumGray} />
          <Text style={styles.emptyTitle}>No tips available</Text>
          <Text style={styles.emptySubtitle}>
            Growing tips for this crop will be added soon.
          </Text>
        </CustomCard>
      )}

      <CustomButton
        text="Get Personalized Tips"
        type={ButtonType.PRIMARY}
        icon={({ size, color }) => (
          <Icon name="tips-and-updates" size={size} color={color} />
        )}
        onPress={() => {
          console.log('Get personalized tips pressed');
        }}
        style={styles.actionButton}
      />
    </View>
  );

  const renderContent = () => {
    switch (activeTab) {
      case 'diseases':
        return renderDiseases();
      case 'tips':
        return renderTips();
      default:
        return renderOverview();
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      {renderHeader()}
      {renderTabs()}
      
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {renderContent()}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.lightGray,
  },
  headerContainer: {
    height: 280,
    width: '100%',
  },
  headerImage: {
    flex: 1,
    width: '100%',
    height: '100%',
  },
  headerGradient: {
    flex: 1,
    justifyContent: 'space-between',
    paddingTop: 50, // Account for status bar
    paddingBottom: Spacing.xl,
    paddingHorizontal: Spacing.lg,
  },
  headerNavigation: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  navButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    backdropFilter: 'blur(10px)',
  },
  headerContent: {
    alignItems: 'flex-start',
  },
  headerTitle: {
    ...Typography.headlineLarge,
    fontSize: 32,
    fontWeight: '700',
    color: AppColors.white,
    textShadowColor: 'rgba(0, 0, 0, 0.5)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 3,
  },
  headerSubtitle: {
    ...Typography.bodyLarge,
    color: 'rgba(255, 255, 255, 0.9)',
    marginTop: Spacing.xs,
    fontStyle: 'italic',
    textShadowColor: 'rgba(0, 0, 0, 0.5)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 3,
  },
  tabsContainer: {
    flexDirection: 'row',
    backgroundColor: AppColors.white,
    paddingHorizontal: Spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.lightGray,
  },
  tab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: Spacing.md,
    borderBottomWidth: 2,
    borderBottomColor: 'transparent',
  },
  activeTab: {
    borderBottomColor: AppColors.primaryGreen,
  },
  tabLabel: {
    ...Typography.labelMedium,
    marginLeft: Spacing.xs,
    color: AppColors.mediumGray,
  },
  activeTabLabel: {
    color: AppColors.primaryGreen,
    fontWeight: '600',
  },
  content: {
    flex: 1,
  },
  tabContent: {
    padding: Spacing.lg,
  },
  infoCard: {
    marginBottom: Spacing.lg,
  },
  cardTitle: {
    ...Typography.labelLarge,
    marginBottom: Spacing.md,
  },
  description: {
    ...Typography.bodyMedium,
    lineHeight: 22,
  },
  infoRow: {
    flexDirection: 'row',
    marginBottom: Spacing.sm,
  },
  infoLabel: {
    ...Typography.labelMedium,
    width: 120,
    color: AppColors.mediumGray,
  },
  infoValue: {
    ...Typography.bodyMedium,
    flex: 1,
  },
  sectionHeader: {
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    ...Typography.headlineMedium,
    marginBottom: Spacing.xs,
  },
  sectionSubtitle: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
  },
  diseaseCard: {
    marginBottom: Spacing.md,
  },
  tipsCard: {
    marginBottom: Spacing.lg,
  },
  tipItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: Spacing.md,
  },
  tipBullet: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: `${AppColors.primaryGreen}20`,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.md,
    marginTop: 2,
  },
  tipText: {
    ...Typography.bodyMedium,
    flex: 1,
    lineHeight: 20,
  },
  emptyCard: {
    alignItems: 'center',
    paddingVertical: Spacing.xxl,
  },
  emptyTitle: {
    ...Typography.headlineSmall,
    marginTop: Spacing.lg,
    textAlign: 'center',
  },
  emptySubtitle: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginTop: Spacing.sm,
    textAlign: 'center',
  },
  actionButton: {
    marginTop: Spacing.lg,
  },
});

export default CropDetailsScreen; 