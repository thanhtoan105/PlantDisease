import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  Modal,
  ScrollView,
  Dimensions,
  StatusBar,
} from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation } from '@react-navigation/native';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard, CustomButton, ButtonType } from '../components/shared';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

const AiScanTab = () => {
  const navigation = useNavigation();
  const cameraRef = useRef(null);
  const [permission, requestPermission] = useCameraPermissions();
  const [facing, setFacing] = useState('back');
  const [flash, setFlash] = useState('off');
  const [isCapturing, setIsCapturing] = useState(false);
  const [showTips, setShowTips] = useState(false);

  const photographyTips = [
    {
      icon: 'wb-sunny',
      title: 'Good Lighting',
      description: 'Take photos in natural daylight for best results. Avoid harsh shadows and direct sunlight.',
    },
    {
      icon: 'center-focus-strong',
      title: 'Focus on the Plant',
      description: 'Make sure the affected area fills most of the frame. Keep the plant in sharp focus.',
    },
    {
      icon: 'camera-alt',
      title: 'Steady Shot',
      description: 'Hold the camera steady and tap to focus. Take multiple photos from different angles.',
    },
    {
      icon: 'visibility',
      title: 'Clear View',
      description: 'Remove any obstructions like other leaves or debris blocking the affected area.',
    },
    {
      icon: 'crop',
      title: 'Close-up Detail',
      description: 'Get close enough to see disease symptoms clearly, but not so close that details are blurry.',
    },
    {
      icon: 'palette',
      title: 'True Colors',
      description: 'Ensure colors appear natural. Avoid filters or extreme lighting that changes leaf color.',
    },
  ];

  // Permission is now handled by the useCameraPermissions hook

  const toggleFlash = () => {
    setFlash(current =>
      current === 'off'
        ? 'on'
        : 'off'
    );
  };

  const flipCamera = () => {
    setFacing(current =>
      current === 'back'
        ? 'front'
        : 'back'
    );
  };

  const takePicture = async () => {
    if (!cameraRef.current || isCapturing) return;

    try {
      setIsCapturing(true);
      
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.8,
        base64: false,
        exif: false,
      });

      // Save to a media library
      await MediaLibrary.saveToLibraryAsync(photo.uri);
      
      // Navigate to the result screen with the photo
      navigation.navigate('Results', { 
        imageUri: photo.uri,
        source: 'camera',
        timestamp: new Date().toISOString(),
      });
      
    } catch (error) {
      console.error('Error taking picture:', error);
      Alert.alert(
        'Camera Error',
        'Failed to take picture. Please try again.',
        [{ text: 'OK' }]
      );
    } finally {
      setIsCapturing(false);
    }
  };

  const pickImageFromGallery = async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [4, 3],
        quality: 0.8,
      });

      if (!result.canceled && result.assets[0]) {
        navigation.navigate('Results', { 
          imageUri: result.assets[0].uri,
          source: 'gallery',
          timestamp: new Date().toISOString(),
        });
      }
    } catch (error) {
      console.error('Error picking image:', error);
      Alert.alert(
        'Gallery Error',
        'Failed to select image from gallery.',
        [{ text: 'OK' }]
      );
    }
  };

  const renderTipsModal = () => (
    <Modal
      visible={showTips}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={() => setShowTips(false)}
    >
      <SafeAreaView style={styles.tipsModal}>
        <View style={styles.tipsHeader}>
          <Text style={styles.tipsTitle}>Photography Tips</Text>
          <TouchableOpacity onPress={() => setShowTips(false)}>
            <Icon name="close" size={24} color={AppColors.darkNavy} />
          </TouchableOpacity>
        </View>
        
        <ScrollView style={styles.tipsContent} showsVerticalScrollIndicator={false}>
          <Text style={styles.tipsSubtitle}>
            Follow these tips to get the best results from AI disease detection:
          </Text>
          
          {photographyTips.map((tip, index) => (
            <CustomCard key={index} style={styles.tipCard}>
              <View style={styles.tipContent}>
                <View style={[styles.tipIcon, { backgroundColor: `${AppColors.primaryGreen}20` }]}>
                  <Icon name={tip.icon} size={24} color={AppColors.primaryGreen} />
                </View>
                <View style={styles.tipText}>
                  <Text style={styles.tipTitle}>{tip.title}</Text>
                  <Text style={styles.tipDescription}>{tip.description}</Text>
                </View>
              </View>
            </CustomCard>
          ))}
          
          <View style={styles.tipsFooter}>
            <CustomButton
              title="Got it!"
              type={ButtonType.PRIMARY}
              onPress={() => setShowTips(false)}
            />
          </View>
        </ScrollView>
      </SafeAreaView>
    </Modal>
  );

  const renderCameraControls = () => (
    <View style={styles.controlsContainer}>
      {/* Top controls */}
      <View style={styles.topControls}>
        <TouchableOpacity
          style={styles.controlButton}
          onPress={toggleFlash}
        >
          <Icon
            name={flash === 'on' ? 'flash-on' : 'flash-off'}
            size={24}
            color={AppColors.white}
          />
        </TouchableOpacity>
      </View>

      {/* Empty center area */}
      <View style={styles.centerControls} />

      {/* Tips button above capture */}
      <View style={styles.tipsContainer}>
        <TouchableOpacity
          style={styles.tipsButton}
          onPress={() => setShowTips(true)}
        >
          <Text style={styles.tipsButtonText}>Tips</Text>
        </TouchableOpacity>
      </View>

      {/* Bottom controls */}
      <View style={styles.bottomControls}>
        <TouchableOpacity
          style={styles.galleryButton}
          onPress={pickImageFromGallery}
        >
          <Icon name="photo-library" size={24} color={AppColors.white} />
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.captureButton, isCapturing && styles.capturingButton]}
          onPress={takePicture}
          disabled={isCapturing}
        >
          {isCapturing && (
            <View style={styles.capturingIndicator} />
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.flipButton}
          onPress={flipCamera}
        >
          <Icon name="flip-camera-ios" size={24} color={AppColors.white} />
        </TouchableOpacity>
      </View>
    </View>
  );

  const renderPermissionScreen = () => (
    <View style={styles.permissionContainer}>
      <Icon name="camera-alt" size={64} color={AppColors.mediumGray} />
      <Text style={styles.permissionTitle}>Camera Access Required</Text>
      <Text style={styles.permissionMessage}>
        This app needs access to your camera and photo library to scan plants for diseases.
      </Text>
      <CustomButton
        title="Grant Permission"
        type={ButtonType.PRIMARY}
        onPress={requestPermission}
        style={styles.permissionButton}
      />
    </View>
  );

  const renderLoadingScreen = () => (
    <View style={styles.loadingContainer}>
      <Icon name="camera" size={64} color={AppColors.primaryGreen} />
      <Text style={styles.loadingText}>Loading Camera...</Text>
    </View>
  );

  if (!permission) {
    return renderLoadingScreen();
  }

  if (!permission.granted) {
    return (
      <SafeAreaView style={styles.container}>
        {renderPermissionScreen()}
      </SafeAreaView>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="transparent" translucent />

      <CameraView
        ref={cameraRef}
        style={styles.camera}
        facing={facing}
        flash={flash}
      >
        {renderCameraControls()}
      </CameraView>

      {renderTipsModal()}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.black,
  },
  camera: {
    flex: 1,
    justifyContent: 'space-between',
  },
  controlsContainer: {
    flex: 1,
    justifyContent: 'space-between',
    paddingTop: 60,
    paddingBottom: 40,
    paddingHorizontal: Spacing.lg,
  },
  topControls: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
    paddingHorizontal: 4,
  },
  centerControls: {
    flex: 1,
  },
  tipsContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  bottomControls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  controlButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  tipsButton: {
    backgroundColor: AppColors.white,
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  tipsButtonText: {
    color: '#333',
    fontSize: 14,
    fontWeight: '500',
  },

  galleryButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  captureButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: AppColors.white,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 3,
    borderColor: '#333',
  },
  flipButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  capturingButton: {
    backgroundColor: AppColors.primaryGreen,
  },
  captureButtonInner: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: AppColors.primaryGreen,
    alignItems: 'center',
    justifyContent: 'center',
  },
  capturingIndicator: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: AppColors.white,
  },
  placeholderButton: {
    width: 60,
    height: 60,
  },
  permissionContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: Spacing.xl,
    backgroundColor: AppColors.lightGray,
  },
  permissionTitle: {
    ...Typography.headlineMedium,
    marginTop: Spacing.xl,
    marginBottom: Spacing.md,
    textAlign: 'center',
  },
  permissionMessage: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    textAlign: 'center',
    marginBottom: Spacing.xl,
  },
  permissionButton: {
    minWidth: 200,
  },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: AppColors.lightGray,
  },
  loadingText: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginTop: Spacing.lg,
  },
  tipsModal: {
    flex: 1,
    backgroundColor: AppColors.white,
  },
  tipsHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.lightGray,
  },
  tipsTitle: {
    ...Typography.headlineMedium,
  },
  tipsContent: {
    flex: 1,
    padding: Spacing.lg,
  },
  tipsSubtitle: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginBottom: Spacing.xl,
    textAlign: 'center',
  },
  tipCard: {
    marginBottom: Spacing.lg,
  },
  tipContent: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  tipIcon: {
    width: 48,
    height: 48,
    borderRadius: BorderRadius.medium,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.md,
  },
  tipText: {
    flex: 1,
  },
  tipTitle: {
    ...Typography.labelLarge,
    marginBottom: Spacing.xs,
  },
  tipDescription: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    lineHeight: 20,
  },
  tipsFooter: {
    paddingVertical: Spacing.xl,
  },
});

export default AiScanTab; 