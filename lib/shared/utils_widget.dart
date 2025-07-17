import 'package:home_widget/home_widget.dart';

Future<void> updateHomeWidget(int taskCount) async {
  await HomeWidget.saveWidgetData('task_count', taskCount);
  await HomeWidget.updateWidget(name: 'HomeWidgetProvider', iOSName: 'HomeWidgetProvider');
}