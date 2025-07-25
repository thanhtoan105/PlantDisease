import axios from 'axios';
import { WEATHER_API_KEY, WEATHER_API_BASE_URL } from '@env';

// ✅ Use environment variables instead of hardcoded API keys
const API_KEY = WEATHER_API_KEY;
const BASE_URL_3_0 =
	WEATHER_API_BASE_URL || 'https://api.openweathermap.org/data/3.0';
const BASE_URL_2_5 = 'https://api.openweathermap.org/data/2.5';
const GEO_URL = 'https://api.openweathermap.org/geo/1.0';

// Add error checking for required environment variables
if (!API_KEY) {
	throw new Error(
		'❌ WEATHER_API_KEY is required!\n' +
			'📝 Please create a .env file in the root directory with your OpenWeather API key.\n' +
			'🔗 Get your free API key from: https://openweathermap.org/api\n' +
			'📄 Check the README.md for detailed setup instructions.',
	);
}

class WeatherApiService {
	/**
	 * Get current weather and forecasts using One Call API 3.0
	 * Includes minute (1h), hourly (48h), daily (8 days) forecasts + alerts
	 */
	static async getCurrentWeatherAndForecasts(
		latitude,
		longitude,
		exclude = null,
	) {
		try {
			const params = {
				lat: latitude,
				lon: longitude,
				appid: API_KEY,
				units: 'metric',
			};

			// Add exclude parameter if provided (current, minutely, hourly, daily, alerts)
			if (exclude) {
				params.exclude = exclude;
			}

			const response = await axios.get(`${BASE_URL_3_0}/onecall`, {
				params,
			});

			return {
				success: true,
				data: this.transformOneCallData(response.data),
			};
		} catch (error) {
			console.error('One Call API 3.0 Error:', error);
			return {
				success: false,
				error: error.response?.data?.message || 'Failed to fetch weather data',
			};
		}
	}

	/**
	 * Get AI-generated weather overview summary (One Call API 3.0 feature)
	 */
	static async getWeatherOverview(latitude, longitude, date = null) {
		try {
			const params = {
				lat: latitude,
				lon: longitude,
				appid: API_KEY,
				units: 'metric',
			};

			if (date) {
				params.date = date; // YYYY-MM-DD format
			}

			const response = await axios.get(`${BASE_URL_3_0}/onecall/overview`, {
				params,
			});

			return {
				success: true,
				data: response.data,
			};
		} catch (error) {
			console.error('Weather Overview API Error:', error);
			return {
				success: false,
				error:
					error.response?.data?.message || 'Failed to fetch weather overview',
			};
		}
	}

	/**
	 * Get historical weather data for any timestamp (One Call API 3.0)
	 * Available from 1979-01-01 to 4 days ahead
	 */
	static async getHistoricalWeather(latitude, longitude, timestamp) {
		try {
			const response = await axios.get(`${BASE_URL_3_0}/onecall/timemachine`, {
				params: {
					lat: latitude,
					lon: longitude,
					dt: timestamp, // Unix timestamp
					appid: API_KEY,
					units: 'metric',
				},
			});

			return {
				success: true,
				data: response.data,
			};
		} catch (error) {
			console.error('Historical Weather API Error:', error);
			return {
				success: false,
				error:
					error.response?.data?.message ||
					'Failed to fetch historical weather data',
			};
		}
	}

	/**
	 * Get daily weather aggregation (One Call API 3.0)
	 * Available from 1979-01-02 to 1.5 years ahead
	 */
	static async getDailyAggregation(latitude, longitude, date, timezone = null) {
		try {
			const params = {
				lat: latitude,
				lon: longitude,
				date: date, // YYYY-MM-DD format
				appid: API_KEY,
				units: 'metric',
			};

			if (timezone) {
				params.tz = timezone; // ±XX:XX format
			}

			const response = await axios.get(`${BASE_URL_3_0}/onecall/day_summary`, {
				params,
			});

			return {
				success: true,
				data: response.data,
			};
		} catch (error) {
			console.error('Daily Aggregation API Error:', error);
			return {
				success: false,
				error:
					error.response?.data?.message ||
					'Failed to fetch daily aggregation data',
			};
		}
	}

	/**
	 * Legacy method - Get current weather by coordinates (2.5 API for compatibility)
	 */
	static async getCurrentWeather(latitude, longitude) {
		try {
			// First try to use 3.0 API
			const result = await this.getCurrentWeatherAndForecasts(
				latitude,
				longitude,
				'minutely,hourly,daily,alerts',
			);
			if (result.success && result.data.current) {
				return {
					success: true,
					data: result.data.current,
				};
			}

			// Fallback to 2.5 API if needed
			const response = await axios.get(`${BASE_URL_2_5}/weather`, {
				params: {
					lat: latitude,
					lon: longitude,
					appid: API_KEY,
					units: 'metric',
				},
			});

			return {
				success: true,
				data: this.transformWeatherData(response.data),
			};
		} catch (error) {
			console.error('Weather API Error:', error);
			return {
				success: false,
				error: error.response?.data?.message || 'Failed to fetch weather data',
			};
		}
	}

