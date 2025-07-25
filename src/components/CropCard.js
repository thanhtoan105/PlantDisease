import React from 'react';
import {
  View,
  Text,
  StyleSheet,
} from 'react-native';

import { CustomCard } from './shared';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';

const CropCard = ({
  name,
  description,
  emoji,
  diseaseCount,
  onPress,
}) => {
  return (
    <View style={styles.container}>
      <CustomCard onPress={onPress} padding={Spacing.lg}>
        <View style={styles.content}>
          {/* Emoji Icon - Larger and more prominent */}
          <View style={styles.emojiContainer}>
            <Text style={styles.emoji}>{emoji}</Text>
          </View>

          {/* Crop Name - More prominent */}
          <Text style={styles.name} numberOfLines={2}>
            {name}
          </Text>

          {/* Disease Count Badge - Smaller and less prominent */}
          <View style={styles.diseaseCountContainer}>
            <Text style={styles.diseaseCount}>
              {diseaseCount} diseases
            </Text>
          </View>
        </View>
      </CustomCard>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginRight: Spacing.md,
  },
  content: {
    flex: 1,
    minHeight: 120,
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: Spacing.sm,
  },
  emojiContainer: {
    width: 60,
    height: 60,
    backgroundColor: `${AppColors.primaryGreen}10`,
    borderRadius: BorderRadius.large,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: Spacing.md,
  },
  emoji: {
    fontSize: 32,
  },
  name: {
    ...Typography.labelLarge,
    textAlign: 'center',
    marginBottom: Spacing.sm,
    fontWeight: '600',
    color: AppColors.darkNavy,
  },
  diseaseCountContainer: {
    alignSelf: 'center',
    paddingHorizontal: Spacing.xs,
    paddingVertical: 2,
    backgroundColor: `${AppColors.primaryGreen}15`,
    borderRadius: BorderRadius.small,
  },
  diseaseCount: {
    fontSize: 9,
    fontWeight: '500',
    color: AppColors.primaryGreen,
  },
});

export default CropCard; 