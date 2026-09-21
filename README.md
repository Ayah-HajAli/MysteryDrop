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



