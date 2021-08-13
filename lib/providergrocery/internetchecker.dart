
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetCheckerEmitter extends Cubit<bool>{
  InternetCheckerEmitter() : super(true){
    hitInternetChecker();
  }

  void hitInternetChecker() {
    InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          emit(true);
          break;
        case InternetConnectionStatus.disconnected:
          emit(false);
          break;
      }
    });
  }

}