import 'package:flutter/foundation.dart';

import 'models.dart';

/// Single source of truth for the demo. Swap the seeded lists for a real API
/// or local store later — every screen only talks to this object.
class MysteryRepository extends ChangeNotifier {
  MysteryRepository() {
    _today = _buildToday();
    _archive = _buildArchive();
  }

  late Drop _today;
  late List<Drop> _archive;

  final Detective detective = Detective(
    codename: 'AGENT TEASPOON',
    filed: 34,
    solved: 14,
    streak: 6,
    backedBest: 9,
    joined: DateTime.now().subtract(const Duration(days: 96)),
  );

  Drop get today => _today;
  List<Drop> get archive => _archive;

  List<Merit> get badges => [
        Merit('First Light', 'Filed a theory before the second clue', true),
        Merit('Hot Streak', 'Six days on the board without missing', detective.streak >= 5),
        Merit('The Long Shot', 'Solved a drop with one clue unlocked', true),
        Merit('Crowd Favourite', 'A theory of yours topped the board', detective.backedBest >= 5),
        Merit('Cartographer', 'Ten locations placed correctly', detective.solved >= 12),
        Merit('Night Shift', 'Filed after midnight, five times', false),
      ];

  // ---------------------------------------------------------------- actions

  void fileTheory(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final existing = _today.myTheory;
    if (existing != null) _today.theories.remove(existing);
    _today.theories.insert(
      0,
      Theory(
        id: 't-${DateTime.now().microsecondsSinceEpoch}',
        author: detective.codename,
        text: trimmed,
        mine: true,
      ),
    );
    if (existing == null) detective.filed += 1;
    notifyListeners();
  }

  void withdrawTheory() {
    final mine = _today.myTheory;
    if (mine == null) return;
    _today.theories.remove(mine);
    detective.filed -= 1;
    notifyListeners();
  }

  void toggleBacking(Theory theory) {
    if (theory.mine) return;
    theory.backed = !theory.backed;
    theory.votes += theory.backed ? 1 : -1;
    notifyListeners();
  }

  /// Public nudge for widgets that need a rebuild (e.g. a countdown hitting 0).
  void refresh() => notifyListeners();

  void renameAgent(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    detective.codename = trimmed.toUpperCase();
    notifyListeners();
  }

  /// Demo hook: jump the reveal forward so you can see the whole arc.
  void forceReveal() {
    _today = Drop(
      caseNumber: _today.caseNumber,
      kind: _today.kind,
      title: _today.title,
      question: _today.question,
      clues: _today.clues,
      answer: _today.answer,
      debrief: _today.debrief,
      releasedAt: _today.releasedAt,
      revealAt: DateTime.now().subtract(const Duration(seconds: 1)),
      seed: _today.seed,
      theories: _today.theories,
    );
    for (final t in _today.theories) {
      if (t.mine) t.verdict = Verdict.close;
    }
    notifyListeners();
  }

  // ------------------------------------------------------------- seed data

  Drop _buildToday() {
    final now = DateTime.now();
    var reveal = DateTime(now.year, now.month, now.day, 21);
    if (!now.isBefore(reveal)) reveal = reveal.add(const Duration(days: 1));
    final released = reveal.subtract(const Duration(hours: 15));

    return Drop(
      caseNumber: 212,
      kind: DropKind.location,
      title: 'The door with no handle',
      question: 'Where is this door, and what is it for?',
      clues: const [
        'The brickwork is Flemish bond, so the wall went up before 1912.',
        'A tram cable crosses four metres above the frame.',
        'The green paint matches the shade the city water board used until 1968.',
        'Someone leaves a single flower on the step every Tuesday morning.',
      ],
      answer: 'A sealed inspection door on the Kirchsteig pumping station, Hafenviertel.',
      debrief:
          'The station stopped pumping in 1968 and was bricked up from the inside, '
          'so the handle was removed rather than replaced. The flower is left by a '
          'retired engineer who worked the last night shift.',
      releasedAt: released,
      revealAt: reveal,
      seed: 212,
      theories: [
        Theory(
          id: 't1',
          author: 'NIGHT PORTER',
          text: 'Old fire brigade hose store. Every district had one and they all got '
              'sealed when the pumps were centralised.',
          votes: 128,
          filedAt: released.add(const Duration(hours: 2)),
        ),
        Theory(
          id: 't2',
          author: 'MRS VANISH',
          text: 'Not a door at all — it is a cast panel over a filled-in stair to a '
              'basement laundry. The step wear stops dead at the threshold.',
          votes: 94,
          filedAt: released.add(const Duration(hours: 3, minutes: 20)),
        ),
        Theory(
          id: 't3',
          author: 'COLD TOAST',
          text: 'That green is water board green. I would bet on a pumping or metering '
              'station, and the flower is for someone who died on shift.',
          votes: 87,
          filedAt: released.add(const Duration(hours: 4)),
        ),
        Theory(
          id: 't4',
          author: 'PARCEL 19',
          text: 'Tram cable plus no handle says traction substation. They were built '
              'blind on purpose so nobody wandered in.',
          votes: 51,
          filedAt: released.add(const Duration(hours: 5, minutes: 40)),
        ),
        Theory(
          id: 't5',
          author: 'SMALL HOURS',
          text: 'Everyone is overthinking it. Bricked-up coal chute, and the flower is a '
              'neighbour with a shrine habit.',
          votes: 23,
          filedAt: released.add(const Duration(hours: 7)),
        ),
      ],
    );
  }

