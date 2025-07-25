import React, { useState, useEffect } from 'react';
import {
	View,
	Text,
	StyleSheet,
	ScrollView,
	TouchableOpacity,
	Alert,
	ActivityIndicator,
	Linking,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import Icon from 'react-native-vector-icons/Ionicons';
import SupabaseService from '../services/SupabaseService';
import DatabaseService from '../services/DatabaseService';
import { AppColors, Spacing, BorderRadius, Typography } from '../theme';

const DatabaseSetupScreen = ({ navigation }) => {
	const [isLoading, setIsLoading] = useState(false);
	const [setupStatus, setSetupStatus] = useState({
		configured: false,
		connected: false,
		schemaInitialized: false,
		dataInserted: false,
	});
	const [logs, setLogs] = useState([]);

	useEffect(() => {
		checkInitialStatus();
	}, []);

	const addLog = (message, type = 'info') => {
		const timestamp = new Date().toLocaleTimeString();
		setLogs((prev) => [...prev, { message, type, timestamp }]);
	};

	const checkInitialStatus = async () => {
		setIsLoading(true);
		addLog('Checking Supabase configuration...', 'info');

		const configured = SupabaseService.isConfigured();
		setSetupStatus((prev) => ({ ...prev, configured }));

		if (configured) {
			addLog('✅ Supabase is configured', 'success');
			await testConnection();
		} else {
			addLog(
				'❌ Supabase not configured. Please check environment variables.',
				'error',
			);
		}

		setIsLoading(false);
	};

	const testConnection = async () => {
		addLog('Testing database connection...', 'info');
		const result = await SupabaseService.testConnection();

		if (result.success) {
			addLog('✅ Database connection successful', 'success');
			setSetupStatus((prev) => ({ ...prev, connected: true }));
			await checkExistingData();
		} else {
			addLog(`❌ Connection failed: ${result.error}`, 'error');
			setSetupStatus((prev) => ({ ...prev, connected: false }));
		}
	};

	const checkExistingData = async () => {
		addLog('Checking existing data...', 'info');

		try {
			const cropsResult = await DatabaseService.getAllCrops();
			const diseasesResult = await DatabaseService.getAllDiseases();

			if (cropsResult.success && diseasesResult.success) {
				const hasData =
					cropsResult.data.length > 0 && diseasesResult.data.length > 0;
				setSetupStatus((prev) => ({
					...prev,
					schemaInitialized: true,
					dataInserted: hasData,
				}));

				if (hasData) {
					addLog(
						`✅ Found ${cropsResult.data.length} crops and ${diseasesResult.data.length} diseases`,
						'success',
					);
				} else {
					addLog('⚠️ Tables exist but no data found', 'warning');
				}
			}
		} catch (error) {
			addLog('⚠️ Tables may not exist yet', 'warning');
		}
	};

	const initializeDatabase = async () => {
		setIsLoading(true);
		addLog('Starting database initialization...', 'info');

		try {
			// Step 1: Initialize schema
			addLog('Creating database tables...', 'info');
			const schemaResult = await SupabaseService.initializeSchema();

			if (schemaResult.success) {
				addLog('✅ Database schema created successfully', 'success');
				setSetupStatus((prev) => ({ ...prev, schemaInitialized: true }));
			} else {
				throw new Error(schemaResult.error);
			}

			// Step 2: Insert initial data
			addLog('Inserting initial data...', 'info');
			const dataResult = await SupabaseService.insertInitialData();

			if (dataResult.success) {
				addLog('✅ Initial data inserted successfully', 'success');
				setSetupStatus((prev) => ({ ...prev, dataInserted: true }));
				addLog('🎉 Database setup completed!', 'success');
			} else {
				throw new Error(dataResult.error);
			}
		} catch (error) {
			addLog(`❌ Setup failed: ${error.message}`, 'error');
			Alert.alert('Setup Failed', error.message);
		}

		setIsLoading(false);
	};

	const openSupabaseDashboard = () => {
		Linking.openURL('https://supabase.com/dashboard');
	};

	const getStatusIcon = (status) => {
		if (status)
			return (
				<Icon
					name='checkmark-circle'
					size={24}
					color={AppColors.successGreen}
				/>
			);
		return <Icon name='close-circle' size={24} color={AppColors.errorRed} />;
	};

	const getLogIcon = (type) => {
		switch (type) {
			case 'success':
				return (
					<Icon
						name='checkmark-circle'
						size={16}
						color={AppColors.successGreen}
					/>
				);
			case 'error':
				return (
					<Icon name='close-circle' size={16} color={AppColors.errorRed} />
				);
			case 'warning':
				return (
					<Icon name='warning' size={16} color={AppColors.warningOrange} />
				);
			default:
				return (
					<Icon
						name='information-circle'
						size={16}
						color={AppColors.primaryGreen}
					/>
				);
		}
	};

	return (
		<SafeAreaView style={styles.container}>
			<View style={styles.header}>
				<TouchableOpacity
					style={styles.backButton}
					onPress={() => navigation.goBack()}
				>
					<Icon name='arrow-back' size={24} color={AppColors.darkNavy} />
				</TouchableOpacity>
				<Text style={styles.title}>Database Setup</Text>
			</View>

			<ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
				{/* Configuration Status */}
				<View style={styles.section}>
					<Text style={styles.sectionTitle}>Configuration Status</Text>

					<View style={styles.statusItem}>
						{getStatusIcon(setupStatus.configured)}
						<Text style={styles.statusText}>Supabase Configured</Text>
					</View>

					<View style={styles.statusItem}>
						{getStatusIcon(setupStatus.connected)}
						<Text style={styles.statusText}>Database Connected</Text>
					</View>

					<View style={styles.statusItem}>
						{getStatusIcon(setupStatus.schemaInitialized)}
						<Text style={styles.statusText}>Schema Initialized</Text>
					</View>

					<View style={styles.statusItem}>
						{getStatusIcon(setupStatus.dataInserted)}
						<Text style={styles.statusText}>Initial Data Loaded</Text>
					</View>
				</View>

				{/* Setup Instructions */}
				{!setupStatus.configured && (
					<View style={styles.section}>
						<Text style={styles.sectionTitle}>Setup Instructions</Text>
						<Text style={styles.instructionText}>
							1. Create a new project at Supabase Dashboard
						</Text>
						<TouchableOpacity
							style={styles.linkButton}
							onPress={openSupabaseDashboard}
						>
							<Text style={styles.linkText}>Open Supabase Dashboard</Text>
							<Icon
								name='open-outline'
								size={16}
								color={AppColors.primaryGreen}
							/>
						</TouchableOpacity>

						<Text style={styles.instructionText}>
							2. Copy your project URL and anon key from Settings → API
						</Text>

						<Text style={styles.instructionText}>
							3. Update your .env file with:
						</Text>
						<View style={styles.codeBlock}>
							<Text style={styles.codeText}>
								EXPO_PUBLIC_SUPABASE_URL=your_project_url
							</Text>
							<Text style={styles.codeText}>
								EXPO_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
							</Text>
						</View>

						<Text style={styles.instructionText}>
							4. Restart the app and return to this screen
						</Text>
					</View>
				)}

				{/* Action Buttons */}
				{setupStatus.configured && (
					<View style={styles.section}>
						<TouchableOpacity
							style={[styles.button, styles.primaryButton]}
							onPress={checkInitialStatus}
							disabled={isLoading}
						>
							<Text style={styles.buttonText}>Refresh Status</Text>
						</TouchableOpacity>

						{setupStatus.connected && !setupStatus.dataInserted && (
							<TouchableOpacity
								style={[styles.button, styles.successButton]}
								onPress={initializeDatabase}
								disabled={isLoading}
							>
								{isLoading ? (
									<ActivityIndicator color='white' />
								) : (
									<Text style={styles.buttonText}>Initialize Database</Text>
								)}
							</TouchableOpacity>
						)}
					</View>
				)}

				{/* Logs */}
				<View style={styles.section}>
					<Text style={styles.sectionTitle}>Setup Logs</Text>
					<View style={styles.logsContainer}>
						{logs.map((log, index) => (
							<View key={index} style={styles.logItem}>
								{getLogIcon(log.type)}
								<Text style={styles.logTime}>{log.timestamp}</Text>
								<Text
									style={[styles.logMessage, { color: AppColors.darkNavy }]}
								>
									{log.message}
								</Text>
							</View>
						))}
					</View>
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
		paddingHorizontal: Spacing.lg,
		paddingVertical: Spacing.md,
		borderBottomWidth: 1,
		borderBottomColor: AppColors.lightGray,
	},
	backButton: {
		marginRight: Spacing.md,
	},
	title: {
		fontSize: 20,
		fontWeight: 'bold',
		color: AppColors.darkNavy,
	},
	content: {
		flex: 1,
		paddingHorizontal: Spacing.lg,
	},
	section: {
		marginVertical: Spacing.lg,
	},
	sectionTitle: {
		fontSize: 18,
		fontWeight: '600',
		color: AppColors.darkNavy,
		marginBottom: Spacing.md,
	},
	statusItem: {
		flexDirection: 'row',
		alignItems: 'center',
		paddingVertical: Spacing.sm,
	},
	statusText: {
		fontSize: 16,
		color: AppColors.darkNavy,
		marginLeft: Spacing.sm,
	},
	instructionText: {
		fontSize: 16,
		color: AppColors.mediumGray,
		marginBottom: Spacing.sm,
		lineHeight: 22,
	},
	linkButton: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.md,
	},
	linkText: {
		fontSize: 16,
		color: AppColors.primaryGreen,
		marginRight: Spacing.xs,
	},
	codeBlock: {
		backgroundColor: AppColors.lightGray,
		padding: Spacing.md,
		borderRadius: BorderRadius.medium,
		marginBottom: Spacing.md,
	},
	codeText: {
		fontFamily: 'monospace',
		fontSize: 14,
		color: AppColors.darkNavy,
	},
	button: {
		paddingVertical: Spacing.md,
		paddingHorizontal: Spacing.lg,
		borderRadius: BorderRadius.medium,
		alignItems: 'center',
		marginBottom: Spacing.md,
	},
	primaryButton: {
		backgroundColor: AppColors.primaryGreen,
	},
	successButton: {
		backgroundColor: AppColors.successGreen,
	},
	buttonText: {
		fontSize: 16,
		fontWeight: '600',
		color: 'white',
	},
	logsContainer: {
		backgroundColor: AppColors.lightGray,
		borderRadius: BorderRadius.medium,
		padding: Spacing.md,
		maxHeight: 300,
	},
	logItem: {
		flexDirection: 'row',
		alignItems: 'flex-start',
		marginBottom: Spacing.xs,
	},
	logTime: {
		fontSize: 12,
		color: AppColors.mediumGray,
		marginLeft: Spacing.xs,
		marginRight: Spacing.sm,
		minWidth: 60,
	},
	logMessage: {
		fontSize: 14,
		flex: 1,
	},
});

export default DatabaseSetupScreen;
