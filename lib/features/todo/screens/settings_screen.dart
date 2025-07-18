import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
        ],
      ),
    );
  }
}