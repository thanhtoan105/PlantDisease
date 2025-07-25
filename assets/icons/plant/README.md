# Plant Disease Detection Icons

This directory contains plant and agriculture-specific icons for the Plant AI Disease Detection application.

## Icon Categories

### Disease Analysis Icons
- `disease_analysis` - For disease detection and analysis features
- `plant_scan` - For scanning/photographing plants
- `plant_photo` - For plant photography features

### Plant Health Icons
- `healthy_plant` - For healthy plant indicators
- `infected_plant` - For diseased plant indicators
- `plant_health` - General plant health monitoring

### Treatment & Care Icons
- `plant_treatment` - For treatment recommendations
- `plant_prevention` - For prevention measures
- `plant_care` - For general plant care

### Environment & Growth Icons
- `plant_environment` - For environmental factors
- `plant_growth` - For growth tracking
- `plant_weather` - For weather conditions affecting plants
- `plant_water` - For watering and irrigation
- `plant_nutrients` - For fertilization and nutrients
- `plant_soil` - For soil conditions

### Agricultural Icons
- `crop_monitoring` - For crop monitoring features
- `leaf_analysis` - For leaf-specific analysis
- `agriculture` - General agriculture icon

### Reference Icons
- `plant_library` - For plant disease library
- `plant_guide` - For plant care guides

## Usage

These icons are mapped in the `CustomIconWidget` and can be used throughout the application by referencing their string names.

Example:
```dart
CustomIconWidget(
  iconName: 'plant_health',
  color: AppTheme.lightTheme.colorScheme.primary,
  size: 24,
)
```

## Icon Mapping

All icons are mapped to Material Design icons in the `custom_icon_widget.dart` file:
- `plant_health` → `Icons.eco`
- `disease_analysis` → `Icons.biotech`
- `plant_treatment` → `Icons.healing`
- `plant_prevention` → `Icons.shield`
- And many more...

This approach ensures consistency with Material Design while providing semantic meaning specific to plant disease detection.
