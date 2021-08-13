
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/providergrocery/benprovider/toporbottombean.dart';

class BottomNavigationEmitter extends Cubit<TopAndBottomTitleCount>{
  BottomNavigationEmitter() : super(TopAndBottomTitleCount(navigation: 0,apptitle: '',searchTitle: ''));

  void hitBottomNavigation(int navigation, String appTitle, String searchTitle){
    emit(TopAndBottomTitleCount(navigation: navigation,apptitle: appTitle,searchTitle: searchTitle));
  }

}