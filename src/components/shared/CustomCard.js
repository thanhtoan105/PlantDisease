import React from 'react';
import {
  View,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import { AppColors, BorderRadius, CardElevation, Spacing } from '../../theme';

const CustomCard = ({
  children,
  padding = Spacing.lg,
  margin,
  backgroundColor = AppColors.white,
  elevation = CardElevation.medium,
  borderRadius = BorderRadius.large,
  border,
  onPress,
  style,
}) => {
  const cardStyles = [
    styles.card,
    {
      padding,
      margin,
      backgroundColor,
      borderRadius,
      elevation,
      borderWidth: border ? 1 : 0,
      borderColor: border,
    },
    style,
  ];

  const shadowStyles = {
    shadowColor: AppColors.cardShadow,
    shadowOffset: {
      width: 0,
      height: elevation / 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: elevation,
  };

  if (onPress) {
    return (
      <TouchableOpacity
        style={[cardStyles, shadowStyles]}
        onPress={onPress}
        activeOpacity={0.8}
      >
        {children}
      </TouchableOpacity>
    );
  }

  return (
    <View style={[cardStyles, shadowStyles]}>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: AppColors.white,
  },
});

export default CustomCard; 