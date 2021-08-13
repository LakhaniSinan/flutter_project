import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/providergrocery/benprovider/trndproviderbean.dart';

class TopRecentNewDealProvider extends Cubit<TopRecentNewDataBean>{
  TopRecentNewDealProvider() : super(TopRecentNewDataBean(data: null,index: 0));

  void hitTopRecentNewDealPro(List<ProductDataModel> pData, int index) async{
    emit(TopRecentNewDataBean(data: pData,index: index));
  }

}