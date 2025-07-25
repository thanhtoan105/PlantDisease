const { AppColors } = require('../theme/colors');

/**
 * Validates that all required color properties are defined in AppColors
 * Call this function during app initialization to catch missing colors early
 */
const validateColors = () => {
  const requiredColors = [
    'primaryGreen',
    'secondary', 
    'accentOrange',
    'darkNavy',
    'mediumGray',
    'lightGray',
    'white',
    'errorRed',
    'successGreen', 
    'warningOrange',
    'error',
    'success',
    'warning',
    'info',
    'disabled',
    'shadowColor',
    'cardShadow',
    'darkGray'
  ];

  const missingColors = requiredColors.filter(color => !AppColors[color]);
  
  if (missingColors.length > 0) {
    console.error('Missing color properties:', missingColors);
    throw new Error(`Missing color properties: ${missingColors.join(', ')}`);
  }
  
  console.log('✅ All color properties are properly defined');
  return true;
};

/**
 * Get a color safely with fallback
 */
const getColor = (colorName, fallback = '#000000') => {
  return AppColors[colorName] || fallback;
};

module.exports = { validateColors, getColor }; 