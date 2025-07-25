import React, { useState, useRef, useEffect } from 'react';
import {
	View,
	Text,
	TouchableOpacity,
	StyleSheet,
	SafeAreaView,
	Alert,
	StatusBar,
	ActivityIndicator,
} from 'react-native';
import {
	Camera,
	useCameraDevices,
	useCameraPermission,
} from 'react-native-vision-camera';
import { launchImageLibrary } from 'react-native-image-picker';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation } from '@react-navigation/native';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import TensorFlowService from '../services/TensorFlowService';
import PlantDiseaseService from '../services/PlantDiseaseService';
import { useTensorFlowModel } from '../hooks/useTensorFlowModel';

const CameraScreen = () => {
	const navigation = useNavigation();
	const cameraRef = useRef(null);
	const { hasPermission, requestPermission } = useCameraPermission();
	const devices = useCameraDevices();
	const [facing, setFacing] = useState('back');
	const [flash, setFlash] = useState('off');
	const [isCapturing, setIsCapturing] = useState(false);
	
	// Use the TensorFlow hook
	const tensorflowModel = useTensorFlowModel();

	const device = facing === 'back' ? devices.back : devices.front;

	useEffect(() => {
		if (!hasPermission) {
			requestPermission();
		}
	}, [hasPermission, requestPermission]);

	const takePicture = async () => {
		if (cameraRef.current && !isCapturing) {
			try {
				setIsCapturing(true);
				const photo = await cameraRef.current.takePhoto({
					quality: 80,
					flash: flash,
				});

				const imageUri = `file://${photo.path}`;

				// Analyze the image with TensorFlow
				await analyzeImage(imageUri);
			} catch (error) {
				console.error('Error taking picture:', error);
				Alert.alert('Error', 'Failed to take picture. Please try again.');
			} finally {
				setIsCapturing(false);
			}
		}
	};

	const analyzeImage = async (imageUri) => {
		try {
			console.log('Starting analysis for image:', imageUri);

			// Check if model is loaded
			if (!tensorflowModel.isLoaded) {
				Alert.alert('Model Not Ready', 'Please wait for the model to load before analyzing images.');
				return;
			}

			// Use the TensorFlow hook for analysis
			const result = await tensorflowModel.analyzeImage(imageUri);

			if (result.success) {
				console.log('Analysis successful:', result.data);

				// Enhance with database information
				const enhancedResult = await PlantDiseaseService.analyzeImage(imageUri);

				// Navigate to results screen with the analysis data
				navigation.navigate('Results', {
					imageUri,
					analysisResult: enhancedResult.success ? enhancedResult.data : result.data,
				});
			} else {
				console.error('Analysis failed:', result.error);
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
			console.error('Error analyzing image:', error);
			Alert.alert('Error', 'Failed to analyze the image. Please try again.', [
				{
					text: 'Try Again',
					onPress: () => analyzeImage(imageUri),
				},
				{
					text: 'Cancel',
					style: 'cancel',
				},
			]);
		}
	};

	const pickFromGallery = async () => {
		try {
			const options = {
				mediaType: 'photo',
				includeBase64: false,
				maxHeight: 2000,
				maxWidth: 2000,
				quality: 0.8,
			};

			launchImageLibrary(options, async (response) => {
				if (response.didCancel) {
					console.log('User cancelled image picker');
				} else if (response.error) {
					console.error('ImagePicker Error: ', response.error);
					Alert.alert('Error', 'Failed to pick image from gallery.');
				} else if (response.assets && response.assets[0]) {
					const imageUri = response.assets[0].uri;
					console.log('Selected image from gallery:', imageUri);
					await analyzeImage(imageUri);
				}
			});
		} catch (error) {
			console.error('Error picking from gallery:', error);
			Alert.alert('Error', 'Failed to pick image from gallery.');
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

	if (!device) {
		return (
			<View style={styles.permissionContainer}>
				<Text style={styles.permissionText}>Camera device not available</Text>
			</View>
		);
	}

	return (
		<SafeAreaView style={styles.container}>
			<StatusBar barStyle='light-content' backgroundColor='black' />

			{/* Model Status Indicator */}
			<View style={styles.statusContainer}>
				<View
					style={[
						styles.statusIndicator,
						{
							backgroundColor: tensorflowModel.isLoaded
								? AppColors.success
								: tensorflowModel.error
								? AppColors.error
								: AppColors.accentOrange,
						},
					]}
				>
					<Text style={styles.statusText}>
						{tensorflowModel.isLoaded 
							? 'Model Ready' 
							: tensorflowModel.error 
							? 'Model Error' 
							: 'Model Loading...'}
					</Text>
				</View>
			</View>

			{/* Camera View */}
			<View style={styles.cameraContainer}>
				<Camera
					ref={cameraRef}
					style={styles.camera}
					device={device}
					isActive={true}
					photo={true}
					enableZoomGesture={true}
				/>

				{/* Loading Overlay */}
				{(isCapturing || tensorflowModel.isAnalyzing) && (
					<View style={styles.loadingOverlay}>
						<ActivityIndicator size='large' color={AppColors.white} />
						<Text style={styles.loadingText}>
							{isCapturing ? 'Capturing...' : 'Analyzing Image...'}
						</Text>
					</View>
				)}

				{/* Camera Guide Overlay */}
				<View style={styles.guideOverlay}>
					<View style={styles.guideFrame} />
					<Text style={styles.guideText}>
						Position the plant leaf within the frame
					</Text>
				</View>
			</View>

			{/* Controls */}
			<View style={styles.controlsContainer}>
				{/* Top Controls */}
				<View style={styles.topControls}>
					<TouchableOpacity
						style={styles.controlButton}
						onPress={() => navigation.goBack()}
					>
						<Icon name='arrow-back' size={24} color={AppColors.white} />
					</TouchableOpacity>

					<TouchableOpacity style={styles.controlButton} onPress={toggleFlash}>
						<Icon
							name={flash === 'on' ? 'flash-on' : 'flash-off'}
							size={24}
							color={AppColors.white}
						/>
					</TouchableOpacity>
				</View>

				{/* Bottom Controls */}
				<View style={styles.bottomControls}>
					<TouchableOpacity
						style={styles.galleryButton}
						onPress={pickFromGallery}
						disabled={isCapturing || tensorflowModel.isAnalyzing}
					>
						<Icon name='photo-library' size={24} color={AppColors.white} />
					</TouchableOpacity>

					<TouchableOpacity
						style={[
							styles.captureButton,
							(isCapturing || tensorflowModel.isAnalyzing || !tensorflowModel.isLoaded) &&
								styles.captureButtonDisabled,
						]}
						onPress={takePicture}
						disabled={isCapturing || tensorflowModel.isAnalyzing || !tensorflowModel.isLoaded}
					>
						<View style={styles.captureButtonInner} />
					</TouchableOpacity>

					<TouchableOpacity
						style={styles.flipButton}
						onPress={toggleCamera}
						disabled={isCapturing || tensorflowModel.isAnalyzing}
					>
						<Icon name='flip-camera-ios' size={24} color={AppColors.white} />
					</TouchableOpacity>
				</View>
			</View>
		</SafeAreaView>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: 'black',
	},
	permissionContainer: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: AppColors.lightGray,
		padding: Spacing.large,
	},
	permissionText: {
		...Typography.body,
		textAlign: 'center',
		marginBottom: Spacing.large,
		color: AppColors.mediumGray,
	},
	permissionButton: {
		backgroundColor: AppColors.primaryGreen,
		paddingHorizontal: Spacing.large,
		paddingVertical: Spacing.medium,
		borderRadius: BorderRadius.medium,
	},
	permissionButtonText: {
		...Typography.button,
		color: AppColors.white,
	},
	statusContainer: {
		position: 'absolute',
		top: 60,
		left: 20,
		right: 20,
		zIndex: 10,
	},
	statusIndicator: {
		paddingHorizontal: Spacing.medium,
		paddingVertical: Spacing.small,
		borderRadius: BorderRadius.small,
		alignSelf: 'center',
	},
	statusText: {
		...Typography.caption,
		color: AppColors.white,
		fontWeight: 'bold',
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
		...Typography.body,
		color: AppColors.white,
		marginTop: Spacing.medium,
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
		width: 250,
		height: 250,
		borderWidth: 2,
		borderColor: AppColors.white,
		borderRadius: BorderRadius.medium,
		backgroundColor: 'transparent',
	},
	guideText: {
		...Typography.caption,
		color: AppColors.white,
		textAlign: 'center',
		marginTop: Spacing.medium,
		backgroundColor: 'rgba(0, 0, 0, 0.5)',
		paddingHorizontal: Spacing.medium,
		paddingVertical: Spacing.small,
		borderRadius: BorderRadius.small,
	},
	controlsContainer: {
		position: 'absolute',
		top: 0,
		left: 0,
		right: 0,
		bottom: 0,
		justifyContent: 'space-between',
		padding: Spacing.large,
	},
	topControls: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		marginTop: 40,
	},
	bottomControls: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		marginBottom: 40,
	},
	controlButton: {
		width: 48,
		height: 48,
		borderRadius: 24,
		backgroundColor: 'rgba(0, 0, 0, 0.5)',
		justifyContent: 'center',
		alignItems: 'center',
	},
	captureButton: {
		width: 80,
		height: 80,
		borderRadius: 40,
		backgroundColor: AppColors.white,
		justifyContent: 'center',
		alignItems: 'center',
		borderWidth: 4,
		borderColor: 'rgba(255, 255, 255, 0.3)',
	},
	captureButtonDisabled: {
		backgroundColor: AppColors.disabled,
		borderColor: 'rgba(0, 0, 0, 0.3)',
	},
	captureButtonInner: {
		width: 60,
		height: 60,
		borderRadius: 30,
		backgroundColor: AppColors.white,
	},
	galleryButton: {
		width: 48,
		height: 48,
		borderRadius: 24,
		backgroundColor: 'rgba(0, 0, 0, 0.5)',
		justifyContent: 'center',
		alignItems: 'center',
	},
	flipButton: {
		width: 48,
		height: 48,
		borderRadius: 24,
		backgroundColor: 'rgba(0, 0, 0, 0.5)',
		justifyContent: 'center',
		alignItems: 'center',
	},
});

export default CameraScreen;
