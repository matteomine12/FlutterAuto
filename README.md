# Autō · FlutterAuto

A minimal, dark automotive dashboard for Android phones and tablets. Built with
Flutter Material 3 and **core layout widgets only**. No third-party runtime packages,
remote fonts, map keys, or image downloads are required for the demo.

## Run

Use **Flutter 3.35+ / Dart 3.9+**, JDK 17, and the Android SDK. CI is configured for
Flutter 3.35.7. Install the Android SDK components requested by `flutter doctor`.

```sh
flutter doctor
flutter pub get
flutter run                     # Select a connected Android device/emulator
```

Flutter configures `android/local.properties` with your local SDK paths. No
`flutter create` step is necessary; Android runner and Gradle wrapper are included.
This is an ordinary Android app, not an Android Auto projection app or replacement
system launcher. It does not require root.

Optional browser preview (Android actions explain that they require Android):

```sh
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

## Design & adaptive behavior

Charcoal backgrounds, warm white typography, pale mint controls, muted coral
artwork, generous whitespace, and softly differentiated surfaces. No outlined
cards, climate controls, vehicle telemetry, or pretend connection indicators.
Original vector artwork is painted locally and stays crisp at any resolution.

`HomePage` uses `SafeArea`, two `LayoutBuilder`s, `Row`/`Column`/`Expanded`, and
vertical scrolling. Breakpoints refer to **usable content width after padding**:

| Width | Composition |
| --- | --- |
| 1,000 dp and up | Clock/weather column, navigation, media; horizontal utilities |
| 600–999 dp | Clock/weather row, navigation/media row |
| Under 600 dp | Single-column modules; wrapped utilities and separate volume row |

Large accessibility text (>1.3× at 16sp) switches to a vertically flowing layout.
There is no orientation lock or clipped fixed-height page: short landscape
screens can scroll. The content is capped at 1,600 dp on very large displays.
Clock digits scale down within their module; other text respects system scaling.
Controls have 48 dp or larger touch targets, tooltips/semantics, and disabled
states. Media scrolling honors the system's reduced-animation preference.

## What works in phase one

| Component | Behavior |
| --- | --- |
| Clock & date | Device-local time/date, midnight updates, lifecycle refresh, session-only 12/24-hour setting |
| Media | Explicit **demo session**; play/pause simulation, next/previous, seek, progress, end-of-track handling; **no audio output** |
| Weather | Explicit **demo**: San Francisco, 21°C; injectable immutable state, not a live weather request |
| Navigation | Original **fictional preview**, not GPS or map tiles; button opens Google Maps on Android, or its website if Maps is absent |
| Apps | Lists launchable Android apps off the UI thread and opens a selected app |
| Phone | Opens the Android dialer; no automatic calls or contact permission |
| Settings | Clock format toggle and Android system settings shortcut |
| Volume | Reads/writes Android's media stream; refreshes on resume and after slider release; disabled on unsupported/fixed-volume devices |

Physical volume buttons target the media stream. This phase does not subscribe
to hardware-volume-change events while the app remains foregrounded, so the
slider refreshes on resume or after a slider interaction. Unsupported device
actions show a useful message instead of silently doing nothing. No location,
notification access, phone-call, or broad package-list permission is requested.

## Source layout

```text
lib/
  main.dart                          # Entry point and system bars
  app/
    auto_app.dart                    # MaterialApp
    auto_theme.dart                  # Shared color and component tokens
  core/platform/
    device_service.dart              # Typed Android method-channel adapter
  features/
    home/
      home_page.dart                 # Adaptive composition and lifecycle
      clock_module.dart
      navigation_module.dart         # Shortcut and vector preview
      quick_actions.dart
      device_sheets.dart             # App drawer and settings
    media/
      media_controller.dart          # Immutable state, contract, demo transport
      media_module.dart              # Provider-independent presentation
    weather/
      weather_module.dart            # Immutable state and presentation
  widgets/
    landscape_art.dart               # Local album-art placeholder
    module_label.dart
android/app/src/main/kotlin/com/flutterauto/headunit/
  MainActivity.kt                    # Maps, dialer, settings, apps, media volume
```

`HomePage(device: ..., media: ...)` accepts injected services/controllers for tests
or future production adapters. It owns/disposes only the controller it creates;
callers retain ownership of injected controllers.

## Next phase: Android background media

Replace `DemoMediaController` with a `MediaController` implementation without
changing the dashboard layout. `MediaState` separates metadata, source app,
artwork, position/duration, play state, and individual transport capabilities.
Unsupported transport controls are automatically disabled.

A real implementation should:

1. Add a `NotificationListenerService` and an explicit explanation/consent flow
   leading to Android notification-listener settings. Notification access is
   sensitive and **not requested by this scaffold**. It is not the same as a
   normal runtime notification permission.
2. Use `MediaSessionManager.getActiveSessions` and register `MediaController`
   callbacks. Select the active session; handle revocation, removed sessions,
   disconnections, buffering, live streams, and no-session state.
3. Send metadata and `PlaybackState` updates through an `EventChannel`, with
   transport commands through a `MethodChannel`. Gate controls using native
   playback capabilities; extrapolate position only while playing.
4. Forward toggle/next/previous/seek to `TransportControls`; never use demo
   timers as the authority for real playback.
5. Normalize Android bitmap/content-URI artwork into an app-owned file/bytes
   provider before displaying it. The current optional `artworkUri` renderer
   supports network URLs; Android `content://` URIs need a native resolver or
   a dedicated artwork provider. Retain the local error/placeholder artwork.

Apps may expose different media-session capabilities; Spotify/YouTube Music
control is **not implemented or guaranteed** in this phase. Add a separate
weather repository (including consent, units, stale/loading/error states, and
caching) before removing the weather demo label.

## Checks

```sh
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```

The test suite covers six screen dimensions (including 320 dp phones and short
landscape), 2× accessibility text, media transport and seek bounds, clock format,
Maps delegation, app drawer loading, missing native handlers, and method-channel
arguments. GitHub Actions is configured to run formatting, analysis, tests, and
Android/web builds.

**Validation in the authoring sandbox:** Flutter, Dart, Java, and Android SDKs are
not installed, so Flutter analysis, tests, and builds have **not been executed**.
All Dart sources were parsed/formatted with the WASM port of `dart_style`; Android
XML was parsed and Git whitespace checks passed. These do not replace compilation
or device testing. Run the commands above before release, generate/commit the
resulting `pubspec.lock`, and configure private Android release signing.

For device acceptance, also check orientation changes, display cutouts, TalkBack,
large font sizes, app resume at midnight, missing dialer/Maps apps, fixed media
volume, and installed-app launching on the target tablet. This is not a certified
in-motion driving interface; interact only when safe.
