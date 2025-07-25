# Plant AI Disease Flutter - Project Overview

## Purpose
A Flutter mobile application for plant disease detection using AI/ML. The app allows users to:
- Take photos of plants using their camera
- Analyze plant diseases using TensorFlow Lite models
- Get weather information for farming decisions
- Browse crop library and disease information
- Manage user profiles and authentication

## Tech Stack
- **Framework**: Flutter (Dart 3.0+)
- **State Management**: Provider pattern
- **Navigation**: GoRouter
- **Backend**: Supabase (PostgreSQL with custom 'plant_disease' schema)
- **AI/ML**: TensorFlow Lite for on-device inference
- **Camera**: Flutter camera plugin
- **Weather**: OpenWeatherMap API
- **Local Storage**: SharedPreferences
- **HTTP**: Dio and HTTP packages
- **Authentication**: Supabase Auth with PKCE flow

## Key Features
- Plant disease detection using camera and AI
- Weather integration for farming insights
- Crop library with disease information
- User authentication and profiles
- Offline-capable AI inference
- Material 3 design system

## Model Information
- **Model**: apple_model_final.tflite (128x128x3 input)
- **Classes**: Apple scab, Black rot, Cedar apple rust, Healthy
- **Input**: Normalized RGB images [0,1]
- **Output**: Probability scores for disease classification