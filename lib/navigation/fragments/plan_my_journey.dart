import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:myrapidplanmyjourney/api.dart';
import 'package:myrapidplanmyjourney/navigation/fragments.dart' show FragmentUtils;
import 'package:myrapidplanmyjourney/navigation/navigations.dart';

class PlanMyJourney extends StatefulWidget {
  @override
  _PlanMyJourneyState createState() => new _PlanMyJourneyState();
}

class _PlanMyJourneyState extends State<PlanMyJourney> with FragmentUtils, AutomaticKeepAliveClientMixin<PlanMyJourney> {

  List<dynamic> data = [];
  Map<String, dynamic?> from = {};
  final TextEditingController _fromController = TextEditingController();
  Map<String, dynamic?> to = {};
  final TextEditingController _toController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  String time = TimeOfDay.now().toString().replaceAll('TimeOfDay(', '').replaceAll(')', '');
  String mode = 'mix';
  String type = 'fastest';

  _PlanMyJourneyState();

  @override
  bool get wantKeepAlive => true;

  Future<List> _getListStreetAutocomplete(String term) async {
    try {
      Map<String, String> query = {};
      query['term'] = term;
      final response = await Api.ListStreetAutocomplete(query);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return Map.from(responseBody['data']!)['results']!;
      } else {
        final snackBar = SnackBar(content: Text('Server Error'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on Exception {
      final snackBar = SnackBar(content: Text('Network Error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return <dynamic>[];
  }

  String _humanReadableDuration(int duration) {
    if ((duration/60) < 60) {
      return (duration/60).toStringAsFixed(0) + " min";
    } else {
      return ((duration/60)/60).toStringAsFixed(0) + " hour & " + ((duration/60)%60).toStringAsFixed(0) + " min";
    }
    return "Unknown";
  }

  String _calculateETA(int duration) {
    var parsedDate = DateTime.parse(new DateTime.now().toString().substring(0,10) + ' ' + time + ':00');
    var eta = parsedDate.add(Duration(seconds: duration));
    return DateFormat('hh:mm a').format(eta).toString();
  }

  Map<String, dynamic> _analyzeLegs(List<dynamic> legs) {
    List<dynamic> instructions = <dynamic>[];
    Map<String, dynamic> cost = new Map();
    legs.forEach((_leg) {
      var leg = Map.from(_leg);
      if (leg['type'] != "pedestrain" && leg['alt_fare_price'] != null) {
        Map.from(leg['alt_fare_price']).forEach((key, value) {
          if (cost[key] == null) {
            cost[key] = double.parse(value);
          } else {
            cost[key] += double.parse(value);
          }
        });
      }
      if (leg['type'] == "pedestrain") {
        var temp = new Map();
        temp['text'] = "Walk for about ${_humanReadableDuration(leg['duration'])} or ${(leg['distance']/1000).toStringAsFixed(2)}KM";
        temp['distance'] = (leg['distance']/1000).toStringAsFixed(2) + "KM";
        temp['duration'] = _humanReadableDuration(leg['duration']);
        instructions.add(temp);
      } else {
        var transport = "LRT";
        if (leg['other_route'].contains(new RegExp(r'[0-9]'))) {
          transport = "Bus";
        } else if (leg['other_route'][0].toLowerCase() == "mrt") {
          transport = "MRT";
        }
        var temp = new Map();
        var stop = Map.from(leg['steps'][leg['steps'].length - 1]);
        temp['text'] =  "Take ${transport} ${leg['other_route'][0]} for about ${_humanReadableDuration(leg['duration'])} and stop at ${stop['stop_name']} station";
        temp['distance'] = (leg['distance']/1000).toStringAsFixed(2) + "KM";
        temp['duration'] = _humanReadableDuration(leg['duration']);
        temp['stops'] =  leg['steps'].length;
        instructions.add(temp);
      }
    });
    return <String, dynamic>{
      'instructions': instructions,
      'cost': cost,
    };
  }

  Widget _renderRouteOptions(List<dynamic> options) {
    int idx = 0;
    List<Widget> routes = [];
    for(var i in options) {
      routes.add(
        Container(
          height: 58,
          child: new Row(
            children: <Widget>[
              new Container(
                color: Colors.grey[100],
                padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                width: (MediaQuery.of(context).size.width) * 0.25,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('ETA'),
                    Text(_calculateETA(i['total_duration'])),
                  ]
                )
              ),
              new Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                width: (MediaQuery.of(context).size.width) * 0.25,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(_humanReadableDuration(i['total_duration'])),
                    Text('Duration'),
                  ]
                ),
              ),
              new Container(
                color: Colors.grey[100],
                padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                width: (MediaQuery.of(context).size.width) * 0.25,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text((i['total_distance']/1000).toStringAsFixed(2)),
                    Text('KM'),
                  ]
                ),
              ),
              new Container(
                color: Theme.of(context).primaryColor,
                width: (MediaQuery.of(context).size.width) * 0.25,
                child: new Material(
                  child: new InkWell(
                    onLongPress: () {
                      // final snackBar = SnackBar(content: Text(i['t_route'].toString().toUpperCase()));
                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    onTap: () {
                      //Navigator.push(
                      //  context,
                      //  MaterialPageRoute(builder: (BuildContext context) => new RouteDetail.fromJson(i))
                      //);
                      //print(i['legs'].runtimeType);
                      print(_analyzeLegs(i['legs']));
                    },
                    child: new Container(
                      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                      width: (MediaQuery.of(context).size.width) * 0.33,
                      child: new Center(
                        child: Text(
                          'VIEW DETAIL',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
                        )
                      )
                    )
                  ),
                  color: Colors.transparent,
                )
              ),
            ]
          )
        )
      );
      idx++;
      if (idx != options.length) {
        routes.add(new Divider(height: 3, color: Colors.grey));
      }
    }
    return new SingleChildScrollView(
      child: new Column(
        children: routes,
      )
    );
  }

