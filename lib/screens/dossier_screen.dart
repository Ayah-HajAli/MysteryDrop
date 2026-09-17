import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import '../widgets/agent.dart';
import '../widgets/poster.dart';

class DossierScreen extends StatelessWidget {
  const DossierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context);
    final me = repo.detective;
    final toNext = me.toNextRank;

    return Container(
      color: Pal.bruise,
      child: Stack(
        children: [
          const Positioned.fill(child: Grain(opacity: 0.07)),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                Text('DOSSIER', style: display(40, color: Pal.paper)),
                const SizedBox(height: 18),
                ChunkyBox(
                  color: Pal.paper,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Agent(
                            pose: AgentPose.standing,
                            height: 150,
                            lookAt: 0.55,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CODENAME', style: label(10, color: Pal.black.withOpacity(0.6))),
                                const SizedBox(height: 5),
                                Text(me.codename, style: display(26)),
                                const SizedBox(height: 12),
                                Tag(me.rank, color: Pal.black, filled: true),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => _rename(context),
                                  child: Text(
                                    'Change codename',
                                    style: body(13,
                                        color: Pal.rust, w: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _RankMeter(progress: me.rankProgress, toNext: toNext, rank: me.rank),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _Stat(value: '${me.solved}', label: 'Solved', color: Pal.olive)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(value: '${me.filed}', label: 'Filed', color: Pal.paper)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        value: '${(me.hitRate * 100).round()}%',
                        label: 'Hit rate',
                        color: Pal.mustard,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ChunkyBox(
                  color: Pal.rust,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${me.streak} DAYS RUNNING',
                                style: display(24, color: Pal.paper)),
                            const SizedBox(height: 6),
                            Text('Miss a day and the streak resets at midnight.',
                                style: body(13, color: Pal.paper.withOpacity(0.9))),
                          ],
                        ),
                      ),
                      const Starburst(
                        top: 'Hot',
                        bottom: 'Keep it',
                        size: 84,
                        color: Pal.paper,
                        textColor: Pal.black,
                        rotation: 0.14,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text('MERITS', style: display(30, color: Pal.paper)),
                const SizedBox(height: 14),
                for (final m in repo.badges)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChunkyBox(
                      color: m.earned ? Pal.paper : Pal.bruise,
                      offset: 4,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            m.earned ? Icons.verified_rounded : Icons.lock_outline_rounded,
                            size: 22,
                            color: Pal.black,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name.toUpperCase(), style: display(17)),
                                const SizedBox(height: 4),
                                Text(m.note,
                                    style: body(13, color: Pal.black.withOpacity(0.75))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _rename(BuildContext context) {
    final repo = AppScope.of(context);
    final controller = TextEditingController(text: repo.detective.codename);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ChunkyBox(
          color: Pal.paper,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PICK A CODENAME', style: display(24)),
              const SizedBox(height: 6),
              Text('Other agents only ever see this.', style: body(13)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Pal.paperDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pal.black, width: 2.5),
                ),
                child: TextField(
                  controller: controller,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.characters,
                  style: display(20),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterStyle: label(10, color: Pal.black.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ChunkyButton(
                label: 'Save codename',
                onPressed: () {
                  repo.renameAgent(controller.text);
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankMeter extends StatelessWidget {
  const _RankMeter({required this.progress, required this.toNext, required this.rank});
  final double progress;
  final int? toNext;
  final String rank;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18,
          decoration: BoxDecoration(
            color: Pal.paperDeep,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Pal.black, width: 2.5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.02, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Pal.olive,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          toNext == null
              ? 'Top of the tree. Nothing left to climb.'
              : '$toNext more solves to leave $rank behind.',
          style: body(13, w: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ChunkyBox(
      color: color,
      offset: 5,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Text(value, style: display(30)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: Pal.black.withOpacity(0.7),
              )),
        ],
      ),
    );
  }
}
