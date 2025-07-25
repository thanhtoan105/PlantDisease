import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
} from 'react-native';
import { AppColors, Typography } from '../theme';

const MockCameraView = ({ onCapture, isScanning }) => {
  return (
    <View style={styles.container}>
      <View style={styles.mockCamera}>
        <Text style={styles.emulatorText}>📷 Emulator Camera</Text>
        <Text style={styles.infoText}>
          Camera not available in emulator
        </Text>
        <Text style={styles.suggestionText}>
          For testing, you can:
          {'\n'}• Use a real device
          {'\n'}• Enable emulator camera in AVD settings
          {'\n'}• Upload an image from gallery
        </Text>
        
        {isScanning && (
          <View style={styles.scanningOverlay}>
            <Text style={styles.scanningText}>
              🔍 Simulating scan...
            </Text>
          </View>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  mockCamera: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#333',
  },
  emulatorText: {
    ...Typography.headlineMedium,
    color: AppColors.white,
    marginBottom: 16,
  },
  infoText: {
    ...Typography.bodyMedium,
    color: AppColors.white,
    marginBottom: 8,
  },
  suggestionText: {
    ...Typography.captionMedium,
    color: AppColors.lightGray,
    textAlign: 'center',
    paddingHorizontal: 20,
    marginTop: 16,
  },
  scanningOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  scanningText: {
    ...Typography.bodyMedium,
    color: AppColors.white,
  },
});

export default MockCameraView;
