import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import 'react-native-gesture-handler';

import MainNavigator from './src/navigation/MainNavigator';
import { WeatherProvider } from './src/context/WeatherContext';

export default function App() {
  return (
    <SafeAreaProvider>
      <WeatherProvider>
        <NavigationContainer>
          <StatusBar style="dark" />
          <MainNavigator />
        </NavigationContainer>
      </WeatherProvider>
    </SafeAreaProvider>
  );
} 