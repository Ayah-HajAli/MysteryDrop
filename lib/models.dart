enum DropKind { location, object, photograph }

extension DropKindX on DropKind {
  String get label => switch (this) {
        DropKind.location => 'Location',
        DropKind.object => 'Object',
        DropKind.photograph => 'Photograph',
      };
}

enum Verdict { pending, close, wrong, solved }

class Theory {
  Theory({
    required this.id,
    required this.author,
    required this.text,
    this.votes = 0,
    this.mine = false,
    this.verdict = Verdict.pending,
    DateTime? filedAt,
  }) : filedAt = filedAt ?? DateTime.now();

  final String id;
  final String author;
  final String text;
  final DateTime filedAt;
  final bool mine;

  int votes;
  bool backed = false;
  Verdict verdict;
}

class Drop {
  Drop({
    required this.caseNumber,
    required this.kind,
    required this.title,
    required this.question,
    required this.clues,
    required this.answer,
    required this.debrief,
    required this.releasedAt,
    required this.revealAt,
    required this.seed,
    List<Theory>? theories,
  }) : theories = theories ?? [];

  final int caseNumber;
  final DropKind kind;
  final String title;
  final String question;
  final List<String> clues;
  final String answer;
  final String debrief;
  final DateTime releasedAt;
  final DateTime revealAt;
  final int seed;
  final List<Theory> theories;

  String get code => 'CASE №$caseNumber';

  bool get isRevealed => !DateTime.now().isBefore(revealAt);

  Duration get timeToReveal {
    final left = revealAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Clues arrive on a drip through the day so the board keeps moving.
  int get unlockedClues {
    if (isRevealed) return clues.length;
    final span = revealAt.difference(releasedAt).inSeconds;
    if (span <= 0) return clues.length;
    final gone = DateTime.now().difference(releasedAt).inSeconds;
    final n = ((gone / span) * clues.length).floor() + 1;
    return n.clamp(1, clues.length);
  }

  Duration? get nextClueIn {
    if (isRevealed || unlockedClues >= clues.length) return null;
    final span = revealAt.difference(releasedAt).inSeconds;
    final step = span / clues.length;
    final at = releasedAt.add(Duration(seconds: (step * unlockedClues).round()));
    final left = at.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  Theory? get myTheory {
    for (final t in theories) {
      if (t.mine) return t;
    }
    return null;
  }

  List<Theory> get sortedTheories {
    final list = [...theories];
    list.sort((a, b) {
      if (a.mine != b.mine) return a.mine ? -1 : 1;
      return b.votes.compareTo(a.votes);
    });
    return list;
  }
}

class Detective {
  Detective({
    required this.codename,
    required this.filed,
    required this.solved,
    required this.streak,
    required this.backedBest,
    required this.joined,
  });

  String codename;
  int filed;
  int solved;
  int streak;
  int backedBest;
  final DateTime joined;

  double get hitRate => filed == 0 ? 0 : solved / filed;

  String get rank {
    if (solved >= 40) return 'Chief of Station';
    if (solved >= 25) return 'Field Handler';
    if (solved >= 12) return 'Case Officer';
    if (solved >= 5) return 'Legman';
    return 'Stringer';
  }

  /// 0–1 progress toward the next rank, for the dossier meter.
  double get rankProgress {
    const gates = [0, 5, 12, 25, 40];
    for (var i = 0; i < gates.length - 1; i++) {
      if (solved < gates[i + 1]) {
        final lo = gates[i], hi = gates[i + 1];
        return (solved - lo) / (hi - lo);
      }
    }
    return 1;
  }

  int? get toNextRank {
    const gates = [5, 12, 25, 40];
    for (final g in gates) {
      if (solved < g) return g - solved;
    }
    return null;
  }
}

class Merit {
  const Merit(this.name, this.note, this.earned);
  final String name;
  final String note;
  final bool earned;
}
