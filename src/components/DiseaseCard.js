import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
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
	treatment,
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
				return AppColors.secondary;
			default:
				return AppColors.mediumGray;
		}
	};

	const severityColor = getSeverityColor(severity);

	const renderExpandableSection = (title, content, iconName, iconColor) => (
		<View style={[styles.expandableSection, { borderColor: `${iconColor}33` }]}>
			<View style={styles.expandableSectionHeader}>
				<View
					style={[
						styles.expandableIconContainer,
						{ backgroundColor: `${iconColor}20` },
					]}
				>
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
							<View
								style={[
									styles.severityBadge,
									{ backgroundColor: `${severityColor}20` },
								]}
							>
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
						color={AppColors.secondary}
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
								<Text key={index} style={styles.symptomText}>
									• {symptom}
								</Text>
							))}
						</View>
					)}

					{treatment &&
						renderExpandableSection(
							'Treatment Methods',
							treatment,
							'medical-services',
							AppColors.primaryGreen,
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
