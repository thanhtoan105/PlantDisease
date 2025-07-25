import React, { useState, useEffect } from 'react';
import {
	View,
	Text,
	ScrollView,
	TouchableOpacity,
	StyleSheet,
	SafeAreaView,
	FlatList,
	Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomSearchBar, LoadingSpinner } from '../components/shared';
import CropCard from '../components/CropCard';
import PlantService from '../services/PlantService';

const CropLibraryScreen = () => {
	const navigation = useNavigation();
	const [searchQuery, setSearchQuery] = useState('');
	const [crops, setCrops] = useState([]);
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState(null);

	// Fetch crops from database
	useEffect(() => {
		const fetchCrops = async () => {
			try {
				setLoading(true);
				setError(null);

				const result = await PlantService.getAllCrops();

				if (result.success) {
					setCrops(result.data);
				} else {
					setError(result.error);
					setCrops(result.data); // Fallback data
				}
			} catch (err) {
				console.error('Error fetching crops:', err);
				setError('Failed to load crops');
				setCrops(PlantService.getFallbackCrops());
			} finally {
				setLoading(false);
			}
		};

		fetchCrops();
	}, []);

	const filteredCrops = crops.filter(
		(crop) =>
			crop.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
			crop.description.toLowerCase().includes(searchQuery.toLowerCase()),
	);

	const handleCropPress = (crop) => {
		navigation.navigate('CropDetails', { crop });
	};

	const renderHeader = () => (
		<View style={styles.header}>
			<TouchableOpacity
				style={styles.backButton}
				onPress={() => navigation.goBack()}
			>
				<Icon name='arrow-back' size={24} color={AppColors.darkNavy} />
			</TouchableOpacity>

			<Text style={styles.headerTitle}>Crop Library</Text>

			<View style={styles.headerSpacer} />
		</View>
	);

	const renderCropItem = ({ item, index }) => (
		<View
			style={[
				styles.cropItemContainer,
				{ marginRight: index % 2 === 0 ? Spacing.sm : 0 },
			]}
		>
			<CropCard
				name={item.name}
				description={item.description}
				emoji={item.emoji}
				diseaseCount={item.diseaseCount}
				onPress={() => handleCropPress(item)}
			/>
		</View>
	);

	const renderStats = () => (
		<View style={styles.statsContainer}>
			<View style={styles.statItem}>
				<Text style={styles.statNumber}>{crops.length}</Text>
				<Text style={styles.statLabel}>Total Crops</Text>
			</View>
			<View style={styles.statDivider} />
			<View style={styles.statItem}>
				<Text style={styles.statNumber}>
					{crops.reduce((total, crop) => total + crop.diseaseCount, 0)}
				</Text>
				<Text style={styles.statLabel}>Diseases Covered</Text>
			</View>
		</View>
	);

	return (
		<SafeAreaView style={styles.container}>
			{renderHeader()}

			<ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
				{/* Search Bar */}
				<View style={styles.searchContainer}>
					<CustomSearchBar
						placeholder='Search crops...'
						value={searchQuery}
						onChangeText={setSearchQuery}
					/>
				</View>

				{/* Stats */}
				{renderStats()}

				{/* Section Title */}
				<View style={styles.sectionHeader}>
					<Text style={styles.sectionTitle}>Available Crops</Text>
					<Text style={styles.sectionSubtitle}>
						{filteredCrops.length} crop{filteredCrops.length !== 1 ? 's' : ''}{' '}
						found
					</Text>
				</View>

				{/* Crops Grid */}
				<FlatList
					data={filteredCrops}
					renderItem={renderCropItem}
					keyExtractor={(item) => item.id}
					numColumns={2}
					scrollEnabled={false}
					contentContainerStyle={styles.cropsGrid}
					columnWrapperStyle={styles.cropRow}
					showsVerticalScrollIndicator={false}
				/>

				{/* Empty State */}
				{filteredCrops.length === 0 && (
					<View style={styles.emptyContainer}>
						<Icon name='search-off' size={64} color={AppColors.mediumGray} />
						<Text style={styles.emptyTitle}>No crops found</Text>
						<Text style={styles.emptySubtitle}>
							Try adjusting your search terms
						</Text>
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
	headerSpacer: {
		width: 40,
	},
	content: {
		flex: 1,
	},
	searchContainer: {
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.lg,
		backgroundColor: AppColors.white,
	},
	statsContainer: {
		flexDirection: 'row',
		alignItems: 'center',
		backgroundColor: AppColors.white,
		paddingHorizontal: Spacing.lg,
		paddingBottom: Spacing.lg,
		marginBottom: Spacing.lg,
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
	},
	statDivider: {
		width: 1,
		height: 40,
		backgroundColor: AppColors.lightGray,
		marginHorizontal: Spacing.lg,
	},
	sectionHeader: {
		paddingHorizontal: Spacing.lg,
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
	cropsGrid: {
		paddingHorizontal: Spacing.lg,
		paddingBottom: Spacing.xxl,
	},
	cropRow: {
		justifyContent: 'space-between',
	},
	cropItemContainer: {
		flex: 0.48,
		marginBottom: Spacing.lg,
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

export default CropLibraryScreen;