	/**
	 * Get 5-day weather forecast (2.5 API for compatibility)
	 */
	static async getWeatherForecast(latitude, longitude) {
		try {
			// Try 3.0 API first
			const result = await this.getCurrentWeatherAndForecasts(
				latitude,
				longitude,
				'current,minutely,alerts',
			);
			if (result.success && result.data.hourly) {
				return {
					success: true,
					data: {
						city: {
							name: result.data.location?.name || 'Unknown',
							country: result.data.location?.country || '',
							coordinates: {
								latitude: result.data.lat,
								longitude: result.data.lon,
							},
						},
						list: result.data.hourly.slice(0, 40), // 5 days * 8 (3-hour intervals)
					},
				};
			}

			// Fallback to 2.5 API
			const response = await axios.get(`${BASE_URL_2_5}/forecast`, {
				params: {
					lat: latitude,
					lon: longitude,
					appid: API_KEY,
					units: 'metric',
				},
			});

			return {
				success: true,
				data: this.transformForecastData(response.data),
			};
		} catch (error) {
			console.error('Forecast API Error:', error);
			return {
				success: false,
				error: error.response?.data?.message || 'Failed to fetch forecast data',
			};
		}
	}

	/**
	 * Search cities by name (using Geocoding API)
	 */
	static async searchCities(query) {
		try {
			if (!query || query.trim().length === 0) {
				return {
					success: true,
					data: [],
				};
			}

			const response = await axios.get(`${GEO_URL}/direct`, {
				params: {
					q: query.trim(),
					limit: 5,
					appid: API_KEY,
				},
			});

			const cities = Array.isArray(response.data) ? response.data : [];

			return {
				success: true,
				data: cities.map((city) => ({
					name: city.name,
					country: city.country,
					state: city.state || '',
					latitude: city.lat,
					longitude: city.lon,
				})),
			};
		} catch (error) {
			console.error('City search error:', error);
			return {
				success: false,
				error: error.response?.data?.message || 'Failed to search cities',
			};
		}
	}

	/**
	 * Get weather for specific city
	 */
	static async getWeatherForCity(latitude, longitude) {
		return this.getCurrentWeather(latitude, longitude);
	}

	/**
	 * Get location name from coordinates (reverse geocoding)
	 */
	static async getLocationFromCoordinates(latitude, longitude) {
		try {
			const response = await axios.get(`${GEO_URL}/reverse`, {
				params: {
					lat: latitude,
					lon: longitude,
					limit: 1,
					appid: API_KEY,
				},
			});

			if (response.data.length > 0) {
				const location = response.data[0];
				return {
					success: true,
					data: {
						name: location.name,
						country: location.country,
						state: location.state || '',
						latitude: location.lat,
						longitude: location.lon,
					},
				};
			} else {
				return {
					success: false,
					error: 'Location not found',
				};
			}
		} catch (error) {
			console.error('Reverse geocoding error:', error);
			return {
				success: false,
				error: 'Failed to get location name',
			};
		}
	}

