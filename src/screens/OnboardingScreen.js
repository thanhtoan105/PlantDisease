import React, { useState, useRef } from 'react';
import {
	View,
	Text,
	StyleSheet,
	Dimensions,
	TouchableOpacity,
	Image,
	StatusBar,
	PermissionsAndroid,
	Platform,
	Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { FlatList } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import { AppColors } from '../theme';
import Geolocation from 'react-native-geolocation-service';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

const onboardingData = [
	{
		id: '1',
		title: 'Health Check',
		subtitle:
			'Take picture of your crop or upload image to detect diseases and receive treatment advice',
		image: require('../../assets/onboarding_screen/qr_generator.jpg'),
		backgroundColor: '#FFFFFF',
	},
	{
		id: '2',
		title: 'Community',
		subtitle:
			'Ask a question about your crop to receive help from the community',
		image: require('../../assets/onboarding_screen/news_check.jpg'),
		backgroundColor: '#FFFFFF',
	},
	{
		id: '3',
		title: 'Cultivation Tips',
		subtitle: 'Receive farming advice about how to improve your yield',
		image: require('../../assets/onboarding_screen/culitvation_tips.jpg'),
		backgroundColor: '#FFFFFF',
	},
];

const OnboardingScreen = ({ navigation }) => {
	const [currentIndex, setCurrentIndex] = useState(0);
	const flatListRef = useRef(null);

	const handleNext = () => {
		if (currentIndex < onboardingData.length - 1) {
			const nextIndex = currentIndex + 1;
			setCurrentIndex(nextIndex);
			flatListRef.current?.scrollToIndex({ index: nextIndex, animated: true });
		} else {
			// Navigate to the auth screen
			navigation.navigate('Auth');
		}
	};

	const handleSkip = () => {
		navigation.navigate('Auth');
	};

	const handleScroll = (event) => {
		const contentOffsetX = event.nativeEvent.contentOffset.x;
		const index = Math.round(contentOffsetX / screenWidth);
		setCurrentIndex(index);
	};

	const renderOnboardingItem = ({ item, index }) => (
		<View style={[styles.slide, { backgroundColor: item.backgroundColor }]}>
			<View style={styles.imageContainer}>
				<Image source={item.image} style={styles.image} resizeMode='contain' />
			</View>

			<View style={styles.contentContainer}>
				<Text style={styles.title}>{item.title}</Text>
				<Text style={styles.subtitle}>{item.subtitle}</Text>

				{/* Pagination Dots */}
				<View style={styles.pagination}>
					{onboardingData.map((_, dotIndex) => (
						<View
							key={dotIndex}
							style={[
								styles.dot,
								{
									backgroundColor:
										dotIndex === index
											? AppColors.primaryGreen
											: AppColors.lightGray,
									width: dotIndex === index ? 24 : 8,
								},
							]}
						/>
					))}
				</View>

				{/* Action Buttons */}
				{index === onboardingData.length - 1 ? (
					<View style={styles.finalButtonsContainer}>
						<TouchableOpacity style={styles.signUpButton} onPress={handleNext}>
							<Text style={styles.signUpButtonText}>Sign up</Text>
						</TouchableOpacity>

						<TouchableOpacity
							style={styles.logInButton}
							onPress={() =>
								navigation.navigate('Auth', { initialTab: 'signin' })
							}
						>
							<Text style={styles.logInButtonText}>Log in</Text>
						</TouchableOpacity>
					</View>
				) : (
					<View style={styles.navigationContainer}>
						<View style={styles.spacer} />

						<TouchableOpacity style={styles.nextButton} onPress={handleNext}>
							<Icon name='arrow-forward' size={24} color='white' />
						</TouchableOpacity>
					</View>
				)}
			</View>
		</View>
	);

	return (
		<SafeAreaView style={styles.container}>
			<StatusBar
				barStyle='dark-content'
				backgroundColor='transparent'
				translucent
			/>

			{/* Skip Button - Top Right */}
			{currentIndex < onboardingData.length - 1 && (
				<TouchableOpacity style={styles.topSkipButton} onPress={handleSkip}>
					<Text style={styles.topSkipButtonText}>Skip</Text>
				</TouchableOpacity>
			)}

			<FlatList
				ref={flatListRef}
				data={onboardingData}
				renderItem={renderOnboardingItem}
				keyExtractor={(item) => item.id}
				horizontal
				pagingEnabled
				showsHorizontalScrollIndicator={false}
				onScroll={handleScroll}
				scrollEventThrottle={16}
				bounces={false}
			/>
		</SafeAreaView>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: '#FFFFFF',
	},
	topSkipButton: {
		position: 'absolute',
		top: 60,
		right: 20,
		zIndex: 1,
		paddingHorizontal: 16,
		paddingVertical: 8,
	},
	topSkipButtonText: {
		fontSize: 16,
		color: AppColors.primaryGreen,
		fontWeight: '500',
	},
	slide: {
		width: screenWidth,
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center',
		paddingHorizontal: 20,
	},
	imageContainer: {
		flex: 0.6,
		justifyContent: 'center',
		alignItems: 'center',
		width: '100%',
	},
	image: {
		width: screenWidth * 0.8,
		height: screenHeight * 0.4,
		maxHeight: 400,
	},
	contentContainer: {
		flex: 0.4,
		justifyContent: 'flex-start',
		alignItems: 'center',
		paddingTop: 40,
		width: '100%',
	},
	title: {
		fontSize: 28,
		fontWeight: 'bold',
		color: AppColors.secondary,
		textAlign: 'center',
		marginBottom: 16,
	},
	subtitle: {
		fontSize: 16,
		color: AppColors.mediumGray,
		textAlign: 'center',
		lineHeight: 24,
		marginBottom: 40,
		paddingHorizontal: 20,
	},
	pagination: {
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
		marginBottom: 40,
	},
	dot: {
		height: 8,
		borderRadius: 4,
		marginHorizontal: 4,
	},
	navigationContainer: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		width: '100%',
		paddingHorizontal: 20,
	},
	spacer: {
		flex: 1,
	},
	nextButton: {
		backgroundColor: AppColors.primaryGreen,
		width: 56,
		height: 56,
		borderRadius: 28,
		justifyContent: 'center',
		alignItems: 'center',
		elevation: 3,
		shadowColor: AppColors.primaryGreen,
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.3,
		shadowRadius: 4,
	},
	finalButtonsContainer: {
		width: '100%',
		paddingHorizontal: 20,
	},
	signUpButton: {
		backgroundColor: AppColors.primaryGreen,
		paddingVertical: 16,
		borderRadius: 12,
		alignItems: 'center',
		marginBottom: 16,
		elevation: 2,
		shadowColor: AppColors.primaryGreen,
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.2,
		shadowRadius: 4,
	},
	signUpButtonText: {
		color: 'white',
		fontSize: 16,
		fontWeight: '600',
	},
	logInButton: {
		backgroundColor: 'transparent',
		paddingVertical: 16,
		borderRadius: 12,
		alignItems: 'center',
		borderWidth: 1,
		borderColor: AppColors.primaryGreen,
	},
	logInButtonText: {
		color: AppColors.primaryGreen,
		fontSize: 16,
		fontWeight: '600',
	},
});

export default OnboardingScreen;
