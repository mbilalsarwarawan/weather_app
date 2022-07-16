import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'getLocation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'GetIcons.dart';

void main() => runApp(weatherApp());

String description;
double temp;
String city;
String icon;

class weatherApp extends StatefulWidget {
  const weatherApp({Key key}) : super(key: key);

  @override
  State<weatherApp> createState() => _weatherAppState();
}

class _weatherAppState extends State<weatherApp> {
  // the function to chose the images according to the time

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  initState() {
    super.initState();
    GetLocations();
  }

  displayImage() {
    var now = DateTime.now();
    final currentTime = DateFormat.jm().format(now);
//if time contains AM then the image is daytime
    if (currentTime.contains('AM ')) {
      return Image.asset('images/dayTime.jpg');
    } else {
      return Image.asset('images/nightTime.jpg');
    }
  }

  Future<void> GetLocations() async {
    getLocation Getlocation = new getLocation();
    await Getlocation.determinePosition();

    city = Getlocation.city;
    await getTemp(city);
  }

// get current temperature
  Future<void> getTemp(String city) async {
    String apiKey = '952c54e9857c50df2ebaa7d7f8cf5c7d';

    var url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";
    final http.Response response = await http.get(Uri.parse(url));
    print(response.body);
    var dataDecoded = convert.jsonDecode(response.body);

    setState(() {
      temp = dataDecoded['main']['temp'];
      description = dataDecoded['weather'][0]['description'];
      icon = dataDecoded['weather'][0]['icon'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyBoard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
      ),
      resizeToAvoidBottomInset: false,
      body: temp == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    if (!isKeyBoard)
                      Container(
                        child: displayImage(),
                      ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    'You are In',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[500],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Container(
                        child: Text(
                          '$city',
                          style: TextStyle(
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[500],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  margin:
                      EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
                  color: Colors.white,
                  child: ListTile(
                    leading: GetIcons.getIcon('${icon}'),
                    title: Text(
                      'Temp : ' + temp.toString() + ' C',
                    ),
                    subtitle: Text('${description.toString()}'),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: 300,
                      child: TextField(
                        onSubmitted: (String input) {
                          getTemp(input);
                          setState(() {
                            city = input;
                          });
                        },
                        style: TextStyle(color: Colors.black, fontSize: 25),
                        decoration: InputDecoration(
                          hintText: 'Search another location...',
                          hintStyle:
                              TextStyle(color: Colors.black, fontSize: 18.0),
                          prefixIcon: Icon(Icons.search, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
