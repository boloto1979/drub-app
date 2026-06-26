# Drub — Tibetan Buddhist Practice Tracker

**སྒྲུབ།** (*drub*) is a mobile app for tracking the accumulation of Tibetan Buddhist practices — mantras, prostrations, mandala offerings, and other ngöndro or long-term commitments.

## Overview

Practitioners in the Tibetan Buddhist tradition often commit to accumulating large numbers of recitations or practices over months or years. Drub provides a focused, contemplative interface for recording and visualizing that progress — without distractions.

## Features

- **Practice tracking** — create practices with a target count, daily goal, and mala size
- **Mala-based accumulation** — tap to add one mala at a time; edit manually when needed
- **Progress visualization** — progress bar, total accumulated, and remaining count per practice
- **Daily calendar** — visual overview of practice days across the month
- **Rotating lama quotes** — verified teachings from Dudjom Rinpoche, Dilgo Khyentse Rinpoche, Patrul Rinpoche, and Nyoshul Khen Rinpoche (sourced from [Lotsawa House](https://lotsawahouse.org))
- **Bilingual** — English and Portuguese
- **Offline-first** — all data stored locally on device

## Design

Inspired by the aesthetic of contemplative Tibetan Buddhist institutions — deep maroon, gold, and cream tones; Cormorant Garamond serif typography for titles; Raleway for labels and actions. Designed for daily use.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| State management | Riverpod (with code generation) |
| Database | Isar (local NoSQL) |
| Navigation | GoRouter |
| Fonts | Cormorant Garamond, Raleway (Google Fonts) |

## Getting Started

```bash
flutter pub get
dart run build_runner build
flutter run
```

Requires Flutter 3.x and Dart 3.x.

## Lama Quotes Sources

All quotes are verified translations from [Lotsawa House](https://lotsawahouse.org):

- Dudjom Rinpoche — *Calling the Guru from Afar*
- Dilgo Khyentse Rinpoche — *Heart Advice in Four Lines*, *Advice to Three-Year Retreatants*, *Advice to Jamyang Gyaltsen*
- Patrul Rinpoche — *Preliminary Points*
- Nyoshul Khen Rinpoche — *Natural Great Peace*, *Mindfulness: The Mirror of the Mind*

## License

MIT
