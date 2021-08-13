
class TopAndBottomTitleCount{
  int navigation;
  String apptitle;
  String searchTitle;

  TopAndBottomTitleCount({this.navigation, this.apptitle, this.searchTitle});

  @override
  String toString() {
    return '{navigation: $navigation, apptitle: $apptitle, searchTitle: $searchTitle}';
  }
}