import 'dart:async';
import 'dart:convert';

void main(List<String> args) {
  List<Map<String, dynamic>> _remote = [
    {"127.0.0.1": 123},
    {"128.0.0.1": 456},
  ];
  var keys = _remote.map((e) => e.keys.first);
}