  void _getListPlanner() async {
    try {
      Map<String, String> query = {
        'flat': from['lat']?.toString() ?? '',
        'flng': from['lng']?.toString() ?? '',
        'tlat': to['lat']?.toString() ?? '',
        'tlng': to['lng']?.toString() ?? '',
        'departure_datetime': new DateTime.now().toString().substring(0,10) + ' ' + time + ':00',
        'mode': mode,
        'type': type,
      };
      showloadingDialog(true, context);
      final response = await Api.ListPlanner(query);
      showloadingDialog(false, context);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final routes = Map.from(responseBody['data']!)['routes']!;
        if (routes.length > 0) {
          setState(() { data = routes; });
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext _) {
              return _renderRouteOptions(data);
            },
            backgroundColor: Colors.white,
            isScrollControlled: false
          );
          return;
        }
        final snackBar = SnackBar(content: Text('We are sorry, no results found for option chosen. Please try other modes'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(content: Text('Server Error'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on Exception {
      final snackBar = SnackBar(content: Text('Network Error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      data = [];
    });
    return;
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        time = picked.toString().replaceAll('TimeOfDay(', '').replaceAll(')', '');
      });
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return new Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          new SizedBox(height: 5.0),
          new Container(
            decoration: new BoxDecoration(
              color: Colors.red,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(3.0),
                topRight: const Radius.circular(3.0),
                bottomLeft: const Radius.circular(3.0),
                bottomRight: const Radius.circular(3.0),
              )
            ),
            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  "CURRENT LOCATION",
                  style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    )
                  )
                ),
                new SizedBox(height: 5.0),
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    controller: _fromController,
                    style: DefaultTextStyle.of(context).style.copyWith(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 16.0),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_searching,
                        size: 24.0,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      hintText: 'search a road name or landmark',
                      hintStyle: DefaultTextStyle.of(context).style.copyWith(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 16.0)
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.length == 0) {
                      return Future<List>.value(List.empty());
                    }
                    return await _getListStreetAutocomplete(pattern);
                  },
                  itemBuilder: (context, dynamic suggestion) {
                    return ListTile(
                      leading: Icon(Icons.my_location),
                      title: Text(suggestion['poiname'] ?? suggestion['areaname']!),
                      subtitle: Text(suggestion['poi_id']?.toString() ?? suggestion['line_id']!.toString()),
                    );
                  },
                  onSuggestionSelected: (dynamic suggestion) {
                    Map<String, dynamic?> tempFrom = {};
                    suggestion.forEach((k, v) {
                      if (v == null || v.runtimeType == String) {
                        tempFrom[k] = v;
                      }
                      if (k == 'geometry') {
                        Map<String, dynamic> geo = Map.from(v!);
                        tempFrom['lat'] = geo['coordinates'][1]!;
                        tempFrom['lng'] = geo['coordinates'][0]!;
                      }
                    });
                    setState(() { from = tempFrom; });
                    _fromController.text = from['poiname'] ?? from['areaname']!;
                  },
                ),
                new SizedBox(height: 5.0),
                new Text(
                  "DESTINATION",
                  style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    )
                  )
                ),
                new SizedBox(height: 5.0),
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    controller: _toController,
                    style: DefaultTextStyle.of(context).style.copyWith(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 16.0),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.flag,
                        size: 24.0,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      hintText: 'search a road name or landmark',
                      hintStyle: DefaultTextStyle.of(context).style.copyWith(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 16.0)
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.length == 0) {
                      return Future<List>.value(List.empty());
                    }
                    return await _getListStreetAutocomplete(pattern);
                  },
                  itemBuilder: (context, dynamic suggestion) {
                    return ListTile(
                      leading: Icon(Icons.my_location),
                      title: Text(suggestion['poiname'] ?? suggestion['areaname']!),
                      subtitle: Text(suggestion['poi_id']?.toString() ?? suggestion['line_id']!.toString()),
                    );
                  },
                  onSuggestionSelected: (dynamic suggestion) {
                    Map<String, dynamic?> tempTo = {};
                    suggestion.forEach((k, v) {
                      if (v == null || v.runtimeType == String) {
                        tempTo[k] = v;
                      }
                      if (k == 'geometry') {
                        Map<String, dynamic> geo = Map.from(v!);
                        tempTo['lat'] = geo['coordinates'][1]!;
                        tempTo['lng'] = geo['coordinates'][0]!;
                      }
                    });
                    setState(() { to = tempTo; });
                    _toController.text = to['poiname'] ?? to['areaname']!;
                  },
                )
              ]
            )
          ),
          new SizedBox(height: 5.0),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(3.0),
                topRight: const Radius.circular(3.0),
                bottomLeft: const Radius.circular(3.0),
                bottomRight: const Radius.circular(3.0),
              )
            ),
            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
            child: Theme(
              data: ThemeData.dark(), //set the dark theme or write your own theme
              child:  new Column(
                children: <Widget>[
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        'OPTIONS',
                        style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          )
                        )
                      ),
                      new Column(
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              Radio(
                                autofocus: true,
                                activeColor: Colors.white,
                                groupValue: type,
                                value: 'fastest',
                                onChanged: (String? value) {
                                  setState(() { type = 'fastest'; });
                                },
                              ),
                              new Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.timer,
                                    color: Colors.white,
                                  ),
                                  new Text(
                                    'Shortest Time',
                                    style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white,))
                                  )
                                ]
                              )
                            ]
                          ),
                          new Row(
                            children: <Widget>[
                              Radio(
                                value: 'leasttransit',
                                activeColor: Colors.white,
                                groupValue: type,
                                onChanged: (String? value) {
                                  setState(() { type = 'leasttransit'; });
                                },
                              ),
                              new Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.store_mall_directory,
                                    color: Colors.white,
                                  ),
                                  new Text(
                                    'Least Transfer',
                                    style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white,))
                                  )
                                ]
                              )
                            ]
                          ),
                        ],
                      )
                    ]
                  ),
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        'MODES',
                        style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          )
                        )
                      ),
                      new Column(
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              Radio(
                                autofocus: true,
                                activeColor: Colors.white,
                                groupValue: mode,
                                value: 'mix',
                                onChanged: (String? value) {
                                  setState(() { mode = 'mix'; });
                                },
                              ),
                              new Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.rv_hookup,
                                    color: Colors.white,
                                  ),
                                  new Text(
                                    'Mixed',
                                    style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white,))
                                  )
                                ]
                              )
                            ]
                          ),
                          new Row(
                            children: <Widget>[
                              Radio(
                                value: 'bus',
                                activeColor: Colors.white,
                                groupValue: mode,
                                onChanged: (String? value) {
                                  setState(() { mode = 'bus'; });
                                },
                              ),
                              new Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.directions_bus,
                                    color: Colors.white
                                  ),
                                  new Text(
                                    'Bus',
                                    style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white,))
                                  )
                                ]
                              )
                              
                            ]
                          ),
                          new Row(
                            children: <Widget>[
                              Radio(
                                value: 'rail',
                                activeColor: Colors.white,
                                groupValue: mode,
                                onChanged: (String? value) {
                                  setState(() { mode = 'rail'; });
                                },
                              ),
                              new Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.directions_railway,
                                    color: Colors.white
                                  ),
                                  new Text(
                                    'Rail',
                                    style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white,))
                                  )
                                ]
                              )
                            ]
                          ),
                        ],
                      ),
                    ]
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'DEPARTURE TIME',
                        style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          )
                        )
                      ),
                      new SizedBox(width: 8),
                      new Container(
                        width: (MediaQuery.of(context).size.width - 20) * 0.40,
                        child: new SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            onPressed: () => _selectTime(context),
                            child: new Container(
                              alignment: Alignment.center,
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  new Icon(
                                    Icons.departure_board,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  new SizedBox(width: 8.0),
                                  Text(
                                    selectedTime.format(context),
                                    style: TextStyle(color: Theme.of(context).primaryColor,)
                                  )
                                ]
                              )
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ]
              )
            ),
          ),
          new SizedBox(height: 5.0),
          new Container(
            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: SizedBox(
              width: double.infinity, // match_parent
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                child: new Container(
                  alignment: Alignment.center,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
                        child: Text(
                          'SEARCH',
                          style: TextStyle(color: Colors.white),
                        )
                      ),
                    ]
                  )
                ),
                onPressed: _getListPlanner
              ),
            )
          )
        ],
      ),
    );
  }
}
