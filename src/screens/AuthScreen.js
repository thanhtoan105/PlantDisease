import React, { useState, useEffect } from 'react';
import {
	View,
	Text,
	StyleSheet,
	TouchableOpacity,
	TextInput,
	Image,
	Alert,
	ActivityIndicator,
	KeyboardAvoidingView,
	Platform,
	ScrollView,
	SafeAreaView,
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { useAuth } from '../context/AuthContext';
import { AppColors } from '../theme';

const AuthScreen = ({ navigation, route }) => {
	const {
		signIn,
		signUp,
		resetPassword,
		skipAuth,
		isLoading,
		error,
		clearError,
		onboardingCompleted,
	} = useAuth();

	// Default to signin if onboarding is completed (e.g., after logout)
	// Default to signup for new users
	const getDefaultTab = () => {
		if (route?.params?.initialTab) {
			return route.params.initialTab;
		}
		return onboardingCompleted ? 'signin' : 'signup';
	};

	const [activeTab, setActiveTab] = useState(getDefaultTab());
	const [formData, setFormData] = useState({
		email: '',
		password: '',
		confirmPassword: '',
		phone: '',
		username: '',
	});
	const [showPassword, setShowPassword] = useState(false);
	const [agreeToTerms, setAgreeToTerms] = useState(false);

	useEffect(() => {
		clearError();
	}, [activeTab]);

	// Update tab when onboarding status changes (e.g., after logout)
	useEffect(() => {
		if (!route?.params?.initialTab) {
			setActiveTab(onboardingCompleted ? 'signin' : 'signup');
		}
	}, [onboardingCompleted, route?.params?.initialTab]);

	const handleInputChange = (field, value) => {
		setFormData((prev) => ({ ...prev, [field]: value }));
		clearError();
	};

	const validateForm = () => {
		if (!formData.email.trim()) {
			Alert.alert('Error', 'Please enter your email');
			return false;
		}

		if (!formData.email.includes('@')) {
			Alert.alert('Error', 'Please enter a valid email address');
			return false;
		}

		if (!formData.password.trim()) {
			Alert.alert('Error', 'Please enter your password');
			return false;
		}

		if (activeTab === 'signup') {
			if (formData.password.length < 6) {
				Alert.alert('Error', 'Password must be at least 6 characters long');
				return false;
			}

			if (formData.password !== formData.confirmPassword) {
				Alert.alert('Error', 'Passwords do not match');
				return false;
			}

			if (!agreeToTerms) {
				Alert.alert('Error', 'Please agree to the Terms and Policies');
				return false;
			}
		}

		return true;
	};

	const handleSubmit = async () => {
		if (!validateForm()) return;

		try {
			let result;

			if (activeTab === 'signup') {
				result = await signUp(formData.email, formData.password, {
					username: formData.username || formData.email.split('@')[0],
					phone: formData.phone,
				});
			} else {
				result = await signIn(formData.email, formData.password);
			}

			if (result.success) {
				// Don't show alert for successful sign in, let navigation happen automatically
				if (activeTab === 'signup') {
					Alert.alert('Success', result.message);
				}
				// Navigation will be handled automatically by AuthContext
			} else {
				Alert.alert('Error', result.error);
			}
		} catch (error) {
			Alert.alert('Error', error.message || 'Something went wrong');
		}
	};

	const handleForgotPassword = async () => {
		if (!formData.email.trim()) {
			Alert.alert('Error', 'Please enter your email address first');
			return;
		}

		const result = await resetPassword(formData.email);
		Alert.alert(
			result.success ? 'Success' : 'Error',
			result.message || result.error,
		);
	};

	const handleSkip = async () => {
		Alert.alert(
			'Continue as Guest',
			'You can sign up later to save your data and access all features.',
			[
				{ text: 'Cancel', style: 'cancel' },
				{
					text: 'Continue',
					onPress: async () => {
						await skipAuth();
						// Navigation will be handled by AppNavigator
					},
				},
			],
		);
	};

	const handleBackPress = () => {
		// Check if we can go back in the navigation stack
		if (navigation.canGoBack()) {
			navigation.goBack();
		} else {
			// If we can't go back, navigate to onboarding or handle gracefully
			// This can happen when Auth screen is the first screen in the stack
			navigation.navigate('Onboarding');
		}
	};

	const renderSignUp = () => (
		<ScrollView
			style={styles.formContainer}
			showsVerticalScrollIndicator={false}
		>
			<View style={styles.imageContainer}>
				<Image
					source={require('../../assets/login/sign_up.jpg')}
					style={styles.authImage}
					resizeMode='contain'
				/>
			</View>

			<Text style={styles.title}>Sign up</Text>
			<Text style={styles.subtitle}>Create a new account to continue</Text>

			<View style={styles.inputContainer}>
				<Text style={styles.inputLabel}>Enter your email Id</Text>
				<TextInput
					style={styles.textInput}
					placeholder='example@domain.com'
					value={formData.email}
					onChangeText={(value) => handleInputChange('email', value)}
					keyboardType='email-address'
					autoCapitalize='none'
					autoCorrect={false}
				/>
			</View>

			<View style={styles.inputContainer}>
				<Text style={styles.inputLabel}>Create password</Text>
				<View style={styles.passwordContainer}>
					<TextInput
						style={styles.passwordInput}
						placeholder='Enter password'
						value={formData.password}
						onChangeText={(value) => handleInputChange('password', value)}
						secureTextEntry={!showPassword}
						autoCapitalize='none'
					/>
					<TouchableOpacity
						style={styles.eyeButton}
						onPress={() => setShowPassword(!showPassword)}
					>
						<Ionicons
							name={showPassword ? 'eye-off' : 'eye'}
							size={20}
							color={AppColors.mediumGray}
						/>
					</TouchableOpacity>
				</View>
			</View>

			<View style={styles.inputContainer}>
				<Text style={styles.inputLabel}>Confirm password</Text>
				<TextInput
					style={styles.textInput}
					placeholder='Confirm password'
					value={formData.confirmPassword}
					onChangeText={(value) => handleInputChange('confirmPassword', value)}
					secureTextEntry={!showPassword}
					autoCapitalize='none'
				/>
			</View>

			<TouchableOpacity
				style={styles.checkboxContainer}
				onPress={() => setAgreeToTerms(!agreeToTerms)}
			>
				<View style={[styles.checkbox, agreeToTerms && styles.checkboxChecked]}>
					{agreeToTerms && (
						<Ionicons name='checkmark' size={16} color='white' />
					)}
				</View>
				<Text style={styles.checkboxText}>
					By ticking you agree to our{' '}
					<Text style={styles.linkText}>Terms and Policies</Text>
				</Text>
			</TouchableOpacity>

			<TouchableOpacity
				style={[styles.submitButton, isLoading && styles.submitButtonDisabled]}
				onPress={handleSubmit}
				disabled={isLoading}
			>
				{isLoading ? (
					<ActivityIndicator color='white' />
				) : (
					<Text style={styles.submitButtonText}>Sign up</Text>
				)}
			</TouchableOpacity>

			<TouchableOpacity
				style={styles.switchAuthContainer}
				onPress={() => setActiveTab('signin')}
			>
				<Text style={styles.switchAuthText}>
					Already have an Account? <Text style={styles.linkText}>Log in</Text>
				</Text>
			</TouchableOpacity>
		</ScrollView>
	);

	const renderSignIn = () => (
		<ScrollView
			style={styles.formContainer}
			showsVerticalScrollIndicator={false}
		>
			<View style={styles.imageContainer}>
				<Image
					source={require('../../assets/login/sign_in.jpg')}
					style={styles.authImage}
					resizeMode='contain'
				/>
			</View>

			<Text style={styles.title}>Welcome Back !</Text>
			<Text style={styles.subtitle}>Log in to Continue</Text>

			<View style={styles.inputContainer}>
				<Text style={styles.inputLabel}>Enter your email ID/phone number</Text>
				<TextInput
					style={styles.textInput}
					placeholder='example@domain.com'
					value={formData.email}
					onChangeText={(value) => handleInputChange('email', value)}
					keyboardType='email-address'
					autoCapitalize='none'
					autoCorrect={false}
				/>
			</View>

			<View style={styles.inputContainer}>
				<Text style={styles.inputLabel}>Enter your password</Text>
				<View style={styles.passwordContainer}>
					<TextInput
						style={styles.passwordInput}
						placeholder='••••••••'
						value={formData.password}
						onChangeText={(value) => handleInputChange('password', value)}
						secureTextEntry={!showPassword}
						autoCapitalize='none'
					/>
					<TouchableOpacity
						style={styles.eyeButton}
						onPress={() => setShowPassword(!showPassword)}
					>
						<Ionicons
							name={showPassword ? 'eye-off' : 'eye'}
							size={20}
							color={AppColors.mediumGray}
						/>
					</TouchableOpacity>
				</View>
			</View>

			<TouchableOpacity
				style={styles.forgotPasswordContainer}
				onPress={handleForgotPassword}
			>
				<Text style={styles.forgotPasswordText}>Forgot password ?</Text>
			</TouchableOpacity>

			<TouchableOpacity
				style={[styles.submitButton, isLoading && styles.submitButtonDisabled]}
				onPress={handleSubmit}
				disabled={isLoading}
			>
				{isLoading ? (
					<ActivityIndicator color='white' />
				) : (
					<Text style={styles.submitButtonText}>Log in</Text>
				)}
			</TouchableOpacity>

			<TouchableOpacity
				style={styles.switchAuthContainer}
				onPress={() => setActiveTab('signup')}
			>
				<Text style={styles.switchAuthText}>
					Don't have Account? <Text style={styles.linkText}>Sign up</Text>
				</Text>
			</TouchableOpacity>
		</ScrollView>
	);

	return (
		<SafeAreaView style={styles.container}>
			<KeyboardAvoidingView
				style={styles.keyboardAvoidingView}
				behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
			>
				{/* Header */}
				<View style={styles.header}>
					<TouchableOpacity style={styles.backButton} onPress={handleBackPress}>
						<Ionicons name='arrow-back' size={24} color={AppColors.darkGray} />
					</TouchableOpacity>

					<TouchableOpacity
						style={styles.skipHeaderButton}
						onPress={handleSkip}
					>
						<Text style={styles.skipHeaderButtonText}>Skip</Text>
					</TouchableOpacity>
				</View>

				{/* Error Display */}
				{error && (
					<View style={styles.errorContainer}>
						<Text style={styles.errorText}>{error}</Text>
					</View>
				)}

				{/* Form Content */}
				{activeTab === 'signup' ? renderSignUp() : renderSignIn()}
			</KeyboardAvoidingView>
		</SafeAreaView>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: AppColors.white,
	},
	keyboardAvoidingView: {
		flex: 1,
	},
	header: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		paddingHorizontal: 20,
		paddingVertical: 16,
	},
	backButton: {
		padding: 8,
	},
	skipHeaderButton: {
		paddingHorizontal: 16,
		paddingVertical: 8,
	},
	skipHeaderButtonText: {
		fontSize: 16,
		color: AppColors.primaryGreen,
		fontWeight: '500',
	},
	errorContainer: {
		backgroundColor: '#FFE6E6',
		paddingHorizontal: 20,
		paddingVertical: 12,
		marginHorizontal: 20,
		borderRadius: 8,
		marginBottom: 16,
	},
	errorText: {
		color: '#D32F2F',
		fontSize: 14,
		textAlign: 'center',
	},
	formContainer: {
		flex: 1,
		paddingHorizontal: 20,
	},
	imageContainer: {
		alignItems: 'center',
		marginBottom: 32,
	},
	authImage: {
		width: 200,
		height: 150,
	},
	title: {
		fontSize: 28,
		fontWeight: 'bold',
		color: AppColors.darkGray,
		textAlign: 'center',
		marginBottom: 8,
	},
	subtitle: {
		fontSize: 16,
		color: AppColors.mediumGray,
		textAlign: 'center',
		marginBottom: 32,
	},
	inputContainer: {
		marginBottom: 20,
	},
	inputLabel: {
		fontSize: 14,
		color: AppColors.darkGray,
		marginBottom: 8,
		fontWeight: '500',
	},
	textInput: {
		borderWidth: 1,
		borderColor: AppColors.lightGray,
		borderRadius: 8,
		paddingHorizontal: 16,
		paddingVertical: 12,
		fontSize: 16,
		backgroundColor: AppColors.white,
	},
	passwordContainer: {
		flexDirection: 'row',
		alignItems: 'center',
		borderWidth: 1,
		borderColor: AppColors.lightGray,
		borderRadius: 8,
		backgroundColor: AppColors.white,
	},
	passwordInput: {
		flex: 1,
		paddingHorizontal: 16,
		paddingVertical: 12,
		fontSize: 16,
	},
	eyeButton: {
		paddingHorizontal: 16,
		paddingVertical: 12,
	},
	checkboxContainer: {
		flexDirection: 'row',
		alignItems: 'center',
		marginBottom: 24,
	},
	checkbox: {
		width: 20,
		height: 20,
		borderWidth: 2,
		borderColor: AppColors.lightGray,
		borderRadius: 4,
		marginRight: 12,
		justifyContent: 'center',
		alignItems: 'center',
	},
	checkboxChecked: {
		backgroundColor: AppColors.primaryGreen,
		borderColor: AppColors.primaryGreen,
	},
	checkboxText: {
		fontSize: 14,
		color: AppColors.mediumGray,
		flex: 1,
	},
	linkText: {
		color: AppColors.primaryGreen,
		fontWeight: '500',
	},
	forgotPasswordContainer: {
		alignItems: 'flex-end',
		marginBottom: 24,
	},
	forgotPasswordText: {
		fontSize: 14,
		color: AppColors.primaryGreen,
		fontWeight: '500',
	},
	submitButton: {
		backgroundColor: AppColors.primaryGreen,
		paddingVertical: 16,
		borderRadius: 8,
		alignItems: 'center',
		marginBottom: 24,
	},
	submitButtonDisabled: {
		opacity: 0.6,
	},
	submitButtonText: {
		color: 'white',
		fontSize: 16,
		fontWeight: '600',
	},
	switchAuthContainer: {
		alignItems: 'center',
		paddingBottom: 20,
	},
	switchAuthText: {
		fontSize: 14,
		color: AppColors.mediumGray,
	},
});

export default AuthScreen;
