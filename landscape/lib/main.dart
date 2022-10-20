import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'FITALIVE';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: true,
        title: title,
        theme: ThemeData(primarySwatch: Colors.red),
        home: MainPage(title: title),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: setPortraitAndLandscape,
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(32),
          child: OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? buildPortrait()
                    : buildLandscape(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.rotate_left),
          onPressed: () {
            final isPortrait =
                MediaQuery.of(context).orientation == Orientation.portrait;

            if (isPortrait) {
              setLandscape();
            } else {
              setPortrait();
            }
          },
        ),
      );

  Future setPortrait() async => await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

  Future setLandscape() async => await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

  Future setPortraitAndLandscape() =>
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  Widget buildPortrait() => ListView(
        children: [
          buildImage(),
          const SizedBox(height: 16),
          buildText(),
        ],
      );

  Widget buildLandscape() => Row(
        children: [
          buildImage(),
          const SizedBox(width: 16),
          Expanded(child: SingleChildScrollView(child: buildText())),
        ],
      );

  Widget buildImage() => Image.network(
      'https://images.unsplash.com/photo-1600026453346-a44501602a02?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTA4fHxneW18ZW58MHx8MHx8&auto=format&fit=crop&w=600&q=60');
  Widget buildsImage() => Image.network(
      'https://images.unsplash.com/photo-1600026453346-a44501602a02?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTA4fHxneW18ZW58MHx8MHx8&auto=format&fit=crop&w=600&q=60');
  Widget buildText() => Column(
        children: [
          Text(
            'Focus On Back,Leg',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '''Nowadays, everyone is obsessed with having a good body. Dieting, exercising and lots of stuff they do to achieve their goal. Gym memberships usually grow especially after the holidays when people eat so much. Then they go to the gym to burn the fat.Many reasons to go to gym. Of course exercise is priority. The gym has plenty exercise machines that people can use to develop different muscle groups. Kulas (para. 1) in her article, “The Advantages of Going to the Gym Every Day”, says at least 30 minutes of moderate exercise should be done by adults five days in a week so going to the gym everyday will meet that goal. It will result in good physical and mental health.''',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          new Container(
            child: Text("JOIN OUR TEAM",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          new Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
                      hintText: 'Enter Your Name',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mobile Number',
                      hintText: 'Enter Your Number',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter Your Email_id',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Favourite Player',
                      hintText: 'Enter Player Name',
                    ),
                  ),
                ),
                RaisedButton(
                  textColor: Colors.white,
                  color: Colors.green,
                  child: Text('Submit'),
                  onPressed: () {},
                )
              ]))
        ],
      );
}
