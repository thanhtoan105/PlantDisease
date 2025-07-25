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
import { LoadingSpinner } from '../components/shared';
import CropCard from '../components/CropCard';
import DiseaseCard from '../components/DiseaseCard';
import PlantService from '../services/PlantService';

const SearchScreen = () => {
	const navigation = useNavigation();
	const [searchQuery, setSearchQuery] = useState('');
	const [activeFilter, setActiveFilter] = useState('all');
	const [searchResults, setSearchResults] = useState([]);
	const [isSearching, setIsSearching] = useState(false);
	const [searchError, setSearchError] = useState(null);

	// Search timeout for debouncing
	const [searchTimeout, setSearchTimeout] = useState(null);

	const filters = [
		{ id: 'all', label: 'All', icon: 'search' },
		{ id: 'crops', label: 'Crops', icon: 'agriculture' },
		{ id: 'diseases', label: 'Diseases', icon: 'bug-report' },
	];

	useEffect(() => {
		// Clear previous timeout
		if (searchTimeout) {
			clearTimeout(searchTimeout);
		}

		// Debounce search
		const timeout = setTimeout(() => {
			performSearch();
		}, 500);

		setSearchTimeout(timeout);

		// Cleanup
		return () => {
			if (timeout) {
				clearTimeout(timeout);
			}
		};
	}, [searchQuery, activeFilter]);

	const performSearch = async () => {
		if (!searchQuery.trim()) {
			setSearchResults([]);
			setSearchError(null);
			return;
		}

		setIsSearching(true);
		setSearchError(null);

		try {
			let results = [];

			if (activeFilter === 'all') {
				// Search both crops and diseases
				const searchResult = await PlantService.searchAll(searchQuery.trim());
				if (searchResult.success) {
					results = searchResult.data;
				} else {
					setSearchError(searchResult.error);
				}
			} else if (activeFilter === 'crops') {
				// Search only crops
				const searchResult = await PlantService.searchCrops(searchQuery.trim());
				if (searchResult.success) {
					results = searchResult.data;
				} else {
					setSearchError(searchResult.error);
				}
			} else if (activeFilter === 'diseases') {
				// Search only diseases
				const searchResult = await PlantService.searchDiseases(
					searchQuery.trim(),
				);
				if (searchResult.success) {
					results = searchResult.data;
				} else {
					setSearchError(searchResult.error);
				}
			}

			setSearchResults(results);
		} catch (error) {
			console.error('Search error:', error);
			setSearchError('Failed to search. Please try again.');
			setSearchResults([]);
		} finally {
			setIsSearching(false);
		}
	};

	const handleItemPress = (item) => {
		switch (item.type) {
			case 'crop':
				navigation.navigate('CropDetails', { crop: item });
				break;
			case 'disease':
				navigation.navigate('DiseaseDetail', { disease: item });
				break;
			default:
				console.log('Item selected:', item.name);
				break;
		}
	};

	const renderHeader = () => (
		<View style={styles.header}>
			<TouchableOpacity
				style={styles.backButton}
				onPress={() => navigation.goBack()}
			>
				<Icon name='arrow-back' size={24} color={AppColors.darkNavy} />
			</TouchableOpacity>

			<View style={styles.headerContent}>
				<Text style={styles.headerTitle}>Search</Text>
				<Text style={styles.headerSubtitle}>
					Find crops, diseases, and treatments
				</Text>
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
							color={
								activeFilter === filter.id
									? AppColors.white
									: AppColors.mediumGray
							}
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
							name={item.name}
							title={item.name}
							severity={item.severity}
							description={item.description}
							symptoms={item.symptoms}
							affectedCrops={item.affectedCrops}
							treatment={item.treatment}
							onPress={() => handleItemPress(item)}
						/>
					</View>
				);
			default:
				return null;
		}
	};

	const renderEmptyState = () => (
		<View style={styles.emptyState}>
			<Icon name='search-off' size={64} color={AppColors.mediumGray} />
			<Text style={styles.emptyTitle}>
				{searchQuery ? 'No results found' : 'Start searching'}
			</Text>
			<Text style={styles.emptySubtitle}>
				{searchQuery
					? 'Try different keywords or filters'
					: 'Search for crops, diseases, or treatments'}
			</Text>
		</View>
	);

	return (
		<SafeAreaView style={styles.container}>
			{renderHeader()}

			{/* Search Bar */}
			<View style={styles.searchContainer}>
				<View style={styles.searchInputContainer}>
					<Icon
						name='search'
						size={20}
						color={AppColors.mediumGray}
						style={styles.searchIcon}
					/>
					<TextInput
						style={styles.searchInput}
						placeholder='Search crops, diseases, treatments...'
						value={searchQuery}
						onChangeText={setSearchQuery}
						placeholderTextColor={AppColors.mediumGray}
					/>
					{searchQuery.length > 0 && (
						<TouchableOpacity
							style={styles.clearButton}
							onPress={() => setSearchQuery('')}
						>
							<Icon name='clear' size={20} color={AppColors.mediumGray} />
						</TouchableOpacity>
					)}
				</View>
			</View>

			{/* Filters */}
			{renderFilters()}

			{/* Results */}
			<View style={styles.resultsContainer}>
				{isSearching ? (
					<View style={styles.loadingContainer}>
						<LoadingSpinner size='large' />
						<Text style={styles.loadingText}>Searching...</Text>
					</View>
				) : searchError ? (
					<View style={styles.errorContainer}>
						<Icon name='error-outline' size={48} color={AppColors.errorRed} />
						<Text style={styles.errorTitle}>Search Error</Text>
						<Text style={styles.errorSubtitle}>{searchError}</Text>
					</View>
				) : searchResults.length > 0 ? (
					<>
						<Text style={styles.resultsCount}>
							{searchResults.length} result
							{searchResults.length !== 1 ? 's' : ''} found
						</Text>
						<FlatList
							data={searchResults}
							renderItem={renderSearchResult}
							keyExtractor={(item) => `${item.type}-${item.id}`}
							showsVerticalScrollIndicator={false}
							contentContainerStyle={styles.resultsList}
						/>
					</>
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
	loadingContainer: {
		alignItems: 'center',
		justifyContent: 'center',
		paddingVertical: Spacing.xxl,
	},
	loadingText: {
		...Typography.bodyMedium,
		color: AppColors.mediumGray,
		marginTop: Spacing.md,
	},
	errorContainer: {
		alignItems: 'center',
		justifyContent: 'center',
		paddingVertical: Spacing.xxl,
	},
	errorTitle: {
		...Typography.headlineMedium,
		color: AppColors.errorRed,
		marginTop: Spacing.lg,
		textAlign: 'center',
	},
	errorSubtitle: {
		...Typography.bodyMedium,
		color: AppColors.mediumGray,
		textAlign: 'center',
		marginTop: Spacing.sm,
	},
});

export default SearchScreen;
