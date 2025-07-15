
# Flutter Todo App

A simple Todo List application built with Flutter.

## Features

- Create, Read, Update, Delete todo items
- Local Storage using SQLite
- Search & Filter by priority
- High, Medium, Low priority system
- Mark tasks as complete
- Due dates for tasks
- Statistics for completed vs pending tasks

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/flutter_todo_app.git
   cd flutter_todo_app
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

## Building the APK

To build the APK for Android, run the following command:

```sh
flutter build apk --release
```

The APK file will be located in `build/app/outputs/flutter-apk/app-release.apk`.




## GitHub Actions CI/CD

This project includes a complete GitHub Actions workflow for automated building and deployment.

### Workflow Features

- **Automated Testing**: Runs Flutter tests, analyzer, and formatting checks
- **Multi-format Builds**: Generates both APK and AAB (Android App Bundle) files
- **Signed Releases**: Supports production-ready signed APK builds
- **Artifact Management**: Automatically uploads build artifacts with 30-day retention
- **Release Creation**: Creates GitHub releases with downloadable APK/AAB files
- **Build Notifications**: Provides build status notifications

### Setting Up GitHub Actions

1. **Push to GitHub**: Upload your code to a GitHub repository
2. **Enable Actions**: GitHub Actions will automatically detect the workflow file
3. **Configure Secrets** (for signed builds):
   - Generate a keystore file for app signing
   - Add the following secrets to your repository:
     - `KEYSTORE_BASE64`: Base64 encoded keystore file
     - `STORE_PASSWORD`: Keystore password
     - `KEY_PASSWORD`: Key password
     - `KEY_ALIAS`: Key alias

### Workflow Triggers

- **Push to main/develop**: Triggers full build pipeline
- **Pull Requests**: Runs tests and builds for validation
- **Manual Trigger**: Can be triggered manually from GitHub Actions tab

### Build Artifacts

The workflow generates the following artifacts:
- **Debug APK**: For development and testing
- **Release APK**: Unsigned release build
- **Signed APK**: Production-ready signed build (main branch only)
- **AAB File**: Android App Bundle for Play Store distribution

## Project Structure

```
flutter_todo_app/
├── .github/workflows/
│   └── build_android.yml          # GitHub Actions workflow
├── android/                       # Android-specific configuration
│   ├── app/
│   │   ├── build.gradle          # Android build configuration
│   │   ├── proguard-rules.pro    # ProGuard optimization rules
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/example/flutter_todo_app/
│   │       │   └── MainActivity.kt
│   │       └── res/              # Android resources
│   ├── build.gradle              # Project-level build configuration
│   ├── gradle.properties         # Gradle properties
│   └── settings.gradle           # Gradle settings
├── lib/                          # Flutter source code
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── todo_model.dart       # Todo data model
│   ├── providers/
│   │   └── todo_provider.dart    # State management
│   ├── services/
│   │   ├── database_service.dart # SQLite database operations
│   │   └── notification_service.dart # Local notifications
│   ├── screens/
│   │   ├── home_screen.dart      # Main screen
│   │   ├── add_task_screen.dart  # Add task form
│   │   └── edit_task_screen.dart # Edit task form
│   ├── widgets/
│   │   ├── task_card.dart        # Todo item widget
│   │   ├── priority_chip.dart    # Priority indicator
│   │   └── stats_card.dart       # Statistics widget
│   └── utils/
│       └── constants.dart        # App constants and themes
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # This file
```

## Technical Features

### Database
- **SQLite**: Local storage using sqflite package
- **CRUD Operations**: Full create, read, update, delete functionality
- **Data Persistence**: All data stored locally on device
- **Database Migration**: Supports schema updates

### State Management
- **Provider Pattern**: Uses Provider package for state management
- **Reactive UI**: Automatic UI updates when data changes
- **Loading States**: Proper loading indicators during operations
- **Error Handling**: Comprehensive error handling and user feedback

### Notifications
- **Local Notifications**: Reminder notifications for due tasks
- **Scheduled Notifications**: Automatic reminders before due dates
- **Background Processing**: Notifications work even when app is closed
- **Customizable**: Different notification types and priorities

### UI/UX
- **Material Design 3**: Modern Flutter UI components
- **Dark/Light Mode**: Automatic theme switching based on system settings
- **Responsive Design**: Works on different screen sizes
- **Smooth Animations**: Transitions and micro-interactions
- **Accessibility**: Screen reader support and proper contrast ratios

### Performance
- **Optimized Builds**: ProGuard optimization for release builds
- **Lazy Loading**: Efficient list rendering for large datasets
- **Memory Management**: Proper resource cleanup and disposal
- **Fast Startup**: Optimized app launch time

## Development Setup

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android SDK with API level 21 or higher
- Java 17 for Android builds

### Local Development
1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd flutter_todo_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Building for Production

#### Debug Build
```bash
flutter build apk --debug
```

#### Release Build
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Check formatting
dart format --output=none --set-exit-if-changed .
```

## Deployment Options

### Manual Deployment
1. Build the APK using `flutter build apk --release`
2. Distribute the APK file directly to users
3. Users need to enable "Install from unknown sources"

### Google Play Store
1. Build AAB using `flutter build appbundle --release`
2. Upload the AAB file to Google Play Console
3. Follow Google Play Store review process

### GitHub Releases
1. Push code to main branch
2. GitHub Actions automatically creates a release
3. Download APK/AAB files from the release page

## Configuration

### App Signing
For production releases, you need to configure app signing:

1. **Generate a keystore**:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create key.properties** in android/ directory:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. **Add to .gitignore**:
   ```
   android/key.properties
   android/app/upload-keystore.jks
   ```

### Customization
- **App Name**: Update in `android/app/src/main/res/values/strings.xml`
- **Package Name**: Change in `android/app/build.gradle` and `AndroidManifest.xml`
- **App Icon**: Replace files in `android/app/src/main/res/mipmap-*` directories
- **Theme Colors**: Modify in `lib/utils/constants.dart`

## Troubleshooting

### Common Issues

1. **Build Failures**:
   - Ensure Flutter SDK is properly installed
   - Check Java version (should be 17)
   - Clean build: `flutter clean && flutter pub get`

2. **Notification Issues**:
   - Check Android permissions in AndroidManifest.xml
   - Ensure notification channels are properly configured
   - Test on physical device (notifications may not work in emulator)

3. **Database Issues**:
   - Clear app data if schema changes
   - Check file permissions
   - Verify SQLite package version compatibility

4. **GitHub Actions Failures**:
   - Check workflow logs for specific errors
   - Ensure all required secrets are configured
   - Verify Flutter version in workflow matches local version

### Performance Optimization

1. **App Size**:
   - Enable ProGuard in release builds
   - Use AAB format for Play Store
   - Remove unused dependencies

2. **Runtime Performance**:
   - Use const constructors where possible
   - Implement proper list view builders
   - Dispose controllers and streams properly

3. **Battery Usage**:
   - Optimize notification scheduling
   - Use efficient database queries
   - Minimize background processing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Search existing GitHub issues
3. Create a new issue with detailed information
4. Include device information and error logs

## Changelog

### Version 1.0.0
- Initial release
- Basic CRUD operations for todos
- Priority system (High, Medium, Low)
- Due date functionality
- Search and filter capabilities
- Local notifications
- SQLite database integration
- Material Design 3 UI
- GitHub Actions CI/CD pipeline

