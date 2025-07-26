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
import { LinearGradient } from 'expo-linear-gradient';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard } from '../components/shared';
import { useWeather } from '../context/WeatherContext';
import CitySearchModal from '../components/CitySearchModal';

const { width: screenWidth } = Dimensions.get('window');

// Helper function to get weather background images
const getWeatherBackground = (condition) => {
  const weatherBackgrounds = {
    clear: 'https://images.unsplash.com/photo-1601297183305-6df142704ea2?w=800&h=600&fit=crop',
    clouds: 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=800&h=600&fit=crop',
    rain: 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=800&h=600&fit=crop',
    thunderstorm: 'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28?w=800&h=600&fit=crop',
    mist: 'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=800&h=600&fit=crop',
  };

  const conditionKey = condition?.main?.toLowerCase() || 'clear';
  return weatherBackgrounds[conditionKey] || weatherBackgrounds.clear;
};

// Helper function to get plant-related weather icons
const getPlantWeatherIcon = (condition) => {
  if (!condition) return 'wb-sunny';
  
  const main = condition.main?.toLowerCase() || '';
  const icon = condition.icon || '';
  const isDay = icon.includes('d');

  switch (main) {
    case 'clear':
      return isDay ? 'wb-sunny' : 'nights-stay';
    case 'clouds':
      return 'wb-cloudy';
    case 'rain':
    case 'drizzle':
      return 'grain';
    case 'thunderstorm':
      return 'flash-on';
    case 'snow':
      return 'ac-unit';
    case 'mist':
    case 'fog':
    case 'haze':
      return 'blur-on';
    default:
      return isDay ? 'wb-sunny' : 'nights-stay';
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
    const iconName = getPlantWeatherIcon(condition);
    return (
      <Icon
        name={iconName}
        size={size}
        color={AppColors.primaryGreen}
      />
    );
  };

  const formatTime = (date) => {
    if (!date) return '--:--';
    const timeDate = date instanceof Date ? date : new Date(date);
    return timeDate.toLocaleTimeString('en-US', { 
      hour: 'numeric', 
      minute: '2-digit',
      hour12: true 
    });
  };

  const formatHour = (date) => {
    if (!date) return '--';
    const timeDate = date instanceof Date ? date : new Date(date);
    return timeDate.toLocaleTimeString('en-US', { 
      hour: 'numeric',
      hour12: false 
    });
  };

  // Get location name with proper fallbacks
  const getLocationName = () => {
    if (selectedCity) {
      return `${selectedCity.name}${selectedCity.country ? `, ${selectedCity.country}` : ''}`;
    }
    
    if (currentWeather?.location?.name) {
      return `${currentWeather.location.name}${currentWeather.location.country ? `, ${currentWeather.location.country}` : ''}`;
    }
    
    if (locationInfo) {
      return `${locationInfo.name}${locationInfo.country ? `, ${locationInfo.country}` : ''}`;
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
          }
        },
      ]
    );
  };

  const renderFloatingHeader = () => (
    <View style={styles.floatingHeader}>
      <TouchableOpacity onPress={() => navigation.goBack()}>
        <Icon name="arrow-back" size={24} color={AppColors.weatherDark} />
      </TouchableOpacity>
      <Text style={styles.headerTitle}>Weather Details</Text>
      <TouchableOpacity onPress={() => setShowCityModal(true)}>
        <Icon name="location-on" size={24} color={AppColors.weatherDark} />
      </TouchableOpacity>
    </View>
  );

  const renderErrorState = () => (
    <View style={styles.errorContainer}>
      <Icon name="cloud-off" size={64} color={AppColors.errorRed} />
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
        <ImageBackground
          source={{ uri: getWeatherBackground(currentWeather.condition) }}
          style={styles.currentWeatherImage}
          resizeMode="cover"
        >
          <LinearGradient
            colors={['rgba(0,0,0,0.3)', 'rgba(0,0,0,0.7)']}
            style={styles.currentWeatherGradient}
          >
            {/* Location and weather info overlay */}
            <View style={styles.weatherContent}>
              <Text style={styles.locationName}>
                {getLocationName()}
              </Text>
              <Text style={styles.conditionText}>
                {currentWeather.condition?.description?.charAt(0).toUpperCase() +
                 (currentWeather.condition?.description?.slice(1) || 'Unknown')}
              </Text>
              <Text style={styles.lastUpdated}>
                Last updated: {formatTime(currentWeather.timestamp)}
              </Text>
            </View>

            {/* Temperature display */}
            <View style={styles.temperatureSection}>
              <Text style={styles.mainTemperature}>
                {Math.round(currentWeather.temperature || 0)}°
              </Text>
              <View style={styles.temperatureDetails}>
                <Text style={styles.feelsLike}>
                  Feels like {Math.round(currentWeather.feelsLike || 0)}°
                </Text>
                <Text style={styles.tempRange}>
                  H: {Math.round(currentWeather.tempMax || 0)}° L: {Math.round(currentWeather.tempMin || 0)}°
                </Text>
              </View>
            </View>
          </LinearGradient>
        </ImageBackground>
      </View>
    );
  };

  const renderWeatherStats = () => {
    if (!currentWeather) return null;

    const stats = [
      {
        label: 'Humidity',
        value: `${currentWeather.humidity || 0}%`,
        icon: 'water-drop',
        color: AppColors.secondaryGreen,
      },
      {
        label: 'Wind Speed',
        value: `${currentWeather.windSpeed || 0} km/h`,
        icon: 'air',
        color: AppColors.accentOrange,
      },
      {
        label: 'Visibility',
        value: `${currentWeather.visibility || 0} km`,
        icon: 'visibility',
        color: AppColors.primaryGreen,
      },
      {
        label: 'UV Index',
        value: `${currentWeather.uvIndex || 0}`,
        icon: 'wb-sunny',
        color: AppColors.warningOrange,
      },
    ];

    return (
      <View style={styles.statsContainer}>
        <View style={styles.glassCard}>
          <View style={styles.statsGrid}>
            {stats.map((stat, index) => (
              <View key={index} style={styles.statItem}>
                <Icon name={stat.icon} size={20} color={stat.color} />
                <Text style={styles.statValue}>{stat.value}</Text>
                <Text style={styles.statLabel}>{stat.label}</Text>
              </View>
            ))}
          </View>
        </View>
      </View>
    );
  };

  const renderForecastTabs = () => (
    <View style={styles.tabsContainer}>
      <View style={styles.tabs}>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'today' && styles.activeTab]}
          onPress={() => setActiveTab('today')}
        >
          <Text style={[styles.tabText, activeTab === 'today' && styles.activeTabText]}>
            Today
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'tomorrow' && styles.activeTab]}
          onPress={() => setActiveTab('tomorrow')}
        >
          <Text style={[styles.tabText, activeTab === 'tomorrow' && styles.activeTabText]}>
            Tomorrow
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeTab === '7days' && styles.activeTab]}
          onPress={() => setActiveTab('7days')}
        >
          <Text style={[styles.tabText, activeTab === '7days' && styles.activeTabText]}>
            8 Days
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const renderForecastContent = () => {
    let forecastData = [];
    let title = '';
    
    switch (activeTab) {
      case 'today':
        forecastData = getTodayForecast();
        title = 'Today - Hourly Forecast';
        break;
      case 'tomorrow':
        forecastData = getTomorrowForecast();
        title = 'Tomorrow - Hourly Forecast';
        break;
      case '7days':
        forecastData = getWeeklyForecast();
        title = '8-Day Forecast';
        break;
    }

    if (forecastData.length === 0) {
      return (
        <View style={styles.forecastCard}>
          <View style={styles.glassCard}>
            <View style={styles.forecastHeader}>
              <Icon name="schedule" size={20} color={AppColors.weatherDark} />
              <Text style={styles.forecastTitle}>No forecast data available</Text>
            </View>
          </View>
        </View>
      );
    }

    return (
      <View style={styles.forecastCard}>
        <View style={styles.glassCard}>
          <View style={styles.forecastHeader}>
            <Icon name="schedule" size={20} color={AppColors.weatherDark} />
            <Text style={styles.forecastTitle}>{title}</Text>
          </View>

          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            style={styles.forecastScroll}
          >
            {forecastData.map((item, index) => (
              <View key={index} style={styles.forecastItem}>
                <Text style={styles.forecastTime}>
                  {index === 0 && activeTab !== '7days' ? 'Now' :
                   activeTab === '7days' ?
                     item.timestamp?.toLocaleDateString('en-US', { weekday: 'short' }) || 'N/A' :
                     formatHour(item.timestamp)
                  }
                </Text>
                {getWeatherIcon(item.condition, 28)}
                <Text style={styles.forecastTemp}>
                  {activeTab === '7days' && item.temperature?.max !== undefined ?
                    `${Math.round(item.temperature.max)}°` :
                    `${Math.round(item.temperature || 0)}°`
                  }
                </Text>
                {activeTab === '7days' && item.temperature?.min !== undefined && (
                  <Text style={styles.forecastLowTemp}>
                    {Math.round(item.temperature.min)}°
                  </Text>
                )}
                {(activeTab === 'today' || activeTab === 'tomorrow') && item.precipitationProbability && (
                  <Text style={styles.precipitationText}>
                    {item.precipitationProbability}%
                  </Text>
                )}
              </View>
            ))}
          </ScrollView>
        </View>
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
        value: `${currentWeather.windDegree || 0}° ${currentWeather.windDirection || 'N'}`,
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
            <Icon name="analytics" size={20} color={AppColors.weatherDark} />
            <Text style={styles.metricsTitle}>Detailed Metrics</Text>
          </View>

          <View style={styles.metricsGrid}>
            {metrics.map((metric, index) => (
              <View key={index} style={styles.metricItem}>
                <Icon name={metric.icon} size={16} color={AppColors.weatherGray} />
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
            <Icon name="warning" size={20} color={AppColors.errorRed} />
            <Text style={styles.alertTitle}>Weather Alerts</Text>
          </View>
          {forecast.alerts.map((alert, index) => (
            <View key={index} style={styles.alertItem}>
              <Text style={styles.alertEvent}>{alert.event}</Text>
              <Text style={styles.alertDescription} numberOfLines={3}>
                {alert.description}
              </Text>
              <Text style={styles.alertTime}>
                {formatTime(alert.start)} - {formatTime(alert.end)}
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
          <ActivityIndicator size="large" color={AppColors.primaryGreen} />
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
      {/* Full screen background */}
      <ImageBackground
        source={{ uri: getWeatherBackground(currentWeather?.condition) }}
        style={styles.backgroundImage}
        resizeMode="cover"
      >
        <LinearGradient
          colors={['rgba(214, 227, 245, 0.3)', 'rgba(246, 246, 246, 0.8)']}
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
      </ImageBackground>

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
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerTitle: {
    ...Typography.headlineMedium,
    color: AppColors.weatherDark,
    textAlign: 'center',
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
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
    height: 280,
  },
  currentWeatherImage: {
    flex: 1,
    width: '100%',
    height: '100%',
  },
  currentWeatherGradient: {
    flex: 1,
    justifyContent: 'space-between',
    padding: Spacing.xl,
    paddingTop: Spacing.xl,
  },
  weatherContent: {
    alignItems: 'flex-start',
  },
  locationName: {
    ...Typography.headlineLarge,
    fontSize: 28,
    fontWeight: '700',
    color: AppColors.white,
    textShadowColor: 'rgba(0, 0, 0, 0.5)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 3,
  },
  conditionText: {
    ...Typography.bodyLarge,
    color: 'rgba(255, 255, 255, 0.9)',
    marginTop: Spacing.xs,
    fontStyle: 'italic',
    textShadowColor: 'rgba(0, 0, 0, 0.5)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 3,
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
  },
  statCard: {
    flex: 1,
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
    marginBottom: Spacing.xs,
    color: AppColors.weatherGray,
  },
  statValue: {
    ...Typography.labelLarge,
    color: AppColors.weatherDark,
  },
  tabsContainer: {
    marginHorizontal: Spacing.lg,
    marginBottom: Spacing.lg,
  },
  tabs: {
    flexDirection: 'row',
    backgroundColor: 'rgba(255, 255, 255, 0.25)',
    borderRadius: BorderRadius.large,
    padding: 4,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.3)',
  },
  tab: {
    flex: 1,
    paddingVertical: Spacing.md,
    alignItems: 'center',
    borderRadius: BorderRadius.medium,
  },
  activeTab: {
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
    elevation: 2,
    shadowColor: AppColors.shadowColor,
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  tabText: {
    ...Typography.labelMedium,
    color: AppColors.weatherGray,
  },
  activeTabText: {
    color: AppColors.weatherDark,
    fontWeight: '600',
  },
  forecastCard: {
    marginHorizontal: Spacing.lg,
    marginBottom: Spacing.xl,
  },
  forecastHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.lg,
  },
  forecastTitle: {
    ...Typography.headlineSmall,
    marginLeft: Spacing.sm,
    color: AppColors.weatherDark,
  },
  forecastScroll: {
    marginBottom: Spacing.sm,
  },
  forecastItem: {
    alignItems: 'center',
    marginRight: Spacing.lg,
    width: 60,
  },
  forecastTime: {
    ...Typography.bodySmall,
    marginBottom: Spacing.sm,
    color: AppColors.weatherGray,
  },
  forecastTemp: {
    ...Typography.labelMedium,
    marginTop: Spacing.sm,
    color: AppColors.weatherDark,
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