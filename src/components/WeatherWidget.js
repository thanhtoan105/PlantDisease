import React from 'react';
import {
	View,
	Text,
	TouchableOpacity,
	ActivityIndicator,
	StyleSheet,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import LinearGradient from 'react-native-linear-gradient';
import { SvgXml } from 'react-native-svg';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { useWeather } from '../context/WeatherContext';

// Import weather SVG icons
const weatherIcons = {
	sunny: `<svg height="60" viewBox="0 -39 512 512" width="60" xmlns="http://www.w3.org/2000/svg"><path d="m397.683594 229.976562c0 78.476563-63.621094 142.09375-142.09375 142.09375-78.476563 0-142.097656-63.617187-142.097656-142.09375 0-78.476562 63.621093-142.09375 142.097656-142.09375 78.472656 0 142.09375 63.617188 142.09375 142.09375zm0 0" fill="#fab03c"/></svg>`,
	cloudy: `<svg height="60" viewBox="0 -32 512 512" width="60" xmlns="http://www.w3.org/2000/svg"><path d="m62.640625 137.230469c2.804687-46.371094 41.292969-83.113281 88.371094-83.113281 37.964843 0 70.347656 23.902343 82.929687 57.476562 32.695313.394531 59.082032 27.003906 59.082032 59.792969 0 33.035156-26.78125 59.816406-59.816407 59.816406-13.828125 0-154.71875 0-168.925781 0-25.960938 0-47.007812-21.046875-47.007812-47.007813 0-25.410156 20.167968-46.097656 45.367187-46.964843zm0 0" fill="#f0f5f7"/></svg>`,
	rainy: `<svg height="60" viewBox="-2 0 512 512" width="60" xmlns="http://www.w3.org/2000/svg"><path d="m435.753906 131.359375c-4.4375-73.289063-65.269531-131.359375-139.675781-131.359375-60.007813 0-111.1875 37.773438-131.078125 90.839844-51.675781.625-93.378906 42.683594-93.378906 94.507812 0 52.214844 42.328125 94.542969 94.539062 94.542969h266.996094c41.035156 0 74.296875-33.265625 74.296875-74.296875 0-40.164062-31.871094-72.863281-71.699219-74.234375zm0 0" fill="#6d6d6d"/></svg>`,
	night: `<svg height="60" viewBox="0 -38 511.99957 511" width="60" xmlns="http://www.w3.org/2000/svg"><path d="m257.503906 127.75c.003906 76.394531-61.769531 138.167969-138.164062 138.167969-49.726563 0-93.320313-26.269531-117.648438-65.691407-5.441406-8.8125 3.15625-19.683593 12.976563-16.394531 12.636719 4.238281 26.164062 6.535157 40.230469 6.550781 70.023437.066407 127.070312-56.929687 127.070312-126.953124 0-14.109376-2.300781-27.679688-6.550781-40.359376-3.289063-9.816406 7.589843-18.410156 16.398437-12.972656 39.417969 24.335938 65.6875 67.925782 65.6875 117.652344zm0 0" fill="#f6cb43"/></svg>`,
	thunder: `<svg height="60" viewBox="0 -6 512 512" width="60" xmlns="http://www.w3.org/2000/svg"><path d="m281.980469 363.222656-202.148438 135.269532c-5.730469 3.835937-11.777343 1.816406-15.105469-2.359376-3.25-4.082031-3.914062-10.222656.855469-14.992187l99.5625-99.5625h-66.191406c-10.039063 0-15.082031-12.152344-7.972656-19.257813l106.511719-106.5h95.117187l-86.746094 86.746094h69.84375c11.148438 0 15.535157 14.449219 6.273438 20.65625zm0 0" fill="#f6cb43"/></svg>`,
	windy: `<svg height="60" viewBox="0 -80 511.99927 511" width="60" xmlns="http://www.w3.org/2000/svg"><path d="m287.621094.5c-33.636719 0-61.023438 27.261719-61.226563 60.855469-.046875 7.296875 5.691407 13.546875 12.988281 13.757812 7.578126.222657 13.789063-5.855469 13.789063-13.382812 0-19.8125 16.808594-35.769531 36.914063-34.363281 16.972656 1.183593 30.71875 14.933593 31.902343 31.902343 1.402344 20.105469-14.558593 36.910157-34.367187 36.910157h-267.773438c-7.394531 0-13.390625 5.996093-13.390625 13.390624 0 7.394532 5.996094 13.390626 13.390625 13.390626h266.84375c33.601563 0 61.640625-26.683594 62.15625-60.28125.519532-34.195313-27.148437-62.179688-61.226562-62.179688zm0 0" fill="#78ffce"/></svg>`,
};

const WeatherWidget = ({ onPress }) => {
	const { currentWeather, selectedCity, isLoading, error, refreshWeatherData } =
		useWeather();

	const getWeatherIcon = (condition) => {
		if (!condition) return weatherIcons.sunny;

		const conditionLower = condition.main.toLowerCase();

		switch (conditionLower) {
			case 'clear':
				return weatherIcons.sunny;
			case 'clouds':
				return weatherIcons.cloudy;
			case 'rain':
			case 'drizzle':
				return weatherIcons.rainy;
			case 'thunderstorm':
				return weatherIcons.thunder;
			case 'mist':
			case 'fog':
			case 'haze':
				return weatherIcons.cloudy;
			default:
				return weatherIcons.sunny;
		}
	};

	const formatDate = () => {
		return new Date().toLocaleDateString('en-US', {
			weekday: 'long',
			month: 'long',
			day: 'numeric',
		});
	};

	// Get location name with fallback
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

		return 'Current Location';
	};

	// Get temperature with proper fallback
	const getTemperature = () => {
		if (currentWeather?.temperature !== undefined) {
			return Math.round(currentWeather.temperature);
		}
		return '--';
	};

	// Get temperature range with fallback
	const getTemperatureRange = () => {
		const hasMinMax =
			currentWeather?.tempMin !== undefined &&
			currentWeather?.tempMax !== undefined;
		if (hasMinMax) {
			return `${Math.round(currentWeather.tempMin)}°-${Math.round(
				currentWeather.tempMax,
			)}°`;
		}

		// For API 3.0, try to get feels like temperature as alternative
		if (currentWeather?.feelsLike !== undefined) {
			return `Feels ${Math.round(currentWeather.feelsLike)}°`;
		}

		return '';
	};

	// Get condition description with fallback
	const getConditionDescription = () => {
		if (currentWeather?.condition?.description) {
			return (
				currentWeather.condition.description.charAt(0).toUpperCase() +
				currentWeather.condition.description.slice(1)
			);
		}
		return 'No data';
	};

	const renderContent = () => {
		if (isLoading) {
			return (
				<View style={styles.loadingContainer}>
					<ActivityIndicator size='large' color={AppColors.primaryGreen} />
					<Text style={styles.loadingText}>Loading weather...</Text>
				</View>
			);
		}

		if (error) {
			return (
				<TouchableOpacity
					style={styles.errorContainer}
					onPress={refreshWeatherData}
				>
					<Icon name='cloud-off' size={32} color={AppColors.errorRed} />
					<Text style={styles.errorTitle}>Weather unavailable</Text>
					<Text style={styles.errorSubtitle}>
						{error.includes('permission')
							? 'Location permission required'
							: 'Tap to retry'}
					</Text>
				</TouchableOpacity>
			);
		}

		if (!currentWeather) {
			return (
				<TouchableOpacity
					style={styles.errorContainer}
					onPress={refreshWeatherData}
				>
					<Icon name='refresh' size={32} color={AppColors.mediumGray} />
					<Text style={styles.errorTitle}>No weather data</Text>
					<Text style={styles.errorSubtitle}>Tap to load</Text>
				</TouchableOpacity>
			);
		}

		return (
			<View style={styles.content}>
				{/* Header with location */}
				<View style={styles.header}>
					<View style={styles.locationContainer}>
						<Text style={styles.location}>{getLocationName()}</Text>
						<Text style={styles.date}>{formatDate()}</Text>
					</View>
				</View>

				{/* Main temperature display */}
				<View style={styles.temperatureContainer}>
					<View style={styles.temperatureLeft}>
						<Text style={styles.temperature}>{getTemperature()}°</Text>
					</View>
					<View style={styles.temperatureRight}>
						<SvgXml
							xml={getWeatherIcon(currentWeather.condition)}
							width={60}
							height={60}
						/>
						{getTemperatureRange() && (
							<Text style={styles.tempRange}>{getTemperatureRange()}</Text>
						)}
						<Text style={styles.condition}>{getConditionDescription()}</Text>
					</View>
				</View>
			</View>
		);
	};

	return (
		<TouchableOpacity onPress={onPress} style={styles.container}>
			<LinearGradient
				colors={[AppColors.weatherSecondary, AppColors.weatherBackground]}
				start={{ x: 0, y: 0 }}
				end={{ x: 1, y: 1 }}
				style={styles.gradient}
			>
				{/* Background pattern */}
				<View style={styles.backgroundPattern} />

				{/* Content */}
				{renderContent()}
			</LinearGradient>
		</TouchableOpacity>
	);
};

