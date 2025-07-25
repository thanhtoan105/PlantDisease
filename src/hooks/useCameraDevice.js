import { useState, useEffect } from 'react';
import { useCameraDevices } from 'react-native-vision-camera';
import { Platform } from 'react-native';

/**
 * Custom hook for camera device initialization with retry logic
 * Handles edge cases where camera devices aren't immediately available
 */
export const useCameraDevice = () => {
  const [selectedDevice, setSelectedDevice] = useState(null);
  const [isInitializing, setIsInitializing] = useState(true);
  const [error, setError] = useState(null);
  const devices = useCameraDevices();
  
  useEffect(() => {
    let retryCount = 0;
    const maxRetries = 10;
    const retryDelay = 500; // 500ms between retries
    
    const findDevice = () => {
      // Try to find back camera first
      const backDevice = devices.back || devices.find(d => d.position === 'back');
      const anyDevice = devices.find(d => d != null);
      
      if (backDevice) {
        console.log('✅ Back camera device found:', backDevice.id);
        setSelectedDevice(backDevice);
        setIsInitializing(false);
        setError(null);
      } else if (anyDevice) {
        console.log('⚠️ Using available camera (not back):', anyDevice.id);
        setSelectedDevice(anyDevice);
        setIsInitializing(false);
        setError(null);
      } else if (retryCount < maxRetries) {
        retryCount++;
        console.log(`🔄 Retrying camera initialization (${retryCount}/${maxRetries})...`);
        setTimeout(findDevice, retryDelay);
      } else {
        console.error('❌ No camera device found after retries');
        setError('No camera device found. Please ensure camera permissions are granted.');
        setIsInitializing(false);
      }
    };
    
    // Start device search
    findDevice();
    
    // Log available devices for debugging
    if (devices && Object.keys(devices).length > 0) {
      console.log('📱 Available camera devices:', Object.keys(devices));
    }
  }, [devices]);
  
  return {
    device: selectedDevice,
    isInitializing,
    error,
    devices,
  };
};
