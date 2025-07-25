import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { AppColors, Typography, Spacing } from '../theme';
import { CustomCard } from './shared';
import PlantService from '../services/PlantService';

const DatabaseStatus = ({ onStatusChange }) => {
	const [status, setStatus] = useState({
		isConfigured: false,
		connectionStatus: 'checking',
		message: 'Checking database connection...',
		error: null,
	});

	const checkDatabaseStatus = async () => {
		try {
			setStatus(prev => ({
				...prev,
				connectionStatus: 'checking',
				message: 'Checking database connection...',
				error: null,
			}));

			// Check if service is configured
			const isConfigured = PlantService.isConfigured();
			
			if (!isConfigured) {
				setStatus({
					isConfigured: false,
					connectionStatus: 'error',
					message: 'Database not configured',
					error: 'Please check your environment variables',
				});
				onStatusChange?.(false);
				return;
			}

			// Test connection
			const connectionResult = await PlantService.testConnection();
			
			if (connectionResult.success) {
				setStatus({
					isConfigured: true,
					connectionStatus: 'connected',
					message: 'Database connected successfully',
					error: null,
				});
				onStatusChange?.(true);
			} else {
				setStatus({
					isConfigured: true,
					connectionStatus: 'error',
					message: 'Database connection failed',
					error: connectionResult.error,
				});
				onStatusChange?.(false);
			}
		} catch (error) {
			setStatus({
				isConfigured: false,
				connectionStatus: 'error',
				message: 'Connection test failed',
				error: error.message,
			});
			onStatusChange?.(false);
		}
	};

	useEffect(() => {
		checkDatabaseStatus();
	}, []);

	const getStatusIcon = () => {
		switch (status.connectionStatus) {
			case 'checking':
				return { name: 'sync', color: AppColors.secondary };
			case 'connected':
				return { name: 'check-circle', color: AppColors.primaryGreen };
			case 'error':
				return { name: 'error', color: AppColors.errorRed };
			default:
				return { name: 'help', color: AppColors.mediumGray };
		}
	};

	const icon = getStatusIcon();

	return (
		<CustomCard style={styles.container}>
			<View style={styles.header}>
				<Icon name={icon.name} size={24} color={icon.color} />
				<Text style={styles.title}>Database Status</Text>
			</View>
			
			<Text style={styles.message}>{status.message}</Text>
			
			{status.error && (
				<Text style={styles.error}>{status.error}</Text>
			)}
			
			<TouchableOpacity 
				style={styles.retryButton} 
				onPress={checkDatabaseStatus}
			>
				<Icon name="refresh" size={16} color={AppColors.white} />
				<Text style={styles.retryText}>Test Connection</Text>
			</TouchableOpacity>
		</CustomCard>
	);
};

const styles = StyleSheet.create({
	container: {
		marginVertical: Spacing.sm,
	},
	header: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.sm,
	},
	title: {
		...Typography.labelLarge,
		marginLeft: Spacing.sm,
		color: AppColors.darkNavy,
	},
	message: {
		...Typography.bodyMedium,
		color: AppColors.mediumGray,
		marginBottom: Spacing.sm,
	},
	error: {
		...Typography.bodySmall,
		color: AppColors.errorRed,
		marginBottom: Spacing.sm,
		fontStyle: 'italic',
	},
	retryButton: {
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'center',
		backgroundColor: AppColors.secondary,
		paddingHorizontal: Spacing.md,
		paddingVertical: Spacing.sm,
		borderRadius: 6,
		alignSelf: 'flex-start',
	},
	retryText: {
		...Typography.labelMedium,
		color: AppColors.white,
		marginLeft: Spacing.xs,
	},
});

export default DatabaseStatus;
