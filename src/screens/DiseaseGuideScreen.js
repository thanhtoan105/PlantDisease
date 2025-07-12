import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  FlatList,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomSearchBar, CustomCard } from '../components/shared';
import DiseaseCard from '../components/DiseaseCard';

const DiseaseGuideScreen = () => {
  const navigation = useNavigation();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');

  const categories = [
    { id: 'all', label: 'All', icon: 'list' },
    { id: 'fungal', label: 'Fungal', icon: 'nature' },
    { id: 'bacterial', label: 'Bacterial', icon: 'bug-report' },
    { id: 'viral', label: 'Viral', icon: 'virus' },
    { id: 'pest', label: 'Pests', icon: 'pest-control' },
  ];

  const diseases = [
    {
      id: 'late-blight',
      name: 'Late Blight',
      category: 'fungal',
      severity: 'High',
      affectedCrops: ['Tomato', 'Potato'],
      description: 'Devastating fungal disease that can destroy entire crops rapidly.',
      symptoms: [
        'Dark water-soaked lesions on leaves',
        'White mold growth on leaf undersides',
        'Brown spots on stems',
        'Fruit rot with dark lesions',
      ],
      treatment: [
        'Apply copper-based fungicides',
        'Remove affected plant parts',
        'Improve air circulation',
        'Avoid overhead watering',
      ],
    },
    {
      id: 'early-blight',
      name: 'Early Blight',
      category: 'fungal',
      severity: 'Moderate',
      affectedCrops: ['Tomato', 'Potato'],
      description: 'Common fungal disease causing leaf spots and defoliation.',
      symptoms: [
        'Dark spots with concentric rings',
        'Yellowing and browning of leaves',
        'Progressive defoliation from bottom up',
        'Sunken spots on fruit',
      ],
      treatment: [
        'Apply fungicide spray',
        'Remove affected leaves',
        'Mulch around plants',
        'Rotate crops annually',
      ],
    },
    {
      id: 'bacterial-spot',
      name: 'Bacterial Spot',
      category: 'bacterial',
      severity: 'Moderate',
      affectedCrops: ['Tomato', 'Pepper'],
      description: 'Bacterial infection affecting leaves, stems, and fruit.',
      symptoms: [
        'Small dark spots on leaves',
        'Raised brown spots on fruit',
        'Yellowing around spots',
        'Leaf drop in severe cases',
      ],
      treatment: [
        'Use copper-based bactericides',
        'Remove infected plant material',
        'Avoid working with wet plants',
        'Use pathogen-free seeds',
      ],
    },
    {
      id: 'mosaic-virus',
      name: 'Mosaic Virus',
      category: 'viral',
      severity: 'High',
      affectedCrops: ['Tomato', 'Cucumber', 'Pepper'],
      description: 'Viral disease causing mottled patterns and stunted growth.',
      symptoms: [
        'Mottled light and dark green patterns',
        'Stunted plant growth',
        'Distorted leaves',
        'Reduced fruit quality',
      ],
      treatment: [
        'Remove infected plants',
        'Control aphid vectors',
        'Use virus-resistant varieties',
        'Sanitize tools between plants',
      ],
    },
    {
      id: 'powdery-mildew',
      name: 'Powdery Mildew',
      category: 'fungal',
      severity: 'Moderate',
      affectedCrops: ['Cucumber', 'Zucchini', 'Grape'],
      description: 'Fungal disease creating white powdery coating on leaves.',
      symptoms: [
        'White powdery coating on leaves',
        'Yellowing and wilting',
        'Stunted growth',
        'Premature leaf drop',
      ],
      treatment: [
        'Apply sulfur-based fungicides',
        'Improve air circulation',
        'Avoid overhead watering',
        'Remove affected leaves',
      ],
    },
    {
      id: 'aphids',
      name: 'Aphids',
      category: 'pest',
      severity: 'Low',
      affectedCrops: ['Tomato', 'Pepper', 'Lettuce'],
      description: 'Small soft-bodied insects that feed on plant sap.',
      symptoms: [
        'Small green or black insects on plants',
        'Curled or yellowing leaves',
        'Sticky honeydew on leaves',
        'Stunted growth',
      ],
      treatment: [
        'Spray with insecticidal soap',
        'Introduce beneficial insects',
        'Use reflective mulch',
        'Remove with water spray',
      ],
    },
  ];

  const filteredDiseases = diseases.filter(disease => {
    const matchesSearch = disease.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         disease.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         disease.affectedCrops.some(crop => 
                           crop.toLowerCase().includes(searchQuery.toLowerCase())
                         );
    const matchesCategory = selectedCategory === 'all' || disease.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const handleDiseasePress = (disease) => {
    // Navigate to disease details or show modal
    console.log('Disease pressed:', disease.name);
  };

  const renderHeader = () => (
    <View style={styles.header}>
      <TouchableOpacity
        style={styles.backButton}
        onPress={() => navigation.goBack()}
      >
        <Icon name="arrow-back" size={24} color={AppColors.darkNavy} />
      </TouchableOpacity>
      
      <Text style={styles.headerTitle}>Disease Guide</Text>
      
      <TouchableOpacity style={styles.filterButton}>
        <Icon name="filter-list" size={24} color={AppColors.darkNavy} />
      </TouchableOpacity>
    </View>
  );

  const renderCategories = () => (
    <View style={styles.categoriesContainer}>
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.categoriesContent}
      >
        {categories.map((category) => (
          <TouchableOpacity
            key={category.id}
            style={[
              styles.categoryChip,
              selectedCategory === category.id && styles.activeCategoryChip,
            ]}
            onPress={() => setSelectedCategory(category.id)}
          >
            <Icon
              name={category.icon}
              size={16}
              color={selectedCategory === category.id ? AppColors.white : AppColors.mediumGray}
            />
            <Text
              style={[
                styles.categoryLabel,
                selectedCategory === category.id && styles.activeCategoryLabel,
              ]}
            >
              {category.label}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );

  const renderStats = () => (
    <CustomCard style={styles.statsCard}>
      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>{diseases.length}</Text>
          <Text style={styles.statLabel}>Total Diseases</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>{filteredDiseases.length}</Text>
          <Text style={styles.statLabel}>Filtered Results</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>
            {new Set(diseases.flatMap(d => d.affectedCrops)).size}
          </Text>
          <Text style={styles.statLabel}>Crops Covered</Text>
        </View>
      </View>
    </CustomCard>
  );

  const renderDiseaseItem = ({ item }) => (
    <DiseaseCard
      title={item.name}
      severity={item.severity}
      description={item.description}
      symptoms={item.symptoms}
      affectedCrops={item.affectedCrops}
      category={item.category}
      onPress={() => handleDiseasePress(item)}
      style={styles.diseaseItem}
    />
  );

  const renderEmptyState = () => (
    <View style={styles.emptyContainer}>
      <Icon name="search-off" size={64} color={AppColors.mediumGray} />
      <Text style={styles.emptyTitle}>No diseases found</Text>
      <Text style={styles.emptySubtitle}>
        Try adjusting your search terms or category filter
      </Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      {renderHeader()}
      
      <View style={styles.content}>
        {/* Search Bar */}
        <View style={styles.searchContainer}>
          <CustomSearchBar
            placeholder="Search diseases, symptoms, or crops..."
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </View>

        {/* Categories */}
        {renderCategories()}

        {/* Stats */}
        {renderStats()}

        {/* Results Section */}
        <View style={styles.resultsSection}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Disease Database</Text>
            <Text style={styles.sectionSubtitle}>
              {filteredDiseases.length} disease{filteredDiseases.length !== 1 ? 's' : ''} found
            </Text>
          </View>

          {filteredDiseases.length > 0 ? (
            <FlatList
              data={filteredDiseases}
              renderItem={renderDiseaseItem}
              keyExtractor={(item) => item.id}
              showsVerticalScrollIndicator={false}
              contentContainerStyle={styles.diseasesList}
            />
          ) : (
            renderEmptyState()
          )}
        </View>
      </View>
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
    ...Typography.headlineLarge,
    flex: 1,
    textAlign: 'center',
  },
  filterButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.medium,
    backgroundColor: AppColors.lightGray,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
  },
  searchContainer: {
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.lg,
    backgroundColor: AppColors.white,
  },
  categoriesContainer: {
    backgroundColor: AppColors.white,
    paddingBottom: Spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.lightGray,
  },
  categoriesContent: {
    paddingHorizontal: Spacing.lg,
  },
  categoryChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.lightGray,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    borderRadius: BorderRadius.large,
    marginRight: Spacing.sm,
  },
  activeCategoryChip: {
    backgroundColor: AppColors.primaryGreen,
  },
  categoryLabel: {
    ...Typography.labelMedium,
    marginLeft: Spacing.xs,
    color: AppColors.mediumGray,
  },
  activeCategoryLabel: {
    color: AppColors.white,
    fontWeight: '600',
  },
  statsCard: {
    margin: Spacing.lg,
  },
  statsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statNumber: {
    ...Typography.headlineLarge,
    color: AppColors.primaryGreen,
    fontWeight: '700',
  },
  statLabel: {
    ...Typography.bodySmall,
    color: AppColors.mediumGray,
    marginTop: Spacing.xs,
    textAlign: 'center',
  },
  statDivider: {
    width: 1,
    height: 40,
    backgroundColor: AppColors.lightGray,
    marginHorizontal: Spacing.md,
  },
  resultsSection: {
    flex: 1,
    paddingHorizontal: Spacing.lg,
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
  diseasesList: {
    paddingBottom: Spacing.xxl,
  },
  diseaseItem: {
    marginBottom: Spacing.md,
  },
  emptyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: Spacing.xxl,
    paddingHorizontal: Spacing.xl,
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
});

export default DiseaseGuideScreen; 