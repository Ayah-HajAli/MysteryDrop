import 'package:flutter/material.dart';

import '../app.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/agent.dart';
import '../widgets/evidence.dart';
import '../widgets/poster.dart';

class DropScreen extends StatelessWidget {
  const DropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context);
    final drop = repo.today;
    final revealed = drop.isRevealed;

    return Container(
      color: Pal.rust,
      child: Stack(
        children: [
          const Positioned.fill(child: Grain(opacity: 0.07)),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
              children: [
                const _Masthead(),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Tag(drop.code, color: Pal.paper),
                    const SizedBox(width: 8),
                    Tag(drop.kind.label, color: Pal.paper, filled: false),
                  ],
                ),
                const SizedBox(height: 14),
                Text(drop.title.toUpperCase(), style: display(46, color: Pal.paper)),
                const SizedBox(height: 14),
                Text(
                  drop.question,
                  style: body(16.5, color: Pal.paper.withOpacity(0.92)),
                ),
                const SizedBox(height: 22),
                ChunkyBox(
                  color: Pal.paper,
                  padding: const EdgeInsets.all(12),
                  child: EvidencePlate(
                    seed: drop.seed,
                    kind: drop.kind,
                    height: 262,
                    showAgent: true,
                    caption: revealed
                        ? 'EXHIBIT A — CASE CLOSED'
                        : 'EXHIBIT A — DO NOT REMOVE FROM FILE',
                  ),
                ),
                const SizedBox(height: 24),
                if (revealed) _RevealPanel(drop: drop) else _CountdownPanel(drop: drop),
                const SizedBox(height: 24),
                _Clues(drop: drop),
                const SizedBox(height: 24),
                _FileCta(drop: drop),
                const SizedBox(height: 18),
                if (!revealed)
                  Center(
                    child: TextButton(
                      onPressed: repo.forceReveal,
                      child: Text(
                        'Skip the wait (demo)',
                        style: body(13,
                            color: Pal.paper.withOpacity(0.75), w: FontWeight.w700),
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
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MYSTERYDROP', style: display(26, color: Pal.paper)),
              const SizedBox(height: 6),
              Text(
                'Drop ${now.day} ${months[now.month - 1]} — one mystery a day',
                style: body(12.5, color: Pal.paper.withOpacity(0.8), w: FontWeight.w600),
              ),
            ],
          ),
        ),
        Agent(pose: AgentPose.peeking, height: 52, coat: Pal.paper, lookAt: 0.7),
      ],
    );
  }
}

class _CountdownPanel extends StatelessWidget {
  const _CountdownPanel({required this.drop});
  final Drop drop;

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context);
    final t = drop.revealAt;
    final at = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return ChunkyBox(
      color: Pal.paper,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The answer opens at $at', style: body(13.5, w: FontWeight.w700)),
                const SizedBox(height: 8),
                Countdown(
                  target: drop.revealAt,
                  style: display(44),
                  onFinished: repo.refresh,
                ),
                const SizedBox(height: 8),
                Text(
                  '${drop.theories.length} theories on the board',
                  style: body(13, color: Pal.black.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const Starburst(top: 'Live', bottom: 'Filing open', size: 92),
        ],
      ),
    );
  }
}

class _RevealPanel extends StatelessWidget {
  const _RevealPanel({required this.drop});
  final Drop drop;

  @override
  Widget build(BuildContext context) {
    final mine = drop.myTheory;
    return ChunkyBox(
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
                    Text('IT WAS', style: display(22)),
                    const SizedBox(height: 8),
                    Text(drop.answer, style: display(26)),
                  ],
                ),
              ),
              Agent(pose: AgentPose.evidence, height: 118, coat: Pal.paper),
            ],
          ),
          const SizedBox(height: 14),
          Text(drop.debrief, style: body(14.5)),
          if (mine != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Pal.paper,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Pal.black, width: 2.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_verdictLine(mine.verdict), style: label(11.5)),
                  const SizedBox(height: 6),
                  Text(mine.text, style: body(13.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _verdictLine(Verdict v) => switch (v) {
        Verdict.solved => 'YOUR THEORY — SOLVED',
        Verdict.close => 'YOUR THEORY — RIGHT TRAIL, WRONG DOOR',
        Verdict.wrong => 'YOUR THEORY — NOT THIS TIME',
        Verdict.pending => 'YOUR THEORY',
      };
}

class _Clues extends StatelessWidget {
  const _Clues({required this.drop});
  final Drop drop;

  @override
  Widget build(BuildContext context) {
    final unlocked = drop.unlockedClues;
    final next = drop.nextClueIn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CLUES', style: display(28, color: Pal.paper)),
        const SizedBox(height: 4),
        Text(
          next == null
              ? 'Everything the desk has is on the table.'
              : 'A new clue every few hours. Next one in ${_short(next)}.',
          style: body(13, color: Pal.paper.withOpacity(0.85)),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < drop.clues.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ClueRow(
              index: i + 1,
              text: drop.clues[i],
              locked: i >= unlocked,
            ),
          ),
      ],
    );
  }

  String _short(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }
}

class _ClueRow extends StatelessWidget {
  const _ClueRow({required this.index, required this.text, required this.locked});
  final int index;
  final String text;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return ChunkyBox(
      color: locked ? Pal.rust : Pal.paper,
      offset: 4,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: locked ? Pal.paper.withOpacity(0.25) : Pal.black,
              shape: BoxShape.circle,
            ),
            child: Text('$index',
                style: label(13, color: locked ? Pal.paper : Pal.mustard)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: locked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Redacted(width: double.infinity, height: 14),
                      const Redacted(width: 150, height: 14),
                      const SizedBox(height: 2),
                      Text('Sealed until the next release',
                          style: label(10, color: Pal.paper)),
                    ],
                  )
                : Text(text, style: body(14.5)),
          ),
        ],
      ),
    );
  }
}

class _FileCta extends StatelessWidget {
  const _FileCta({required this.drop});
  final Drop drop;

  @override
  Widget build(BuildContext context) {
    final mine = drop.myTheory;
    if (drop.isRevealed) {
      return ChunkyButton(
        label: 'Read every theory',
        color: Pal.paper,
        icon: Icons.record_voice_over_rounded,
        onPressed: () => ShellState.go(context, 1),
      );
    }
    return Column(
      children: [
        ChunkyButton(
          label: mine == null ? 'File a theory' : 'Edit your theory',
          icon: Icons.edit_note_rounded,
          onPressed: () => ShellState.go(context, 1),
        ),
        if (mine != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Filed at ${mine.filedAt.hour.toString().padLeft(2, '0')}:'
              '${mine.filedAt.minute.toString().padLeft(2, '0')}',
              style: body(12.5, color: Pal.paper.withOpacity(0.8), w: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
