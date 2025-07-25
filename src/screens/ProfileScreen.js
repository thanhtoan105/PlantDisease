import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  Switch,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { AppColors, Typography, Spacing, BorderRadius } from '../theme';
import { CustomCard, CustomButton, ButtonType } from '../components/shared';

const ProfileScreen = () => {
  const navigation = useNavigation();
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [darkModeEnabled, setDarkModeEnabled] = useState(false);

  const userStats = {
    scansCompleted: 47,
    diseasesDetected: 12,
    plantsSaved: 8,
    streakDays: 15,
  };

  const profileOptions = [
    {
      id: 'personal-info',
      title: 'Personal Information',
      subtitle: 'Update your profile details',
      icon: 'person',
      onPress: () => Alert.alert('Personal Info', 'This would open personal information settings.'),
    },
    {
      id: 'scan-history',
      title: 'Scan History',
      subtitle: 'View your previous scans',
      icon: 'history',
      onPress: () => Alert.alert('Scan History', 'This would show scan history.'),
    },
    {
      id: 'favorites',
      title: 'Favorite Crops',
      subtitle: 'Manage your favorite crops',
      icon: 'favorite',
      onPress: () => Alert.alert('Favorites', 'This would show favorite crops.'),
    },
    {
      id: 'weather-settings',
      title: 'Weather Settings',
      subtitle: 'Configure weather preferences',
      icon: 'wb-sunny',
      onPress: () => Alert.alert('Weather Settings', 'This would open weather settings.'),
    },
    {
      id: 'help',
      title: 'Help & Support',
      subtitle: 'Get help and contact support',
      icon: 'help',
      onPress: () => Alert.alert('Help', 'This would open help and support.'),
    },
    {
      id: 'about',
      title: 'About PlantAI',
      subtitle: 'Learn more about the app',
      icon: 'info',
      onPress: () => Alert.alert('About', 'PlantAI Disease Detection v1.0.0'),
    },
  ];

  const renderHeader = () => (
    <View style={styles.header}>
      <TouchableOpacity
        style={styles.backButton}
        onPress={() => navigation.goBack()}
      >
        <Icon name="arrow-back" size={24} color={AppColors.darkNavy} />
      </TouchableOpacity>
      
      <Text style={styles.headerTitle}>Profile</Text>
      
      <TouchableOpacity style={styles.editButton}>
        <Icon name="edit" size={24} color={AppColors.darkNavy} />
      </TouchableOpacity>
    </View>
  );

  const renderProfileInfo = () => (
    <CustomCard style={styles.profileCard}>
      <View style={styles.avatarContainer}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>JD</Text>
        </View>
        <View style={styles.profileTextContainer}>
          <Text style={styles.userName}>John Doe</Text>
          <Text style={styles.userEmail}>john.doe@example.com</Text>
          <Text style={styles.joinDate}>Member since March 2024</Text>
        </View>
      </View>
    </CustomCard>
  );

  const renderStatsCard = () => (
    <CustomCard style={styles.statsCard}>
      <Text style={styles.statsTitle}>Your Statistics</Text>
      <View style={styles.statsGrid}>
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>{userStats.scansCompleted}</Text>
          <Text style={styles.statLabel}>Scans Completed</Text>
        </View>
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>{userStats.diseasesDetected}</Text>
          <Text style={styles.statLabel}>Diseases Detected</Text>
        </View>
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>{userStats.plantsSaved}</Text>
          <Text style={styles.statLabel}>Plants Saved</Text>
        </View>
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>{userStats.streakDays}</Text>
          <Text style={styles.statLabel}>Day Streak</Text>
        </View>
      </View>
    </CustomCard>
  );

  const renderSettingsSection = () => (
    <View style={styles.settingsSection}>
      <Text style={styles.sectionTitle}>Settings</Text>
      
      <CustomCard style={styles.settingsCard}>
        <View style={styles.settingItem}>
          <View style={styles.settingLeft}>
            <Icon name="notifications" size={20} color={AppColors.primaryGreen} />
            <View style={styles.settingTextContainer}>
              <Text style={styles.settingTitle}>Push Notifications</Text>
              <Text style={styles.settingSubtitle}>Get alerts for weather and plant care</Text>
            </View>
          </View>
          <Switch
            value={notificationsEnabled}
            onValueChange={setNotificationsEnabled}
            trackColor={{ false: AppColors.lightGray, true: AppColors.primaryGreen }}
            thumbColor={notificationsEnabled ? AppColors.white : AppColors.mediumGray}
          />
        </View>

        <View style={styles.settingDivider} />

        <View style={styles.settingItem}>
          <View style={styles.settingLeft}>
            <Icon name="dark-mode" size={20} color={AppColors.primaryGreen} />
            <View style={styles.settingTextContainer}>
              <Text style={styles.settingTitle}>Dark Mode</Text>
              <Text style={styles.settingSubtitle}>Switch to dark theme</Text>
            </View>
          </View>
          <Switch
            value={darkModeEnabled}
            onValueChange={setDarkModeEnabled}
            trackColor={{ false: AppColors.lightGray, true: AppColors.primaryGreen }}
            thumbColor={darkModeEnabled ? AppColors.white : AppColors.mediumGray}
          />
        </View>
      </CustomCard>
    </View>
  );

  const renderProfileOptions = () => (
    <View style={styles.optionsSection}>
      <Text style={styles.sectionTitle}>Account</Text>
      
      <CustomCard style={styles.optionsCard}>
        {profileOptions.map((option, index) => (
          <View key={option.id}>
            <TouchableOpacity
              style={styles.optionItem}
              onPress={option.onPress}
            >
              <View style={styles.optionLeft}>
                <View style={styles.optionIconContainer}>
                  <Icon name={option.icon} size={20} color={AppColors.primaryGreen} />
                </View>
                <View style={styles.optionTextContainer}>
                  <Text style={styles.optionTitle}>{option.title}</Text>
                  <Text style={styles.optionSubtitle}>{option.subtitle}</Text>
                </View>
              </View>
              <Icon name="chevron-right" size={20} color={AppColors.mediumGray} />
            </TouchableOpacity>
            {index < profileOptions.length - 1 && <View style={styles.optionDivider} />}
          </View>
        ))}
      </CustomCard>
    </View>
  );

  const renderSignOutButton = () => (
    <View style={styles.signOutSection}>
      <CustomButton
        text="Sign Out"
        type={ButtonType.SECONDARY}
        icon={({ size, color }) => (
          <Icon name="logout" size={size} color={color} />
        )}
        onPress={() => {
          Alert.alert(
            'Sign Out',
            'Are you sure you want to sign out?',
            [
              { text: 'Cancel', style: 'cancel' },
              { text: 'Sign Out', style: 'destructive', onPress: () => console.log('Sign out') },
            ]
          );
        }}
        style={styles.signOutButton}
      />
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      {renderHeader()}
      
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {renderProfileInfo()}
        {renderStatsCard()}
        {renderSettingsSection()}
        {renderProfileOptions()}
        {renderSignOutButton()}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.lightGray,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    backgroundColor: AppColors.white,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.lightGray,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.medium,
    backgroundColor: AppColors.lightGray,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerTitle: {
    ...Typography.headlineLarge,
    flex: 1,
    textAlign: 'center',
  },
  editButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.medium,
    backgroundColor: AppColors.lightGray,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.lg,
  },
  profileCard: {
    marginBottom: Spacing.lg,
  },
  avatarContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: AppColors.primaryGreen,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.lg,
  },
  avatarText: {
    ...Typography.headlineLarge,
    color: AppColors.white,
    fontWeight: '700',
  },
  profileTextContainer: {
    flex: 1,
  },
  userName: {
    ...Typography.headlineMedium,
    marginBottom: Spacing.xs,
  },
  userEmail: {
    ...Typography.bodyMedium,
    color: AppColors.mediumGray,
    marginBottom: Spacing.xs,
  },
  joinDate: {
    ...Typography.bodySmall,
    color: AppColors.mediumGray,
  },
  statsCard: {
    marginBottom: Spacing.lg,
  },
  statsTitle: {
    ...Typography.labelLarge,
    marginBottom: Spacing.lg,
    textAlign: 'center',
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  statItem: {
    width: '50%',
    alignItems: 'center',
    marginBottom: Spacing.lg,
  },
  statNumber: {
    ...Typography.headlineLarge,
    color: AppColors.primaryGreen,
    fontWeight: '700',
  },
  statLabel: {
    ...Typography.bodySmall,
    color: AppColors.mediumGray,
    marginTop: Spacing.xs,
    textAlign: 'center',
  },
  settingsSection: {
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    ...Typography.labelLarge,
    marginBottom: Spacing.md,
    color: AppColors.darkNavy,
  },
  settingsCard: {
    paddingVertical: Spacing.sm,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: Spacing.md,
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  settingTextContainer: {
    marginLeft: Spacing.md,
    flex: 1,
  },
  settingTitle: {
    ...Typography.labelMedium,
    marginBottom: 2,
  },
  settingSubtitle: {
    ...Typography.bodySmall,
    color: AppColors.mediumGray,
  },
  settingDivider: {
    height: 1,
    backgroundColor: AppColors.lightGray,
    marginLeft: 44,
  },
  optionsSection: {
    marginBottom: Spacing.lg,
  },
  optionsCard: {
    paddingVertical: Spacing.sm,
  },
  optionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: Spacing.md,
  },
  optionLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  optionIconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: `${AppColors.primaryGreen}20`,
    alignItems: 'center',
    justifyContent: 'center',
  },
  optionTextContainer: {
    marginLeft: Spacing.md,
    flex: 1,
  },
  optionTitle: {
    ...Typography.labelMedium,
    marginBottom: 2,
  },
  optionSubtitle: {
    ...Typography.bodySmall,
    color: AppColors.mediumGray,
  },
  optionDivider: {
    height: 1,
    backgroundColor: AppColors.lightGray,
    marginLeft: 60,
  },
  signOutSection: {
    paddingBottom: Spacing.xxl,
  },
  signOutButton: {
    borderColor: AppColors.errorRed,
  },
});

export default ProfileScreen; 