	/**
	 * Transform One Call API 3.0 data to app format
	 */
	static transformOneCallData(data) {
		const result = {
			lat: data.lat,
			lon: data.lon,
			timezone: data.timezone,
			timezone_offset: data.timezone_offset,
		};

		// Current weather
		if (data.current) {
			result.current = {
				temperature: Math.round(data.current.temp),
				feelsLike: Math.round(data.current.feels_like),
				humidity: data.current.humidity,
				pressure: data.current.pressure,
				visibility: Math.round(data.current.visibility / 1000), // Convert to km
				windSpeed: Math.round(data.current.wind_speed * 3.6), // Convert to km/h
				windDegree: data.current.wind_deg || 0,
				windDirection: this.getWindDirection(data.current.wind_deg || 0),
				cloudiness: data.current.clouds,
				uvIndex: data.current.uvi,
				condition: {
					main: data.current.weather[0].main,
					description: data.current.weather[0].description,
					icon: data.current.weather[0].icon,
				},
				sunrise: new Date(data.current.sunrise * 1000),
				sunset: new Date(data.current.sunset * 1000),
				timestamp: new Date(data.current.dt * 1000),
			};

			if (data.current.dew_point) {
				result.current.dewPoint = Math.round(data.current.dew_point);
			}
		}

		// Minutely forecast (1 hour)
		if (data.minutely) {
			result.minutely = data.minutely.map((item) => ({
				timestamp: new Date(item.dt * 1000),
				precipitation: item.precipitation,
			}));
		}

		// Hourly forecast (48 hours)
		if (data.hourly) {
			result.hourly = data.hourly.map((item) => ({
				temperature: Math.round(item.temp),
				feelsLike: Math.round(item.feels_like),
				humidity: item.humidity,
				pressure: item.pressure,
				windSpeed: Math.round(item.wind_speed * 3.6),
				windDegree: item.wind_deg || 0,
				cloudiness: item.clouds,
				uvIndex: item.uvi,
				condition: {
					main: item.weather[0].main,
					description: item.weather[0].description,
					icon: item.weather[0].icon,
				},
				precipitationProbability: Math.round(item.pop * 100),
				timestamp: new Date(item.dt * 1000),
				visibility: item.visibility ? Math.round(item.visibility / 1000) : null,
			}));
		}

		// Daily forecast (8 days)
		if (data.daily) {
			result.daily = data.daily.map((item) => ({
				temperature: {
					min: Math.round(item.temp.min),
					max: Math.round(item.temp.max),
					morning: Math.round(item.temp.morn),
					day: Math.round(item.temp.day),
					evening: Math.round(item.temp.eve),
					night: Math.round(item.temp.night),
				},
				feelsLike: {
					morning: Math.round(item.feels_like.morn),
					day: Math.round(item.feels_like.day),
					evening: Math.round(item.feels_like.eve),
					night: Math.round(item.feels_like.night),
				},
				humidity: item.humidity,
				pressure: item.pressure,
				windSpeed: Math.round(item.wind_speed * 3.6),
				windDegree: item.wind_deg || 0,
				cloudiness: item.clouds,
				uvIndex: item.uvi,
				condition: {
					main: item.weather[0].main,
					description: item.weather[0].description,
					icon: item.weather[0].icon,
				},
				precipitationProbability: Math.round(item.pop * 100),
				summary: item.summary || '', // AI-generated summary in 3.0
				sunrise: new Date(item.sunrise * 1000),
				sunset: new Date(item.sunset * 1000),
				moonPhase: item.moon_phase,
				timestamp: new Date(item.dt * 1000),
			}));
		}

		// Weather alerts
		if (data.alerts) {
			result.alerts = data.alerts.map((alert) => ({
				senderName: alert.sender_name,
				event: alert.event,
				description: alert.description,
				start: new Date(alert.start * 1000),
				end: new Date(alert.end * 1000),
				tags: alert.tags || [],
			}));
		}

		return result;
	}

	/**
	 * Transform raw weather data to app format (for 2.5 API compatibility)
	 */
	static transformWeatherData(data) {
		return {
			temperature: Math.round(data.main.temp),
			feelsLike: Math.round(data.main.feels_like),
			tempMin: Math.round(data.main.temp_min),
			tempMax: Math.round(data.main.temp_max),
			humidity: data.main.humidity,
			pressure: data.main.pressure,
			visibility: Math.round(data.visibility / 1000), // Convert to km
			windSpeed: Math.round(data.wind.speed * 3.6), // Convert to km/h
			windDegree: data.wind.deg || 0,
			windDirection: this.getWindDirection(data.wind.deg || 0),
			cloudiness: data.clouds.all,
			condition: {
				main: data.weather[0].main,
				description: data.weather[0].description,
				icon: data.weather[0].icon,
			},
			location: {
				name: data.name,
				country: data.sys.country,
				coordinates: {
					latitude: data.coord.lat,
					longitude: data.coord.lon,
				},
			},
			sunrise: new Date(data.sys.sunrise * 1000),
			sunset: new Date(data.sys.sunset * 1000),
			timestamp: new Date(data.dt * 1000),
		};
	}

	/**
	 * Transform forecast data (for 2.5 API compatibility)
	 */
	static transformForecastData(data) {
		return {
			city: {
				name: data.city.name,
				country: data.city.country,
				coordinates: {
					latitude: data.city.coord.lat,
					longitude: data.city.coord.lon,
				},
			},
			list: data.list.map((item) => ({
				temperature: Math.round(item.main.temp),
				tempMin: Math.round(item.main.temp_min),
				tempMax: Math.round(item.main.temp_max),
				humidity: item.main.humidity,
				condition: {
					main: item.weather[0].main,
					description: item.weather[0].description,
					icon: item.weather[0].icon,
				},
				windSpeed: Math.round(item.wind.speed * 3.6),
				timestamp: new Date(item.dt * 1000),
				dateText: item.dt_txt,
			})),
		};
	}

	/**
	 * Get wind direction from degrees
	 */
	static getWindDirection(degree) {
		const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
		const index = Math.round(degree / 45) % 8;
		return directions[index];
	}

	/**
	 * Get weather icon based on condition
	 */
	static getWeatherIcon(condition, isDay = true) {
		switch (condition.toLowerCase()) {
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
	}
}

export default WeatherApiService;
export { WeatherApiService };
