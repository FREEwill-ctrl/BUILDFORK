import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../shared/app_theme.dart';
import '../providers/todo_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String _selectedLang = 'id';
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')), 
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Mode Tema', style: Theme.of(context).textTheme.subtitle1),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Otomatis'),
                selected: themeProvider.themeMode == ThemeMode.system,
                onSelected: (_) => themeProvider.setThemeMode(ThemeMode.system),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Terang'),
                selected: themeProvider.themeMode == ThemeMode.light,
                onSelected: (_) => themeProvider.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Gelap'),
                selected: themeProvider.themeMode == ThemeMode.dark,
                onSelected: (_) => themeProvider.setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Warna Utama', style: Theme.of(context).textTheme.subtitle1),
          Wrap(
            spacing: 8,
            children: AppTheme.presetColors.entries.map((e) => ChoiceChip(
              label: Text(e.key),
              selected: themeProvider.primaryColor == e.value,
              selectedColor: e.value,
              backgroundColor: e.value.withOpacity(0.2),
              labelStyle: TextStyle(color: Colors.white),
              onSelected: (_) => themeProvider.setPrimaryColor(e.value),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Text('Ukuran Font', style: Theme.of(context).textTheme.subtitle1),
          Wrap(
            spacing: 8,
            children: AppTheme.fontScales.entries.map((e) => ChoiceChip(
              label: Text(e.key),
              selected: themeProvider.fontScale == e.value,
              onSelected: (_) => themeProvider.setFontScale(e.value),
            )).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final path = await FilePicker.platform.saveFile(dialogTitle: 'Export Todo', fileName: 'todo_backup.json');
              if (path != null) {
                await Provider.of<TodoProvider>(context, listen: false).exportTodos(path);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export berhasil ke $path')));
              }
            },
            child: Text('Export Todo'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
              if (result != null && result.files.single.path != null) {
                await Provider.of<TodoProvider>(context, listen: false).importTodos(result.files.single.path!);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import berhasil dari ${result.files.single.name}')));
              }
            },
            child: Text('Import Todo'),
          ),
          const SizedBox(height: 24),
          Text('Bahasa', style: Theme.of(context).textTheme.subtitle1),
          DropdownButton<String>(
            value: _selectedLang,
            items: [
              DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (val) {
              // TODO: Integrasi dengan intl
            },
          ),
        ],
      ),
    );
  }
}