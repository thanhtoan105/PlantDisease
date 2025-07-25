import { Platform } from 'react-native';
import { AppColors } from './colors';

export const FontFamily = {
	interDisplay: Platform.select({
		ios: 'Inter',
		android: 'Inter',
		default: 'Inter',
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
		fontFamily: FontFamily.interDisplay,
		fontSize: 20,
		fontWeight: '600',
		color: AppColors.darkNavy,
	},
	headlineMedium: {
		fontFamily: FontFamily.interDisplay,
		fontSize: 18,
		fontWeight: '600',
		color: AppColors.darkNavy,
	},
	headlineSmall: {
		fontFamily: FontFamily.interDisplay,
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
