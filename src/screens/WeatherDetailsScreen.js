import React, { useState } from 'react';
import {
	View,
	ScrollView,
	Text,
	TouchableOpacity,
	ActivityIndicator,
	StyleSheet,
	SafeAreaView,
	Alert,
	Modal,
	ImageBackground,
	Dimensions,
	RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import LinearGradient from 'react-native-linear-gradient';
import { SvgXml } from 'react-native-svg';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard } from '../components/shared';
import { useWeather } from '../context/WeatherContext';
import CitySearchModal from '../components/CitySearchModal';

const { width: screenWidth } = Dimensions.get('window');

// Weather icon SVGs
const weatherIconSvgs = {
	sunny: `<svg height="512pt" viewBox="0 -39 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m397.683594 229.976562c0 78.476563-63.621094 142.09375-142.09375 142.09375-78.476563 0-142.097656-63.617187-142.097656-142.09375 0-78.476562 63.621093-142.09375 142.097656-142.09375 78.472656 0 142.09375 63.617188 142.09375 142.09375zm0 0" fill="#fab03c"/></svg>`,
	cloudy: `<svg height="512pt" viewBox="0 -32 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m62.640625 137.230469c2.804687-46.371094 41.292969-83.113281 88.371094-83.113281 37.964843 0 70.347656 23.902343 82.929687 57.476562 32.695313.394531 59.082032 27.003906 59.082032 59.792969 0 33.035156-26.78125 59.816406-59.816407 59.816406-13.828125 0-154.71875 0-168.925781 0-25.960938 0-47.007812-21.046875-47.007812-47.007813 0-25.410156 20.167968-46.097656 45.367187-46.964843zm0 0" fill="#f0f5f7"/></svg>`,
	rain: `<svg height="512pt" viewBox="-2 0 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m435.753906 131.359375c-4.4375-73.289063-65.269531-131.359375-139.675781-131.359375-60.007813 0-111.1875 37.773438-131.078125 90.839844-51.675781.625-93.378906 42.683594-93.378906 94.507812 0 52.214844 42.328125 94.542969 94.539062 94.542969h266.996094c41.035156 0 74.296875-33.265625 74.296875-74.296875 0-40.164062-31.871094-72.863281-71.699219-74.234375zm0 0" fill="#6d6d6d"/></svg>`,
	storm: `<svg height="512pt" viewBox="0 -32 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m62.640625 137.230469c2.804687-46.371094 41.292969-83.113281 88.371094-83.113281 37.964843 0 70.347656 23.902343 82.929687 57.476562 32.695313.394531 59.082032 27.003906 59.082032 59.792969 0 33.035156-26.78125 59.816406-59.816407 59.816406-13.828125 0-154.71875 0-168.925781 0-25.960938 0-47.007812-21.046875-47.007812-47.007813 0-25.410156 20.167968-46.097656 45.367187-46.964843zm0 0" fill="#6d6d6d"/></svg>`,
	night: `<svg height="512pt" viewBox="0 -39 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m397.683594 229.976562c0 78.476563-63.621094 142.09375-142.09375 142.09375-78.476563 0-142.097656-63.617187-142.097656-142.09375 0-78.476562 63.621093-142.09375 142.097656-142.09375 78.472656 0 142.09375 63.617188 142.09375 142.09375zm0 0" fill="#4a4a4a"/></svg>`,
	wind: `<svg height="512pt" viewBox="0 -39 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m397.683594 229.976562c0 78.476563-63.621094 142.09375-142.09375 142.09375-78.476563 0-142.097656-63.617187-142.097656-142.09375 0-78.476562 63.621093-142.09375 142.097656-142.09375 78.472656 0 142.09375 63.617188 142.09375 142.09375zm0 0" fill="#87ceeb"/></svg>`,
	winter: `<svg height="512pt" viewBox="0 -39 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m397.683594 229.976562c0 78.476563-63.621094 142.09375-142.09375 142.09375-78.476563 0-142.097656-63.617187-142.097656-142.09375 0-78.476562 63.621093-142.09375 142.097656-142.09375 78.472656 0 142.09375 63.617188 142.09375 142.09375zm0 0" fill="#e6f3ff"/></svg>`,
};

