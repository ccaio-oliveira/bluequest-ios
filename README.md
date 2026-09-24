# BlueQuest — iOS

Native iOS app for group fitness challenges. Friends join a challenge, complete daily tasks, earn points and compete on a live ranking — with photo proof and a shared feed so everyone can see each other's progress.

Backend: [bluequest-api-v2](https://github.com/ccaio-oliveira/bluequest-api-v2)

## Features

- **Challenges** with a start and end date, created and managed by an admin
- **Flexible tasks**: every day, specific weekdays, or specific calendar dates, each with its own deadline and point value
- **Photo proof**: tasks can require a photo (camera or gallery) to be completed
- **Challenge feed**: a timeline of every participant's completions and photos
- **Live ranking** and a final results screen with a podium
- **Invites** by link, which the admin can enable, disable or rotate
- **History calendar** with a monthly view, daily breakdown and streak
- **Admin tools**: edit challenge details and tasks, remove participants, end a challenge early
- Sign in with email or Google

## Tech stack

- **Swift** and **UIKit**, with every screen built in code (no storyboards)
- **MVVM + Coordinators**: view models own state; coordinators own navigation
- **Swift Concurrency** (`async/await`) over a small `URLSession` networking layer
- An in-house **design system** (colors, typography, spacing and reusable components)
- `PhotosUI` for photo picking and an `NSCache`-backed image loader with thumbnailing
- Single third-party dependency: [GoogleSignIn-iOS](https://github.com/google/GoogleSignIn-iOS) (Swift Package Manager)

## Project structure

```
BlueQuest/
├── App/            # App entry, environment config, tab and root coordinators
├── Data/           # API client, services and DTOs
├── DesignSystem/   # Tokens and reusable UI components
├── Domain/         # Domain models
└── Features/       # One folder per feature: Auth, Challenges, History, Profile
```

## Running locally

1. Start the [API](https://github.com/ccaio-oliveira/bluequest-api-v2) (see its README)
2. Open `BlueQuest.xcodeproj` in Xcode
3. Point the app at your API in `BlueQuest/App/AppEnvironment.swift`: the simulator uses `127.0.0.1`, a physical device needs a reachable address such as a tunnel
4. Build and run the `BlueQuest` scheme

Requires iOS 26.5 or later.