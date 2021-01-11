class ValidationMixins {

  String validateNumberField(String value) {

    if(value.isEmpty){
      return 'Este campo no puede estar vacio';
    } else if (!isNumeric(value)){
      return 'Este campo debe de ser numerico';
    } else if(double.parse(value) <= 0) {
      return 'Este campo debe de tener solo numero positivos';
    }

    return null;
  }

  String validateStringField(String value) {
    if(value.isEmpty)
      return 'Este campo no puede estar vacio';

    return null;
  }

  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}