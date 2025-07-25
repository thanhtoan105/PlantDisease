import { createStackNavigator } from '@react-navigation/stack';
import { ActivityIndicator, View, StyleSheet } from 'react-native';
import { useAuth } from '../context/AuthContext';
import { AppColors } from '../theme';

// Screens
import OnboardingScreen from '../screens/OnboardingScreen';
import AuthScreen from '../screens/AuthScreen';
import MainNavigator from './MainNavigator';

const Stack = createStackNavigator();

const AppNavigator = () => {
	const { isLoading, isAuthenticated, isGuestMode, onboardingCompleted } =
		useAuth();

	// Show loading screen while checking auth state
	if (isLoading) {
		return (
			<View style={styles.loadingContainer}>
				<ActivityIndicator size='large' color={AppColors.primaryGreen} />
			</View>
		);
	}

	return (
		<Stack.Navigator screenOptions={{ headerShown: false }}>
			{!onboardingCompleted ? (
				// Show onboarding and auth screens if not completed
				<>
					<Stack.Screen name='Onboarding' component={OnboardingScreen} />
					<Stack.Screen name='Auth' component={AuthScreen} />
					<Stack.Screen name='Main' component={MainNavigator} />
				</>
			) : !isAuthenticated && !isGuestMode ? (
				// Show auth screen directly if onboarding completed but not authenticated (e.g., after logout)
				<>
					<Stack.Screen name='Auth' component={AuthScreen} />
					<Stack.Screen name='Main' component={MainNavigator} />
				</>
			) : (
				// Show main app if authenticated or in guest mode
				<Stack.Screen name='Main' component={MainNavigator} />
			)}
		</Stack.Navigator>
	);
};

const styles = StyleSheet.create({
	loadingContainer: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: AppColors.white,
	},
});

export default AppNavigator;
