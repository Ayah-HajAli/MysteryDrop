import 'package:flutter/material.dart';

import 'repository.dart';
import 'screens/archive_screen.dart';
import 'screens/dossier_screen.dart';
import 'screens/drop_screen.dart';
import 'screens/theories_screen.dart';
import 'theme.dart';

/// Lightweight dependency injection — no packages needed.
class AppScope extends InheritedNotifier<MysteryRepository> {
  const AppScope({super.key, required MysteryRepository repo, required super.child})
      : super(notifier: repo);

  static MysteryRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget');
    return scope!.notifier!;
  }
}

class MysteryDropApp extends StatefulWidget {
  const MysteryDropApp({super.key});

  @override
  State<MysteryDropApp> createState() => _MysteryDropAppState();
}

class _MysteryDropAppState extends State<MysteryDropApp> {
  final MysteryRepository _repo = MysteryRepository();

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      repo: _repo,
      child: MaterialApp(
        title: 'MysteryDrop',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => ShellState();
}

class ShellState extends State<Shell> {
  int _index = 0;

  /// Lets a screen send you somewhere else (e.g. "File a theory").
  static void go(BuildContext context, int index) {
    context.findAncestorStateOfType<ShellState>()?._set(index);
  }

  void _set(int i) => setState(() => _index = i);

  static const _tabs = [
    _TabSpec('Today', Icons.wb_twilight_rounded, Pal.rust),
    _TabSpec('Theories', Icons.record_voice_over_rounded, Pal.olive),
    _TabSpec('Case files', Icons.folder_rounded, Pal.mustard),
    _TabSpec('Dossier', Icons.badge_rounded, Pal.bruise),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DropScreen(),
          TheoriesScreen(),
          ArchiveScreen(),
          DossierScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Pal.paper,
          border: Border(top: BorderSide(color: Pal.black, width: 3)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final t = _tabs[i];
                final on = i == _index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _set(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: on ? t.color : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: on ? Pal.black : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Icon(t.icon, size: 20, color: Pal.black),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          t.label.toUpperCase(),
                          style: label(9.5,
                              color: on ? Pal.black : Pal.black.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
