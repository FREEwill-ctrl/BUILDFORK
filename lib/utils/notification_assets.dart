/// Notification Assets Manager
/// Manages open source notification icons and sounds for the Flutter Todo App
class NotificationAssets {
  // Notification icon paths
  static const String bellIcon = 'assets/notification_icons/bell_icon.png';
  static const String alertIcon = 'assets/notification_icons/alert_icon.png';
  static const String messageIcon = 'assets/notification_icons/message_icon.png';
  
  // Downloaded open source notification icons
  static const String notificationBell = 'assets/notification_icons/notification_bell.jpg';
  static const String notificationIconsSet = 'assets/notification_icons/notification_icons_set.jpg';
  
  // Notification types with corresponding icons
  static const Map<String, String> notificationTypeIcons = {
    'todo_reminder': bellIcon,
    'task_due': alertIcon,
    'message': messageIcon,
    'pomodoro': bellIcon,
    'general': bellIcon,
  };
  
  // Get icon for notification type
  static String getIconForType(String type) {
    return notificationTypeIcons[type] ?? bellIcon;
  }
  
  // Available notification sounds (to be added)
  static const List<String> availableSounds = [
    'bell_notification',
    'alert_sound',
    'message_tone',
  ];
  
  // Get sound for notification type
  static String getSoundForType(String type) {
    switch (type) {
      case 'todo_reminder':
        return 'bell_notification';
      case 'task_due':
        return 'alert_sound';
      case 'message':
        return 'message_tone';
      case 'pomodoro':
        return 'bell_notification';
      default:
        return 'bell_notification';
    }
  }
}

