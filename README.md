# Meditation App

A beautiful and intuitive iOS meditation app that helps you find your inner peace through guided meditation sessions with HealthKit integration.

## Features

### 🧘‍♀️ Meditation Timer
- **Customizable Duration**: Set meditation sessions from 1-60 minutes
- **Quick Presets**: One-tap access to 5, 10, 20, and 30-minute sessions
- **Visual Timer**: Large, easy-to-read countdown display
- **Session Controls**: Start, stop, and pause your meditation sessions

### 📱 Modern UI/UX
- **Clean Design**: Minimalist interface with calming gradient background
- **Intuitive Controls**: Easy-to-use duration selector and preset buttons
- **Visual Feedback**: Clear session status and completion notifications
- **Responsive Layout**: Optimized for all iPhone screen sizes

### 🏥 HealthKit Integration
- **Apple Health Sync**: Automatically saves meditation sessions to Apple Health
- **Session Tracking**: Monitor your meditation progress over time
- **Privacy Focused**: Secure data handling with user consent
- **Wellness Insights**: View meditation data alongside other health metrics

## Requirements

- iOS 13.0 or later
- Xcode 12.0 or later
- Swift 5.0 or later
- HealthKit framework (available on physical devices)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/meditation-app.git
   cd meditation-app
   ```

2. Open the project in Xcode:
   ```bash
   open MeditationApp.xcodeproj
   ```

3. Build and run the project on your iOS device or simulator

## Usage

### Starting a Meditation Session

1. **Set Duration**: Use the text field to enter your desired meditation duration (1-60 minutes)
2. **Quick Presets**: Tap one of the preset buttons (5m, 10m, 20m, 30m) for common durations
3. **Start Session**: Tap the "Start Session" button to begin your meditation
4. **Monitor Progress**: Watch the countdown timer as you meditate
5. **Complete Session**: The app will notify you when your session is complete

### HealthKit Integration

The app automatically requests permission to save meditation data to Apple Health. When you complete a meditation session, it will be saved as a "Mindful Session" in your Health app.

## Project Structure

```
MeditationApp/
├── MeditationViewController.swift    # Main meditation interface
├── HealthKitManager.swift           # HealthKit integration logic
├── AppDelegate.swift                # App lifecycle management
├── SceneDelegate.swift              # Scene configuration
├── Info.plist                       # App configuration and permissions
└── Assets.xcassets/                 # App icons and visual assets
```

## Key Components

### MeditationViewController
- Manages the meditation timer and UI
- Handles user interactions and session controls
- Integrates with HealthKit for data persistence

### HealthKitManager
- Handles HealthKit authorization and permissions
- Saves meditation sessions to Apple Health
- Retrieves meditation history and statistics

## Permissions

The app requires the following permissions:
- **HealthKit**: To save and read meditation session data
- **Health Share**: To read existing meditation data
- **Health Update**: To write new meditation sessions

## Development

### Dependencies
- UIKit (iOS framework)
- HealthKit (health data framework)
- AVFoundation (audio framework)

### Architecture
- **MVC Pattern**: Model-View-Controller architecture
- **HealthKit Integration**: Separate manager class for health data
- **Programmatic UI**: Interface built with Auto Layout constraints

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Apple HealthKit framework for health data integration
- iOS Human Interface Guidelines for design inspiration
- Meditation community for feature feedback and suggestions

---

**Find your inner peace, one session at a time.** 🧘‍♀️✨
