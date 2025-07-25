import React, { useState } from 'react';
import {
	View,
	Text,
	ScrollView,
	TouchableOpacity,
	StyleSheet,
	SafeAreaView,
	Image,
	Dimensions,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import LinearGradient from 'react-native-linear-gradient';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard } from '../components/shared';

const { width } = Dimensions.get('window');

const DiseaseDetailScreen = () => {
	const navigation = useNavigation();
	const route = useRoute();
	const { disease } = route.params || {};

	const [activeTab, setActiveTab] = useState('cause');

	if (!disease) {
		return (
			<SafeAreaView style={styles.container}>
				<View style={styles.errorContainer}>
					<Icon name='error-outline' size={48} color={AppColors.error} />
					<Text style={styles.errorTitle}>Disease not found</Text>
					<Text style={styles.errorSubtitle}>
						Unable to load disease information.
					</Text>
				</View>
			</SafeAreaView>
		);
	}

	const tabs = [
		{ id: 'cause', label: 'Cause', icon: 'info' },
		{ id: 'treatment', label: 'Treatment Tips', icon: 'medical-services' },
	];

	const renderHeader = () => (
		<View style={styles.header}>
			<TouchableOpacity
				style={styles.backButton}
				onPress={() => navigation.goBack()}
			>
				<Icon name='arrow-back' size={24} color={AppColors.white} />
			</TouchableOpacity>

			<View style={styles.diseaseImageContainer}>
				<Image
					source={
						disease.image_url
							? { uri: disease.image_url }
							: {
									uri: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop',
							  }
					}
					style={styles.diseaseImage}
					resizeMode='cover'
					onError={(error) =>
						console.log(
							'DiseaseDetail image load error:',
							error.nativeEvent.error,
						)
					}
					onLoad={() =>
						console.log(
							'DiseaseDetail image loaded successfully:',
							disease.image_url,
						)
					}
				/>
				<LinearGradient
					colors={['transparent', 'rgba(0,0,0,0.7)']}
					style={styles.imageOverlay}
				/>
			</View>

			<View style={styles.diseaseInfo}>
				<Text style={styles.diseaseName}>
					{disease.display_name || disease.name}
				</Text>
				<Text style={styles.diseaseSubtitle}>Disease Information</Text>
			</View>
		</View>
	);

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

	const renderCauseContent = () => (
		<CustomCard style={styles.contentCard}>
			<View style={styles.contentHeader}>
				<Icon name='info' size={24} color={AppColors.primaryGreen} />
				<Text style={styles.contentTitle}>Disease Cause</Text>
			</View>
			<Text style={styles.contentText}>
				{disease.description ||
					'Cause information not available for this disease.'}
			</Text>
		</CustomCard>
	);

	const renderTreatmentContent = () => (
		<CustomCard style={styles.contentCard}>
			<View style={styles.contentHeader}>
				<Icon
					name='medical-services'
					size={24}
					color={AppColors.primaryGreen}
				/>
				<Text style={styles.contentTitle}>Treatment Tips</Text>
			</View>
			<Text style={styles.contentText}>
				{disease.treatment ||
					'Treatment information not available for this disease.'}
			</Text>
		</CustomCard>
	);

	const renderContent = () => {
		switch (activeTab) {
			case 'treatment':
				return renderTreatmentContent();
			default:
				return renderCauseContent();
		}
	};

	return (
		<SafeAreaView style={styles.container}>
			{renderHeader()}
			{renderTabs()}
			<ScrollView
				style={styles.scrollView}
				contentContainerStyle={styles.scrollContent}
				showsVerticalScrollIndicator={false}
			>
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
	header: {
		height: 250,
		position: 'relative',
	},
	backButton: {
		position: 'absolute',
		top: 50,
		left: 20,
		zIndex: 10,
		width: 40,
		height: 40,
		borderRadius: 20,
		backgroundColor: 'rgba(0,0,0,0.3)',
		justifyContent: 'center',
		alignItems: 'center',
	},
	diseaseImageContainer: {
		flex: 1,
		position: 'relative',
	},
	diseaseImage: {
		width: '100%',
		height: '100%',
	},
	imageOverlay: {
		position: 'absolute',
		bottom: 0,
		left: 0,
		right: 0,
		height: 100,
	},
	diseaseInfo: {
		position: 'absolute',
		bottom: 20,
		left: 20,
		right: 20,
	},
	diseaseName: {
		...Typography.h2,
		color: AppColors.white,
		marginBottom: 4,
	},
	diseaseSubtitle: {
		...Typography.body,
		color: AppColors.white,
		opacity: 0.9,
	},
	tabsContainer: {
		flexDirection: 'row',
		backgroundColor: AppColors.white,
		paddingHorizontal: Spacing.md,
		paddingVertical: Spacing.sm,
		borderBottomWidth: 1,
		borderBottomColor: AppColors.lightGray,
	},
	tab: {
		flex: 1,
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'center',
		paddingVertical: Spacing.sm,
		paddingHorizontal: Spacing.md,
		borderRadius: BorderRadius.medium,
		marginHorizontal: Spacing.xs,
	},
	activeTab: {
		backgroundColor: `${AppColors.primaryGreen}15`,
	},
	tabLabel: {
		...Typography.body,
		color: AppColors.mediumGray,
		marginLeft: Spacing.xs,
		fontWeight: '500',
	},
	activeTabLabel: {
		color: AppColors.primaryGreen,
		fontWeight: '600',
	},
	scrollView: {
		flex: 1,
	},
	scrollContent: {
		padding: Spacing.md,
	},
	contentCard: {
		marginBottom: Spacing.md,
	},
	contentHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.md,
	},
	contentTitle: {
		...Typography.h3,
		color: AppColors.darkNavy,
		marginLeft: Spacing.sm,
	},
	contentText: {
		...Typography.body,
		color: AppColors.darkGray,
		lineHeight: 24,
	},
	errorContainer: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center',
		padding: Spacing.lg,
	},
	errorTitle: {
		...Typography.h2,
		color: AppColors.darkNavy,
		marginTop: Spacing.md,
		marginBottom: Spacing.sm,
	},
	errorSubtitle: {
		...Typography.body,
		color: AppColors.mediumGray,
		textAlign: 'center',
	},
});

export default DiseaseDetailScreen;
