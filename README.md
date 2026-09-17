# MysteryDrop

One mystery a day. A photograph, an object or a place turns up in the morning,
clues drip out through the day, everyone files a theory, and at 21:00 the answer
opens.

## Run it

```bash
cd mysterydrop
flutter create . --platforms=ios,android,web   # generates the platform folders
flutter pub get
flutter run
```

No third-party packages. State lives in a single `ChangeNotifier` handed down
through an `InheritedNotifier`, so you can swap `MysteryRepository` for a real
backend without touching a screen.

## What's in the build

**Today** — the day's drop as a printed poster: case number, question, an
evidence plate, the countdown to the reveal, and the clue drip. Clues unlock on
a schedule between release and reveal; locked ones show as redaction bars. There
is a *Skip the wait* link at the bottom so you can watch the reveal state
without waiting for 21:00.

**The board** — write one theory per day, rewrite or withdraw it until the
reveal, and back other agents' theories. After the reveal every theory gets a
verdict: solved, close, or missed.

**Case files** — past drops. Tap one and the sheet opens with the answer and the
debrief explaining how the clues pointed there, plus what you said at the time.

**Dossier** — codename, rank ladder (Stringer → Chief of Station), hit rate,
streak, merits.

## Structure

```
lib/
  main.dart            entry point
  app.dart             AppScope (DI), Shell, bottom navigation
  theme.dart           palette + type scale
  models.dart          Drop, Theory, Detective, Merit
  repository.dart      seeded data and every mutation
  widgets/
    agent.dart         the character, drawn as vector paths
    poster.dart        ChunkyBox, ChunkyButton, Starburst, Grain, Countdown, Tag
    evidence.dart      procedural "evidence photo" per case seed
  screens/
    drop_screen.dart, theories_screen.dart,
    archive_screen.dart, dossier_screen.dart
```

## Design notes

The look follows the reference posters: warm printing ink (`#241F1A`) instead of
black, uncoated cream stock, and one flat spot colour per screen — rust for
today, olive for the board, cream for the archive, a cold blue-grey for the
dossier, mustard reserved so it only ever means *reveal*. Shadows are hard
offsets, not blurs, the way a two-colour print job would do them. Paper speckle
is drawn procedurally over every screen at about 6% opacity.

Type is one family at three roles — `display` for the ultra-bold headline voice,
`label` for stamps and metadata, `body` for reading. Drop an ultra-bold gothic
`.ttf` (Archivo Black, Bungee, Alfa Slab One) into `assets/fonts/`, uncomment
the fonts block in `pubspec.yaml`, and set `_family` in `theme.dart` to `'Slab'`
for the exact poster feel. Without it the app falls back to weight 900 and still
runs.

The character is an original figure built for this app — a trench coat, a
wide-brim hat and two shifty eyes, drawn entirely in `CustomPainter` paths so it
recolours per screen and scales without assets. Four poses: `standing`,
`peeking` (hat and eyes cropped by the widget edge), `evidence` (holding a jar)
and `shrug` (empty states). It is a homage to the mid-century detective style of
your references, not a copy of that artwork — worth keeping in mind if you ship
this commercially, since the source posters belong to their designers.

The evidence plates are procedural too: each case seed produces a stable
composition of flat shapes, a coarse hatch and crop marks. Replace
`EvidencePlate` with a real `Image.network` when you have photographs.

## Next steps worth taking

- Persist state (`shared_preferences` for the local agent, an API for drops).
- Push notification at drop time and fifteen minutes before the reveal.
- Verdict scoring done server-side so answers can't be read out of the client —
  right now the answer ships with the drop, which a determined user could pull
  from memory before the reveal.
- Spoiler guard on the archive for anyone who joined mid-case.
