import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import Icon from 'react-native-vector-icons/MaterialIcons';

import { AppColors } from '../theme';

// Screens
import HomeTab from '../screens/HomeTab';
import AiScanTab from '../screens/AiScanTab';
import ProfileTab from '../screens/ProfileTab';
import CameraScreen from '../screens/CameraScreen';
import ResultsScreen from '../screens/ResultsScreen';
import CropDetailsScreen from '../screens/CropDetailsScreen';
import CropLibraryScreen from '../screens/CropLibraryScreen';
import DiseaseGuideScreen from '../screens/DiseaseGuideScreen';
import WeatherDetailsScreen from '../screens/WeatherDetailsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import SearchScreen from '../screens/SearchScreen';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

// Home Stack Navigator
const HomeStack = () => (
  <Stack.Navigator screenOptions={{ headerShown: false }}>
    <Stack.Screen name="HomeTab" component={HomeTab} />
    <Stack.Screen name="CropLibrary" component={CropLibraryScreen} />
    <Stack.Screen name="CropDetails" component={CropDetailsScreen} />
    <Stack.Screen name="DiseaseGuide" component={DiseaseGuideScreen} />
    <Stack.Screen name="WeatherDetails" component={WeatherDetailsScreen} />
    <Stack.Screen name="Search" component={SearchScreen} />
  </Stack.Navigator>
);

// AI Scan Stack Navigator
const AiScanStack = () => (
  <Stack.Navigator screenOptions={{ headerShown: false }}>
    <Stack.Screen name="AiScanTab" component={AiScanTab} />
    <Stack.Screen name="Camera" component={CameraScreen} />
    <Stack.Screen name="Results" component={ResultsScreen} />
  </Stack.Navigator>
);

// Profile Stack Navigator
const ProfileStack = () => (
  <Stack.Navigator screenOptions={{ headerShown: false }}>
    <Stack.Screen name="ProfileTab" component={ProfileTab} />
    <Stack.Screen name="ProfileDetails" component={ProfileScreen} />
  </Stack.Navigator>
);

const MainNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home';
          } else if (route.name === 'AiScan') {
            iconName = focused ? 'document-scanner' : 'document-scanner';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: AppColors.accentOrange,
        tabBarInactiveTintColor: AppColors.mediumGray,
        tabBarStyle: {
          backgroundColor: AppColors.white,
          borderTopWidth: 0,
          elevation: 8,
          shadowColor: AppColors.shadowColor,
          shadowOffset: {
            width: 0,
            height: -2,
          },
          shadowOpacity: 0.1,
          shadowRadius: 8,
          height: 60,
          paddingBottom: 8,
          paddingTop: 8,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '400',
        },
        headerShown: false,
      })}
    >
      <Tab.Screen 
        name="Home" 
        component={HomeStack} 
        options={{ tabBarLabel: 'Home' }}
      />
      <Tab.Screen 
        name="AiScan" 
        component={AiScanStack} 
        options={{ tabBarLabel: 'AI Scan' }}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileStack} 
        options={{ tabBarLabel: 'Profile' }}
      />
    </Tab.Navigator>
  );
};

export default MainNavigator; 