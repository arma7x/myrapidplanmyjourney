import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:myrapidplanmyjourney/api.dart';
import 'package:myrapidplanmyjourney/navigation/fragments.dart' show FragmentUtils;

class PlanMyJourney extends StatefulWidget {
  @override
  _PlanMyJourneyState createState() => new _PlanMyJourneyState();
}

class _PlanMyJourneyState extends State<PlanMyJourney> with FragmentUtils, AutomaticKeepAliveClientMixin<PlanMyJourney> {

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
        return responseBody['data'];
      } else {
        //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
      }
    } on Exception {
      //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
    }
    return <dynamic>[];
  }

  void _getListPlanner() async {
    try {
      Map<String, String> query = {
        'flat': from['lat'] != null ? from['lat'] : '',
        'flng': from['lng'] != null ? from['lng'] : '',
        'tlat': to['lat'] != null ? to['lat'] : '',
        'tlng': to['lng'] != null ? to['lng'] : '',
        'time': time + ':00',
        'mode': mode,
        'type': type,
      };
      showloadingDialog(true, context);
      final response = await Api.ListPlanner(query);
      showloadingDialog(false, context);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print(responseBody['data']);
      } else {
        //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
      }
    } on Exception {
      //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
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
    // TODO: implement build
    return new Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          new SizedBox(height: 10.0),
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
                  style: Theme.of(context).textTheme.body2.merge(TextStyle(
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
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: Icon(Icons.my_location),
                      title: Text(suggestion['label']),
                      subtitle: Text(suggestion['id']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
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
                    _fromController.text = from['label'];
                  },
                ),
                new SizedBox(height: 10.0),
                new Text(
                  "DESTINATION",
                  style: Theme.of(context).textTheme.body2.merge(TextStyle(
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
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: Icon(Icons.my_location),
                      title: Text(suggestion['label']),
                      subtitle: Text(suggestion['id']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
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
                    _toController.text = to['label'];
                  },
                )
              ]
            )
          ),
          new SizedBox(height: 10.0),
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
                        style: Theme.of(context).textTheme.body2.merge(TextStyle(
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
                                onChanged: (String value) {
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
                                    style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
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
                                onChanged: (String value) {
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
                                    style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
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
                        style: Theme.of(context).textTheme.body2.merge(TextStyle(
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
                                onChanged: (String value) {
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
                                    style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
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
                                onChanged: (String value) {
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
                                    style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
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
                                onChanged: (String value) {
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
                                    style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
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
                        style: Theme.of(context).textTheme.body2.merge(TextStyle(
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
                          child: RaisedButton(
                            color: Colors.white,
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
                                    time,
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
          new Container(
            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: SizedBox(
              width: double.infinity, // match_parent
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
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
