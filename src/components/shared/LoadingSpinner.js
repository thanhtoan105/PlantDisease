import React from 'react';
import { View, ActivityIndicator, Text, StyleSheet } from 'react-native';
import { AppColors, Typography, Spacing } from '../../theme';

const LoadingSpinner = ({ 
  size = 'large', 
  color = AppColors.primaryGreen, 
  text = 'Loading...', 
  showText = true,
  style 
}) => {
  return (
    <View style={[styles.container, style]}>
      <ActivityIndicator size={size} color={color} />
      {showText && <Text style={styles.text}>{text}</Text>}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: Spacing.lg,
  },
  text: {
    ...Typography.body,
    color: AppColors.darkGray,
    marginTop: Spacing.md,
    textAlign: 'center',
  },
});

export default LoadingSpinner;
