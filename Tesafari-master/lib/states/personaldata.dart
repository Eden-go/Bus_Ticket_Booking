import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localstorage/localstorage.dart';

class Person {
  String name;
  String phoneNum;

  Person({required this.name, required this.phoneNum});
  toJsonEncodable() {
    Map<String, dynamic> m = Map();
    m['name'] = name;
    m["phoneNum"] = phoneNum;

    return m;
  }
}

class PersonalData with ChangeNotifier {
  String? _name;
  List<Person> _people = [];
  String? _number;
  String? _email;
  String? _deviceId;
  Directory? dir;
  LocalStorage? storage;
  Mutex mutex = Mutex();

  PersonalData() {
    storage = new LocalStorage("persons");

    readLocalStorage();
    _getPref();
  }

  String? get getName => _name;
  String? get getNumber => _number;
  String? get getEmail => _email;
  String? get getDeviceId => _deviceId;
  List<Person> get getPeople => _people;

  void readLocalStorage() async {
    bool isReady = await storage!.ready;

    if (isReady) {
      var persons = storage?.getItem('person');
      if (persons != null) {
        _people = List<Person>.from(
          (persons as List).map(
            (person) => Person(
              name: person['name'],
              phoneNum: person['phoneNum'],
            ),
          ),
        );
      }

      notifyListeners();
    }
  }

  Future<String> setDeviceId(String value) async {
    final pref = await SharedPreferences.getInstance();
    value = value.split(' ')[0];

    if (_deviceId == null || _deviceId!.length == 0) {
      final sha512Algorithm = Sha512();
      List<int> secret = [];
      Hash hashedValue;

      for (int i = 0; i < value.length; i++)
        if (value[i] != '-' &&
            value != ' ' &&
            value[i] != ':' &&
            value[i] != '.') {
          if (value[i].contains(RegExp(r'[a-zA-z]')))
            secret.add(_getAlphabetIndex(value));
          else
            secret.add(int.parse(value[i]));
        }

      hashedValue = await sha512Algorithm.hash(secret);
      _deviceId = hashedValue.toString();
      pref.setString("deviceid", _deviceId!);
      notifyListeners();

      return Future.value(_deviceId);
    }

    return Future.value('');
  }

  int _getAlphabetIndex(String value) {
    switch (value) {
      case 'A':
      case 'a':
        return 1;
      case 'B':
      case 'b':
        return 2;
      case 'C':
      case 'c':
        return 3;
      case 'D':
      case 'd':
        return 4;
      case 'E':
      case 'e':
        return 5;
      case 'F':
      case 'f':
        return 6;
      case 'G':
      case 'g':
        return 7;
      case 'H':
      case 'h':
        return 8;
      case 'I':
      case 'i':
        return 9;
      case 'J':
      case 'j':
        return 10;
      case 'K':
      case 'k':
        return 11;
      case 'L':
      case 'l':
        return 12;
      case 'M':
      case 'm':
        return 13;
      case 'N':
      case 'n':
        return 14;
      case 'O':
      case 'o':
        return 15;
      case 'P':
      case 'p':
        return 16;
      case 'Q':
      case 'q':
        return 17;
      case 'R':
      case 'r':
        return 18;
      case 'S':
      case 's':
        return 19;
      case 'T':
      case 't':
        return 20;
      case 'U':
      case 'u':
        return 21;
      case 'V':
      case 'v':
        return 22;
      case 'W':
      case 'w':
        return 23;
      case 'X':
      case 'x':
        return 24;
      case 'Y':
      case 'y':
        return 25;
      case 'Z':
      case 'z':
        return 26;
      default:
        return -1;
    }
  }

  _getPref() async {
    final pref = await SharedPreferences.getInstance();

    _name = pref.getString("name") ?? "";
    _number = pref.getString("number") ?? "";
    _email = pref.getString("email") ?? "";
    _deviceId = pref.getString("deviceid") ?? "";

    notifyListeners();
  }

  Future<bool> setPref(String name, String number) async {
    String numberVerifier = r"^(0|\+251)([0-9]{9})$";
    final pref = await SharedPreferences.getInstance();

    if (number.contains(RegExp(numberVerifier)) && name.length > 0) {
      pref.setString("name", name);
      pref.setString("number", number);

      this._name = name;
      this._number = number;

      notifyListeners();
      return Future.value(true);
    }

    if (name.isEmpty && number.isEmpty) {
      pref.setString("name", name);
      pref.setString("number", number);

      this._name = name;
      this._number = number;

      notifyListeners();
      return Future.value(true);
    }

    return Future.value(false);
  }

  deletePerson(Person person) {
    _people.remove(person);
    _saveToStorage();

    notifyListeners();
  }

  _addPerson(String name, phoneNum) {
    final person = new Person(name: name, phoneNum: phoneNum);

    _people.add(person);
    _saveToStorage();

    notifyListeners();
  }

  void _saveToStorage() async {
    await mutex.protect(
        () async => await storage!.setItem('person', _toJsonEncodable()));

    notifyListeners();
  }

  _toJsonEncodable() {
    return _people.map((person) {
      return person.toJsonEncodable();
    }).toList();
  }

  bool save(String name, phoneNum) {
    String numberVerifier = r"^(0|\+251)([0-9]{9})$";
    if (phoneNum.contains(RegExp(numberVerifier)) && name.compareTo('') != 0) {
      _addPerson(name, phoneNum);
      return true;
    }

    notifyListeners();
    return false;
  }

  bool checkInfoExists() {
    return (_number != null && _name != null && _name != "" && _number != "")
        ? true
        : false;
  }
}
