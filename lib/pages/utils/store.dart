import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  // static StoreKeys storeKeys;
  static StoreKeys storeKeys = StoreKeys.token;
  final SharedPreferences _store;
  static Future<Store> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Store._internal(prefs);
  }

  Store._internal(this._store);
  getString(StoreKeys key) async {
    return _store.get(key.toString());
  }

  setString(StoreKeys key, String value) async {
    _store.setString(key.toString(), value);
  }

  getStringList(StoreKeys key) async {
    return _store.getStringList(key.toString());
  }

  setStringList(StoreKeys key, List<String> value) async {
    _store.setStringList(key.toString(), value);
  }
}

enum StoreKeys {
  token,
  city,
}
