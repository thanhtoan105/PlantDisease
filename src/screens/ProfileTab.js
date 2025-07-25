import React from 'react';
import {
	View,
	ScrollView,
	Text,
	TouchableOpacity,
	StyleSheet,
	SafeAreaView,
	Alert,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { CustomButton, CustomCard, ButtonType } from '../components/shared';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { useAuth } from '../context/AuthContext';

const ProfileAvatar = ({ size = 64 }) => (
	<View style={[styles.avatarContainer, { width: size, height: size }]}>
		<View style={styles.avatarGradient}>
			<Icon name='person' size={size * 0.6} color={AppColors.white} />
		</View>
	</View>
);

const StatsCard = ({ title, value, icon, color }) => (
	<CustomCard>
		<View style={styles.statsCardContent}>
			<View style={styles.statsCardHeader}>
				<View
					style={[styles.statsIconContainer, { backgroundColor: `${color}20` }]}
				>
					<Icon name={icon} size={18} color={color} />
				</View>
				<Text style={styles.statsValue}>{value}</Text>
			</View>
			<Text style={styles.statsTitle}>{title}</Text>
		</View>
	</CustomCard>
);

const ProfileOptionCard = ({ icon, title, subtitle, onPress, trailing }) => (
	<CustomCard onPress={onPress} style={styles.optionCard}>
		<View style={styles.optionContent}>
			<View style={styles.optionIconContainer}>
				<Icon name={icon} size={20} color={AppColors.secondary} />
			</View>
			<View style={styles.optionTextContainer}>
				<Text style={styles.optionTitle}>{title}</Text>
				<Text style={styles.optionSubtitle}>{subtitle}</Text>
			</View>
			{trailing || (
				<Icon name='chevron-right' size={20} color={AppColors.mediumGray} />
			)}
		</View>
	</CustomCard>
);

const ProfileTab = ({ navigation }) => {
	const { user, profile, signOut, isAuthenticated, resetOnboarding } =
		useAuth();

	const showEditProfileModal = () => {
		Alert.alert(
			'Edit Profile',
			'Edit profile functionality not implemented yet',
		);
	};

	const showLogoutDialog = () => {
		if (!isAuthenticated) {
			// Guest mode - show sign in option
			Alert.alert(
				'Sign In',
				'You are currently in guest mode. Would you like to sign in to save your data?',
				[
					{ text: 'Cancel', style: 'cancel' },
					{
						text: 'Sign In',
						onPress: async () => {
							await resetOnboarding();
							// This will trigger navigation back to onboarding
						},
					},
				],
			);
		} else {
			// Authenticated user - show logout
			Alert.alert('Logout', 'Are you sure you want to logout?', [
				{ text: 'Cancel', style: 'cancel' },
				{
					text: 'Logout',
					style: 'destructive',
					onPress: async () => {
						const result = await signOut();
						if (result.success) {
							// Navigation will be handled by AppNavigator
						} else {
							Alert.alert('Error', result.error);
						}
					},
				},
			]);
		}
	};

	const renderHeader = () => <Text style={styles.header}>Profile</Text>;

	const renderUserInformation = () => (
		<CustomCard>
			<View style={styles.userInfoContent}>
				{/* Avatar and basic info */}
				<View style={styles.userInfoHeader}>
					<ProfileAvatar size={64} />
					<View style={styles.userInfoText}>
						<Text style={styles.userName}>
							{profile?.username || user?.email?.split('@')[0] || 'Guest User'}
						</Text>
						<Text style={styles.userEmail}>
							{user?.email || 'Not signed in'}
						</Text>
						<Text style={styles.memberSince}>
							{isAuthenticated
								? `Member since ${new Date(
										user?.created_at || Date.now(),
								  ).toLocaleDateString('en-US', {
										month: 'long',
										year: 'numeric',
								  })}`
								: 'Guest mode'}
						</Text>
					</View>
				</View>

				{/* Edit Profile Button */}
				<CustomButton
					text='Edit Profile'
					type={ButtonType.PRIMARY}
					icon={() => <Icon name='edit' size={18} color={AppColors.white} />}
					onPress={showEditProfileModal}
					style={styles.editProfileButton}
				/>
			</View>
		</CustomCard>
	);

	const renderStatistics = () => (
		<View style={styles.statisticsContainer}>
			<Text style={styles.sectionTitle}>Your Activity</Text>
			<View style={styles.statsRow}>
				<View style={styles.statsItem}>
					<StatsCard
						title='Scans'
						value='47'
						icon='document-scanner'
						color={AppColors.primaryGreen}
					/>
				</View>
				<View style={styles.statsItem}>
					<StatsCard
						title='Diseases Found'
						value='12'
						icon='bug-report'
						color={AppColors.accentOrange}
					/>
				</View>
			</View>
			<View style={styles.statsRow}>
				<View style={styles.statsItem}>
					<StatsCard
						title='Plants Saved'
						value='23'
						icon='eco'
						color={AppColors.secondary}
					/>
				</View>
				<View style={styles.statsItem}>
					<StatsCard
						title='Streak Days'
						value='15'
						icon='local-fire-department'
						color={AppColors.accentOrange}
					/>
				</View>
			</View>
		</View>
	);

	const renderAccountActions = () => (
		<View style={styles.sectionContainer}>
			<Text style={styles.sectionTitle}>Account</Text>
			<ProfileOptionCard
				icon='history'
				title='Scan History'
				subtitle='View your previous scans'
				onPress={() => console.log('Scan History')}
			/>
			<ProfileOptionCard
				icon='bookmark'
				title='Saved Results'
				subtitle='Access your bookmarked analyses'
				onPress={() => console.log('Saved Results')}
			/>
			<ProfileOptionCard
				icon='download'
				title='Export Data'
				subtitle='Download your scan data'
				onPress={() => console.log('Export Data')}
			/>
		</View>
	);

	const renderSettings = () => (
		<View style={styles.sectionContainer}>
			<Text style={styles.sectionTitle}>Settings</Text>
			<ProfileOptionCard
				icon='notifications'
				title='Notifications'
				subtitle='Manage your notification preferences'
				onPress={() => console.log('Notifications')}
			/>
			<ProfileOptionCard
				icon='security'
				title='Privacy & Security'
				subtitle='Control your privacy settings'
				onPress={() => console.log('Privacy & Security')}
			/>
			<ProfileOptionCard
				icon='language'
				title='Language'
				subtitle='English'
				onPress={() => console.log('Language')}
			/>
			<ProfileOptionCard
				icon='dark-mode'
				title='Theme'
				subtitle='Light mode'
				onPress={() => console.log('Theme')}
			/>
			<ProfileOptionCard
				icon='storage'
				title='Database Setup'
				subtitle='Configure Supabase database'
				onPress={() => navigation.navigate('DatabaseSetup')}
			/>
			<ProfileOptionCard
				icon='bug-report'
				title='Database Test'
				subtitle='Test database connection and functionality'
				onPress={() => navigation.navigate('DatabaseTest')}
			/>
			<ProfileOptionCard
				icon='refresh'
				title='Reset Onboarding'
				subtitle='Reset app to show onboarding again (for testing)'
				onPress={async () => {
					Alert.alert(
						'Reset Onboarding',
						'This will reset the app to show onboarding screen again. Continue?',
						[
							{ text: 'Cancel', style: 'cancel' },
							{
								text: 'Reset',
								style: 'destructive',
								onPress: async () => {
									await resetOnboarding();
								},
							},
						],
					);
				}}
			/>
		</View>
	);

	const renderAppInformation = () => (
		<View style={styles.sectionContainer}>
			<Text style={styles.sectionTitle}>Support</Text>
			<ProfileOptionCard
				icon='help'
				title='Help & Support'
				subtitle='Get help and contact support'
				onPress={() => console.log('Help & Support')}
			/>
			<ProfileOptionCard
				icon='star-rate'
				title='Rate App'
				subtitle='Rate us on the app store'
				onPress={() => console.log('Rate App')}
			/>
			<ProfileOptionCard
				icon='info'
				title='About'
				subtitle='App version 1.0.0'
				onPress={() => console.log('About')}
			/>

			{/* Sign In/Logout Button */}
			<CustomButton
				text={isAuthenticated ? 'Logout' : 'Sign In'}
				type={ButtonType.SECONDARY}
				icon={() => (
					<Icon
						name={isAuthenticated ? 'logout' : 'login'}
						size={18}
						color={
							isAuthenticated ? AppColors.errorRed : AppColors.primaryGreen
						}
					/>
				)}
				onPress={showLogoutDialog}
				style={styles.logoutButton}
				textStyle={{
					color: isAuthenticated ? AppColors.errorRed : AppColors.primaryGreen,
				}}
			/>
		</View>
	);

	return (
		<SafeAreaView style={styles.container}>
			<ScrollView
				style={styles.scrollView}
				contentContainerStyle={styles.scrollContent}
			>
				{renderHeader()}
				{renderUserInformation()}
				{renderStatistics()}
				{renderAccountActions()}
				{renderSettings()}
				{renderAppInformation()}
			</ScrollView>
		</SafeAreaView>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: AppColors.lightGray,
	},
	scrollView: {
		flex: 1,
	},
	scrollContent: {
		padding: Spacing.lg,
	},
	header: {
		...Typography.headlineLarge,
		marginBottom: Spacing.xxl,
	},
	avatarContainer: {
		borderRadius: 50,
		borderWidth: 3,
		borderColor: AppColors.accentOrange,
		overflow: 'hidden',
	},
	avatarGradient: {
		flex: 1,
		backgroundColor: AppColors.primaryGreen,
		alignItems: 'center',
		justifyContent: 'center',
	},
	userInfoContent: {
		marginBottom: Spacing.lg,
	},
	userInfoHeader: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: Spacing.xl,
	},
	userInfoText: {
		flex: 1,
		marginLeft: Spacing.lg,
	},
	userName: {
		...Typography.headlineMedium,
		marginBottom: Spacing.xs,
	},
	userEmail: {
		...Typography.bodyMedium,
		color: AppColors.mediumGray,
		marginBottom: Spacing.xs,
	},
	memberSince: {
		...Typography.bodySmall,
		color: AppColors.mediumGray,
	},
	editProfileButton: {
		marginTop: Spacing.md,
	},
	sectionContainer: {
		marginBottom: Spacing.xxl,
	},
	sectionTitle: {
		...Typography.headlineMedium,
		marginBottom: Spacing.md,
	},
	statisticsContainer: {
		marginBottom: Spacing.xxl,
	},
	statsRow: {
		flexDirection: 'row',
		marginBottom: Spacing.md,
	},
	statsItem: {
		flex: 1,
		marginHorizontal: Spacing.xs,
	},
	statsCardContent: {
		alignItems: 'flex-start',
	},
	statsCardHeader: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		width: '100%',
		marginBottom: Spacing.md,
	},
	statsIconContainer: {
		width: 32,
		height: 32,
		borderRadius: Spacing.sm,
		alignItems: 'center',
		justifyContent: 'center',
	},
	statsValue: {
		fontSize: 24,
		fontWeight: '600',
		color: AppColors.darkNavy,
	},
	statsTitle: {
		...Typography.bodySmall,
		fontWeight: '500',
		color: AppColors.mediumGray,
	},
	optionCard: {
		marginBottom: Spacing.sm,
	},
	optionContent: {
		flexDirection: 'row',
		alignItems: 'center',
	},
	optionIconContainer: {
		width: 40,
		height: 40,
		backgroundColor: AppColors.lightGray,
		borderRadius: 10,
		alignItems: 'center',
		justifyContent: 'center',
		marginRight: Spacing.lg,
	},
	optionTextContainer: {
		flex: 1,
	},
	optionTitle: {
		...Typography.labelMedium,
		marginBottom: 2,
	},
	optionSubtitle: {
		...Typography.bodySmall,
	},
	logoutButton: {
		marginTop: Spacing.xl,
	},
});

export default ProfileTab;
