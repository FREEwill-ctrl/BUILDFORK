# Notification Assets Documentation

## Overview
This Flutter Todo App has been enhanced with open source notification assets including icons and sounds to improve user experience and provide better visual feedback for notifications.

## Added Assets

### Notification Icons
The following open source notification icons have been added to the project:

1. **Bell Icon** (`assets/notification_icons/bell_icon.png`)
   - Simple minimalist bell notification icon
   - Flat design with transparent background
   - Used for general notifications and todo reminders

2. **Alert Icon** (`assets/notification_icons/alert_icon.png`)
   - Alert notification icon with exclamation mark
   - Orange/red color scheme for warning notifications
   - Used for urgent task reminders and due date alerts

3. **Message Icon** (`assets/notification_icons/message_icon.png`)
   - Speech bubble design for message notifications
   - Blue color scheme
   - Used for communication-related notifications

4. **Downloaded Open Source Icons**
   - `notification_bell.jpg` - Collection of notification bell icons
   - `notification_icons_set.jpg` - Set of various notification icons

### Directory Structure
```
assets/
├── notification_icons/
│   ├── bell_icon.png
│   ├── alert_icon.png
│   ├── message_icon.png
│   ├── notification_bell.jpg
│   └── notification_icons_set.jpg
└── notification_sounds/
    └── (to be added)
```

## Implementation

### NotificationAssets Class
A new utility class `NotificationAssets` has been created in `lib/utils/notification_assets.dart` to manage notification assets:

```dart
class NotificationAssets {
  // Icon paths
  static const String bellIcon = 'assets/notification_icons/bell_icon.png';
  static const String alertIcon = 'assets/notification_icons/alert_icon.png';
  static const String messageIcon = 'assets/notification_icons/message_icon.png';
  
  // Get icon for notification type
  static String getIconForType(String type) {
    return notificationTypeIcons[type] ?? bellIcon;
  }
}
```

### Updated Notification Service
The `NotificationService` has been updated to use the new bell icon:
- Changed initialization to use `@drawable/bell_icon` instead of default launcher icon
- Bell icon copied to Android drawable resources

### Pubspec.yaml Updates
Added new asset directories to `pubspec.yaml`:
```yaml
assets:
  - assets/notification_icons/
  - assets/notification_sounds/
```

## Usage

### Using Notification Icons in Code
```dart
import 'package:flutter_todo_app/utils/notification_assets.dart';

// Get icon for specific notification type
String iconPath = NotificationAssets.getIconForType('todo_reminder');

// Use in Image widget
Image.asset(NotificationAssets.bellIcon)
```

### Notification Types and Icons
- `todo_reminder` → Bell Icon
- `task_due` → Alert Icon
- `message` → Message Icon
- `pomodoro` → Bell Icon
- `general` → Bell Icon (default)

## Open Source Compliance

All notification assets added to this project are either:
1. Generated using AI tools (bell_icon.png, alert_icon.png, message_icon.png)
2. Sourced from open source collections with appropriate licensing

### License Information
- Generated icons: Available under MIT license (same as project)
- Downloaded icons: Sourced from open source collections (Vecteezy, etc.)

## Future Enhancements

### Planned Additions
1. **Notification Sounds**
   - Open source notification sound files
   - Different sounds for different notification types
   - Custom sound selection in app settings

2. **Additional Icons**
   - Success/completion icons
   - Priority level indicators
   - Category-specific icons

3. **Customization**
   - User-selectable notification icons
   - Theme-based icon variations
   - Dynamic icon colors

## Building and Testing

### Android Build
The bell icon has been copied to Android drawable resources:
```
android/app/src/main/res/drawable/bell_icon.png
```

### Testing Notifications
To test the new notification assets:
1. Run the app: `flutter run`
2. Create a todo with due date
3. Wait for notification or trigger manually
4. Verify the bell icon appears in notification

### APK Build
When building APK, ensure all assets are included:
```bash
flutter build apk --release
```

## Troubleshooting

### Common Issues
1. **Icon not showing**: Verify asset paths in pubspec.yaml
2. **Build errors**: Clean and rebuild project
3. **Notification not using custom icon**: Check Android drawable resources

### Asset Verification
```bash
# Check if assets are properly included
flutter packages get
flutter clean
flutter build apk --debug
```

## Contributing

When adding new notification assets:
1. Ensure open source compliance
2. Add to appropriate asset directory
3. Update NotificationAssets class
4. Update this documentation
5. Test on both debug and release builds

## Credits

- Bell, Alert, and Message icons: Generated using AI tools
- Open source icon collections: Vecteezy and other open source platforms
- Flutter Local Notifications package for notification functionality

