import 'package:flutter/material.dart';

import '../app.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/agent.dart';
import '../widgets/poster.dart';

class TheoriesScreen extends StatefulWidget {
  const TheoriesScreen({super.key});

  @override
  State<TheoriesScreen> createState() => _TheoriesScreenState();
}

class _TheoriesScreenState extends State<TheoriesScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _composing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _open(String? seedText) {
    _controller.text = seedText ?? '';
    setState(() => _composing = true);
    _focus.requestFocus();
  }

  void _submit() {
    AppScope.of(context).fileTheory(_controller.text);
    _focus.unfocus();
    setState(() => _composing = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context);
    final drop = repo.today;
    final mine = drop.myTheory;
    final theories = drop.sortedTheories;

    return Container(
      color: Pal.olive,
      child: Stack(
        children: [
          const Positioned.fill(child: Grain(opacity: 0.06)),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('THE BOARD', style: display(40)),
                          const SizedBox(height: 6),
                          Text(
                            '${drop.code} — ${theories.length} theories, '
                            '${drop.isRevealed ? "closed" : "open until the reveal"}',
                            style: body(13, w: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (drop.isRevealed)
                  ChunkyBox(
                    color: Pal.mustard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ANSWER', style: label(11)),
                        const SizedBox(height: 6),
                        Text(drop.answer, style: display(22)),
                      ],
                    ),
                  )
                else if (_composing)
                  _Composer(
                    controller: _controller,
                    focus: _focus,
                    onSubmit: _submit,
                    onCancel: () {
                      _focus.unfocus();
                      setState(() => _composing = false);
                    },
                  )
                else
                  _ComposePrompt(
                    mine: mine,
                    onWrite: () => _open(mine?.text),
                    onWithdraw: mine == null
                        ? null
                        : () {
                            repo.withdrawTheory();
                            _controller.clear();
                          },
                  ),
                const SizedBox(height: 26),
                if (theories.isEmpty)
                  _EmptyBoard(onWrite: () => _open(null))
                else
                  for (final t in theories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TheoryCard(
                        theory: t,
                        revealed: drop.isRevealed,
                        onBack: () => repo.toggleBacking(t),
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

class _ComposePrompt extends StatelessWidget {
  const _ComposePrompt({required this.mine, required this.onWrite, this.onWithdraw});

  final Theory? mine;
  final VoidCallback onWrite;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    if (mine == null) {
      return ChunkyBox(
        color: Pal.paper,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'You have not put anything on the board yet.',
                    style: display(22),
                  ),
                ),
                const Agent(pose: AgentPose.shrug, height: 92),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'One theory per agent per day. You can rewrite it until the reveal.',
              style: body(14),
            ),
            const SizedBox(height: 16),
            ChunkyButton(label: 'Write my theory', icon: Icons.edit_note_rounded, onPressed: onWrite),
          ],
        ),
      );
    }
    return ChunkyBox(
      color: Pal.mustard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR THEORY IS IN', style: label(11)),
          const SizedBox(height: 8),
          Text(mine!.text, style: body(15.5, w: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  label: 'Rewrite',
                  color: Pal.paper,
                  icon: Icons.edit_rounded,
                  onPressed: onWrite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChunkyButton(
                  label: 'Withdraw',
                  color: Pal.rust,
                  textColor: Pal.paper,
                  onPressed: onWithdraw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ChunkyBox(
      color: Pal.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHAT DO YOU THINK IT IS?', style: display(22)),
          const SizedBox(height: 4),
          Text('Say what you see and why. Guesses with reasons get backed.',
              style: body(13, color: Pal.black.withOpacity(0.7))),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Pal.paperDeep,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Pal.black, width: 2.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: controller,
              focusNode: focus,
              maxLines: 5,
              minLines: 3,
              maxLength: 280,
              style: body(15),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterStyle: label(10, color: Pal.black.withOpacity(0.6)),
                hintText: 'It looks like...',
                hintStyle: body(15, color: Pal.black.withOpacity(0.4)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  label: 'Cancel',
                  color: Pal.paperDeep,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ChunkyButton(
                  label: 'Put it on the board',
                  icon: Icons.push_pin_rounded,
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TheoryCard extends StatelessWidget {
  const _TheoryCard({
    required this.theory,
    required this.revealed,
    required this.onBack,
  });

  final Theory theory;
  final bool revealed;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = theory.filedAt;
    final stamp = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return ChunkyBox(
      color: theory.mine ? Pal.mustard : Pal.paper,
      offset: 5,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Pal.black, shape: BoxShape.circle),
                child: Text(theory.author.substring(0, 1),
                    style: label(14, color: Pal.mustard)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  theory.mine ? 'You — ${theory.author}' : theory.author,
                  style: label(12),
                ),
              ),
              Text(stamp, style: label(11, color: Pal.black.withOpacity(0.55))),
            ],
          ),
          const SizedBox(height: 12),
          Text(theory.text, style: body(15)),
          const SizedBox(height: 14),
          Row(
            children: [
              if (revealed && theory.verdict != Verdict.pending)
                Tag(_verdict(theory.verdict), color: Pal.black, filled: true)
              else
                Tag('${theory.votes} backing', color: Pal.black.withOpacity(0.55)),
              const Spacer(),
              if (!theory.mine)
                GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: theory.backed ? Pal.olive : Colors.transparent,
                      border: Border.all(color: Pal.black, width: 2.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          theory.backed
                              ? Icons.check_rounded
                              : Icons.arrow_upward_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(theory.backed ? 'BACKED' : 'BACK IT', style: label(11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _verdict(Verdict v) => switch (v) {
        Verdict.solved => 'Solved it',
        Verdict.close => 'Close',
        Verdict.wrong => 'Missed',
        Verdict.pending => 'Pending',
      };
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.onWrite});
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Agent(pose: AgentPose.shrug, height: 150),
        const SizedBox(height: 12),
        Text('Nobody has spoken yet.', style: display(24)),
        const SizedBox(height: 8),
        Text('First theory sets the tone for the whole board.',
            textAlign: TextAlign.center, style: body(14)),
        const SizedBox(height: 16),
        ChunkyButton(label: 'Go first', onPressed: onWrite, expand: false),
      ],
    );
  }
}
