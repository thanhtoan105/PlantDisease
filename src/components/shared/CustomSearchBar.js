import React from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { AppColors, Typography, BorderRadius, Spacing } from '../../theme';

const CustomSearchBar = ({
  placeholder = 'Search...',
  value,
  onChangeText,
  onPress,
  editable = true,
  style,
}) => {
  if (!editable && onPress) {
    return (
      <TouchableOpacity style={[styles.container, style]} onPress={onPress}>
        <Icon name="search" size={20} color={AppColors.secondary} />
        <View style={styles.textContainer}>
          <TextInput
            style={styles.input}
            placeholder={placeholder}
            placeholderTextColor={AppColors.mediumGray}
            editable={false}
            pointerEvents="none"
          />
        </View>
      </TouchableOpacity>
    );
  }

  return (
    <View style={[styles.container, style]}>
      <Icon name="search" size={20} color={AppColors.secondary} />
      <TextInput
        style={styles.input}
        placeholder={placeholder}
        placeholderTextColor={AppColors.mediumGray}
        value={value}
        onChangeText={onChangeText}
        editable={editable}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.lightGray,
    borderRadius: BorderRadius.medium,
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.lg,
  },
  textContainer: {
    flex: 1,
    marginLeft: Spacing.md,
  },
  input: {
    flex: 1,
    ...Typography.bodyMedium,
    color: AppColors.darkNavy,
    marginLeft: Spacing.md,
  },
});

export default CustomSearchBar; 