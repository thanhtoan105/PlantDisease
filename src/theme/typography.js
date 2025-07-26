import { Platform } from 'react-native';
import { AppColors } from './colors';

export const FontFamily = {
  playfairDisplay: Platform.select({
    ios: 'PlayfairDisplay',
    android: 'PlayfairDisplay-Regular',
    default: 'PlayfairDisplay',
  }),
  roboto: Platform.select({
    ios: 'System',
    android: 'Roboto',
    default: 'System',
  }),
};

export const Typography = {
  // Headings - Playfair Display
  headlineLarge: {
    fontFamily: FontFamily.playfairDisplay,
    fontSize: 20,
    fontWeight: '600',
    color: AppColors.darkNavy,
  },
  headlineMedium: {
    fontFamily: FontFamily.playfairDisplay,
    fontSize: 18,
    fontWeight: '600',
    color: AppColors.darkNavy,
  },
  headlineSmall: {
    fontFamily: FontFamily.playfairDisplay,
    fontSize: 16,
    fontWeight: '600',
    color: AppColors.darkNavy,
  },

  // Body text - Roboto
  bodyLarge: {
    fontFamily: FontFamily.roboto,
    fontSize: 16,
    fontWeight: '400',
    color: AppColors.darkNavy,
  },
  bodyMedium: {
    fontFamily: FontFamily.roboto,
    fontSize: 14,
    fontWeight: '400',
    color: AppColors.darkNavy,
  },
  bodySmall: {
    fontFamily: FontFamily.roboto,
    fontSize: 12,
    fontWeight: '400',
    color: AppColors.mediumGray,
  },

  // Labels - Roboto Semibold
  labelLarge: {
    fontFamily: FontFamily.roboto,
    fontSize: 16,
    fontWeight: '600',
    color: AppColors.darkNavy,
  },
  labelMedium: {
    fontFamily: FontFamily.roboto,
    fontSize: 14,
    fontWeight: '600',
    color: AppColors.darkNavy,
  },
  labelSmall: {
    fontFamily: FontFamily.roboto,
    fontSize: 12,
    fontWeight: '600',
    color: AppColors.darkNavy,
  },
}; 