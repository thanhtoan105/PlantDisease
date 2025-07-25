import React, { useState, useEffect, useRef } from 'react';
import {
	View,
	Text,
	StyleSheet,
	TouchableOpacity,
	Alert,
	SafeAreaView,
	ActivityIndicator,
	Platform,
	Animated,
	Dimensions,
	AppState,
} from 'react-native';
import {
	Camera,
	useCameraPermission,
	useCameraDevices,
	useCameraFormat,
} from 'react-native-vision-camera';
import { launchImageLibrary } from 'react-native-image-picker';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import TensorFlowService from '../services/TensorFlowService';

const { width, height } = Dimensions.get('window');

const AiScanTab = ({ navigation }) => {
	const cameraRef = useRef(null);
	const { hasPermission, requestPermission } = useCameraPermission();
	const devices = useCameraDevices();
	const [facing, setFacing] = useState('back');
	const [flash, setFlash] = useState('off');
	const [isCapturing, setIsCapturing] = useState(false);
	const [isAnalyzing, setIsAnalyzing] = useState(false);
	const [modelLoaded, setModelLoaded] = useState(false);
	const [isCameraActive, setIsCameraActive] = useState(true);

	// Animation values
	const pulseAnim = useRef(new Animated.Value(1)).current;
	const fadeAnim = useRef(new Animated.Value(0)).current;

	// Enhanced device selection following react-native-vision-camera best practices
	const device = facing === 'back' ? devices.back : devices.front;

	// Get the best format for photo capture (following official docs)
	const format = useCameraFormat(device, [
		{ photoResolution: { width: 1920, height: 1080 } },
		{ fps: 30 },
	]);

	useEffect(() => {
		if (!hasPermission) {
			requestPermission();
		}
	}, [hasPermission, requestPermission]);

	// Load TensorFlow model on component mount
	useEffect(() => {
		const loadModel = async () => {
			try {
				console.log('🔄 Loading TensorFlow model...');
				const loaded = await TensorFlowService.loadModel();
				setModelLoaded(loaded);

				if (loaded) {
					console.log('✅ Model loaded successfully');
					// Fade in animation when model is ready
					Animated.timing(fadeAnim, {
						toValue: 1,
						duration: 500,
						useNativeDriver: true,
					}).start();
				}
			} catch (error) {
				console.error('❌ Failed to load model:', error);
				Alert.alert(
					'Model Error',
					'Failed to load AI model. Please restart the app.',
				);
			}
		};

		loadModel();
	}, [fadeAnim]);

	// Pulse animation for capture button
	useEffect(() => {
		if (modelLoaded && !isCapturing && !isAnalyzing) {
			const pulse = Animated.loop(
				Animated.sequence([
					Animated.timing(pulseAnim, {
						toValue: 1.1,
						duration: 1000,
						useNativeDriver: true,
					}),
					Animated.timing(pulseAnim, {
						toValue: 1,
						duration: 1000,
						useNativeDriver: true,
					}),
				]),
			);
			pulse.start();
			return () => pulse.stop();
		}
	}, [modelLoaded, isCapturing, isAnalyzing, pulseAnim]);

	// Camera lifecycle management following react-native-vision-camera best practices
	useEffect(() => {
		const handleAppStateChange = (nextAppState) => {
			console.log('📱 App state changed to:', nextAppState);
			if (nextAppState === 'background' || nextAppState === 'inactive') {
				setIsCameraActive(false);
			} else if (nextAppState === 'active') {
				setIsCameraActive(true);
			}
		};

		// Add AppState listener
		const subscription = AppState.addEventListener(
			'change',
			handleAppStateChange,
		);

		// Focus/blur listeners for navigation
		const unsubscribeFocus = navigation.addListener('focus', () => {
			console.log('📱 Screen focused - activating camera');
			setIsCameraActive(true);
		});

		const unsubscribeBlur = navigation.addListener('blur', () => {
			console.log('📱 Screen blurred - deactivating camera');
			setIsCameraActive(false);
		});

		return () => {
			subscription?.remove();
			unsubscribeFocus();
			unsubscribeBlur();
		};
	}, [navigation]);

	// Debug logging for camera devices
	useEffect(() => {
		console.log('🔍 Camera Debug Info:');
		console.log('- Has permission:', hasPermission);
		console.log('- Available devices:', devices);
		console.log('- Back device:', devices.back);
		console.log('- Front device:', devices.front);
		console.log('- Selected device:', device);
		console.log('- Current facing:', facing);
	}, [hasPermission, devices, device, facing]);

	const takePicture = async () => {
		if (
			cameraRef.current &&
			!isCapturing &&
			!isAnalyzing &&
			modelLoaded &&
			device
		) {
			try {
				console.log('📸 Taking picture with react-native-vision-camera...');
				setIsCapturing(true);
				setIsCameraActive(false); // Pause camera during capture

				// Enhanced photo options following official documentation
				const photo = await cameraRef.current.takePhoto({
					qualityPrioritization: 'balanced',
					flash: flash,
					enableShutterSound: Platform.OS === 'ios',
					enableAutoRedEyeReduction: true,
					enableAutoStabilization: true,
					enableAutoDistortionCorrection: true,
				});

				const imageUri = `file://${photo.path}`;
				console.log('✅ Picture taken successfully:', {
					path: photo.path,
					width: photo.width,
					height: photo.height,
					orientation: photo.orientation,
				});

				// Analyze the captured image
				await analyzeImage(imageUri);
			} catch (error) {
				console.error('❌ Error taking picture:', error);
				Alert.alert(
					'Camera Error',
					'Failed to take picture. Please try again.',
					[
						{
							text: 'OK',
							onPress: () => setIsCameraActive(true),
						},
					],
				);
			} finally {
				setIsCapturing(false);
				setIsCameraActive(true); // Resume camera
			}
		}
	};

	const analyzeImage = async (imageUri) => {
		try {
			console.log('🔬 Starting analysis for image:', imageUri);
			setIsAnalyzing(true);

			// Check if model is loaded
			if (!modelLoaded) {
				Alert.alert(
					'Model Not Ready',
					'Please wait for the AI model to load before analyzing images.',
				);
				setIsAnalyzing(false);
				return;
			}

			// Use the real TensorFlowService for analysis
			const result = await TensorFlowService.analyzeImage(imageUri);

			if (result.success) {
				console.log('✅ Analysis successful:', result.data);

				// Navigate to results screen with the analysis data
				navigation.navigate('Results', {
					imageUri: imageUri,
					analysisResult: result.data,
				});
			} else {
				console.error('❌ Analysis failed:', result.error);
				Alert.alert(
					'Analysis Failed',
					result.error || 'Failed to analyze the image. Please try again.',
					[
						{
							text: 'Try Again',
							onPress: () => analyzeImage(imageUri),
						},
						{
							text: 'Cancel',
							style: 'cancel',
						},
					],
				);
			}
		} catch (error) {
			console.error('❌ Error analyzing image:', error);
			Alert.alert('Error', 'Failed to analyze image. Please try again.');
		} finally {
			setIsAnalyzing(false);
		}
	};

	const pickFromGallery = async () => {
		try {
			console.log('📷 Opening gallery picker...');

			const options = {
				mediaType: 'photo',
				includeBase64: false,
				maxHeight: 2000,
				maxWidth: 2000,
				quality: 0.8,
				selectionLimit: 1,
			};

			launchImageLibrary(options, async (response) => {
				console.log('📷 Gallery picker response:', response);

				if (response.didCancel) {
					console.log('👤 User cancelled image picker');
					return;
				}

				if (response.errorMessage) {
					console.error('❌ ImagePicker Error:', response.errorMessage);
					Alert.alert(
						'Gallery Error',
						'Failed to access gallery. Please check permissions.',
					);
					return;
				}

				if (response.assets && response.assets.length > 0) {
					const asset = response.assets[0];
					const imageUri = asset.uri;

					console.log('✅ Selected image from gallery:', imageUri);
					console.log('📊 Image details:', {
						width: asset.width,
						height: asset.height,
						fileSize: asset.fileSize,
						type: asset.type,
					});

					// Analyze the selected image
					await analyzeImage(imageUri);
				} else {
					console.log('⚠️ No image selected');
				}
			});
		} catch (error) {
			console.error('❌ Error picking from gallery:', error);
			Alert.alert('Gallery Error', 'Failed to open gallery. Please try again.');
		}
	};

	const toggleFlash = () => {
		setFlash(flash === 'off' ? 'on' : 'off');
	};

	const toggleCamera = () => {
		setFacing(facing === 'back' ? 'front' : 'back');
	};

	if (!hasPermission) {
		return (
			<View style={styles.permissionContainer}>
				<Text style={styles.permissionText}>
					Camera permission is required to use this feature
				</Text>
				<TouchableOpacity
					style={styles.permissionButton}
					onPress={requestPermission}
				>
					<Text style={styles.permissionButtonText}>Grant Permission</Text>
				</TouchableOpacity>
			</View>
		);
	}

	// Check if running on emulator (common issue)
	const isEmulator =
		Platform.OS === 'android' &&
		(Platform.constants?.Brand?.includes('google') ||
			Platform.constants?.Model?.includes('sdk') ||
			Platform.constants?.Model?.includes('emulator'));

	if (!device) {
		return (
			<SafeAreaView style={styles.container}>
				<View style={styles.permissionContainer}>
					<Icon name='camera-alt' size={64} color={AppColors.primaryGreen} />
					<Text style={styles.permissionText}>Camera device not available</Text>
					{isEmulator && (
						<>
							<Text style={styles.emulatorWarning}>
								⚠️ You're running on an emulator
							</Text>
							<Text style={styles.emulatorText}>
								Camera functionality requires a real device. Please test on a
								physical Android device.
							</Text>
						</>
					)}
					<TouchableOpacity
						style={[styles.permissionButton, { marginTop: 20 }]}
						onPress={pickFromGallery}
						disabled={!modelLoaded}
					>
						<Icon name='photo-library' size={20} color={AppColors.white} />
						<Text style={styles.permissionButtonText}>Pick from Gallery</Text>
					</TouchableOpacity>

					<TouchableOpacity
						style={[
							styles.permissionButton,
							{ marginTop: 10, backgroundColor: AppColors.darkNavy },
						]}
						onPress={() => navigation.goBack()}
					>
						<Icon name='arrow-back' size={20} color={AppColors.white} />
						<Text style={styles.permissionButtonText}>Go Back</Text>
					</TouchableOpacity>
				</View>
			</SafeAreaView>
		);
	}

	return (
		<SafeAreaView style={styles.container}>
			{/* Modern Header with Status */}
			<Animated.View style={[styles.modernHeader, { opacity: fadeAnim }]}>
				<View style={styles.headerContent}>
					<Text style={styles.modernTitle}>Plant Health Scanner</Text>
					<View style={styles.statusContainer}>
						<View
							style={[
								styles.statusDot,
								{ backgroundColor: modelLoaded ? '#4CAF50' : '#FF9800' },
							]}
						/>
						<Text style={styles.statusText}>
							{modelLoaded ? 'AI Ready' : 'Loading AI...'}
						</Text>
					</View>
				</View>
			</Animated.View>

			{/* Camera Container with Modern Frame */}
			<View style={styles.modernCameraContainer}>
				<Camera
					ref={cameraRef}
					style={styles.modernCamera}
					device={device}
					isActive={isCameraActive && !isAnalyzing}
					photo={true}
					format={format}
					enableZoomGesture={true}
					enableFpsGraph={__DEV__}
					orientation='portrait'
					photoQualityBalance='balanced'
				/>

				{/* Modern Scanning Frame */}
				<View style={styles.scanningFrame}>
					<View style={styles.frameCorners}>
						<View style={[styles.corner, styles.topLeft]} />
						<View style={[styles.corner, styles.topRight]} />
						<View style={[styles.corner, styles.bottomLeft]} />
						<View style={[styles.corner, styles.bottomRight]} />
					</View>
				</View>

				{/* Loading Overlay with Modern Design */}
				{(isCapturing || isAnalyzing) && (
					<View style={styles.modernLoadingOverlay}>
						<View style={styles.loadingCard}>
							<ActivityIndicator size='large' color={AppColors.primaryGreen} />
							<Text style={styles.modernLoadingText}>
								{isCapturing
									? 'Capturing Image...'
									: 'Analyzing Plant Health...'}
							</Text>
						</View>
					</View>
				)}

				{/* Modern Guide Text */}
				<View style={styles.modernGuideContainer}>
					<Text style={styles.modernGuideText}>
						{!modelLoaded
							? 'Loading AI model...'
							: isCapturing
							? 'Capturing image...'
							: isAnalyzing
							? 'Analyzing plant health...'
							: 'Position plant leaf within the frame'}
					</Text>
					{modelLoaded && !isCapturing && !isAnalyzing && (
						<Text style={styles.modernGuideSubtext}>
							Ensure good lighting for best results
						</Text>
					)}
				</View>
			</View>

			{/* Modern Top Controls */}
			<View style={styles.modernTopControls}>
				<TouchableOpacity
					style={[
						styles.modernControlButton,
						flash === 'on' && styles.modernControlButtonActive,
					]}
					onPress={toggleFlash}
					disabled={isCapturing || isAnalyzing}
					activeOpacity={0.8}
				>
					<Icon
						name={flash === 'off' ? 'flash-off' : 'flash-on'}
						size={22}
						color={flash === 'on' ? AppColors.primaryGreen : AppColors.white}
					/>
				</TouchableOpacity>

				<TouchableOpacity
					style={styles.modernControlButton}
					onPress={toggleCamera}
					disabled={isCapturing || isAnalyzing}
					activeOpacity={0.8}
				>
					<Icon name='flip-camera-ios' size={22} color={AppColors.white} />
				</TouchableOpacity>
			</View>

			{/* Modern Bottom Controls */}
			<View style={styles.modernBottomControls}>
				<TouchableOpacity
					style={[
						styles.modernSecondaryButton,
						(isCapturing || isAnalyzing || !modelLoaded) &&
							styles.modernButtonDisabled,
					]}
					onPress={pickFromGallery}
					disabled={isCapturing || isAnalyzing || !modelLoaded}
					activeOpacity={0.8}
				>
					<Icon name='photo-library' size={24} color={AppColors.white} />
					<Text style={styles.modernButtonLabel}>Gallery</Text>
				</TouchableOpacity>

				<Animated.View style={{ transform: [{ scale: pulseAnim }] }}>
					<TouchableOpacity
						style={[
							styles.modernCaptureButton,
							(isCapturing || isAnalyzing || !modelLoaded) &&
								styles.modernCaptureButtonDisabled,
						]}
						onPress={takePicture}
						disabled={isCapturing || isAnalyzing || !modelLoaded}
						activeOpacity={0.9}
					>
						<View style={styles.modernCaptureButtonInner}>
							{isCapturing || isAnalyzing ? (
								<ActivityIndicator size='large' color={AppColors.white} />
							) : (
								<Icon name='camera-alt' size={36} color={AppColors.white} />
							)}
						</View>
					</TouchableOpacity>
				</Animated.View>

				<TouchableOpacity
					style={[
						styles.modernSecondaryButton,
						(isCapturing || isAnalyzing || !modelLoaded) &&
							styles.modernButtonDisabled,
					]}
					onPress={() => navigation.navigate('Test')}
					disabled={isCapturing || isAnalyzing}
					activeOpacity={0.8}
				>
					<Icon name='bug-report' size={24} color={AppColors.white} />
					<Text style={styles.modernButtonLabel}>Test</Text>
				</TouchableOpacity>
			</View>
		</SafeAreaView>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: '#000000',
	},

	// Modern Header Styles
	modernHeader: {
		paddingHorizontal: 20,
		paddingVertical: 16,
		backgroundColor: 'rgba(0, 0, 0, 0.8)',
		position: 'absolute',
		top: 0,
		left: 0,
		right: 0,
		zIndex: 10,
	},
	headerContent: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
	},
	modernTitle: {
		fontSize: 20,
		fontWeight: '600',
		color: AppColors.white,
		fontFamily: Typography.fontFamily,
	},
	statusContainer: {
		flexDirection: 'row',
		alignItems: 'center',
	},
	statusDot: {
		width: 8,
		height: 8,
		borderRadius: 4,
		marginRight: 8,
	},
	statusText: {
		fontSize: 14,
		color: AppColors.white,
		fontWeight: '500',
	},

	// Modern Camera Styles
	modernCameraContainer: {
		flex: 1,
		position: 'relative',
	},
	modernCamera: {
		flex: 1,
	},

	// Scanning Frame Styles
	scanningFrame: {
		position: 'absolute',
		top: '20%',
		left: '10%',
		right: '10%',
		bottom: '30%',
		justifyContent: 'center',
		alignItems: 'center',
	},
	frameCorners: {
		width: '100%',
		height: '100%',
		position: 'relative',
	},
	corner: {
		position: 'absolute',
		width: 30,
		height: 30,
		borderColor: AppColors.primaryGreen,
		borderWidth: 3,
	},
	topLeft: {
		top: 0,
		left: 0,
		borderRightWidth: 0,
		borderBottomWidth: 0,
	},
	topRight: {
		top: 0,
		right: 0,
		borderLeftWidth: 0,
		borderBottomWidth: 0,
	},
	bottomLeft: {
		bottom: 0,
		left: 0,
		borderRightWidth: 0,
		borderTopWidth: 0,
	},
	bottomRight: {
		bottom: 0,
		right: 0,
		borderLeftWidth: 0,
		borderTopWidth: 0,
	},

	// Modern Loading Overlay
	modernLoadingOverlay: {
		position: 'absolute',
		top: 0,
		left: 0,
		right: 0,
		bottom: 0,
		backgroundColor: 'rgba(0, 0, 0, 0.7)',
		justifyContent: 'center',
		alignItems: 'center',
	},
	loadingCard: {
		backgroundColor: 'rgba(255, 255, 255, 0.95)',
		padding: 24,
		borderRadius: 16,
		alignItems: 'center',
		minWidth: 200,
	},
	modernLoadingText: {
		marginTop: 16,
		fontSize: 16,
		fontWeight: '600',
		color: AppColors.darkNavy,
		textAlign: 'center',
	},

	// Modern Guide Container
	modernGuideContainer: {
		position: 'absolute',
		bottom: 120,
		left: 20,
		right: 20,
		alignItems: 'center',
	},
	modernGuideText: {
		fontSize: 16,
		fontWeight: '600',
		color: AppColors.white,
		textAlign: 'center',
		backgroundColor: 'rgba(0, 0, 0, 0.6)',
		paddingHorizontal: 16,
		paddingVertical: 8,
		borderRadius: 20,
		overflow: 'hidden',
	},
	modernGuideSubtext: {
		fontSize: 14,
		color: AppColors.white,
		textAlign: 'center',
		marginTop: 8,
		opacity: 0.8,
	},

	// Modern Top Controls
	modernTopControls: {
		position: 'absolute',
		top: 80,
		left: 20,
		right: 20,
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		zIndex: 5,
	},
	modernControlButton: {
		width: 48,
		height: 48,
		borderRadius: 24,
		backgroundColor: 'rgba(0, 0, 0, 0.6)',
		justifyContent: 'center',
		alignItems: 'center',
		borderWidth: 2,
		borderColor: 'rgba(255, 255, 255, 0.3)',
	},
	modernControlButtonActive: {
		backgroundColor: 'rgba(76, 175, 80, 0.8)',
		borderColor: AppColors.primaryGreen,
	},

	// Modern Bottom Controls
	modernBottomControls: {
		position: 'absolute',
		bottom: 40,
		left: 20,
		right: 20,
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		paddingHorizontal: 10,
	},
	modernSecondaryButton: {
		width: 70,
		height: 70,
		borderRadius: 35,
		backgroundColor: 'rgba(0, 0, 0, 0.7)',
		justifyContent: 'center',
		alignItems: 'center',
		borderWidth: 2,
		borderColor: 'rgba(255, 255, 255, 0.3)',
	},
	modernButtonLabel: {
		fontSize: 12,
		color: AppColors.white,
		marginTop: 4,
		fontWeight: '500',
	},
	modernButtonDisabled: {
		opacity: 0.5,
	},

	// Modern Capture Button
	modernCaptureButton: {
		width: 90,
		height: 90,
		borderRadius: 45,
		backgroundColor: AppColors.primaryGreen,
		justifyContent: 'center',
		alignItems: 'center',
		borderWidth: 4,
		borderColor: AppColors.white,
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 4,
		},
		shadowOpacity: 0.3,
		shadowRadius: 8,
		elevation: 8,
	},
	modernCaptureButtonInner: {
		width: '100%',
		height: '100%',
		borderRadius: 41,
		justifyContent: 'center',
		alignItems: 'center',
	},
	modernCaptureButtonDisabled: {
		backgroundColor: 'rgba(76, 175, 80, 0.5)',
		borderColor: 'rgba(255, 255, 255, 0.5)',
	},
	permissionContainer: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: AppColors.lightGray,
		padding: Spacing.large,
	},
	permissionText: {
		...Typography.bodyMedium,
		color: AppColors.darkNavy,
		textAlign: 'center',
		marginBottom: Spacing.medium,
	},
	permissionButton: {
		backgroundColor: AppColors.primaryGreen,
		paddingHorizontal: Spacing.large,
		paddingVertical: Spacing.medium,
		borderRadius: BorderRadius.medium,
		flexDirection: 'row',
		alignItems: 'center',
		justifyContent: 'center',
		minWidth: 200,
	},
	permissionButtonText: {
		...Typography.bodyMedium,
		color: AppColors.white,
		fontWeight: 'bold',
		marginLeft: 8,
	},
	cameraContainer: {
		flex: 1,
		position: 'relative',
	},
	camera: {
		flex: 1,
	},
	loadingOverlay: {
		position: 'absolute',
		top: 0,
		left: 0,
		right: 0,
		bottom: 0,
		backgroundColor: 'rgba(0, 0, 0, 0.7)',
		justifyContent: 'center',
		alignItems: 'center',
	},
	loadingText: {
		...Typography.bodyMedium,
		color: AppColors.white,
		marginTop: Spacing.small,
		textAlign: 'center',
	},
	guideOverlay: {
		position: 'absolute',
		top: 0,
		left: 0,
		right: 0,
		bottom: 0,
		justifyContent: 'center',
		alignItems: 'center',
	},
	guideFrame: {
		width: 280,
		height: 280,
		borderWidth: 3,
		borderColor: 'rgba(255, 255, 255, 0.5)',
		borderRadius: BorderRadius.large,
		backgroundColor: 'transparent',
		position: 'relative',
	},
	guideFrameReady: {
		borderColor: AppColors.primaryGreen,
		shadowColor: AppColors.primaryGreen,
		shadowOffset: {
			width: 0,
			height: 0,
		},
		shadowOpacity: 0.5,
		shadowRadius: 10,
	},
	guideFrameActive: {
		borderColor: AppColors.warning,
		shadowColor: AppColors.warning,
	},
	cornerIndicator: {
		position: 'absolute',
		width: 20,
		height: 20,
		borderColor: AppColors.primaryGreen,
		borderWidth: 3,
	},
	topLeft: {
		top: -3,
		left: -3,
		borderRightWidth: 0,
		borderBottomWidth: 0,
		borderTopLeftRadius: BorderRadius.large,
	},
	topRight: {
		top: -3,
		right: -3,
		borderLeftWidth: 0,
		borderBottomWidth: 0,
		borderTopRightRadius: BorderRadius.large,
	},
	bottomLeft: {
		bottom: -3,
		left: -3,
		borderRightWidth: 0,
		borderTopWidth: 0,
		borderBottomLeftRadius: BorderRadius.large,
	},
	bottomRight: {
		bottom: -3,
		right: -3,
		borderLeftWidth: 0,
		borderTopWidth: 0,
		borderBottomRightRadius: BorderRadius.large,
	},
	guideText: {
		...Typography.bodyMedium,
		color: AppColors.white,
		backgroundColor: 'rgba(0, 0, 0, 0.8)',
		paddingHorizontal: Spacing.large,
		paddingVertical: Spacing.medium,
		borderRadius: BorderRadius.large,
		marginTop: Spacing.large,
		textAlign: 'center',
		fontWeight: '600',
		maxWidth: '80%',
	},
	guideSubtext: {
		...Typography.captionMedium,
		color: 'rgba(255, 255, 255, 0.8)',
		backgroundColor: 'rgba(0, 0, 0, 0.6)',
		paddingHorizontal: Spacing.medium,
		paddingVertical: Spacing.small,
		borderRadius: BorderRadius.medium,
		marginTop: Spacing.small,
		textAlign: 'center',
		maxWidth: '70%',
	},
	topControls: {
		position: 'absolute',
		top: Spacing.large + 20,
		left: 0,
		right: 0,
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		paddingHorizontal: Spacing.large,
	},
	controlButton: {
		width: 56,
		height: 56,
		borderRadius: 28,
		backgroundColor: 'rgba(0, 0, 0, 0.7)',
		justifyContent: 'center',
		alignItems: 'center',
		borderWidth: 2,
		borderColor: 'rgba(255, 255, 255, 0.3)',
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 2,
		},
		shadowOpacity: 0.25,
		shadowRadius: 3.84,
		elevation: 5,
	},
	controlButtonActive: {
		backgroundColor: 'rgba(76, 175, 80, 0.9)',
		borderColor: AppColors.primaryGreen,
	},
	controlButtonDisabled: {
		backgroundColor: 'rgba(0, 0, 0, 0.4)',
		borderColor: 'rgba(255, 255, 255, 0.1)',
	},
	statusIndicator: {
		backgroundColor: 'rgba(0, 0, 0, 0.8)',
		paddingHorizontal: Spacing.medium,
		paddingVertical: Spacing.small,
		borderRadius: BorderRadius.large,
		borderWidth: 1,
		borderColor: 'rgba(255, 255, 255, 0.2)',
	},
	statusText: {
		...Typography.captionMedium,
		color: AppColors.white,
		fontWeight: '600',
		textAlign: 'center',
	},
	bottomControls: {
		position: 'absolute',
		bottom: Spacing.large + 20,
		left: 0,
		right: 0,
		flexDirection: 'row',
		justifyContent: 'space-around',
		alignItems: 'center',
		paddingHorizontal: Spacing.large,
	},
	secondaryButton: {
		width: 70,
		height: 70,
		borderRadius: 35,
		backgroundColor: 'rgba(0, 0, 0, 0.7)',
		justifyContent: 'center',
		alignItems: 'center',
		borderWidth: 2,
		borderColor: 'rgba(255, 255, 255, 0.3)',
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 2,
		},
		shadowOpacity: 0.25,
		shadowRadius: 3.84,
		elevation: 5,
	},
	secondaryButtonDisabled: {
		backgroundColor: 'rgba(0, 0, 0, 0.4)',
		borderColor: 'rgba(255, 255, 255, 0.1)',
	},
	buttonLabel: {
		...Typography.captionSmall,
		color: AppColors.white,
		marginTop: 2,
		fontWeight: '500',
		textAlign: 'center',
	},
	captureButton: {
		width: 90,
		height: 90,
		borderRadius: 45,
		backgroundColor: AppColors.white,
		justifyContent: 'center',
		alignItems: 'center',
		borderWidth: 5,
		borderColor: AppColors.primaryGreen,
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 4,
		},
		shadowOpacity: 0.3,
		shadowRadius: 4.65,
		elevation: 8,
	},
	captureButtonDisabled: {
		backgroundColor: AppColors.mediumGray,
		borderColor: AppColors.mediumGray,
		opacity: 0.6,
	},
	captureButtonInner: {
		width: 70,
		height: 70,
		borderRadius: 35,
		backgroundColor: AppColors.primaryGreen,
		justifyContent: 'center',
		alignItems: 'center',
	},
	captureButtonInnerActive: {
		backgroundColor: AppColors.darkGreen,
	},
	emulatorWarning: {
		...Typography.body,
		color: AppColors.warning,
		textAlign: 'center',
		marginTop: Spacing.medium,
		fontWeight: 'bold',
	},
	emulatorText: {
		...Typography.caption,
		color: AppColors.mediumGray,
		textAlign: 'center',
		marginTop: Spacing.small,
		marginHorizontal: Spacing.large,
		lineHeight: 20,
	},
});

export default AiScanTab;
