import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({required this.onFinish, super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Selamat Datang!',
      'desc': 'Aplikasi Todo Modular membantu Anda mengatur tugas, fokus, dan produktivitas secara offline.'
    },
    {
      'title': 'Fitur Utama',
      'desc': '• Todo dengan prioritas\n• Pomodoro timer\n• Analitik waktu\n• Offline & aman'
    },
    {
      'title': 'Mudah Digunakan',
      'desc': 'Cari, filter, urutkan, dan kelola tugas dengan mudah. Semua data tersimpan di perangkat Anda.'
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_pages[i]['title']!, style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      Text(_pages[i]['desc']!, style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? Colors.blue : Colors.grey[300],
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ElevatedButton(
                onPressed: _page == _pages.length - 1
                  ? _finishOnboarding
                  : () => _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: Text(_page == _pages.length - 1 ? 'Selesai' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}