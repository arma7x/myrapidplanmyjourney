import 'package:flutter/material.dart';

class RouteDetail extends StatefulWidget {

  final List<dynamic> instructions;
  final Map<String, dynamic> cost;

  RouteDetail(this.instructions, this.cost);

  @override
  _RouteDetailState createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {

  _RouteDetailState();

  Widget _renderPrice(Widget name, Widget price, Color bg_color) {
    return new Container(
      color: bg_color,
      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      width: (MediaQuery.of(context).size.width) / 2,
      height: (MediaQuery.of(context).size.width - 20) * 0.20,
      child: new Row(
        children: <Widget>[name, price]
      )
    );
  }

  List<Widget> _renderFarePrices() {
    List<Widget> prices = [];
    List<Widget> prices_row = [];
    prices_row.add(_renderPrice(
      new Icon(Icons.local_atm, color: Colors.white, size: 38),
      Text(
        ' FARE PRICES',
        style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))
      ),
      Theme.of(context).primaryColor
    ));
    widget.cost.forEach((k, v) {
      Color bg_color = Theme.of(context).primaryColor;
      switch (k) {
        case 'cash':
          bg_color = Colors.grey;
          break;
        case 'cashless':
          bg_color = Colors.red;
          break;
        case 'concession':
          bg_color = Colors.purple;
          break;
        case 'monthly':
          bg_color = Colors.green;
          break;
        case 'weekly':
          bg_color = Colors.teal;
          break;
      }
      prices_row.add(_renderPrice(
        Text(
          k.toUpperCase() + ': ',
          style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
        ),
        Text(
          "RM" + v.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
        ),
        bg_color
      ));
      if (prices_row.length == 2) {
        prices.add(new Row(children: <Widget>[...prices_row]));
        prices_row = [];
      }
    });
    return prices;
  }

  Widget _renderDetail() {
    List<Widget> details = [];
    details.add(new Center(
      child: new Text(
        'Transport Detail',
        style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))
      )
    ));
    details.add(new SizedBox(height: 10));
    for (var i in widget.instructions) {
      details.add(new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            width: double.infinity,
            child: new Text(
              i['text'],
              style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
            ),
          ),
          new Container(
            width: double.infinity,
            child: new Text(
              i['distance'],
              style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
            )
          ),
          new Container(
            width: double.infinity,
            child: new Text(
              i['duration'],
              style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
            )
          ),
        ]
      ));
    }
    return new Container(
      color: Colors.red,
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      width: (MediaQuery.of(context).size.width),
      child: new Column(
        children: <Widget>[...details],
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("Route"),
          elevation: 0.0,
        ),
        body: new Container(
          child: new ListView(
            children: <Widget>[
              ..._renderFarePrices(),
              _renderDetail(),
            ]
          )
        )
    );
  }
}
