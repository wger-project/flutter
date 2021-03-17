# Mobile app for wger Workout Manager

Mobile app for wger written with flutter, still in early stages of development.
As soon as it is finished, it will be published in the different play stores.

If you want to contribute, hop on the discord server and say hi!

## Getting Started

### 1
Install the wger server, the easiest way is starting the development docker-compose:
<https://github.com/wger-project/wger>

### 2
Install flutter, all its dependencies and create a new virtual device: 
<https://flutter.dev/docs/get-started/install>

### 3
Create a new file ``wger.properties`` in ``android/app`` (next to build.gradle):

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
Start the application with ``flutter run`` or use your IDE (please note that
depending on how you run your emulator you will need to change the IP address
of the server)

## Translation
The application can be easily translated online with [Weblate](https://hosted.weblate.org/engage/wger/).


## Contact

Feel free to contact us if you found this useful or if there was something that
didn't behave as you expected. We can't fix what we don't know about, so please
report liberally. If you're not sure if something is a bug or not, feel free to
file a bug anyway.

* **discord:** <https://discord.gg/rPWFv6W>
* **issue tracker:** <https://github.com/wger-project/flutter/issues>
* **twitter:** <https://twitter.com/wger_project>

## License

The application is licensed under the GNU General Public License 3 or later (GPL 3+).

The initial exercise and ingredient data is licensed additionally under one of
the Creative Commons licenses, see the individual exercises for more details.
