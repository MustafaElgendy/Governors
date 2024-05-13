class FormArgumentData {
  String? data;
  FormArgumentData(this.data);
}

class IntFormArgument {
  int? number;
  set setSize(int? size) {
    size = number;
  }

  int? get getSize {
    return number;
  }
}
