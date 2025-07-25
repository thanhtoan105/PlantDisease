import React, { useState, useEffect } from 'react';
import {
	View,
	ScrollView,
	Text,
	TouchableOpacity,
	StyleSheet,
	SafeAreaView,
	Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import {
	CustomCard,
	CustomSearchBar,
	LoadingSpinner,
} from '../components/shared';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import WeatherWidget from '../components/WeatherWidget';
import CropCard from '../components/CropCard';
import PlantService from '../services/PlantService';

const HomeTab = () => {
	const navigation = useNavigation();
	const [crops, setCrops] = useState([]);
	const [loading, setLoading] = useState(true);

	// Fetch crops from database
	useEffect(() => {
		const fetchCrops = async () => {
			try {
				const result = await PlantService.getAllCrops();
				if (result.success) {
					// Show only first 4 crops for home screen
					setCrops(result.data.slice(0, 4));
				} else {
					// Use fallback data
					setCrops(PlantService.getFallbackCrops().slice(0, 4));
				}
			} catch (err) {
				console.error('Error fetching crops for home:', err);
				setCrops(PlantService.getFallbackCrops().slice(0, 4));
			} finally {
				setLoading(false);
			}
		};

		fetchCrops();
	}, []);

	const functionCards = [
		{
			title: 'Plant Details',
			icon: 'eco',
			color: AppColors.secondary,
			onPress: () => {
				try {
					navigation.navigate('CropLibrary');
				} catch (error) {
					console.error('Navigation error:', error);
					Alert.alert(
						'Navigation Error',
						'Unable to open Crop Library. Please try again.',
					);
				}
			},
		},
		{
			title: 'Weather',
			icon: 'wb-sunny',
			color: AppColors.primaryGreen,
			onPress: () => {
				try {
					navigation.navigate('WeatherDetails');
				} catch (error) {
					console.error('Navigation error:', error);
					Alert.alert(
						'Navigation Error',
						'Unable to open Weather Details. Please try again.',
					);
				}
			},
		},
		{
			title: 'Disease Library',
			icon: 'bug-report',
			color: AppColors.accentOrange,
			onPress: () => {
				try {
					// Navigate to CropDetails with diseases tab active
					if (crops.length > 0) {
						navigation.navigate('CropDetails', {
							crop: crops[0],
							activeTab: 'diseases',
						});
					} else {
						// Fallback to first available crop
						navigation.navigate('CropLibrary');
					}
				} catch (error) {
					console.error('Navigation error:', error);
					Alert.alert(
						'Navigation Error',
						'Unable to open Disease Library. Please try again.',
					);
				}
			},
		},
	];

	const renderHeader = () => (
		<Text style={styles.header}>Plant Disease Detection</Text>
	);

	const renderAIScanButton = () => (
		<CustomCard
			onPress={() => {
				try {
					// Navigate to the AiScan tab which contains the camera interface
					console.log('Navigate to AiScan');
				} catch (error) {
					console.error('Navigation error:', error);
					Alert.alert(
						'Navigation Error',
						'Unable to open camera. Please try again.',
					);
				}
			}}
			style={styles.aiScanCard}
		>
			<View style={styles.aiScanContent}>
				<View style={styles.aiScanIconContainer}>
					<Icon name='camera-alt' size={28} color={AppColors.white} />
				</View>
				<View style={styles.aiScanTextContainer}>
					<Text style={styles.aiScanTitle}>AI Plant Disease Scanner</Text>
					<Text style={styles.aiScanSubtitle}>
						Tap to scan your plant for diseases
					</Text>
				</View>
				<Icon name='arrow-forward-ios' size={20} color={AppColors.white} />
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
							<View
								style={[
									styles.functionIconContainer,
									{ backgroundColor: `${card.color}20` },
								]}
							>
								<Icon name={card.icon} size={24} color={card.color} />
							</View>
							<Text style={styles.functionCardTitle}>{card.title}</Text>
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
		<ScrollView
			horizontal
			showsHorizontalScrollIndicator={false}
			style={styles.horizontalScroll}
		>
			{crops.map((crop, index) => (
				<CropCard
					key={index}
					name={crop.name}
					description={crop.description}
					emoji={crop.emoji}
					diseaseCount={crop.diseaseCount}
					onPress={() => {
						try {
							navigation.navigate('CropDetails', { crop });
						} catch (error) {
							console.error('Navigation error:', error);
							Alert.alert(
								'Navigation Error',
								'Unable to open crop details. Please try again.',
							);
						}
					}}
				/>
			))}
		</ScrollView>
	);

	return (
		<SafeAreaView style={styles.container}>
			<ScrollView
				style={styles.scrollView}
				contentContainerStyle={styles.scrollContent}
			>
				{renderHeader()}

				<CustomSearchBar
					placeholder='Search plants, diseases...'
					editable={false}
					onPress={() => {
						try {
							navigation.navigate('Search');
						} catch (error) {
							console.error('Navigation error:', error);
							Alert.alert(
								'Navigation Error',
								'Unable to open search. Please try again.',
							);
						}
					}}
					style={styles.searchBar}
				/>

				{renderAIScanButton()}
				{renderFunctionCards()}

				<WeatherWidget
					onPress={() => {
						try {
							navigation.navigate('WeatherDetails');
						} catch (error) {
							console.error('Navigation error:', error);
							Alert.alert(
								'Navigation Error',
								'Unable to open weather details. Please try again.',
							);
						}
					}}
				/>

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
