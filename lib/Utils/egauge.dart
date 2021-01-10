import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peta_app/Models/measurement.dart';
import 'package:xml2json/xml2json.dart';

class Egauge {
  String domain;

  Egauge({this.domain});

  getMeasurementByDateRange(DateTime fromDate, DateTime toDate) async {
    final fromDateinMillis = (fromDate.millisecondsSinceEpoch / 1000).floor();
    final toDateinMillis = (toDate.millisecondsSinceEpoch / 1000).floor();
    final actualUrl =
        'https://$domain.egaug.es/cgi-bin/egauge-show?a&E&T=$fromDateinMillis,$toDateinMillis';

    final response = await http.get(actualUrl);

    final myTransformer = Xml2Json();

    myTransformer.parse(response.body);

    final jsonData = myTransformer.toGData();
    final fromReg = (json.decode(jsonData)['group']['data'][0] != null
        ? json.decode(jsonData)['group']['data'][0]['r']['c']
        : json.decode(jsonData)['group']['data']['r'][0]['c']) as List;
    final toReg = (json.decode(jsonData)['group']['data'][1] != null
        ? json.decode(jsonData)['group']['data'][1]['r']['c']
        : json.decode(jsonData)['group']['data']['r'][1]['c']) as List;

    final from = {
      'use': int.parse(fromReg[0]['\$t']) / 3600000,
      'gen': int.parse(fromReg[1]['\$t']) / 3600000
    };
    final to = {
      'use': int.parse(toReg[0]['\$t']) / 3600000,
      'gen': int.parse(toReg[1]['\$t']) / 3600000
    };

    final used = to['use'] - from['use'];
    final gen = to['gen'] - from['gen'];

    return Measurement(consumption: used, generation: gen);
  }

  Future<Measurement> getCurrentMeasurement() async {
    final url = 'https://$domain.egaug.es/cgi-bin/egauge?v1&inst';
    final response = await http.get(url);
    final myTransformer = Xml2Json();

    myTransformer.parse(response.body);

    final attributes = json.decode(myTransformer.toGData())['data']['r'] as List;
    var used = double.parse(
        attributes.firstWhere((element) => element['did'] == '0')['i']['\$t']);
    final generated = double.parse(
        attributes.firstWhere((element) => element['did'] == '2')['i']['\$t']);

    used = generated - used;

    return Measurement(consumption: used.abs(), generation: generated.abs());
  }
}
