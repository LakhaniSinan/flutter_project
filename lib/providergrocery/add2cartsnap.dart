
import 'package:flutter_bloc/flutter_bloc.dart';

class AddtoCartB{
  bool status;
  int prodId;

  AddtoCartB({this.status, this.prodId});
}

class A2CartSnap extends Cubit<AddtoCartB>{
  A2CartSnap(AddtoCartB initialState) : super(initialState);

  void hitSnap(int prodI, bool status){
    emit(AddtoCartB(status: status,prodId: prodI));
  }

}