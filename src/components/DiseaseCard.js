import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { CustomCard } from './shared';
import { AppColors, Typography, Spacing, BorderRadius } from '../theme';

const DiseaseCard = ({
  name,
  title,
  description,
  severity,
  crops,
  affectedCrops,
  symptoms,
  category,
  onPress,
  style,
}) => {
  const [isExpanded, setIsExpanded] = useState(false);

  const getSeverityColor = (severity) => {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.errorRed;
      case 'moderate':
        return AppColors.accentOrange;
      case 'low':
        return AppColors.secondaryGreen;
      default:
        return AppColors.mediumGray;
    }
  };

  const severityColor = getSeverityColor(severity);

  const renderExpandableSection = (title, content, iconName, iconColor) => (
    <View style={[styles.expandableSection, { borderColor: `${iconColor}33` }]}>
      <View style={styles.expandableSectionHeader}>
        <View style={[styles.expandableIconContainer, { backgroundColor: `${iconColor}20` }]}>
          <Icon name={iconName} size={16} color={iconColor} />
        </View>
        <Text style={styles.expandableSectionTitle}>{title}</Text>
      </View>
      <Text style={styles.expandableSectionContent}>{content}</Text>
    </View>
  );

  const displayName = title || name;
  const displayCrops = affectedCrops || crops || [];
  const displaySymptoms = symptoms || [];

  return (
    <CustomCard padding={0} style={[styles.container, style]}>
      {/* Header */}
      <TouchableOpacity
        style={styles.header}
        onPress={onPress || (() => setIsExpanded(!isExpanded))}
      >
        <View style={styles.headerContent}>
          <View style={styles.headerLeft}>
            <View style={styles.nameRow}>
              <Text style={styles.name}>{displayName}</Text>
              <View style={[styles.severityBadge, { backgroundColor: `${severityColor}20` }]}>
                <Text style={[styles.severityText, { color: severityColor }]}>
                  {severity}
                </Text>
              </View>
            </View>
            {displayCrops.length > 0 && (
              <Text style={styles.cropsText}>
                Affects: {displayCrops.join(', ')}
              </Text>
            )}
          </View>
          <Icon
            name={isExpanded ? 'keyboard-arrow-up' : 'keyboard-arrow-down'}
            size={24}
            color={AppColors.secondaryGreen}
          />
        </View>
      </TouchableOpacity>

      {/* Expandable Content */}
      {isExpanded && (
        <View style={styles.expandedContent}>
          <View style={styles.descriptionSection}>
            <Text style={styles.descriptionTitle}>Description</Text>
            <Text style={styles.descriptionText}>{description}</Text>
          </View>

          {displaySymptoms.length > 0 && (
            <View style={styles.descriptionSection}>
              <Text style={styles.descriptionTitle}>Common Symptoms</Text>
              {displaySymptoms.map((symptom, index) => (
                <Text key={index} style={styles.symptomText}>• {symptom}</Text>
              ))}
            </View>
          )}

          {renderExpandableSection(
            'Treatment Methods',
            '• Apply fungicide spray every 7-10 days\n• Remove and destroy infected plant parts\n• Improve drainage around plants\n• Use copper-based treatments for severe cases',
            'medical-services',
            AppColors.primaryGreen
          )}

          {renderExpandableSection(
            'Prevention Tips',
            '• Maintain proper plant spacing\n• Ensure good air circulation\n• Water at soil level, not on leaves\n• Remove infected plant material\n• Rotate crops annually',
            'shield',
            AppColors.secondaryGreen
          )}

          {renderExpandableSection(
            'Symptoms to Watch',
            '• Dark spots on leaves and stems\n• Yellowing of affected areas\n• Wilting during warm weather\n• White fungal growth on undersides',
            'visibility',
            AppColors.accentOrange
          )}
        </View>
      )}
    </CustomCard>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: Spacing.md,
    overflow: 'hidden',
  },
  header: {
    backgroundColor: AppColors.lightGray,
    padding: Spacing.lg,
  },
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerLeft: {
    flex: 1,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.xs,
  },
  name: {
    ...Typography.labelMedium,
    marginRight: Spacing.sm,
  },
  severityBadge: {
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
    borderRadius: Spacing.sm,
  },
  severityText: {
    fontSize: 10,
    fontWeight: '500',
  },
  cropsText: {
    ...Typography.bodySmall,
  },
  expandedContent: {
    backgroundColor: AppColors.white,
    padding: Spacing.lg,
  },
  descriptionSection: {
    marginBottom: Spacing.md,
  },
  descriptionTitle: {
    ...Typography.labelSmall,
    marginBottom: Spacing.xs,
  },
  descriptionText: {
    ...Typography.bodySmall,
  },
  symptomText: {
    ...Typography.bodySmall,
    marginBottom: 2,
  },
  expandableSection: {
    backgroundColor: AppColors.lightGray,
    borderRadius: BorderRadius.medium,
    borderWidth: 1,
    padding: Spacing.md,
    marginBottom: Spacing.md,
  },
  expandableSectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  expandableIconContainer: {
    padding: 6,
    borderRadius: Spacing.sm,
    marginRight: Spacing.sm,
  },
  expandableSectionTitle: {
    ...Typography.labelSmall,
  },
  expandableSectionContent: {
    ...Typography.bodySmall,
    lineHeight: 16,
  },
});

export default DiseaseCard; 