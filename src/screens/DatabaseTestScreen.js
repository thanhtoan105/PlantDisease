import React, { useState, useEffect } from 'react';
import {
	View,
	Text,
	StyleSheet,
	ScrollView,
	TouchableOpacity,
	Alert,
	ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import Icon from 'react-native-vector-icons/Ionicons';
import SupabaseService from '../services/SupabaseService';
import DatabaseService from '../services/DatabaseService';
import AuthService from '../services/AuthService';
import { AppColors, Spacing, BorderRadius, Typography } from '../theme';
import { useAuth } from '../context/AuthContext';

const DatabaseTestScreen = ({ navigation }) => {
	const { user, isAuthenticated } = useAuth();
	const [isLoading, setIsLoading] = useState(false);
	const [testResults, setTestResults] = useState([]);

	useEffect(() => {
		runAllTests();
	}, []);

	const addTestResult = (testName, success, message, data = null) => {
		setTestResults((prev) => [
			...prev,
			{
				testName,
				success,
				message,
				data,
				timestamp: new Date().toLocaleTimeString(),
			},
		]);
	};

	const runAllTests = async () => {
		setIsLoading(true);
		setTestResults([]);

		// Test 1: Supabase Configuration
		addTestResult(
			'Supabase Configuration',
			SupabaseService.isConfigured(),
			SupabaseService.isConfigured()
				? 'Supabase is properly configured'
				: 'Supabase configuration missing',
		);

		if (!SupabaseService.isConfigured()) {
			setIsLoading(false);
			return;
		}

		// Test 2: Database Connection
		const connectionResult = await SupabaseService.testConnection();
		addTestResult(
			'Database Connection',
			connectionResult.success,
			connectionResult.success
				? connectionResult.message
				: connectionResult.error,
		);

		if (!connectionResult.success) {
			setIsLoading(false);
			return;
		}

		// Test 3: Authentication Status
		const authResult = await AuthService.getCurrentUser();
		addTestResult(
			'Authentication Status',
			authResult.success,
			authResult.success
				? `User authenticated: ${authResult.user?.email || 'No email'}`
				: 'User not authenticated',
		);

		// Test 4: Fetch Crops
		const cropsResult = await DatabaseService.getAllCrops();
		addTestResult(
			'Fetch Crops',
			cropsResult.success,
			cropsResult.success
				? `Found ${cropsResult.data.length} crops`
				: cropsResult.error,
			cropsResult.data,
		);

		// Test 5: Fetch Diseases
		const diseasesResult = await DatabaseService.getAllDiseases();
		addTestResult(
			'Fetch Diseases',
			diseasesResult.success,
			diseasesResult.success
				? `Found ${diseasesResult.data.length} diseases`
				: diseasesResult.error,
			diseasesResult.data,
		);

		// Test 6: User Profile (if authenticated)
		if (isAuthenticated && user) {
			const profileResult = await AuthService.getUserProfile(user.id);
			addTestResult(
				'User Profile',
				profileResult.success,
				profileResult.success
					? `Profile loaded: ${
							profileResult.profile?.username || 'No username'
					  }`
					: profileResult.error,
				profileResult.profile,
			);
		}

		setIsLoading(false);
	};

	const getStatusIcon = (success) => {
		return success ? (
			<Icon name='checkmark-circle' size={24} color={AppColors.successGreen} />
		) : (
			<Icon name='close-circle' size={24} color={AppColors.errorRed} />
		);
	};

	const renderTestResult = (result, index) => (
		<View key={index} style={styles.testResultContainer}>
			<View style={styles.testResultHeader}>
				{getStatusIcon(result.success)}
				<View style={styles.testResultInfo}>
					<Text style={styles.testResultName}>{result.testName}</Text>
					<Text style={styles.testResultTime}>{result.timestamp}</Text>
				</View>
			</View>

			<Text
				style={[
					styles.testResultMessage,
					{
						color: result.success ? AppColors.successGreen : AppColors.errorRed,
					},
				]}
			>
				{result.message}
			</Text>

			{result.data && (
				<TouchableOpacity
					style={styles.viewDataButton}
					onPress={() => {
						Alert.alert('Test Data', JSON.stringify(result.data, null, 2), [
							{ text: 'OK' },
						]);
					}}
				>
					<Text style={styles.viewDataButtonText}>View Data</Text>
				</TouchableOpacity>
			)}
		</View>
	);

	return (
		<SafeAreaView style={styles.container}>
			<View style={styles.header}>
				<TouchableOpacity
					style={styles.backButton}
					onPress={() => navigation.goBack()}
				>
					<Icon name='arrow-back' size={24} color={AppColors.darkGray} />
				</TouchableOpacity>
				<Text style={styles.title}>Database Test</Text>
				<TouchableOpacity
					style={styles.refreshButton}
					onPress={runAllTests}
					disabled={isLoading}
				>
					<Icon
						name='refresh'
						size={24}
						color={isLoading ? AppColors.mediumGray : AppColors.primaryGreen}
					/>
				</TouchableOpacity>
			</View>

			<ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
				{/* Status Overview */}
				<View style={styles.overviewContainer}>
					<Text style={styles.overviewTitle}>Test Overview</Text>
					<View style={styles.overviewStats}>
						<View style={styles.statItem}>
							<Text style={styles.statNumber}>
								{testResults.filter((r) => r.success).length}
							</Text>
							<Text style={styles.statLabel}>Passed</Text>
						</View>
						<View style={styles.statItem}>
							<Text style={[styles.statNumber, { color: AppColors.errorRed }]}>
								{testResults.filter((r) => !r.success).length}
							</Text>
							<Text style={styles.statLabel}>Failed</Text>
						</View>
						<View style={styles.statItem}>
							<Text style={styles.statNumber}>{testResults.length}</Text>
							<Text style={styles.statLabel}>Total</Text>
						</View>
					</View>
				</View>

				{/* Loading Indicator */}
				{isLoading && (
					<View style={styles.loadingContainer}>
						<ActivityIndicator size='large' color={AppColors.primaryGreen} />
						<Text style={styles.loadingText}>Running database tests...</Text>
					</View>
				)}

				{/* Test Results */}
				<View style={styles.resultsContainer}>
					<Text style={styles.resultsTitle}>Test Results</Text>
					{testResults.map((result, index) => renderTestResult(result, index))}
				</View>

				{/* User Info */}
				{isAuthenticated && (
					<View style={styles.userInfoContainer}>
						<Text style={styles.userInfoTitle}>Current User</Text>
						<Text style={styles.userInfoText}>
							Email: {user?.email || 'N/A'}
						</Text>
						<Text style={styles.userInfoText}>ID: {user?.id || 'N/A'}</Text>
						<Text style={styles.userInfoText}>
							Created:{' '}
							{user?.created_at
								? new Date(user.created_at).toLocaleDateString()
								: 'N/A'}
						</Text>
					</View>
				)}

				{/* Instructions */}
				<View style={styles.instructionsContainer}>
					<Text style={styles.instructionsTitle}>Troubleshooting</Text>
					<Text style={styles.instructionsText}>
						• If Supabase Configuration fails: Check your .env file{'\n'}• If
						Database Connection fails: Verify your Supabase URL and key{'\n'}•
						If Fetch operations fail: Run the SQL setup script in Supabase{'\n'}
						• If Authentication fails: Try signing in again
					</Text>
				</View>
			</ScrollView>
		</SafeAreaView>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: AppColors.white,
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
	backButton: {
		padding: Spacing.xs,
	},
	title: {
		fontSize: 20,
		fontWeight: 'bold',
		color: AppColors.darkGray,
	},
	refreshButton: {
		padding: Spacing.xs,
	},
	content: {
		flex: 1,
		paddingHorizontal: Spacing.lg,
	},
	overviewContainer: {
		backgroundColor: AppColors.lightGray,
		borderRadius: BorderRadius.medium,
		padding: Spacing.lg,
		marginVertical: Spacing.md,
	},
	overviewTitle: {
		fontSize: 18,
		fontWeight: '600',
		color: AppColors.darkGray,
		marginBottom: Spacing.md,
	},
	overviewStats: {
		flexDirection: 'row',
		justifyContent: 'space-around',
	},
	statItem: {
		alignItems: 'center',
	},
	statNumber: {
		fontSize: 24,
		fontWeight: 'bold',
		color: AppColors.successGreen,
	},
	statLabel: {
		fontSize: 14,
		color: AppColors.mediumGray,
		marginTop: 4,
	},
	loadingContainer: {
		alignItems: 'center',
		paddingVertical: Spacing.xl,
	},
	loadingText: {
		fontSize: 16,
		color: AppColors.mediumGray,
		marginTop: Spacing.md,
	},
	resultsContainer: {
		marginVertical: Spacing.md,
	},
	resultsTitle: {
		fontSize: 18,
		fontWeight: '600',
		color: AppColors.darkGray,
		marginBottom: Spacing.md,
	},
	testResultContainer: {
		backgroundColor: AppColors.lightGray,
		borderRadius: BorderRadius.medium,
		padding: Spacing.md,
		marginBottom: Spacing.sm,
	},
	testResultHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.sm,
	},
	testResultInfo: {
		marginLeft: Spacing.sm,
		flex: 1,
	},
	testResultName: {
		fontSize: 16,
		fontWeight: '600',
		color: AppColors.darkGray,
	},
	testResultTime: {
		fontSize: 14,
		color: AppColors.mediumGray,
	},
	testResultMessage: {
		fontSize: 14,
		marginBottom: Spacing.xs,
	},
	viewDataButton: {
		alignSelf: 'flex-start',
		paddingHorizontal: Spacing.sm,
		paddingVertical: Spacing.xs,
		backgroundColor: AppColors.primaryGreen,
		borderRadius: BorderRadius.small,
	},
	viewDataButtonText: {
		color: 'white',
		fontSize: 14,
		fontWeight: '500',
	},
	userInfoContainer: {
		backgroundColor: AppColors.lightGray,
		borderRadius: BorderRadius.medium,
		padding: Spacing.lg,
		marginVertical: Spacing.md,
	},
	userInfoTitle: {
		fontSize: 18,
		fontWeight: '600',
		color: AppColors.darkGray,
		marginBottom: Spacing.md,
	},
	userInfoText: {
		fontSize: 14,
		color: AppColors.mediumGray,
		marginBottom: Spacing.xs,
	},
	instructionsContainer: {
		backgroundColor: AppColors.lightGray,
		borderRadius: BorderRadius.medium,
		padding: Spacing.lg,
		marginVertical: Spacing.md,
		marginBottom: Spacing.xl,
	},
	instructionsTitle: {
		fontSize: 18,
		fontWeight: '600',
		color: AppColors.darkGray,
		marginBottom: Spacing.md,
	},
	instructionsText: {
		fontSize: 14,
		color: AppColors.mediumGray,
		lineHeight: 20,
	},
});

export default DatabaseTestScreen;