// Helper function to get weather background gradients (iPhone-style)
const getWeatherGradient = (condition) => {
	const main = condition?.main?.toLowerCase() || 'clear';
	const icon = condition?.icon || '';
	const isDay = icon.includes('d');

	const weatherGradients = {
		clear: isDay
			? ['#87CEEB', '#98D8E8', '#F7DC6F'] // Sunny day: sky blue to light yellow
			: ['#2C3E50', '#4A6741', '#1A252F'], // Clear night: dark blue to navy
		clouds: isDay
			? ['#BDC3C7', '#D5DBDB', '#85929E'] // Cloudy day: light gray to medium gray
			: ['#34495E', '#5D6D7E', '#2C3E50'], // Cloudy night: dark gray to navy
		rain: ['#5DADE2', '#85C1E9', '#AED6F1'], // Rain: blue tones
		drizzle: ['#7FB3D3', '#A9CCE3', '#D4E6F1'], // Drizzle: lighter blue
		thunderstorm: ['#566573', '#717D7E', '#85929E'], // Storm: dark gray
		snow: ['#EBF5FB', '#D6EAF8', '#AED6F1'], // Snow: light blue/white
		mist: ['#D5D8DC', '#EAEDED', '#F8F9F9'], // Mist: light gray
		fog: ['#D5D8DC', '#EAEDED', '#F8F9F9'], // Fog: light gray
		haze: ['#F4D03F', '#F7DC6F', '#F9E79F'], // Haze: yellow tones
	};

	return weatherGradients[main] || weatherGradients.clear;
};

// Helper function to get UV index description
const getUVDescription = (uvIndex) => {
	if (uvIndex <= 2) return 'Low';
	if (uvIndex <= 5) return 'Moderate';
	if (uvIndex <= 7) return 'High';
	if (uvIndex <= 10) return 'Very High';
	return 'Extreme';
};

// Helper function to get plant-related weather icons
const getPlantWeatherIcon = (condition) => {
	if (!condition) return weatherIconSvgs.sunny;

	const main = condition.main?.toLowerCase() || '';
	const icon = condition.icon || '';
	const isDay = icon.includes('d');

	switch (main) {
		case 'clear':
			return isDay ? weatherIconSvgs.sunny : weatherIconSvgs.night;
		case 'clouds':
			return weatherIconSvgs.cloudy;
		case 'rain':
		case 'drizzle':
			return weatherIconSvgs.rain;
		case 'thunderstorm':
			return weatherIconSvgs.storm;
		case 'snow':
			return weatherIconSvgs.winter;
		case 'mist':
		case 'fog':
		case 'haze':
			return weatherIconSvgs.cloudy;
		default:
			return isDay ? weatherIconSvgs.sunny : weatherIconSvgs.night;
	}
};