  List<Drop> _buildArchive() {
    final now = DateTime.now();
    Drop past(
      int n,
      int daysAgo,
      DropKind kind,
      String title,
      String question,
      String answer,
      String debrief,
      Verdict verdict,
      String myText,
      int crowd,
    ) {
      final reveal = DateTime(now.year, now.month, now.day, 21)
          .subtract(Duration(days: daysAgo));
      return Drop(
        caseNumber: n,
        kind: kind,
        title: title,
        question: question,
        clues: const [],
        answer: answer,
        debrief: debrief,
        releasedAt: reveal.subtract(const Duration(hours: 15)),
        revealAt: reveal,
        seed: n,
        theories: [
          Theory(
            id: 'a$n',
            author: detective.codename,
            text: myText,
            votes: crowd,
            mine: true,
            verdict: verdict,
            filedAt: reveal.subtract(const Duration(hours: 9)),
          ),
        ],
      );
    }

    return [
      past(
        211,
        1,
        DropKind.object,
        'The brass key',
        'What does this key open?',
        'Room 404 of the Grand Metropol, closed 1974.',
        'The bow carries a hotel crest that was only stamped for four years. '
            'Two hundred of these keys went missing the week the hotel shut.',
        Verdict.solved,
        'Hotel key. The wear pattern on the bit says it was turned thousands of times '
            'by different hands, which rules out a house key.',
        9,
      ),
      past(
        210,
        2,
        DropKind.photograph,
        'Forty-one steps',
        'Which city is this stair in?',
        'Cerro Concepción, Valparaíso.',
        'The handrail casting and the pattern of the tiles are local to one hillside. '
            'The giveaway was the funicular cable in the top-left corner.',
        Verdict.close,
        'Somewhere on the Chilean coast — the rail ironwork looks Valparaíso, but I '
            'guessed the wrong hill.',
        4,
      ),
      past(
        209,
        3,
        DropKind.location,
        'The humming field',
        'What is making the sound in this field?',
        'A decommissioned radio array, still fed by a live substation.',
        'Nine of the twelve dishes were sold for scrap. The hum belongs to the '
            'transformer nobody bothered to switch off.',
        Verdict.wrong,
        'Underground gas compressor station. The vent stacks at the treeline gave it '
            'away — or so I thought.',
        2,
      ),
      past(
        208,
        4,
        DropKind.object,
        'A jar of blue sand',
        'Where did this sand come from?',
        'Cobalt glass waste from a shuttered works, ground by sixty years of surf.',
        'Not sand at all. Under magnification every grain is a rounded shard. '
            'The beach sits directly below the old tip.',
        Verdict.solved,
        'Glass, not mineral. Too uniform in colour to be natural — I would look for a '
            'glassworks upwind of the beach.',
        11,
      ),
      past(
        207,
        5,
        DropKind.photograph,
        'Nobody at the counter',
        'What kind of shop was this?',
        'A licensed pigeon supply merchant, closed 1991.',
        'The rows of small drawers and the perch rail behind the till only make sense '
            'for one trade. The scale is calibrated in ounces, not grams.',
        Verdict.wrong,
        'Hardware shop. Those drawers are for screws and nothing else.',
        1,
      ),
    ];
  }
}
