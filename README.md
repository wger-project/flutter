# Mobile app for wger Workout Manager

wger is a free, open source flutter application that manages and tracks/logs
your exercises and personal workouts, weight and diet plans. This is the mobile
app written with Flutter, it talks via REST with the main server.

If you want to contribute, hop on the Discord server and say hi!


<p float="left">
<img src="https://github.com/wger-project/flutter/blob/master/android/fastlane/metadata/android/en-US/images/phoneScreenshots/01%20-%20workout%20plan.png?raw=true" width="200" />

<img src="https://github.com/wger-project/flutter/blob/master/android/fastlane/metadata/android/en-US/images/phoneScreenshots/02%20-%20workout%20log.png?raw=true" width="200" />

<img src="https://github.com/wger-project/flutter/blob/master/android/fastlane/metadata/android/en-US/images/phoneScreenshots/04%20-%20nutritional%20plan.png?raw=true" width="200" />
</p>


## Getting Started

### 1
Install the wger server, the easiest way is starting the development docker-compose:
<https://github.com/wger-project/wger>

Alternatively, you can use one of our test servers, just ask us for access.

### 2
Install Flutter, all its dependencies and create a new virtual device: 
<https://flutter.dev/docs/get-started/install>

### 3
Create a new file ``wger.properties`` in ``android/fastlane/envfiles``:

```properties
WGER_API_KEY=123456
```

To just run/develop the app it only needs to have any value for WGER_API_KEY, but
you need a correct value if you want to register via the app. For this you need
to allow (a probably dedicated) user on the wger server to register users in its
behalf. For this, generate an API KEY by visiting <http://localhost:8000/de/user/api-key>
on your local instance and then run ``python3 manage.py add-user-rest theusername``

You can later list all the registered users with: ``python3 manage.py list-users-api``  


### 4
Generate translation files with ``flutter gen-l10n``


### 5
Start the application with ``flutter run --no-sound-null-safety`` or use your IDE
(please note that depending on how you run your emulator you will need to change the
IP address of the server)

You can run the tests with ``flutter test --no-sound-null-safety``

## Translation
Translate the app to your language on  [Weblate](https://hosted.weblate.org/engage/wger/).

[![translation status](https://hosted.weblate.org/widgets/wger/-/mobile/multi-blue.svg)](https://hosted.weblate.org/engage/wger/)

## Contact

Feel free to get in touch if you found this useful or something  didn't behave
as expected. We can't fix what we don't know about, so please report liberally.
If you're not sure if something is a bug or not, feel free to file a bug anyway.

* **Discord:** <https://discord.gg/rPWFv6W>
* **Issue tracker:** <https://github.com/wger-project/flutter/issues>
* **Twitter:** <https://twitter.com/wger_project>

## License

The application is licensed under the GNU Affero General Public License 3 or later
(AGPL 3+) with an app store exception.

As an additional permission under section 7, you are allowed to distribute the
software through an app store, even if that store has restrictive terms and
conditions that are incompatible with the AGPL, provided that the source is also
available under the AGPL with or without this permission through a channel without
those restrictive terms and conditions.


The initial exercise and ingredient data is licensed additionally under one of
the Creative Commons licenses, see the individual exercises for more details.
