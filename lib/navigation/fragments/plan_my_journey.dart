import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:myrapidplanmyjourney/api.dart';

class PlanMyJourney extends StatefulWidget {
  @override
  _PlanMyJourneyState createState() => new _PlanMyJourneyState();
}

class _PlanMyJourneyState extends State<PlanMyJourney> with AutomaticKeepAliveClientMixin<PlanMyJourney> {

  Map<String, String> from = {};
  final TextEditingController _fromController = TextEditingController();
  Map<String, String> to = {};
  final TextEditingController _toController = TextEditingController();
  String time = ''; //(HH:mm:ss)
  String mode = ''; //(bus || rail || ""[mixed])
  String type = ''; //(leasttransit[Least Transfer]) || ""[Shortes Time])

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
      child: new Column(
        children: <Widget>[
          new Text("From"),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: false,
              controller: _fromController,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontStyle: FontStyle.italic),
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'search a road name or landmark'),
            ),
            suggestionsCallback: (pattern) async {
              return await _getListStreetAutocomplete(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Icon(Icons.my_location),
                title: Text(suggestion['label']),
                subtitle: Text('\$${suggestion['id']}'),
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
          new Text("To"),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: false,
              controller: _toController,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontStyle: FontStyle.italic),
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'search a road name or landmark'),
            ),
            suggestionsCallback: (pattern) async {
              return await _getListStreetAutocomplete(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Icon(Icons.my_location),
                title: Text(suggestion['label']),
                subtitle: Text('\$${suggestion['id']}'),
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
          ),
          new Text('Options'),
          new Row(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  Radio(
                    autofocus: true,
                    focusColor: Theme.of(context).primaryColor,
                    groupValue: type,
                    value: '',
                    onChanged: (String value) {
                      setState(() { type = ''; });
                    },
                  ),
                  const Text('Shortest Time')
                ]
              ),
              new Row(
                children: <Widget>[
                  Radio(
                    value: 'leasttransit',
                    focusColor: Theme.of(context).primaryColor,
                    groupValue: type,
                    onChanged: (String value) {
                      setState(() { type = 'leasttransit'; });
                    },
                  ),
                  const Text('Least Transfer')
                ]
              ),
            ],
          ),
          new Text('Modes'),
          new Row(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  Radio(
                    autofocus: true,
                    focusColor: Theme.of(context).primaryColor,
                    groupValue: mode,
                    value: '',
                    onChanged: (String value) {
                      setState(() { mode = ''; });
                    },
                  ),
                  const Text('Mixed')
                ]
              ),
              new Row(
                children: <Widget>[
                  Radio(
                    value: 'bus',
                    focusColor: Theme.of(context).primaryColor,
                    groupValue: mode,
                    onChanged: (String value) {
                      setState(() { mode = 'bus'; });
                    },
                  ),
                  const Text('Bus')
                ]
              ),
              new Row(
                children: <Widget>[
                  Radio(
                    value: 'rail',
                    focusColor: Theme.of(context).primaryColor,
                    groupValue: mode,
                    onChanged: (String value) {
                      setState(() { mode = 'rail'; });
                    },
                  ),
                  const Text('Rail')
                ]
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity, // match_parent
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  'Search',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Map<String, String> query = {};
                  if (from['lat'] != null) {
                    query['flat'] = from['lat'];
                  }
                  if (from['lng'] != null) {
                    query['flng'] = from['lng'];
                  }
                  if (to['lat'] != null) {
                    query['tlat'] = to['lat'];
                  }
                  if (to['lng'] != null) {
                    query['tlng'] = to['lng'];
                  }
                  query['time'] = time;
                  query['mode'] = mode;
                  query['type'] = type;
                  print(query);
                }
              ),
            )
          )
        ],
      ),
    );
  }
}
