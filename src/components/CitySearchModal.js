import React, { useState, useRef, useEffect } from 'react';
import {
	View,
	Text,
	TextInput,
	TouchableOpacity,
	FlatList,
	StyleSheet,
	Modal,
	SafeAreaView,
	Alert,
	ActivityIndicator,
	Keyboard,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { SvgXml } from 'react-native-svg';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { useWeather } from '../context/WeatherContext';

// Weather SVG icons (simplified versions)
const weatherIcons = {
	sunny: `<svg height="24" viewBox="0 -39 512 512" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m397.683594 229.976562c0 78.476563-63.621094 142.09375-142.09375 142.09375-78.476563 0-142.097656-63.617187-142.097656-142.09375 0-78.476562 63.621093-142.09375 142.097656-142.09375 78.472656 0 142.09375 63.617188 142.09375 142.09375zm0 0" fill="#fab03c"/></svg>`,
	cloudy: `<svg height="24" viewBox="0 -32 512 512" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m62.640625 137.230469c2.804687-46.371094 41.292969-83.113281 88.371094-83.113281 37.964843 0 70.347656 23.902343 82.929687 57.476562 32.695313.394531 59.082032 27.003906 59.082032 59.792969 0 33.035156-26.78125 59.816406-59.816407 59.816406-13.828125 0-154.71875 0-168.925781 0-25.960938 0-47.007812-21.046875-47.007812-47.007813 0-25.410156 20.167968-46.097656 45.367187-46.964843zm0 0" fill="#f0f5f7"/></svg>`,
	rainy: `<svg height="24" viewBox="-2 0 512 512" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m435.753906 131.359375c-4.4375-73.289063-65.269531-131.359375-139.675781-131.359375-60.007813 0-111.1875 37.773438-131.078125 90.839844-51.675781.625-93.378906 42.683594-93.378906 94.507812 0 52.214844 42.328125 94.542969 94.539062 94.542969h266.996094c41.035156 0 74.296875-33.265625 74.296875-74.296875 0-40.164062-31.871094-72.863281-71.699219-74.234375zm0 0" fill="#6d6d6d"/></svg>`,
};

const CitySearchModal = ({
	visible,
	onClose,
	onCitySelect,
	onUseCurrentLocation,
}) => {
	const [searchQuery, setSearchQuery] = useState('');
	const [searchResults, setSearchResults] = useState([]);
	const [isSearching, setIsSearching] = useState(false);
	const [selectedCity, setSelectedCity] = useState(null);
	const [cityWeatherPreview, setCityWeatherPreview] = useState(null);
	const [isLoadingPreview, setIsLoadingPreview] = useState(false);
	const searchInputRef = useRef(null);
	const searchTimeoutRef = useRef(null);

	const {
		currentWeather,
		getWeatherForCity,
		searchCities: searchCitiesFromContext,
		locationHistory,
		removeFromLocationHistory,
	} = useWeather();

	useEffect(() => {
		if (visible && searchInputRef.current) {
			setTimeout(() => {
				searchInputRef.current?.focus();
			}, 300);
		}
	}, [visible]);

	const getWeatherIcon = (condition) => {
		if (!condition) return weatherIcons.sunny;

		const conditionLower = condition.main?.toLowerCase() || '';

		switch (conditionLower) {
			case 'clear':
				return weatherIcons.sunny;
			case 'clouds':
				return weatherIcons.cloudy;
			case 'rain':
			case 'drizzle':
				return weatherIcons.rainy;
			default:
				return weatherIcons.sunny;
		}
	};

	const searchCities = async (query) => {
		if (!query.trim()) {
			setSearchResults([]);
			return;
		}

		setIsSearching(true);
		try {
			const results = await searchCitiesFromContext(query.trim());
			setSearchResults(results.slice(0, 5)); // Limit to 5 results
		} catch (error) {
			console.error('Error searching cities:', error);
			setSearchResults([]);
		} finally {
			setIsSearching(false);
		}
	};

	const handleSearchInputChange = (text) => {
		setSearchQuery(text);
		setSelectedCity(null);

		// Clear previous timeout
		if (searchTimeoutRef.current) {
			clearTimeout(searchTimeoutRef.current);
		}

		// Debounce search
		searchTimeoutRef.current = setTimeout(() => {
			searchCities(text);
		}, 500);
	};

	const handleCityPress = async (city) => {
		setSelectedCity(city);
		setSearchQuery(`${city.name}, ${city.country}`);
		setSearchResults([]);
		setIsLoadingPreview(true);
		setCityWeatherPreview(null);
		Keyboard.dismiss();

		try {
			const weatherData = await getWeatherForCity(
				city.latitude,
				city.longitude,
			);
			setCityWeatherPreview(weatherData);
		} catch (error) {
			console.error('Failed to load weather preview:', error);
			setCityWeatherPreview(null);
		} finally {
			setIsLoadingPreview(false);
		}
	};

	const handleAddCity = () => {
		if (selectedCity) {
			// The city will be automatically added to location history when selected
			// through the selectCity function in the context

			// Reset search state but keep modal open
			setSelectedCity(null);
			setSearchQuery('');
			setSearchResults([]);
			setCityWeatherPreview(null);
			setIsLoadingPreview(false);
		}
	};

	const handleSelectCity = (city) => {
		onCitySelect(city);
		handleModalClose();
	};

	const handleCancel = () => {
		if (selectedCity) {
			setSelectedCity(null);
			setSearchQuery('');
			setSearchResults([]);
			setCityWeatherPreview(null);
			setIsLoadingPreview(false);
		} else {
			onClose();
		}
	};

	const resetModal = () => {
		setSearchQuery('');
		setSearchResults([]);
		setSelectedCity(null);
		setIsSearching(false);
	};

	const handleModalClose = () => {
		resetModal();
		onClose();
	};

	// Safe temperature access with fallbacks
	const getTemperature = (weatherData) => {
		if (!weatherData) return '--';
		return Math.round(weatherData.temperature || 0);
	};

	const getFeelsLike = (weatherData) => {
		if (!weatherData?.feelsLike) return '--';
		return Math.round(weatherData.feelsLike);
	};

	const getConditionDescription = (weatherData) => {
		if (!weatherData?.condition?.description) return 'Unknown';
		return (
			weatherData.condition.description.charAt(0).toUpperCase() +
			weatherData.condition.description.slice(1)
		);
	};

	const getHumidity = (weatherData) => {
		if (!weatherData?.humidity) return 0;
		return weatherData.humidity;
	};

	const getWindSpeed = (weatherData) => {
		if (!weatherData?.windSpeed) return 0;
		return Math.round(weatherData.windSpeed);
	};

	const renderCurrentLocationSection = () => {
		if (!currentWeather) return null;

		return (
			<View style={styles.currentLocationSection}>
				<Text style={styles.sectionTitle}>Current Location</Text>
				<View style={styles.currentLocationCard}>
					<View style={styles.currentLocationInfo}>
						<View style={styles.locationHeader}>
							<Icon
								name='my-location'
								size={16}
								color={AppColors.primaryGreen}
							/>
							<Text style={styles.locationName}>
								{currentWeather.location?.name || 'Current Location'}
								{currentWeather.location?.country
									? `, ${currentWeather.location.country}`
									: ''}
							</Text>
						</View>
						<View style={styles.weatherInfo}>
							<SvgXml
								xml={getWeatherIcon(currentWeather.condition)}
								width={24}
								height={24}
							/>
							<Text style={styles.temperature}>
								{getTemperature(currentWeather)}°
							</Text>
							<Text style={styles.condition}>
								{getConditionDescription(currentWeather)}
							</Text>
						</View>
					</View>
					<TouchableOpacity
						style={styles.useLocationButton}
						onPress={onUseCurrentLocation}
					>
						<Text style={styles.useLocationText}>Use</Text>
					</TouchableOpacity>
				</View>
			</View>
		);
	};

	const renderAddedCities = () => {
		if (!locationHistory || locationHistory.length === 0) return null;

		return (
			<View style={styles.addedCitiesSection}>
				<Text style={styles.sectionTitle}>Recent Locations</Text>
				{locationHistory.map((city) => (
					<View
						key={`${city.latitude}-${city.longitude}`}
						style={styles.addedCityCard}
					>
						<View style={styles.addedCityInfo}>
							<Icon name='location-on' size={16} color={AppColors.mediumGray} />
							<Text style={styles.addedCityName}>
								{city.name}, {city.country}
							</Text>
						</View>
						<View style={styles.addedCityActions}>
							<TouchableOpacity
								style={styles.selectCityButton}
								onPress={() => handleSelectCity(city)}
							>
								<Text style={styles.selectCityText}>Select</Text>
							</TouchableOpacity>
							<TouchableOpacity
								style={styles.removeCityButton}
								onPress={() => removeFromLocationHistory(city)}
							>
								<Icon name='close' size={16} color={AppColors.errorRed} />
							</TouchableOpacity>
						</View>
					</View>
				))}
			</View>
		);
	};

	const renderSearchResults = () => {
		if (isSearching) {
			return (
				<View style={styles.loadingContainer}>
					<ActivityIndicator size='small' color={AppColors.primaryGreen} />
					<Text style={styles.loadingText}>Searching cities...</Text>
				</View>
			);
		}

		if (searchResults.length === 0 && searchQuery.length > 0) {
			return (
				<View style={styles.noResultsContainer}>
					<Icon name='search-off' size={48} color={AppColors.mediumGray} />
					<Text style={styles.noResultsText}>No cities found</Text>
					<Text style={styles.noResultsSubtext}>
						Try searching with a different term
					</Text>
				</View>
			);
		}

		return (
			<FlatList
				data={searchResults}
				keyExtractor={(item) =>
					`${item.name}-${item.country}-${item.latitude}-${item.longitude}`
				}
				renderItem={({ item }) => (
					<TouchableOpacity
						style={styles.cityItem}
						onPress={() => handleCityPress(item)}
					>
						<View style={styles.cityInfo}>
							<Icon name='location-on' size={20} color={AppColors.mediumGray} />
							<View style={styles.cityDetails}>
								<Text style={styles.cityName}>{item.name}</Text>
								<Text style={styles.cityCountry}>{item.country}</Text>
								{item.state && (
									<Text style={styles.cityState}>{item.state}</Text>
								)}
							</View>
						</View>
						<Icon name='chevron-right' size={20} color={AppColors.lightGray} />
					</TouchableOpacity>
				)}
				style={styles.searchResults}
				showsVerticalScrollIndicator={false}
			/>
		);
	};

	const renderWeatherPreview = () => {
		if (!selectedCity) return null;

		return (
			<View style={styles.weatherPreviewContainer}>
				<View style={styles.weatherPreviewCard}>
					<View style={styles.previewHeader}>
						<View style={styles.cityInfo}>
							<Text style={styles.previewCityName}>
								{selectedCity.name}, {selectedCity.country}
							</Text>
							{selectedCity.state && (
								<Text style={styles.previewCityRegion}>
									{selectedCity.state}
								</Text>
							)}
						</View>
						<TouchableOpacity
							style={styles.closePreviewButton}
							onPress={handleCancel}
						>
							<Icon name='close' size={20} color={AppColors.mediumGray} />
						</TouchableOpacity>
					</View>

					{isLoadingPreview ? (
						<View style={styles.previewLoading}>
							<ActivityIndicator size='small' color={AppColors.primaryGreen} />
							<Text style={styles.loadingText}>Loading weather...</Text>
						</View>
					) : cityWeatherPreview ? (
						<View style={styles.weatherPreviewContent}>
							<View style={styles.weatherMainInfo}>
								<Text style={styles.previewTemperature}>
									{getTemperature(cityWeatherPreview)}°
								</Text>
								<View style={styles.weatherDetails}>
									<Text style={styles.previewCondition}>
										{getConditionDescription(cityWeatherPreview)}
									</Text>
									<Text style={styles.previewFeelsLike}>
										Feels like {getFeelsLike(cityWeatherPreview)}°
									</Text>
								</View>
							</View>

							<View style={styles.weatherStats}>
								<View style={styles.statItem}>
									<Icon
										name='water-drop'
										size={16}
										color={AppColors.secondary}
									/>
									<Text style={styles.statText}>
										{getHumidity(cityWeatherPreview)}%
									</Text>
								</View>
								<View style={styles.statItem}>
									<Icon name='air' size={16} color={AppColors.accentOrange} />
									<Text style={styles.statText}>
										{getWindSpeed(cityWeatherPreview)} km/h
									</Text>
								</View>
							</View>
						</View>
					) : (
						<View style={styles.previewError}>
							<Icon name='cloud-off' size={24} color={AppColors.errorRed} />
							<Text style={styles.errorText}>Unable to load weather</Text>
						</View>
					)}

					<View style={styles.actionButtonsContainer}>
						<TouchableOpacity
							style={styles.cancelButton}
							onPress={handleCancel}
						>
							<Text style={styles.cancelButtonText}>Cancel</Text>
						</TouchableOpacity>
						<TouchableOpacity style={styles.addButton} onPress={handleAddCity}>
							<Text style={styles.addButtonText}>Add</Text>
						</TouchableOpacity>
					</View>
				</View>
			</View>
		);
	};

	return (
		<Modal
			visible={visible}
			animationType='slide'
			presentationStyle='overFullScreen'
			transparent={true}
			onRequestClose={handleModalClose}
		>
			<View style={styles.modalOverlay}>
				<TouchableOpacity
					style={styles.modalBackdrop}
					activeOpacity={1}
					onPress={handleModalClose}
				/>
				<View style={styles.modalContainer}>
					<SafeAreaView style={styles.container}>
						{/* Header */}
						<View style={styles.header}>
							{!selectedCity ? (
								<TouchableOpacity onPress={handleModalClose}>
									<Icon name='close' size={24} color={AppColors.darkNavy} />
								</TouchableOpacity>
							) : (
								<View style={{ width: 24 }} />
							)}

							<Text style={styles.headerTitle}>Select Location</Text>

							<View style={{ width: 24 }} />
						</View>

						{/* Weather preview for selected city */}
						{renderWeatherPreview()}

						{/* Content */}
						{!selectedCity && (
							<View style={styles.content}>
								{/* Current Location Section */}
								{renderCurrentLocationSection()}

								{/* Added Cities Section */}
								{renderAddedCities()}

								{/* Search Section */}
								<View style={styles.searchSection}>
									<Text style={styles.sectionTitle}>Search Cities</Text>

									<View style={styles.searchContainer}>
										<Icon
											name='search'
											size={20}
											color={AppColors.mediumGray}
										/>
										<TextInput
											ref={searchInputRef}
											style={styles.searchInput}
											placeholder='Search for a city...'
											placeholderTextColor={AppColors.mediumGray}
											value={searchQuery}
											onChangeText={handleSearchInputChange}
											returnKeyType='search'
											autoCapitalize='words'
											autoCorrect={false}
										/>
										{searchQuery.length > 0 && (
											<TouchableOpacity
												onPress={() => handleSearchInputChange('')}
											>
												<Icon
													name='clear'
													size={20}
													color={AppColors.mediumGray}
												/>
											</TouchableOpacity>
										)}
									</View>

									{/* Search Results */}
									{renderSearchResults()}
								</View>
							</View>
						)}
					</SafeAreaView>
				</View>
			</View>
		</Modal>
	);
};

const styles = StyleSheet.create({
	modalOverlay: {
		flex: 1,
		justifyContent: 'flex-end',
	},
	modalBackdrop: {
		flex: 1,
		backgroundColor: 'rgba(0, 0, 0, 0.5)',
	},
	modalContainer: {
		height: '60%', // Half screen height
		backgroundColor: AppColors.white,
		borderTopLeftRadius: 20,
		borderTopRightRadius: 20,
		shadowColor: AppColors.shadowColor,
		shadowOffset: {
			width: 0,
			height: -4,
		},
		shadowOpacity: 0.1,
		shadowRadius: 10,
		elevation: 10,
	},
	container: {
		flex: 1,
		backgroundColor: 'transparent',
	},
	header: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.md,
		borderBottomWidth: 1,
		borderBottomColor: AppColors.lightGray,
	},
	headerTitle: {
		...Typography.headlineSmall,
	},
	actionButtonsContainer: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.md,
		backgroundColor: AppColors.lightGray,
		borderBottomWidth: 1,
		borderBottomColor: AppColors.mediumGray,
	},
	cancelButton: {
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.sm,
		borderRadius: BorderRadius.medium,
		backgroundColor: AppColors.white,
		borderWidth: 1,
		borderColor: AppColors.mediumGray,
	},
	cancelButtonText: {
		...Typography.labelMedium,
		color: AppColors.darkNavy,
	},
	addButton: {
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.sm,
		borderRadius: BorderRadius.medium,
		backgroundColor: AppColors.primaryGreen,
	},
	addButtonText: {
		...Typography.labelMedium,
		color: AppColors.white,
		fontWeight: '600',
	},
	content: {
		flex: 1,
		padding: Spacing.lg,
	},
	sectionTitle: {
		...Typography.labelLarge,
		marginBottom: Spacing.md,
		color: AppColors.darkNavy,
	},
	currentLocationSection: {
		marginBottom: Spacing.xl,
	},
	currentLocationCard: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		backgroundColor: AppColors.lightGray,
		padding: Spacing.lg,
		borderRadius: BorderRadius.large,
		borderWidth: 1,
		borderColor: AppColors.primaryGreen + '20',
	},
	currentLocationInfo: {
		flex: 1,
	},
	locationHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.sm,
	},
	locationName: {
		...Typography.labelMedium,
		marginLeft: Spacing.sm,
		color: AppColors.darkNavy,
	},
	weatherInfo: {
		flexDirection: 'row',
		alignItems: 'center',
		gap: Spacing.sm,
	},
	temperature: {
		...Typography.labelLarge,
		color: AppColors.darkNavy,
	},
	condition: {
		...Typography.bodySmall,
		color: AppColors.mediumGray,
	},
	useLocationButton: {
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.sm,
		backgroundColor: AppColors.primaryGreen,
		borderRadius: BorderRadius.medium,
	},
	useLocationText: {
		...Typography.labelMedium,
		color: AppColors.white,
		fontWeight: '600',
	},
	addedCitiesSection: {
		marginBottom: Spacing.xl,
	},
	addedCityCard: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		backgroundColor: AppColors.lightGray,
		padding: Spacing.lg,
		borderRadius: BorderRadius.large,
		marginBottom: Spacing.sm,
	},
	addedCityInfo: {
		flexDirection: 'row',
		alignItems: 'center',
		flex: 1,
	},
	addedCityName: {
		...Typography.labelMedium,
		marginLeft: Spacing.sm,
		color: AppColors.darkNavy,
	},
	addedCityActions: {
		flexDirection: 'row',
		alignItems: 'center',
		gap: Spacing.sm,
	},
	selectCityButton: {
		paddingHorizontal: Spacing.md,
		paddingVertical: Spacing.sm,
		backgroundColor: AppColors.primaryGreen,
		borderRadius: BorderRadius.medium,
	},
	selectCityText: {
		...Typography.labelSmall,
		color: AppColors.white,
		fontWeight: '600',
	},
	removeCityButton: {
		padding: Spacing.sm,
	},
	searchSection: {
		flex: 1,
	},
	searchContainer: {
		flexDirection: 'row',
		alignItems: 'center',
		backgroundColor: AppColors.lightGray,
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.md,
		borderRadius: BorderRadius.large,
		marginBottom: Spacing.lg,
	},
	searchInput: {
		...Typography.bodyMedium,
		flex: 1,
		marginLeft: Spacing.sm,
		color: AppColors.darkNavy,
	},
	loadingContainer: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'center',
		paddingVertical: Spacing.xl,
	},
	loadingText: {
		...Typography.bodyMedium,
		marginLeft: Spacing.sm,
		color: AppColors.mediumGray,
	},
	noResultsContainer: {
		alignItems: 'center',
		paddingVertical: Spacing.xl,
	},
	noResultsText: {
		...Typography.labelLarge,
		marginTop: Spacing.lg,
		color: AppColors.darkNavy,
	},
	noResultsSubtext: {
		...Typography.bodySmall,
		marginTop: Spacing.xs,
		color: AppColors.mediumGray,
		textAlign: 'center',
	},
	searchResults: {
		flex: 1,
	},
	cityItem: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'space-between',
		paddingVertical: Spacing.lg,
		paddingHorizontal: Spacing.md,
		borderBottomWidth: 1,
		borderBottomColor: AppColors.lightGray,
	},
	cityInfo: {
		flexDirection: 'row',
		alignItems: 'center',
		flex: 1,
	},
	cityDetails: {
		marginLeft: Spacing.md,
	},
	cityName: {
		...Typography.labelMedium,
		color: AppColors.darkNavy,
	},
	cityCountry: {
		...Typography.bodySmall,
		color: AppColors.mediumGray,
		marginTop: 2,
	},
	cityState: {
		...Typography.bodySmall,
		color: AppColors.mediumGray,
		marginTop: 2,
	},
	weatherPreviewContainer: {
		flex: 1,
		padding: Spacing.lg,
	},
	weatherPreviewCard: {
		backgroundColor: AppColors.white,
		borderRadius: BorderRadius.large,
		padding: Spacing.lg,
		elevation: 4,
		shadowColor: AppColors.shadowColor,
		shadowOffset: {
			width: 0,
			height: 2,
		},
		shadowOpacity: 0.1,
		shadowRadius: 8,
	},
	previewHeader: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'flex-start',
		marginBottom: Spacing.lg,
	},
	previewCityName: {
		...Typography.headlineSmall,
		color: AppColors.darkNavy,
	},
	previewCityRegion: {
		...Typography.bodySmall,
		color: AppColors.mediumGray,
		marginTop: 2,
	},
	closePreviewButton: {
		padding: Spacing.sm,
	},
	previewLoading: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'center',
		paddingVertical: Spacing.xl,
	},
	weatherPreviewContent: {
		marginBottom: Spacing.xl,
	},
	weatherMainInfo: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.lg,
	},
	previewTemperature: {
		fontSize: 48,
		fontWeight: '300',
		color: AppColors.darkNavy,
		marginRight: Spacing.lg,
	},
	weatherDetails: {
		flex: 1,
	},
	previewCondition: {
		...Typography.labelMedium,
		color: AppColors.darkNavy,
		marginBottom: Spacing.xs,
	},
	previewFeelsLike: {
		...Typography.bodySmall,
		color: AppColors.mediumGray,
	},
	weatherStats: {
		flexDirection: 'row',
		justifyContent: 'space-around',
		paddingVertical: Spacing.md,
		backgroundColor: AppColors.lightGray,
		borderRadius: BorderRadius.medium,
	},
	statItem: {
		flexDirection: 'row',
		alignItems: 'center',
	},
	statText: {
		...Typography.bodySmall,
		marginLeft: Spacing.xs,
		color: AppColors.darkNavy,
	},
	previewError: {
		alignItems: 'center',
		paddingVertical: Spacing.xl,
	},
	errorText: {
		...Typography.bodyMedium,
		color: AppColors.errorRed,
		marginTop: Spacing.sm,
	},
});

export default CitySearchModal;
