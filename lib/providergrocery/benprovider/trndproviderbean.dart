import 'package:grocery/beanmodel/productbean/productwithvarient.dart';

class TopRecentNewDataBean{
  List<ProductDataModel> data;
  int index;

  TopRecentNewDataBean({this.data, this.index});

  @override
  String toString() {
    return 'TopRecentNewDataBean{data: $data, index: $index}';
  }
}