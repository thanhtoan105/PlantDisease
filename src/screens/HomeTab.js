import React from 'react';
import {
  View,
  ScrollView,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { CustomCard, CustomSearchBar } from '../components/shared';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import WeatherWidget from '../components/WeatherWidget';
import CropCard from '../components/CropCard';

const HomeTab = () => {
  const navigation = useNavigation();

  const functionCards = [
    {
      title: 'Plant Details',
      subtitle: 'Crop Library',
      icon: 'eco',
      color: AppColors.secondaryGreen,
      onPress: () => navigation.navigate('CropLibrary'),
    },
    {
      title: 'Weather',
      subtitle: 'Current Data',
      icon: 'wb-sunny',
      color: AppColors.primaryGreen,
      onPress: () => navigation.navigate('WeatherDetails'),
    },
  ];

  const crops = [
    {
      id: 'tomato',
      name: 'Tomato',
      description: 'Common vegetable crop',
      emoji: '🍅',
      diseaseCount: 12,
    },
    {
      id: 'potato',
      name: 'Potato',
      description: 'Root vegetable',
      emoji: '🥔',
      diseaseCount: 8,
    },
    {
      id: 'corn',
      name: 'Corn',
      description: 'Cereal grain',
      emoji: '🌽',
      diseaseCount: 10,
    },
    {
      id: 'apple',
      name: 'Apple',
      description: 'Tree fruit',
      emoji: '🍎',
      diseaseCount: 6,
    },
  ];

  const renderHeader = () => (
    <Text style={styles.header}>Plant Disease Detection</Text>
  );

  const renderAIScanButton = () => (
    <CustomCard onPress={() => {
      try {
        // Navigate to the AiScan tab which contains the camera interface
        navigation.navigate('AiScan');
      } catch (error) {
        console.error('Navigation error:', error);
        Alert.alert('Navigation Error', 'Unable to open camera. Please try again.');
      }
    }} style={styles.aiScanCard}>
      <View style={styles.aiScanContent}>
        <View style={styles.aiScanIconContainer}>
          <Icon name="camera-alt" size={28} color={AppColors.white} />
        </View>
        <View style={styles.aiScanTextContainer}>
          <Text style={styles.aiScanTitle}>AI Plant Disease Scanner</Text>
          <Text style={styles.aiScanSubtitle}>Tap to scan your plant for diseases</Text>
        </View>
        <Icon name="arrow-forward-ios" size={20} color={AppColors.white} />
      </View>
    </CustomCard>
  );

  const renderFunctionCards = () => (
    <View style={styles.functionCardsContainer}>
      {functionCards.map((card, index) => (
        <TouchableOpacity
          key={index}
          style={styles.functionCard}
          onPress={card.onPress}
        >
          <CustomCard padding={Spacing.lg}>
            <View style={styles.functionCardContent}>
              <View style={[styles.functionIconContainer, { backgroundColor: `${card.color}20` }]}>
                <Icon name={card.icon} size={24} color={card.color} />
              </View>
              <Text style={styles.functionCardTitle}>{card.title}</Text>
              <Text style={styles.functionCardSubtitle}>{card.subtitle}</Text>
            </View>
          </CustomCard>
        </TouchableOpacity>
      ))}
    </View>
  );

  const renderSectionHeader = (title) => (
    <Text style={styles.sectionHeader}>{title}</Text>
  );

  const renderCropLibrary = () => (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.horizontalScroll}>
      {crops.map((crop, index) => (
        <CropCard
          key={index}
          name={crop.name}
          description={crop.description}
          emoji={crop.emoji}
          diseaseCount={crop.diseaseCount}
          onPress={() => navigation.navigate('CropDetails', crop)}
        />
      ))}
    </ScrollView>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        {renderHeader()}
        
        <CustomSearchBar
          placeholder="Search plants, diseases..."
          editable={false}
          onPress={() => navigation.navigate('Search')}
          style={styles.searchBar}
        />

        {renderAIScanButton()}
        {renderFunctionCards()}

        <WeatherWidget />

        {renderSectionHeader('Crop Library')}
        {renderCropLibrary()}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.lightGray,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: Spacing.lg,
  },
  header: {
    ...Typography.headlineLarge,
    marginBottom: Spacing.lg,
  },
  searchBar: {
    marginBottom: Spacing.xl,
  },
  aiScanCard: {
    backgroundColor: AppColors.primaryGreen,
    marginBottom: Spacing.xl,
  },
  aiScanContent: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 80,
  },
  aiScanIconContainer: {
    width: 60,
    height: 60,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: BorderRadius.large,
    alignItems: 'center',
    justifyContent: 'center',
  },
  aiScanTextContainer: {
    flex: 1,
    marginLeft: Spacing.lg,
  },
  aiScanTitle: {
    ...Typography.headlineMedium,
    color: AppColors.white,
  },
  aiScanSubtitle: {
    ...Typography.bodyMedium,
    color: 'rgba(255, 255, 255, 0.9)',
    marginTop: Spacing.xs,
  },
  functionCardsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: Spacing.xxl,
  },
  functionCard: {
    flex: 1,
    marginHorizontal: Spacing.xs,
  },
  functionCardContent: {
    alignItems: 'center',
    minHeight: 100,
  },
  functionIconContainer: {
    width: 48,
    height: 48,
    borderRadius: BorderRadius.medium,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: Spacing.md,
  },
  functionCardTitle: {
    ...Typography.labelMedium,
    textAlign: 'center',
    marginBottom: Spacing.xs,
  },
  functionCardSubtitle: {
    ...Typography.bodySmall,
    textAlign: 'center',
  },
  sectionHeader: {
    ...Typography.headlineMedium,
    marginBottom: Spacing.md,
    marginTop: Spacing.xxl,
  },
  horizontalScroll: {
    marginBottom: Spacing.xxl,
  },
});

export default HomeTab; 