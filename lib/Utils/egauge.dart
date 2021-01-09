import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peta_app/Models/measurement.dart';
import 'package:xml2json/xml2json.dart';

class Egauge {
  String domain;

  Egauge({this.domain});

  getMeasurementByDateRange(DateTime fromDate, DateTime toDate) async {
    var fromDateinMillis = (fromDate.millisecondsSinceEpoch / 1000).floor();
    var toDateinMillis = (toDate.millisecondsSinceEpoch / 1000).floor();
    var actualUrl =
        'https://$domain.egaug.es/cgi-bin/egauge-show?a&E&T=$fromDateinMillis,$toDateinMillis';

    var response = await http.get(actualUrl);

    final myTransformer = Xml2Json();

    myTransformer.parse(response.body);

    var jsonData = myTransformer.toGData();
    var fromReg = (json.decode(jsonData)['group']['data'][0] != null
        ? json.decode(jsonData)['group']['data'][0]['r']['c']
        : json.decode(jsonData)['group']['data']['r'][0]['c']) as List;
    var toReg = (json.decode(jsonData)['group']['data'][1] != null
        ? json.decode(jsonData)['group']['data'][1]['r']['c']
        : json.decode(jsonData)['group']['data']['r'][1]['c']) as List;

    var from = {
      'use': int.parse(fromReg[0]['\$t']) / 3600000,
      'gen': int.parse(fromReg[1]['\$t']) / 3600000
    };
    var to = {
      'use': int.parse(toReg[0]['\$t']) / 3600000,
      'gen': int.parse(toReg[1]['\$t']) / 3600000
    };

    final used = to['use'] - from['use'];
    final gen = to['gen'] - from['gen'];

    return Measurement(consumption: used, generation: gen);
  }

  Future<Measurement> getCurrentMeasurement() async {
    var url = 'https://$domain.egaug.es/cgi-bin/egauge?v1&inst';
    var response = await http.get(url);
    final myTransformer = Xml2Json();

    myTransformer.parse(response.body);

    var attributes = json.decode(myTransformer.toGData())['data']['r'] as List;
    var used = double.parse(
        attributes.firstWhere((element) => element['did'] == '0')['i']['\$t']);
    var generated = double.parse(
        attributes.firstWhere((element) => element['did'] == '2')['i']['\$t']);

    used = generated - used;

    return Measurement(consumption: used.abs(), generation: generated.abs());
  }
}
