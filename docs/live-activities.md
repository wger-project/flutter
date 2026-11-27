# iOS rest Live Activities

Countdown rests in gym mode appear on the Lock Screen and, on supported iPhones,
in Dynamic Island. The native timer uses the planned start and end instants and
continues rendering while Flutter is suspended. Extending a rest updates the same
activity; skipping it, advancing to a set, leaving gym mode or finishing ends it.
Existing local rest notifications continue to provide alerts.

Live Activities require iOS 16.2 or later and permission in iOS Settings.
Devices running older supported iOS versions keep the existing in-app timer.
No external service, remote push token or additional Flutter package is needed.

The WgerRestWidget extension is included in Runner.xcodeproj and embedded in the
normal iOS build. Its bundle identifier is de.wger.flutter.community.rest.
Distribution requires provisioning the extension alongside the main app using the
same development team. Build name and number come from Flutter's Generated.xcconfig.

At zero, the native countdown stays at zero until the next app update ends the
activity or the user dismisses it. A Live Activity is a visual countdown, not an
alarm; existing scheduled local notifications remain responsible for alerts.
