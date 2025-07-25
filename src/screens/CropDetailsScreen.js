import React, { useState, useEffect } from 'react';
import {
	View,
	Text,
	ScrollView,
	TouchableOpacity,
	StyleSheet,
	SafeAreaView,
	ImageBackground,
	Image,
	Animated,
	Dimensions,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import LinearGradient from 'react-native-linear-gradient';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import {
	CustomCard,
	CustomButton,
	ButtonType,
	LoadingSpinner,
} from '../components/shared';

import PlantService from '../services/PlantService';

const { width } = Dimensions.get('window');

const CropDetailsScreen = () => {
	const navigation = useNavigation();
	const route = useRoute();
	const { crop, activeTab: initialActiveTab } = route.params || {};

	const [activeTab, setActiveTab] = useState(initialActiveTab || 'overview');
	const [cropDetails, setCropDetails] = useState(null);
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState(null);
	const [expandedSections, setExpandedSections] = useState({});
	const [selectedTipCategory, setSelectedTipCategory] = useState('all');

	// Animation values
	const fadeAnim = useState(new Animated.Value(0))[0];
	const slideAnim = useState(new Animated.Value(50))[0];

	useEffect(() => {
		const fetchCropDetails = async () => {
			if (!crop?.id) {
				setError('No crop ID provided');
				setLoading(false);
				return;
			}

			try {
				setLoading(true);
				setError(null);
				const result = await PlantService.getCropDetails(crop.id);
				if (result.success) {
					setCropDetails(result.data);
				} else {
					setError(result.error);
					setCropDetails(result.data);
				}
			} catch (err) {
				console.error('Error fetching crop details:', err);
				setError('Failed to load crop details');
				setCropDetails(PlantService.getFallbackCropDetails(crop.id));
			} finally {
				setLoading(false);
				// Start animations
				Animated.parallel([
					Animated.timing(fadeAnim, {
						toValue: 1,
						duration: 600,
						useNativeDriver: true,
					}),
					Animated.timing(slideAnim, {
						toValue: 0,
						duration: 600,
						useNativeDriver: true,
					}),
				]).start();
			}
		};

		fetchCropDetails();
	}, [crop?.id]);

	const toggleSection = (sectionId) => {
		setExpandedSections((prev) => ({
			...prev,
			[sectionId]: !prev[sectionId],
		}));
	};

	if (loading) {
		return (
			<SafeAreaView style={styles.container}>
				<View style={styles.loadingContainer}>
					<LoadingSpinner size='large' />
				</View>
			</SafeAreaView>
		);
	}

	if (!cropDetails) {
		return (
			<SafeAreaView style={styles.container}>
				<View style={styles.errorContainer}>
					<Icon name='error-outline' size={48} color={AppColors.error} />
					<Text style={styles.errorTitle}>Unable to load crop details</Text>
					<Text style={styles.errorSubtitle}>
						{error || 'Please check your connection and try again.'}
					</Text>
					<CustomButton
						title='Retry'
						type={ButtonType.PRIMARY}
						onPress={() => {
							setLoading(true);
							setError(null);
							setCropDetails(null);
						}}
						style={styles.retryButton}
					/>
				</View>
			</SafeAreaView>
		);
	}

	const currentCrop = cropDetails;

	const tabs = [
		{ id: 'overview', label: 'Overview', icon: 'info' },
		{ id: 'diseases', label: 'Diseases', icon: 'bug-report' },
		{ id: 'tips', label: 'Growing Tips', icon: 'eco' },
	];

	const tipCategories = [
		{ id: 'all', label: 'All Tips', icon: 'list' },
		{ id: 'watering', label: 'Watering', icon: 'opacity' },
		{ id: 'fertilizing', label: 'Fertilizing', icon: 'grass' },
		{ id: 'pruning', label: 'Pruning', icon: 'content-cut' },
		{ id: 'pests', label: 'Pest Control', icon: 'bug-report' },
	];

	const renderHeader = () => {
		console.log(
			'CropDetailsScreen - Current crop image_url:',
			currentCrop?.image_url,
		);
		return (
			<ImageBackground
				source={
					currentCrop?.image_url
						? { uri: currentCrop.image_url }
						: {
								uri: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop',
						  }
				}
				style={styles.headerContainer}
				imageStyle={styles.headerImage}
			>
				<LinearGradient
					colors={['rgba(0, 0, 0, 0.3)', 'rgba(0, 0, 0, 0.7)']}
					style={styles.headerGradient}
				>
					<View style={styles.headerNavigation}>
						<TouchableOpacity
							onPress={() => navigation.goBack()}
							style={styles.navButton}
						>
							<Icon name='arrow-back' size={24} color={AppColors.white} />
						</TouchableOpacity>
						<TouchableOpacity style={styles.navButton}>
							<Icon name='favorite-border' size={24} color={AppColors.white} />
						</TouchableOpacity>
					</View>

					<Animated.View
						style={[
							styles.headerContent,
							{
								opacity: fadeAnim,
								transform: [{ translateY: slideAnim }],
							},
						]}
					>
						<Text style={styles.headerTitle}>{currentCrop.name}</Text>
						<Text style={styles.headerSubtitle}>
							{currentCrop.scientificName}
						</Text>
					</Animated.View>
				</LinearGradient>
			</ImageBackground>
		);
	};

	const renderTabs = () => (
		<View style={styles.tabsContainer}>
			{tabs.map((tab) => (
				<TouchableOpacity
					key={tab.id}
					style={[styles.tab, activeTab === tab.id && styles.activeTab]}
					onPress={() => setActiveTab(tab.id)}
				>
					<Icon
						name={tab.icon}
						size={20}
						color={
							activeTab === tab.id
								? AppColors.primaryGreen
								: AppColors.mediumGray
						}
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

	const renderQuickStats = () => (
		<View style={styles.quickStatsContainer}>
			<View style={styles.statCard}>
				<Icon name='thermostat' size={24} color={AppColors.primaryGreen} />
				<Text style={styles.statValue}>20-25°C</Text>
				<Text style={styles.statLabel}>Temperature</Text>
			</View>
			<View style={styles.statCard}>
				<Icon name='wb-sunny' size={24} color={AppColors.warning} />
				<Text style={styles.statValue}>6-8 hrs</Text>
				<Text style={styles.statLabel}>Sunlight</Text>
			</View>
			<View style={styles.statCard}>
				<Icon name='opacity' size={24} color={AppColors.info} />
				<Text style={styles.statValue}>Regular</Text>
				<Text style={styles.statLabel}>Watering</Text>
			</View>
		</View>
	);

	const renderExpandableSection = (title, content, sectionId, icon) => (
		<CustomCard style={styles.expandableCard}>
			<TouchableOpacity
				style={styles.expandableHeader}
				onPress={() => toggleSection(sectionId)}
			>
				<View style={styles.sectionTitleContainer}>
					<Icon name={icon} size={20} color={AppColors.primaryGreen} />
					<Text style={styles.expandableSectionTitle}>{title}</Text>
				</View>
				<Icon
					name={expandedSections[sectionId] ? 'expand-less' : 'expand-more'}
					size={24}
					color={AppColors.mediumGray}
				/>
			</TouchableOpacity>
			{expandedSections[sectionId] && (
				<Animated.View style={styles.expandableContent}>
					{content}
				</Animated.View>
			)}
		</CustomCard>
	);

	const renderOverview = () => (
		<Animated.View style={[styles.tabContent, { opacity: fadeAnim }]}>
			{renderQuickStats()}

			<CustomCard style={styles.infoCard}>
				<Text style={styles.cardTitle}>Description</Text>
				<Text style={styles.description}>{currentCrop.description}</Text>
			</CustomCard>

			{renderExpandableSection(
				'Basic Information',
				<View>
					<View style={styles.infoRow}>
						<Text style={styles.infoLabel}>Scientific Name:</Text>
						<Text style={styles.infoValue}>{currentCrop.scientificName}</Text>
					</View>
					{currentCrop.overview?.basic_info?.family && (
						<View style={styles.infoRow}>
							<Text style={styles.infoLabel}>Family:</Text>
							<Text style={styles.infoValue}>
								{currentCrop.overview.basic_info.family}
							</Text>
						</View>
					)}
					{currentCrop.overview?.basic_info?.origin && (
						<View style={styles.infoRow}>
							<Text style={styles.infoLabel}>Origin:</Text>
							<Text style={styles.infoValue}>
								{currentCrop.overview.basic_info.origin}
							</Text>
						</View>
					)}
				</View>,
				'basic-info',
				'info',
			)}

			{currentCrop.growingConditions &&
				Object.keys(currentCrop.growingConditions).length > 0 &&
				renderExpandableSection(
					'Growing Conditions',
					<View>
						{Object.entries(currentCrop.growingConditions).map(
							([key, value]) => (
								<View key={key} style={styles.infoRow}>
									<Text style={styles.infoLabel}>
										{key.charAt(0).toUpperCase() + key.slice(1)}:
									</Text>
									<Text style={styles.infoValue}>{value}</Text>
								</View>
							),
						)}
					</View>,
					'growing-conditions',
					'eco',
				)}

			{currentCrop.seasons &&
				Object.keys(currentCrop.seasons).length > 0 &&
				renderExpandableSection(
					'Growing Season',
					<View>
						{Object.entries(currentCrop.seasons).map(([key, value]) => (
							<View key={key} style={styles.infoRow}>
								<Text style={styles.infoLabel}>
									{key.charAt(0).toUpperCase() + key.slice(1)}:
								</Text>
								<Text style={styles.infoValue}>{value}</Text>
							</View>
						))}
					</View>,
					'growing-season',
					'schedule',
				)}
		</Animated.View>
	);

	const renderEnhancedDiseases = () => (
		<Animated.View style={[styles.tabContent, { opacity: fadeAnim }]}>
			<View style={styles.sectionHeader}>
				<Text style={styles.sectionTitle}>Common Diseases</Text>
				<Text style={styles.sectionSubtitle}>
					{currentCrop.diseases?.length || 0} disease
					{(currentCrop.diseases?.length || 0) !== 1 ? 's' : ''} identified
				</Text>
			</View>

			{currentCrop.diseases && currentCrop.diseases.length > 0 ? (
				<View style={styles.diseaseCardsContainer}>
					{currentCrop.diseases.map((disease) => (
						<TouchableOpacity
							key={disease.id}
							style={styles.diseaseCard}
							onPress={() => {
								console.log(
									'Disease pressed:',
									disease.name,
									'image_url:',
									disease.image_url,
								);
								navigation.navigate('DiseaseDetail', { disease });
							}}
						>
							<View style={styles.diseaseImageContainer}>
								<Image
									source={
										disease.image_url
											? { uri: disease.image_url }
											: {
													uri: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop',
											  }
									}
									style={styles.diseaseCardImage}
									resizeMode='cover'
									onError={(error) =>
										console.log(
											'Disease image load error:',
											error.nativeEvent.error,
										)
									}
								/>
							</View>
							<View style={styles.diseaseCardContent}>
								<Text style={styles.diseaseCardName} numberOfLines={2}>
									{disease.display_name || disease.name}
								</Text>
							</View>
						</TouchableOpacity>
					))}
				</View>
			) : (
				<CustomCard style={styles.emptyCard}>
					<Icon name='bug-report' size={48} color={AppColors.mediumGray} />
					<Text style={styles.emptyTitle}>No disease data available</Text>
					<Text style={styles.emptySubtitle}>
						Disease information for this crop is not yet available.
					</Text>
				</CustomCard>
			)}
		</Animated.View>
	);

	const renderInteractiveTips = () => (
		<Animated.View style={[styles.tabContent, { opacity: fadeAnim }]}>
			<View style={styles.sectionHeader}>
				<Text style={styles.sectionTitle}>Growing Tips</Text>
			</View>

			{currentCrop.tips && currentCrop.tips.length > 0 ? (
				<CustomCard style={styles.tipsCard}>
					{currentCrop.tips.map((tip, index) => (
						<View key={index} style={styles.numberedTipItem}>
							<View style={styles.tipNumber}>
								<Text style={styles.tipNumberText}>{index + 1}</Text>
							</View>
							<View style={styles.tipContent}>
								<Text style={styles.tipText}>{tip}</Text>
							</View>
						</View>
					))}
				</CustomCard>
			) : (
				<CustomCard style={styles.emptyCard}>
					<Icon name='eco' size={48} color={AppColors.mediumGray} />
					<Text style={styles.emptyTitle}>No tips available</Text>
					<Text style={styles.emptySubtitle}>
						Growing tips for this crop will be added soon.
					</Text>
				</CustomCard>
			)}
		</Animated.View>
	);

	const renderContent = () => {
		switch (activeTab) {
			case 'diseases':
				return renderEnhancedDiseases();
			case 'tips':
				return renderInteractiveTips();
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
		paddingTop: 50,
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
	// Quick Stats Styles
	quickStatsContainer: {
		flexDirection: 'row',
		marginBottom: Spacing.lg,
		gap: Spacing.sm,
	},
	statCard: {
		flex: 1,
		backgroundColor: AppColors.white,
		borderRadius: 12,
		padding: Spacing.md,
		alignItems: 'center',
		shadowColor: '#000',
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.1,
		shadowRadius: 4,
		elevation: 3,
	},
	statValue: {
		...Typography.labelLarge,
		fontWeight: '700',
		marginTop: Spacing.xs,
		color: AppColors.darkNavy,
	},
	statLabel: {
		...Typography.caption,
		color: AppColors.mediumGray,
		marginTop: Spacing.xxs,
	},
	// Expandable Section Styles
	expandableCard: {
		marginBottom: Spacing.md,
		overflow: 'hidden',
	},
	expandableHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		paddingVertical: Spacing.sm,
	},
	sectionTitleContainer: {
		flexDirection: 'row',
		alignItems: 'center',
	},
	expandableSectionTitle: {
		...Typography.labelLarge,
		marginLeft: Spacing.xs,
		color: AppColors.darkNavy,
	},
	expandableContent: {
		paddingTop: Spacing.sm,
	},
	// Enhanced Disease Styles
	enhancedDiseaseCard: {
		marginBottom: Spacing.md,
		borderLeftWidth: 4,
		borderLeftColor: AppColors.primaryGreen,
	},
	diseaseHeader: {
		marginBottom: Spacing.sm,
	},
	diseaseMainInfo: {
		flex: 1,
	},
	diseaseTitleRow: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		marginBottom: Spacing.xs,
	},
	diseaseName: {
		...Typography.labelLarge,
		fontWeight: '600',
		color: AppColors.darkNavy,
		flex: 1,
	},
	severityBadge: {
		paddingHorizontal: Spacing.sm,
		paddingVertical: 4,
		borderRadius: 12,
		marginLeft: Spacing.sm,
	},
	severityText: {
		...Typography.caption,
		color: AppColors.white,
		fontWeight: '600',
		textTransform: 'uppercase',
	},
	diseaseType: {
		...Typography.caption,
		color: AppColors.mediumGray,
		textTransform: 'capitalize',
	},
	diseaseSection: {
		marginTop: Spacing.sm,
		borderTopWidth: 1,
		borderTopColor: AppColors.lightGray,
		paddingTop: Spacing.sm,
	},
	diseaseSectionHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		paddingVertical: Spacing.xs,
	},
	diseaseSectionTitle: {
		...Typography.labelMedium,
		marginLeft: Spacing.xs,
		color: AppColors.darkNavy,
	},
	diseaseDescription: {
		...Typography.bodyMedium,
		color: AppColors.darkGray,
		lineHeight: 20,
		marginTop: Spacing.xs,
	},
	// Interactive Tips Styles
	categoriesScroll: {
		marginBottom: Spacing.lg,
	},
	categoriesContainer: {
		paddingHorizontal: Spacing.lg,
		gap: Spacing.sm,
	},
	categoryChip: {
		flexDirection: 'row',
		alignItems: 'center',
		paddingHorizontal: Spacing.md,
		paddingVertical: Spacing.sm,
		borderRadius: 20,
		borderWidth: 1,
		borderColor: AppColors.primaryGreen,
		backgroundColor: AppColors.white,
	},
	activeCategoryChip: {
		backgroundColor: AppColors.primaryGreen,
	},
	categoryLabel: {
		...Typography.caption,
		marginLeft: Spacing.xs,
		color: AppColors.primaryGreen,
		fontWeight: '500',
	},
	activeCategoryLabel: {
		color: AppColors.white,
	},
	interactiveTipItem: {
		flexDirection: 'row',
		alignItems: 'flex-start',
		paddingVertical: Spacing.sm,
		borderBottomWidth: 1,
		borderBottomColor: AppColors.lightGray,
	},
	tipCheckbox: {
		marginRight: Spacing.md,
		marginTop: 2,
	},
	tipContent: {
		flex: 1,
		justifyContent: 'center',
	},
	completedTipText: {
		textDecorationLine: 'line-through',
		color: AppColors.mediumGray,
	},
	tipMeta: {
		flexDirection: 'row',
		alignItems: 'center',
		marginTop: Spacing.xs,
	},
	tipDifficulty: {
		...Typography.caption,
		color: AppColors.mediumGray,
		marginLeft: Spacing.xs,
	},
	// Existing styles remain the same...
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
	tipsCard: {
		marginBottom: Spacing.lg,
	},
	tipText: {
		...Typography.bodyMedium,
		flex: 1,
		lineHeight: 22,
		color: AppColors.darkNavy,
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
	loadingContainer: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center',
		paddingHorizontal: Spacing.xl,
	},
	loadingText: {
		...Typography.bodyLarge,
		color: AppColors.secondary,
		marginTop: Spacing.lg,
		textAlign: 'center',
	},
	errorContainer: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center',
		paddingHorizontal: Spacing.xl,
	},
	errorTitle: {
		...Typography.headlineMedium,
		color: AppColors.darkNavy,
		marginTop: Spacing.lg,
		textAlign: 'center',
	},
	errorSubtitle: {
		...Typography.bodyMedium,
		color: AppColors.mediumGray,
		marginTop: Spacing.sm,
		textAlign: 'center',
		lineHeight: 22,
	},
	retryButton: {
		marginTop: Spacing.xl,
		minWidth: 120,
	},
	// New disease card styles
	diseaseCardsContainer: {
		flexDirection: 'row',
		flexWrap: 'wrap',
		justifyContent: 'space-between',
		marginTop: Spacing.md,
	},
	diseaseCard: {
		width: '48%',
		backgroundColor: AppColors.white,
		borderRadius: BorderRadius.large,
		marginBottom: Spacing.md,
		shadowColor: AppColors.shadowColor,
		shadowOffset: {
			width: 0,
			height: 2,
		},
		shadowOpacity: 0.1,
		shadowRadius: 4,
		elevation: 3,
	},
	diseaseImageContainer: {
		height: 120,
		borderTopLeftRadius: BorderRadius.large,
		borderTopRightRadius: BorderRadius.large,
		overflow: 'hidden',
	},
	diseaseCardImage: {
		width: '100%',
		height: '100%',
	},
	diseaseCardContent: {
		padding: Spacing.md,
	},
	diseaseCardName: {
		...Typography.bodyLarge,
		fontWeight: '600',
		color: AppColors.darkNavy,
		textAlign: 'center',
	},
	// New numbered tip styles
	numberedTipItem: {
		flexDirection: 'row',
		alignItems: 'center',
		paddingVertical: Spacing.md,
		borderBottomWidth: 1,
		borderBottomColor: AppColors.lightGray,
	},
	tipNumber: {
		width: 32,
		height: 32,
		borderRadius: 16,
		backgroundColor: AppColors.primaryGreen,
		justifyContent: 'center',
		alignItems: 'center',
		marginRight: Spacing.md,
		marginTop: 0,
	},
	tipNumberText: {
		...Typography.bodyMedium,
		color: AppColors.white,
		fontWeight: '600',
		fontSize: 14,
	},
	tipLabel: {
		...Typography.caption,
		color: AppColors.primaryGreen,
		marginLeft: Spacing.xs,
		fontWeight: '500',
	},
});

export default CropDetailsScreen;
