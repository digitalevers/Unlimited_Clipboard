// import 'dart:async';
// import 'dart:convert';



import 'dart:async';

void main(List<String> args) {
  // List<Map<String, dynamic>> _remote = [
  //   {"127.0.0.1": 123},
  //   {"128.0.0.1": 456},
  // ];
  // var keys = _remote.map((e) => e.keys.first);
  Duration timeout = const Duration(seconds: 3);
  Timer timer = Timer.periodic(timeout, (_) {
    print("timer");
  });

  Duration timeout2 = const Duration(seconds: 1);
  Timer timer2 = Timer.periodic(timeout2, (_) {
    //timer.cancel();
  });
  
}