const styles = StyleSheet.create({
	container: {
		marginBottom: Spacing.xxl,
		marginTop: Spacing.md,
		borderRadius: 20,
		overflow: 'hidden',
		elevation: 4,
		shadowColor: AppColors.shadowColor,
		shadowOffset: {
			width: 0,
			height: 4,
		},
		shadowOpacity: 0.1,
		shadowRadius: 10,
		zIndex: 1,
	},
	gradient: {
		padding: 20,
		minHeight: 120,
	},
	backgroundPattern: {
		position: 'absolute',
		top: -20,
		right: -20,
		width: 100,
		height: 100,
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		borderRadius: 50,
	},
	content: {
		flex: 1,
	},
	header: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'flex-start',
		marginBottom: Spacing.xl,
	},
	locationContainer: {
		flex: 1,
	},
	location: {
		fontSize: 24,
		fontWeight: '600',
		color: AppColors.weatherDark,
		marginBottom: Spacing.xs,
	},
	date: {
		...Typography.bodyMedium,
		color: AppColors.weatherGray,
	},
	temperatureContainer: {
		flexDirection: 'row',
		alignItems: 'flex-start',
	},
	temperatureLeft: {
		flex: 1,
	},
	temperature: {
		fontSize: 64,
		fontWeight: '300',
		color: AppColors.weatherDark,
		lineHeight: 64,
	},
	temperatureRight: {
		alignItems: 'flex-end',
		paddingTop: Spacing.sm,
	},
	tempRange: {
		fontSize: 16,
		fontWeight: '500',
		color: AppColors.weatherDark,
		marginTop: Spacing.sm,
	},
	condition: {
		...Typography.bodyMedium,
		color: AppColors.weatherGray,
		marginTop: Spacing.xs,
	},
	loadingContainer: {
		flex: 1,
		alignItems: 'center',
		justifyContent: 'center',
		minHeight: 120,
	},
	loadingText: {
		...Typography.bodyMedium,
		color: AppColors.weatherDark,
		marginTop: Spacing.sm,
	},
	errorContainer: {
		flex: 1,
		alignItems: 'center',
		justifyContent: 'center',
		minHeight: 120,
	},
	errorTitle: {
		...Typography.labelMedium,
		color: AppColors.weatherDark,
		marginTop: Spacing.sm,
	},
	errorSubtitle: {
		...Typography.bodySmall,
		color: AppColors.weatherGray,
		marginTop: Spacing.xs,
		textAlign: 'center',
	},
});

export default WeatherWidget;
