import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  FlatList,
  TextInput,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard, CustomSearchBar } from '../components/shared';
import CropCard from '../components/CropCard';
import DiseaseCard from '../components/DiseaseCard';

const SearchScreen = () => {
  const navigation = useNavigation();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState('all');
  const [searchResults, setSearchResults] = useState([]);

  // Mock data for search
  const searchData = {
    crops: [
      {
        id: 'tomato',
        name: 'Tomato',
        description: 'Rich in vitamins and antioxidants',
        emoji: '🍅',
        diseaseCount: 8,
        type: 'crop',
        scientificName: 'Solanum lycopersicum',
        family: 'Solanaceae',
      },
      {
        id: 'potato',
        name: 'Potato',
        description: 'Versatile root vegetable',
        emoji: '🥔',
        diseaseCount: 6,
        type: 'crop',
        scientificName: 'Solanum tuberosum',
        family: 'Solanaceae',
      },
      {
        id: 'corn',
        name: 'Corn',
        description: 'Essential grain crop',
        emoji: '🌽',
        diseaseCount: 5,
        type: 'crop',
        scientificName: 'Zea mays',
        family: 'Poaceae',
      },
    ],
    diseases: [
      {
        id: 'late-blight',
        name: 'Late Blight',
        description: 'Devastating fungal disease affecting tomatoes and potatoes',
        severity: 'High',
        type: 'disease',
        affectedCrops: ['Tomato', 'Potato'],
        symptoms: ['Dark water-soaked lesions', 'White mold on leaf undersides'],
      },
      {
        id: 'early-blight',
        name: 'Early Blight',
        description: 'Common fungal disease with characteristic target spots',
        severity: 'Moderate',
        type: 'disease',
        affectedCrops: ['Tomato', 'Potato'],
        symptoms: ['Brown spots with concentric rings', 'Yellowing leaves'],
      },
      {
        id: 'powdery-mildew',
        name: 'Powdery Mildew',
        description: 'White powdery fungal growth on leaves',
        severity: 'Moderate',
        type: 'disease',
        affectedCrops: ['Cucumber', 'Squash', 'Pumpkin'],
        symptoms: ['White powdery coating', 'Leaf distortion'],
      },
    ],
    treatments: [
      {
        id: 'copper-fungicide',
        name: 'Copper-based Fungicide',
        description: 'Effective against bacterial and fungal diseases',
        type: 'treatment',
        category: 'Chemical',
        targetDiseases: ['Late Blight', 'Early Blight', 'Bacterial Spot'],
        applicationMethod: 'Foliar spray',
      },
      {
        id: 'neem-oil',
        name: 'Neem Oil',
        description: 'Organic treatment for various plant diseases',
        type: 'treatment',
        category: 'Organic',
        targetDiseases: ['Powdery Mildew', 'Aphids', 'Whiteflies'],
        applicationMethod: 'Foliar spray',
      },
      {
        id: 'crop-rotation',
        name: 'Crop Rotation',
        description: 'Preventive practice to break disease cycles',
        type: 'treatment',
        category: 'Cultural',
        targetDiseases: ['Soil-borne diseases', 'Nematodes'],
        applicationMethod: 'Field management',
      },
    ],
  };

  const filters = [
    { id: 'all', label: 'All', icon: 'search' },
    { id: 'crops', label: 'Crops', icon: 'agriculture' },
    { id: 'diseases', label: 'Diseases', icon: 'bug-report' },
    { id: 'treatments', label: 'Treatments', icon: 'healing' },
  ];

  useEffect(() => {
    performSearch();
  }, [searchQuery, activeFilter]);

  const performSearch = () => {
    if (!searchQuery.trim()) {
      setSearchResults([]);
      return;
    }

    const query = searchQuery.toLowerCase();
    let results = [];

    if (activeFilter === 'all' || activeFilter === 'crops') {
      const cropResults = searchData.crops.filter(crop =>
        crop.name.toLowerCase().includes(query) ||
        crop.description.toLowerCase().includes(query) ||
        crop.scientificName.toLowerCase().includes(query)
      );
      results = [...results, ...cropResults];
    }

    if (activeFilter === 'all' || activeFilter === 'diseases') {
      const diseaseResults = searchData.diseases.filter(disease =>
        disease.name.toLowerCase().includes(query) ||
        disease.description.toLowerCase().includes(query) ||
        disease.affectedCrops.some(crop => crop.toLowerCase().includes(query))
      );
      results = [...results, ...diseaseResults];
    }

    if (activeFilter === 'all' || activeFilter === 'treatments') {
      const treatmentResults = searchData.treatments.filter(treatment =>
        treatment.name.toLowerCase().includes(query) ||
        treatment.description.toLowerCase().includes(query) ||
        treatment.category.toLowerCase().includes(query) ||
        treatment.targetDiseases.some(disease => disease.toLowerCase().includes(query))
      );
      results = [...results, ...treatmentResults];
    }

    setSearchResults(results);
  };

  const handleItemPress = (item) => {
    switch (item.type) {
      case 'crop':
        navigation.navigate('CropDetails', { crop: item });
        break;
      case 'disease':
        // Navigate to disease details or show info
        console.log('Disease selected:', item.name);
        break;
      case 'treatment':
        // Navigate to treatment details or show info
        console.log('Treatment selected:', item.name);
        break;
    }
  };

  const renderHeader = () => (
    <View style={styles.header}>
      <TouchableOpacity
        style={styles.backButton}
        onPress={() => navigation.goBack()}
      >
        <Icon name="arrow-back" size={24} color={AppColors.darkNavy} />
      </TouchableOpacity>
      
      <View style={styles.headerContent}>
        <Text style={styles.headerTitle}>Search</Text>
        <Text style={styles.headerSubtitle}>Find crops, diseases, and treatments</Text>
      </View>
    </View>
  );

  const renderFilters = () => (
    <View style={styles.filtersContainer}>
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        {filters.map((filter) => (
          <TouchableOpacity
            key={filter.id}
            style={[
              styles.filterChip,
              activeFilter === filter.id && styles.activeFilterChip,
            ]}
            onPress={() => setActiveFilter(filter.id)}
          >
            <Icon
              name={filter.icon}
              size={16}
              color={activeFilter === filter.id ? AppColors.white : AppColors.mediumGray}
            />
            <Text
              style={[
                styles.filterLabel,
                activeFilter === filter.id && styles.activeFilterLabel,
              ]}
            >
              {filter.label}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );

  const renderSearchResult = ({ item }) => {
    switch (item.type) {
      case 'crop':
        return (
          <View style={styles.resultItem}>
            <CropCard
              name={item.name}
              description={item.description}
              emoji={item.emoji}
              diseaseCount={item.diseaseCount}
              onPress={() => handleItemPress(item)}
            />
          </View>
        );
      case 'disease':
        return (
          <View style={styles.resultItem}>
            <DiseaseCard
              title={item.name}
              severity={item.severity}
              description={item.description}
              symptoms={item.symptoms}
              onPress={() => handleItemPress(item)}
            />
          </View>
        );
      case 'treatment':
        return (
          <View style={styles.resultItem}>
            <CustomCard onPress={() => handleItemPress(item)} padding={Spacing.md}>
              <View style={styles.treatmentCard}>
                <View style={styles.treatmentHeader}>
                  <Icon name="healing" size={24} color={AppColors.primaryGreen} />
                  <View style={styles.treatmentInfo}>
                    <Text style={styles.treatmentName}>{item.name}</Text>
                    <Text style={styles.treatmentCategory}>{item.category}</Text>
                  </View>
                </View>
                <Text style={styles.treatmentDescription}>{item.description}</Text>
                <Text style={styles.treatmentMethod}>Method: {item.applicationMethod}</Text>
              </View>
            </CustomCard>
          </View>
        );
      default:
        return null;
    }
  };

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Icon name="search-off" size={64} color={AppColors.mediumGray} />
      <Text style={styles.emptyTitle}>
        {searchQuery ? 'No results found' : 'Start searching'}
      </Text>
      <Text style={styles.emptySubtitle}>
        {searchQuery 
          ? 'Try different keywords or filters'
          : 'Search for crops, diseases, or treatments'
        }
      </Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      {renderHeader()}
      
      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <View style={styles.searchInputContainer}>
          <Icon name="search" size={20} color={AppColors.mediumGray} style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search crops, diseases, treatments..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholderTextColor={AppColors.mediumGray}
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity
              style={styles.clearButton}
              onPress={() => setSearchQuery('')}
            >
              <Icon name="clear" size={20} color={AppColors.mediumGray} />
            </TouchableOpacity>
          )}
        </View>
      </View>

      {/* Filters */}
      {renderFilters()}

      {/* Results */}
      <View style={styles.resultsContainer}>
        {searchResults.length > 0 && (
          <Text style={styles.resultsCount}>
            {searchResults.length} result{searchResults.length !== 1 ? 's' : ''} found
          </Text>
        )}
        
        {searchResults.length > 0 ? (
          <FlatList
            data={searchResults}
            renderItem={renderSearchResult}
            keyExtractor={(item) => `${item.type}-${item.id}`}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={styles.resultsList}
          />
        ) : (
          renderEmptyState()
        )}
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
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.lg,
    backgroundColor: AppColors.white,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.medium,
    backgroundColor: AppColors.lightGray,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerContent: {
    flex: 1,
    marginLeft: Spacing.lg,
  },
  headerTitle: {
    ...Typography.headlineLarge,
  },
  headerSubtitle: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
  },
  searchContainer: {
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    backgroundColor: AppColors.white,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.lightGray,
  },
  searchInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.lightGray,
    borderRadius: BorderRadius.medium,
    paddingHorizontal: Spacing.md,
  },
  searchIcon: {
    marginRight: Spacing.sm,
  },
  searchInput: {
    flex: 1,
    ...Typography.bodyMedium,
    paddingVertical: Spacing.md,
    color: AppColors.darkNavy,
  },
  clearButton: {
    padding: Spacing.xs,
  },
  filtersContainer: {
    paddingVertical: Spacing.md,
    backgroundColor: AppColors.white,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.lightGray,
  },
  filterChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    marginLeft: Spacing.lg,
    backgroundColor: AppColors.lightGray,
    borderRadius: BorderRadius.large,
  },
  activeFilterChip: {
    backgroundColor: AppColors.primaryGreen,
  },
  filterLabel: {
    ...Typography.labelMedium,
    marginLeft: Spacing.xs,
    color: AppColors.mediumGray,
  },
  activeFilterLabel: {
    color: AppColors.white,
  },
  resultsContainer: {
    flex: 1,
    paddingHorizontal: Spacing.lg,
  },
  resultsCount: {
    ...Typography.labelMedium,
    color: AppColors.mediumGray,
    paddingVertical: Spacing.md,
  },
  resultsList: {
    paddingBottom: Spacing.xl,
  },
  resultItem: {
    marginBottom: Spacing.md,
  },
  treatmentCard: {
    flex: 1,
  },
  treatmentHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  treatmentInfo: {
    flex: 1,
    marginLeft: Spacing.md,
  },
  treatmentName: {
    ...Typography.labelLarge,
    marginBottom: Spacing.xs,
  },
  treatmentCategory: {
    ...Typography.bodySmall,
    color: AppColors.primaryGreen,
    fontWeight: '500',
  },
  treatmentDescription: {
    ...Typography.bodyMedium,
    marginBottom: Spacing.sm,
    lineHeight: 20,
  },
  treatmentMethod: {
    ...Typography.bodySmall,
    color: AppColors.mediumGray,
    fontStyle: 'italic',
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: Spacing.xxl,
  },
  emptyTitle: {
    ...Typography.headlineMedium,
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

export default SearchScreen;
