import React from 'react';
import {
  TouchableOpacity,
  Text,
  View,
  ActivityIndicator,
  StyleSheet,
} from 'react-native';
import { AppColors, Typography, BorderRadius, ButtonHeight } from '../../theme';

export const ButtonType = {
  PRIMARY: 'primary',
  SECONDARY: 'secondary',
  ACCENT: 'accent',
};

const CustomButton = ({
  text,
  onPress,
  type = ButtonType.PRIMARY,
  icon: Icon,
  isLoading = false,
  width,
  height = ButtonHeight.large,
  disabled = false,
  style,
  textStyle,
}) => {
  const getButtonColors = () => {
    switch (type) {
      case ButtonType.PRIMARY:
        return {
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
        };
      case ButtonType.SECONDARY:
        return {
          backgroundColor: AppColors.lightGray,
          textColor: AppColors.darkNavy,
        };
      case ButtonType.ACCENT:
        return {
          backgroundColor: AppColors.accentOrange,
          textColor: AppColors.white,
        };
      default:
        return {
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
        };
    }
  };

  const { backgroundColor, textColor } = getButtonColors();

  const buttonStyles = [
    styles.button,
    {
      backgroundColor: disabled ? AppColors.mediumGray : backgroundColor,
      width,
      height,
    },
    style,
  ];

  const textStyles = [
    styles.text,
    { color: textColor },
    textStyle,
  ];

  return (
    <TouchableOpacity
      style={buttonStyles}
      onPress={onPress}
      disabled={disabled || isLoading}
      activeOpacity={0.8}
    >
      {isLoading ? (
        <ActivityIndicator size="small" color={textColor} />
      ) : (
        <View style={styles.content}>
          {Icon && (
            <View style={styles.iconContainer}>
              <Icon size={18} color={textColor} />
            </View>
          )}
          <Text style={textStyles}>{text}</Text>
        </View>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: BorderRadius.medium,
    paddingHorizontal: 24,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 2,
    shadowColor: AppColors.shadowColor,
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconContainer: {
    marginRight: 8,
  },
  text: {
    ...Typography.labelMedium,
    fontWeight: '600',
  },
});

export default CustomButton; 