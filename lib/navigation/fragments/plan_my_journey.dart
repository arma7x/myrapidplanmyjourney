import 'dart:async';
import 'dart:convert';
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
  Map<String, String> from = {};
  final TextEditingController _fromController = TextEditingController();
  Map<String, String> to = {};
  final TextEditingController _toController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  String time = TimeOfDay.now().toString().replaceAll('TimeOfDay(', '').replaceAll(')', '');
  String mode = '';
  String type = '';

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
                width: (MediaQuery.of(context).size.width) * 0.22,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('ETA'),
                    Text(i['t_arrival_time'].toString().replaceAll(' ', '')),
                  ]
                )
              ),
              new Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                width: (MediaQuery.of(context).size.width) * 0.16,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(i['t_duration_hour'].toString()),
                    Text('Hours'),
                  ]
                ),
              ),
              new Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                width: (MediaQuery.of(context).size.width) * 0.14,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(i['t_duration_min'].toString()),
                    Text('Mins'),
                  ]
                ),
              ),
              new Container(
                color: Colors.grey[100],
                padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                width: (MediaQuery.of(context).size.width) * 0.15,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(i['t_distance'].toString()),
                    Text('KM'),
                  ]
                ),
              ),
              new Container(
                color: Theme.of(context).primaryColor,
                width: (MediaQuery.of(context).size.width) * 0.33,
                child: new Material(
                  child: new InkWell(
                    onLongPress: () {
                      final snackBar = SnackBar(content: Text(i['t_route'].toString().toUpperCase()));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => new RouteDetail.fromJson(i))
                      );
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
        'flat': from['lat'] ?? '',
        'flng': from['lng'] ?? '',
        'tlat': to['lat'] ?? '',
        'tlng': to['lng'] ?? '',
        'time': time + ':00',
        'mode': mode,
        'type': type,
      };
      showloadingDialog(true, context);
      final response = await Api.ListPlanner(query);
      showloadingDialog(false, context);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['data'].length > 0) {
          if (responseBody['data'][0]['a'].length > 0) {
            setState(() { data = responseBody['data'][0]['a']; });
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext _) {
                return _renderRouteOptions(responseBody['data'][0]['a']);
              },
              backgroundColor: Colors.white,
              isScrollControlled: false
            );
            return;
          }
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
                    return await _getListStreetAutocomplete(pattern);
                  },
                  itemBuilder: (context, dynamic suggestion) {
                    return ListTile(
                      leading: Icon(Icons.my_location),
                      title: Text(suggestion['label']!),
                      subtitle: Text(suggestion['id']!),
                    );
                  },
                  onSuggestionSelected: (dynamic suggestion) {
                    Map<String, String> tempFrom = {};
                    suggestion.forEach((k, v) {
                      tempFrom[k] = v;
                      if (k == 'id') {
                        final latlong = v.split('/');
                        tempFrom['lat'] = latlong[0];
                        tempFrom['lng'] = latlong[1];
                      }
                    });
                    setState(() { from = tempFrom; });
                    _fromController.text = from['label']!;
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
                    return await _getListStreetAutocomplete(pattern);
                  },
                  itemBuilder: (context, dynamic suggestion) {
                    return ListTile(
                      leading: Icon(Icons.my_location),
                      title: Text(suggestion['label']!),
                      subtitle: Text(suggestion['id']!),
                    );
                  },
                  onSuggestionSelected: (dynamic suggestion) {
                    Map<String, String> tempTo = {};
                    suggestion.forEach((k, v) {
                      tempTo[k] = v;
                      if (k == 'id') {
                        final latlong = v.split('/');
                        tempTo['lat'] = latlong[0];
                        tempTo['lng'] = latlong[1];
                      }
                    });
                    setState(() { to = tempTo; });
                    _toController.text = to['label']!;
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
                                value: '',
                                onChanged: (String? value) {
                                  setState(() { type = ''; });
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
                                value: '',
                                onChanged: (String? value) {
                                  setState(() { mode = ''; });
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
                      new SizedBox(width: 5),
                      Text(
                        'SEARCH',
                        style: TextStyle(color: Colors.white),
                      )
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