const WeatherDetailsScreen = () => {
	const navigation = useNavigation();
	const {
		currentWeather,
		forecast,
		isLoading,
		isRefreshing,
		error,
		refreshWeatherData,
		selectCity,
		useCurrentLocation,
		selectedCity,
		locationInfo,
	} = useWeather();

	const [showCityModal, setShowCityModal] = useState(false);
	const [activeTab, setActiveTab] = useState('today');

	const getWeatherIcon = (condition, size = 24) => {
		const iconSvg = getPlantWeatherIcon(condition);
		return <SvgXml xml={iconSvg} width={size} height={size} />;
	};

	const formatTime = (date) => {
		if (!date) return '--:--';
		const timeDate = date instanceof Date ? date : new Date(date);
		return timeDate.toLocaleTimeString('en-US', {
			hour: 'numeric',
			minute: '2-digit',
			hour12: true,
		});
	};

	const formatHour = (date) => {
		if (!date) return '--';
		const timeDate = date instanceof Date ? date : new Date(date);
		return timeDate.toLocaleTimeString('en-US', {
			hour: 'numeric',
			hour12: false,
		});
	};

	// Get location name with proper fallbacks
	const getLocationName = () => {
		if (selectedCity) {
			return `${selectedCity.name}${
				selectedCity.country ? `, ${selectedCity.country}` : ''
			}`;
		}

		if (currentWeather?.location?.name) {
			return `${currentWeather.location.name}${
				currentWeather.location.country
					? `, ${currentWeather.location.country}`
					: ''
			}`;
		}

		if (locationInfo) {
			return `${locationInfo.name}${
				locationInfo.country ? `, ${locationInfo.country}` : ''
			}`;
		}

		return 'Current Location';
	};

	// Get today's hourly forecast (next 24 hours)
	const getTodayForecast = () => {
		if (!forecast?.hourly) return [];
		return forecast.hourly.slice(0, 24);
	};

	// Get tomorrow's forecast (24-48 hours)
	const getTomorrowForecast = () => {
		if (!forecast?.hourly) return [];
		return forecast.hourly.slice(24, 48);
	};

	// Get weekly forecast (daily data)
	const getWeeklyForecast = () => {
		if (!forecast?.daily) return [];
		return forecast.daily.slice(0, 8);
	};

	const handleCitySelect = (city) => {
		selectCity(city);
		setShowCityModal(false);
	};

	const handleUseCurrentLocation = () => {
		Alert.alert(
			'Use Current Location',
			'Switch to using your current location for weather data?',
			[
				{ text: 'Cancel', style: 'cancel' },
				{
					text: 'Yes',
					onPress: () => {
						useCurrentLocation();
						setShowCityModal(false);
					},
				},
			],
		);
	};

	const renderFloatingHeader = () => (
		<View style={styles.floatingHeader}>
			<TouchableOpacity
				style={styles.headerButton}
				onPress={() => navigation.goBack()}
			>
				<Icon name='arrow-back' size={24} color={AppColors.white} />
			</TouchableOpacity>
			<Text style={styles.headerTitle}>Weather Details</Text>
			<TouchableOpacity
				style={styles.headerButton}
				onPress={() => setShowCityModal(true)}
			>
				<Icon name='location-on' size={24} color={AppColors.white} />
			</TouchableOpacity>
		</View>
	);

	const renderErrorState = () => (
		<View style={styles.errorContainer}>
			<Icon name='cloud-off' size={64} color={AppColors.errorRed} />
			<Text style={styles.errorTitle}>Weather Unavailable</Text>
			<Text style={styles.errorMessage}>
				{error || 'Unable to load weather data'}
			</Text>
			<TouchableOpacity style={styles.retryButton} onPress={refreshWeatherData}>
				<Text style={styles.retryButtonText}>Try Again</Text>
			</TouchableOpacity>
		</View>
	);

	const renderCurrentWeather = () => {
		if (!currentWeather) return null;

		return (
			<View style={styles.currentWeatherContainer}>
				{/* iPhone-style current weather display */}
				<View style={styles.weatherHeader}>
					<TouchableOpacity
						style={styles.locationButton}
						onPress={() => setShowCityModal(true)}
					>
						<Text style={styles.locationName}>{getLocationName()}</Text>
						<Icon name='expand-more' size={20} color='rgba(255,255,255,0.9)' />
					</TouchableOpacity>
				</View>

				<View style={styles.mainWeatherDisplay}>
					{/* Large temperature */}
					<Text style={styles.mainTemperature}>
						{Math.round(currentWeather.temperature || 0)}°
					</Text>

					{/* Weather condition */}
					<Text style={styles.conditionText}>
						{currentWeather.condition?.description?.charAt(0).toUpperCase() +
							(currentWeather.condition?.description?.slice(1) || 'Unknown')}
					</Text>

					{/* High/Low temperatures */}
					<Text style={styles.tempRange}>
						H:{Math.round(currentWeather.tempMax || 0)}° L:
						{Math.round(currentWeather.tempMin || 0)}°
					</Text>
				</View>

				{/* Weather icon */}
				<View style={styles.weatherIconContainer}>
					{getWeatherIcon(currentWeather.condition, 80)}
				</View>
			</View>
		);
	};

	const renderWeatherStats = () => {
		if (!currentWeather) return null;

		const stats = [
			{
				label: 'FEELS LIKE',
				value: `${Math.round(currentWeather.feelsLike || 0)}°`,
				icon: 'thermostat',
				description: 'Similar to the actual temperature.',
			},
			{
				label: 'HUMIDITY',
				value: `${currentWeather.humidity || 0}%`,
				icon: 'water-drop',
				description: 'The dew point is 12° right now.',
			},
			{
				label: 'WIND',
				value: `${Math.round(currentWeather.windSpeed || 0)} km/h`,
				icon: 'air',
				description: `Wind direction ${currentWeather.windDirection || 'N'}`,
			},
			{
				label: 'UV INDEX',
				value: `${currentWeather.uvIndex || 0}`,
				icon: 'wb-sunny',
				description: getUVDescription(currentWeather.uvIndex || 0),
			},
			{
				label: 'VISIBILITY',
				value: `${Math.round(currentWeather.visibility || 0)} km`,
				icon: 'visibility',
				description: "It's perfectly clear right now.",
			},
			{
				label: 'PRESSURE',
				value: `${Math.round(currentWeather.pressure || 0)} hPa`,
				icon: 'speed',
				description: 'Steady pressure.',
			},
		];

		return (
			<View style={styles.statsContainer}>
				{stats.map((stat, index) => (
					<View key={index} style={styles.statCard}>
						<Text style={styles.statLabel}>{stat.label}</Text>
						<Text style={styles.statValue}>{stat.value}</Text>
						<Text style={styles.statDescription}>{stat.description}</Text>
					</View>
				))}
			</View>
		);
	};

	const renderForecastTabs = () => (
		<View style={styles.tabsContainer}>
			<View style={styles.forecastCard}>
				<View style={styles.forecastHeader}>
					<Icon name='schedule' size={20} color='rgba(255, 255, 255, 0.8)' />
					<Text style={styles.forecastTitle}>Hourly Forecast</Text>
				</View>
				<View style={styles.tabs}>
					<TouchableOpacity
						style={[styles.tab, activeTab === 'today' && styles.activeTab]}
						onPress={() => setActiveTab('today')}
					>
						<Text
							style={[
								styles.tabText,
								activeTab === 'today' && styles.activeTabText,
							]}
						>
							Today
						</Text>
					</TouchableOpacity>
					<TouchableOpacity
						style={[styles.tab, activeTab === 'tomorrow' && styles.activeTab]}
						onPress={() => setActiveTab('tomorrow')}
					>
						<Text
							style={[
								styles.tabText,
								activeTab === 'tomorrow' && styles.activeTabText,
							]}
						>
							Tomorrow
						</Text>
					</TouchableOpacity>
					<TouchableOpacity
						style={[styles.tab, activeTab === '7days' && styles.activeTab]}
						onPress={() => setActiveTab('7days')}
					>
						<Text
							style={[
								styles.tabText,
								activeTab === '7days' && styles.activeTabText,
							]}
						>
							10-Day
						</Text>
					</TouchableOpacity>
				</View>
			</View>
		</View>
	);

	const renderForecastContent = () => {
		let forecastData = [];

		switch (activeTab) {
			case 'today':
				forecastData = getTodayForecast();
				break;
			case 'tomorrow':
				forecastData = getTomorrowForecast();
				break;
			case '7days':
				forecastData = getWeeklyForecast();
				break;
		}

		if (forecastData.length === 0) {
			return (
				<View style={styles.forecastContentCard}>
					<Text style={styles.noDataText}>No forecast data available</Text>
				</View>
			);
		}

		return (
			<View style={styles.forecastContentCard}>
				<ScrollView
					horizontal
					showsHorizontalScrollIndicator={false}
					style={styles.forecastScroll}
					contentContainerStyle={styles.forecastScrollContent}
				>
					{forecastData.map((item, index) => (
						<View key={index} style={styles.forecastItem}>
							<Text style={styles.forecastTime}>
								{index === 0 && activeTab !== '7days'
									? 'Now'
									: activeTab === '7days'
									? item.timestamp?.toLocaleDateString('en-US', {
											weekday: 'short',
									  }) || 'N/A'
									: formatHour(item.timestamp)}
							</Text>
							{getWeatherIcon(item.condition, 28)}
							<Text style={styles.forecastTemp}>
								{activeTab === '7days' && item.temperature?.max !== undefined
									? `${Math.round(item.temperature.max)}°`
									: `${Math.round(item.temperature || 0)}°`}
							</Text>
							{activeTab === '7days' && item.temperature?.min !== undefined && (
								<Text style={styles.forecastLowTemp}>
									{Math.round(item.temperature.min)}°
								</Text>
							)}
							{(activeTab === 'today' || activeTab === 'tomorrow') &&
								item.precipitationProbability && (
									<Text style={styles.precipitationText}>
										{item.precipitationProbability}%
									</Text>
								)}
						</View>
					))}
				</ScrollView>
			</View>
		);
	};

	const renderDetailedMetrics = () => {
		if (!currentWeather) return null;

		const metrics = [
			{
				label: 'Pressure',
				value: `${currentWeather.pressure || 0} hPa`,
				icon: 'compress',
			},
			{
				label: 'Cloudiness',
				value: `${currentWeather.cloudiness || 0}%`,
				icon: 'cloud',
			},
			{
				label: 'Wind Direction',
				value: `${currentWeather.windDegree || 0}° ${
					currentWeather.windDirection || 'N'
				}`,
				icon: 'navigation',
			},
			{
				label: 'Sunrise',
				value: formatTime(currentWeather.sunrise),
				icon: 'wb-sunny',
			},
			{
				label: 'Sunset',
				value: formatTime(currentWeather.sunset),
				icon: 'wb-twilight',
			},
			{
				label: 'Dew Point',
				value: `${Math.round(currentWeather.dewPoint || 0)}°`,
				icon: 'water-drop',
			},
		];

		return (
			<View style={styles.metricsCard}>
				<View style={styles.glassCard}>
					<View style={styles.metricsHeader}>
						<Icon name='analytics' size={20} color={AppColors.weatherDark} />
						<Text style={styles.metricsTitle}>Detailed Metrics</Text>
					</View>

					<View style={styles.metricsGrid}>
						{metrics.map((metric, index) => (
							<View key={index} style={styles.metricItem}>
								<Icon
									name={metric.icon}
									size={16}
									color={AppColors.weatherGray}
								/>
								<Text style={styles.metricLabel}>{metric.label}</Text>
								<Text style={styles.metricValue}>{metric.value}</Text>
							</View>
						))}
					</View>
				</View>
			</View>
		);
	};

	// Render weather alerts if available (API 3.0 feature)
	const renderWeatherAlerts = () => {
		if (!forecast?.alerts || forecast.alerts.length === 0) return null;

		return (
			<View style={styles.alertsCard}>
				<View style={[styles.glassCard, styles.alertCard]}>
					<View style={styles.alertHeader}>
						<Icon name='warning' size={20} color={AppColors.errorRed} />
						<Text style={styles.alertTitle}>Weather Alerts</Text>
					</View>
					{forecast.alerts.map((alert, index) => (
						<View key={index} style={styles.alertItem}>
							<Text style={styles.alertEvent}>{alert.event}</Text>
							<Text style={styles.alertDescription} numberOfLines={3}>
								{alert.description}
							</Text>
							<Text style={styles.alertTime}>
								{formatTime(alert.start)}
								<Text> - </Text>
								{formatTime(alert.end)}
							</Text>
						</View>
					))}
				</View>
			</View>
		);
	};

	if (isLoading) {
		return (
			<SafeAreaView style={styles.container}>
				{renderFloatingHeader()}
				<View style={styles.loadingContainer}>
					<ActivityIndicator size='large' color={AppColors.primaryGreen} />
					<Text style={styles.loadingText}>Loading weather data...</Text>
				</View>
			</SafeAreaView>
		);
	}

	if (error) {
		return (
			<SafeAreaView style={styles.container}>
				{renderFloatingHeader()}
				{renderErrorState()}
			</SafeAreaView>
		);
	}

	return (
		<View style={styles.container}>
			{/* iPhone-style gradient background */}
			<LinearGradient
				colors={getWeatherGradient(currentWeather?.condition)}
				style={styles.backgroundGradient}
			>
				{renderFloatingHeader()}

				<ScrollView
					style={styles.scrollView}
					contentContainerStyle={styles.scrollContent}
					showsVerticalScrollIndicator={false}
					refreshControl={
						<RefreshControl
							refreshing={isRefreshing}
							onRefresh={refreshWeatherData}
							tintColor={AppColors.primaryGreen}
						/>
					}
				>
					{renderCurrentWeather()}
					{renderWeatherStats()}
					{renderWeatherAlerts()}
					{renderForecastTabs()}
					{renderForecastContent()}
					{renderDetailedMetrics()}
				</ScrollView>
			</LinearGradient>

			<CitySearchModal
				visible={showCityModal}
				onClose={() => setShowCityModal(false)}
				onCitySelect={handleCitySelect}
				onUseCurrentLocation={handleUseCurrentLocation}
			/>
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: AppColors.weatherBackground,
	},
	backgroundImage: {
		flex: 1,
		width: '100%',
		height: '100%',
	},
	backgroundGradient: {
		flex: 1,
	},
	floatingHeader: {
		position: 'absolute',
		top: 50,
		left: 0,
		right: 0,
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		paddingHorizontal: Spacing.lg,
		zIndex: 1000,
	},
	headerButton: {
		width: 40,
		height: 40,
		borderRadius: BorderRadius.medium,
		backgroundColor: 'rgba(0, 0, 0, 0.5)',
		alignItems: 'center',
		justifyContent: 'center',
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.3)',
	},
	headerTitle: {
		...Typography.headlineMedium,
		color: AppColors.white,
		textAlign: 'center',
		flex: 1,
		textShadowColor: 'rgba(0, 0, 0, 0.7)',
		textShadowOffset: { width: 0, height: 1 },
		textShadowRadius: 3,
		fontWeight: '600',
	},
	scrollView: {
		flex: 1,
	},
	scrollContent: {
		paddingTop: 100, // Account for floating header
		paddingBottom: Spacing.lg,
	},
	loadingContainer: {
		flex: 1,
		alignItems: 'center',
		justifyContent: 'center',
		marginTop: 100,
	},
	loadingText: {
		...Typography.bodyMedium,
		color: AppColors.mediumGray,
		marginTop: Spacing.md,
	},
	errorContainer: {
		flex: 1,
		alignItems: 'center',
		justifyContent: 'center',
		paddingHorizontal: Spacing.xl,
		marginTop: 100,
	},
	errorTitle: {
		...Typography.headlineMedium,
		marginTop: Spacing.lg,
		textAlign: 'center',
	},
	errorMessage: {
		...Typography.bodyMedium,
		color: AppColors.mediumGray,
		marginTop: Spacing.sm,
		textAlign: 'center',
	},
	retryButton: {
		flexDirection: 'row',
		alignItems: 'center',
		backgroundColor: AppColors.primaryGreen,
		paddingHorizontal: Spacing.xl,
		paddingVertical: Spacing.md,
		borderRadius: BorderRadius.large,
		marginTop: Spacing.xl,
	},
	retryButtonText: {
		...Typography.labelMedium,
		color: AppColors.white,
		marginLeft: Spacing.sm,
	},
	currentWeatherContainer: {
		marginTop: Spacing.lg,
		marginHorizontal: Spacing.lg,
		marginBottom: Spacing.xl,
		alignItems: 'center',
		paddingVertical: Spacing.xl,
	},
	weatherHeader: {
		alignItems: 'center',
		marginBottom: Spacing.lg,
	},
	locationButton: {
		flexDirection: 'row',
		alignItems: 'center',
		paddingHorizontal: Spacing.md,
		paddingVertical: Spacing.sm,
		borderRadius: BorderRadius.medium,
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
	},
	locationName: {
		...Typography.headlineMedium,
		fontSize: 22,
		fontWeight: '600',
		color: 'rgba(255, 255, 255, 0.95)',
		marginRight: Spacing.xs,
	},
	mainWeatherDisplay: {
		alignItems: 'center',
		marginBottom: Spacing.lg,
	},
	mainTemperature: {
		fontSize: 96,
		fontWeight: '200',
		color: 'rgba(255, 255, 255, 0.95)',
		lineHeight: 96,
		marginBottom: Spacing.sm,
	},
	conditionText: {
		...Typography.headlineSmall,
		fontSize: 20,
		color: 'rgba(255, 255, 255, 0.8)',
		marginBottom: Spacing.xs,
		textAlign: 'center',
	},
	tempRange: {
		...Typography.bodyLarge,
		fontSize: 18,
		color: 'rgba(255, 255, 255, 0.7)',
		textAlign: 'center',
	},
	weatherIconContainer: {
		alignItems: 'center',
		justifyContent: 'center',
	},
	lastUpdated: {
		...Typography.bodySmall,
		color: 'rgba(255, 255, 255, 0.7)',
		marginTop: Spacing.xs,
		textShadowColor: 'rgba(0, 0, 0, 0.5)',
		textShadowOffset: { width: 0, height: 1 },
		textShadowRadius: 3,
	},
	temperatureSection: {
		alignItems: 'flex-end',
	},
	mainTemperature: {
		fontSize: 72,
		fontWeight: '200',
		color: AppColors.white,
		lineHeight: 72,
		textShadowColor: 'rgba(0, 0, 0, 0.5)',
		textShadowOffset: { width: 0, height: 2 },
		textShadowRadius: 4,
	},
	temperatureDetails: {
		alignItems: 'flex-end',
		marginTop: Spacing.sm,
	},
	feelsLike: {
		...Typography.bodyMedium,
		color: 'rgba(255, 255, 255, 0.8)',
		textShadowColor: 'rgba(0, 0, 0, 0.5)',
		textShadowOffset: { width: 0, height: 1 },
		textShadowRadius: 3,
	},
	tempRange: {
		...Typography.bodyMedium,
		color: AppColors.white,
		marginTop: Spacing.xs,
		textShadowColor: 'rgba(0, 0, 0, 0.5)',
		textShadowOffset: { width: 0, height: 1 },
		textShadowRadius: 3,
	},
	statsContainer: {
		marginHorizontal: Spacing.lg,
		marginBottom: Spacing.xl,
		flexDirection: 'row',
		flexWrap: 'wrap',
		justifyContent: 'space-between',
	},
	statCard: {
		width: '48%',
		backgroundColor: 'rgba(255, 255, 255, 0.15)',
		borderRadius: BorderRadius.large,
		padding: Spacing.lg,
		marginBottom: Spacing.md,
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.2)',
	},
	glassCard: {
		backgroundColor: 'rgba(255, 255, 255, 0.25)',
		borderRadius: BorderRadius.large,
		padding: Spacing.lg,
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.3)',
		shadowColor: 'rgba(0, 0, 0, 0.1)',
		shadowOffset: {
			width: 0,
			height: 4,
		},
		shadowOpacity: 0.3,
		shadowRadius: 10,
		elevation: 5,
	},
	glassTabsCard: {
		backgroundColor: 'rgba(255, 255, 255, 0.25)',
		borderRadius: BorderRadius.large,
		padding: 4,
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.3)',
		flexDirection: 'row',
	},
	statContent: {
		alignItems: 'center',
	},
	statIconContainer: {
		width: 48,
		height: 48,
		borderRadius: BorderRadius.medium,
		alignItems: 'center',
		justifyContent: 'center',
		marginBottom: Spacing.md,
	},
	statLabel: {
		...Typography.bodySmall,
		fontSize: 12,
		fontWeight: '600',
		color: 'rgba(255, 255, 255, 0.6)',
		marginBottom: Spacing.xs,
		letterSpacing: 0.5,
	},
	statValue: {
		...Typography.headlineMedium,
		fontSize: 28,
		fontWeight: '600',
		color: 'rgba(255, 255, 255, 0.95)',
		marginBottom: Spacing.xs,
	},
	statDescription: {
		...Typography.bodySmall,
		fontSize: 12,
		color: 'rgba(255, 255, 255, 0.6)',
		lineHeight: 16,
	},
	tabsContainer: {
		marginHorizontal: Spacing.lg,
		marginBottom: Spacing.lg,
	},
	tabs: {
		flexDirection: 'row',
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		borderRadius: BorderRadius.large,
		padding: 3,
		marginTop: Spacing.sm,
	},
	tab: {
		flex: 1,
		paddingVertical: Spacing.sm,
		alignItems: 'center',
		borderRadius: BorderRadius.medium,
	},
	activeTab: {
		backgroundColor: 'rgba(255, 255, 255, 0.3)',
	},
	tabText: {
		...Typography.labelMedium,
		fontSize: 14,
		color: 'rgba(255, 255, 255, 0.7)',
		fontWeight: '500',
	},
	activeTabText: {
		color: 'rgba(255, 255, 255, 0.95)',
		fontWeight: '600',
	},
	forecastCard: {
		marginHorizontal: Spacing.lg,
		marginBottom: Spacing.lg,
		backgroundColor: 'rgba(255, 255, 255, 0.15)',
		borderRadius: BorderRadius.large,
		padding: Spacing.lg,
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.2)',
	},
	forecastContentCard: {
		marginHorizontal: Spacing.lg,
		marginBottom: Spacing.xl,
		backgroundColor: 'rgba(255, 255, 255, 0.15)',
		borderRadius: BorderRadius.large,
		padding: Spacing.lg,
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.2)',
	},
	forecastHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.md,
	},
	forecastTitle: {
		...Typography.headlineSmall,
		fontSize: 16,
		fontWeight: '600',
		color: 'rgba(255, 255, 255, 0.9)',
		marginLeft: Spacing.sm,
		color: AppColors.weatherDark,
	},
	forecastScroll: {
		marginBottom: Spacing.sm,
	},
	forecastScrollContent: {
		paddingHorizontal: Spacing.sm,
	},
	noDataText: {
		...Typography.bodyMedium,
		color: 'rgba(255, 255, 255, 0.7)',
		textAlign: 'center',
		padding: Spacing.lg,
	},
	forecastItem: {
		alignItems: 'center',
		marginRight: Spacing.lg,
		width: 60,
		paddingVertical: Spacing.sm,
	},
	forecastTime: {
		...Typography.bodySmall,
		fontSize: 12,
		marginBottom: Spacing.sm,
		color: 'rgba(255, 255, 255, 0.7)',
		fontWeight: '500',
	},
	forecastTemp: {
		...Typography.labelMedium,
		fontSize: 16,
		fontWeight: '600',
		marginTop: Spacing.sm,
		color: 'rgba(255, 255, 255, 0.95)',
	},
	forecastLowTemp: {
		...Typography.bodySmall,
		color: AppColors.weatherGray,
		marginTop: 2,
	},
	precipitationText: {
		...Typography.bodySmall,
		color: AppColors.weatherGray,
		marginTop: Spacing.xs,
	},
	metricsCard: {
		marginHorizontal: Spacing.lg,
		marginBottom: Spacing.xl,
	},
	metricsHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.lg,
	},
	metricsTitle: {
		...Typography.headlineSmall,
		marginLeft: Spacing.sm,
		color: AppColors.weatherDark,
	},
	metricsGrid: {
		flexDirection: 'row',
		flexWrap: 'wrap',
		gap: Spacing.md,
	},
	metricItem: {
		width: '47%',
		backgroundColor: 'rgba(255, 255, 255, 0.2)',
		padding: Spacing.md,
		borderRadius: BorderRadius.medium,
		alignItems: 'center',
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.3)',
	},
	metricLabel: {
		...Typography.bodySmall,
		marginTop: Spacing.sm,
		marginBottom: Spacing.xs,
		color: AppColors.weatherGray,
	},
	metricValue: {
		...Typography.labelMedium,
		color: AppColors.weatherDark,
	},
	alertsCard: {
		marginHorizontal: Spacing.lg,
		marginBottom: Spacing.xl,
	},
	alertCard: {
		padding: Spacing.lg,
		borderRadius: BorderRadius.large,
		backgroundColor: 'rgba(255, 255, 255, 0.2)',
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.3)',
		shadowColor: 'rgba(0, 0, 0, 0.1)',
		shadowOffset: {
			width: 0,
			height: 4,
		},
		shadowOpacity: 0.3,
		shadowRadius: 10,
		elevation: 5,
	},
	alertHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.md,
	},
	alertTitle: {
		...Typography.headlineSmall,
		marginLeft: Spacing.sm,
		color: AppColors.errorRed,
	},
	alertItem: {
		marginBottom: Spacing.sm,
	},
	alertEvent: {
		...Typography.bodyMedium,
		fontWeight: '600',
		color: AppColors.weatherDark,
	},
	alertDescription: {
		...Typography.bodySmall,
		color: AppColors.weatherGray,
		marginTop: Spacing.xs,
	},
	alertTime: {
		...Typography.bodySmall,
		color: AppColors.weatherGray,
		marginTop: Spacing.xs,
	},
	statsGrid: {
		flexDirection: 'row',
		flexWrap: 'wrap',
		justifyContent: 'space-between',
	},
	statItem: {
		width: '48%', // Two columns for stats
		alignItems: 'center',
		marginBottom: Spacing.md,
	},
});

export default WeatherDetailsScreen;
