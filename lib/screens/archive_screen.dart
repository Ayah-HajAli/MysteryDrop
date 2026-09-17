import 'package:flutter/material.dart';

import '../app.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/agent.dart';
import '../widgets/evidence.dart';
import '../widgets/poster.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context);
    final cases = repo.archive;
    final solved = cases.where((c) => c.myTheory?.verdict == Verdict.solved).length;

    return Container(
      color: Pal.paper,
      child: Stack(
        children: [
          const Positioned.fill(child: Grain()),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                Text('CASE FILES', style: display(40)),
                const SizedBox(height: 6),
                Text(
                  'Every drop that has already opened. You called $solved of the '
                  'last ${cases.length}.',
                  style: body(13.5, w: FontWeight.w600),
                ),
                const SizedBox(height: 22),
                for (final c in cases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CaseRow(drop: c),
                  ),
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      const Agent(pose: AgentPose.standing, height: 140, lookAt: -0.5),
                      const SizedBox(height: 10),
                      Text('That is the whole drawer.', style: label(11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow({required this.drop});
  final Drop drop;

  Color get _tint => switch (drop.myTheory?.verdict) {
        Verdict.solved => Pal.olive,
        Verdict.close => Pal.mustard,
        Verdict.wrong => Pal.rust,
        _ => Pal.paperDeep,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCase(context, drop),
      child: ChunkyBox(
        color: Pal.paper,
        offset: 5,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: EvidencePlate(
                seed: drop.seed,
                kind: drop.kind,
                height: 76,
                base: _tint,
                caption: drop.code,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${drop.code} — ${drop.kind.label}',
                      style: label(10, color: Pal.black.withOpacity(0.6))),
                  const SizedBox(height: 5),
                  Text(drop.title.toUpperCase(), style: display(19)),
                  const SizedBox(height: 8),
                  Tag(_verdictLabel(drop.myTheory?.verdict), color: Pal.black),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 26),
          ],
        ),
      ),
    );
  }

  static String _verdictLabel(Verdict? v) => switch (v) {
        Verdict.solved => 'You called it',
        Verdict.close => 'Close',
        Verdict.wrong => 'You missed',
        _ => 'No theory filed',
      };
}

void _openCase(BuildContext context, Drop drop) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Pal.paper,
          border: Border(
            top: BorderSide(color: Pal.black, width: 4),
            left: BorderSide(color: Pal.black, width: 4),
            right: BorderSide(color: Pal.black, width: 4),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Pal.black,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(drop.code, style: label(11, color: Pal.black.withOpacity(0.6))),
              const SizedBox(height: 6),
              Text(drop.title.toUpperCase(), style: display(34)),
              const SizedBox(height: 10),
              Text(drop.question, style: body(15)),
              const SizedBox(height: 16),
              EvidencePlate(seed: drop.seed, kind: drop.kind, height: 200),
              const SizedBox(height: 20),
              ChunkyBox(
                color: Pal.mustard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('IT WAS', style: label(11)),
                              const SizedBox(height: 6),
                              Text(drop.answer, style: display(24)),
                            ],
                          ),
                        ),
                        const Agent(pose: AgentPose.evidence, height: 110),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(drop.debrief, style: body(14.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (drop.myTheory != null) ...[
                Text('WHAT YOU SAID', style: display(20)),
                const SizedBox(height: 10),
                ChunkyBox(
                  color: Pal.paperDeep,
                  offset: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(drop.myTheory!.text, style: body(15)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Tag(_CaseRow._verdictLabel(drop.myTheory!.verdict),
                              color: Pal.black, filled: true),
                          const SizedBox(width: 8),
                          Tag('${drop.myTheory!.votes} backed you', color: Pal.black),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ChunkyButton(
                label: 'Close the file',
                color: Pal.paperDeep,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
