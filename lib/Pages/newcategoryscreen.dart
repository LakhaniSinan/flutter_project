import 'dart:convert';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/providergrocery/benprovider/categorysearchbean.dart';
import 'package:grocery/providergrocery/categoryprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NewCategoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewCategoryScreenState();
  }
}

class NewCategoryScreenState extends State<NewCategoryScreen> {
  var http = Client();
  CategoryProvider categoryP;

  @override
  void initState() {
    categoryP = BlocProvider.of<CategoryProvider>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Container(
        color: kWhiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: BlocBuilder<CategoryProvider, CategorySearchBean>(
            builder: (context,listModel){
              if(listModel.isSearching){
                return GridView.builder(
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 10,
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: 8,
                    shrinkWrap: true,
                    primary: false,
                    // physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            height: 100,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: kWhiteColor,
                                borderRadius:
                                BorderRadius.circular(
                                    10)),
                            child:Shimmer(
                                duration: Duration(seconds: 3),
                                color: kWhiteColor,
                                enabled: true,
                                direction: ShimmerDirection.fromLTRB(),
                                child: Container(
                              height: 100,
                              color: kButtonColor,
                            )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Shimmer(
                            duration: Duration(seconds: 3),
                            color: kWhiteColor,
                            enabled: true,
                            direction: ShimmerDirection.fromLTRB(),
                            child: Container(
                              height: 10,
                              color: kButtonColor,
                            ),
                          )
                        ],
                      );
                    });
              }else{
                if(listModel!=null && listModel.data.length>0){
                  return GridView.builder(
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: listModel.data.length,
                      shrinkWrap: true,
                      primary: false,
                      // physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
                              'title': listModel.data[index].title,
                              'storeid': listModel.data[index].store_id,
                              'cat_id': listModel.data[index].cat_id,
                              'storedetail': listModel.storeFinderData,
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: [
                              Container(
                                height: 100,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    borderRadius:
                                    BorderRadius.circular(
                                        10)),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    '${listModel.data[index].image}',
                                    placeholder: (context, url) =>
                                        Align(
                                          widthFactor: 50,
                                          heightFactor: 50,
                                          alignment: Alignment.center,
                                          child: Container(
                                            padding:
                                            const EdgeInsets.all(
                                                5.0),
                                            width: 50,
                                            height: 50,
                                            child:
                                            CircularProgressIndicator(),
                                          ),
                                        ),
                                    errorWidget: (context, url,
                                        error) =>
                                        Image.asset(
                                            'assets/icon.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                // child:Image.asset('assets/icon.png'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${listModel.data[index].title}',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              )
                            ],
                          ),
                        );
                      });
                }
                else{
                  return Align(
                    alignment: Alignment.center,
                    child: Text(locale.nocatfount1),
                  );
                }
              }
            })
    );
  }
}
