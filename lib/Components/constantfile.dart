import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

Container buildRating(BuildContext context, {double avrageRating = 0.0}) {
  return Container(
    padding: EdgeInsets.only(top: 1.5, bottom: 1.5, left: 4, right: 3),
    //width: 30,
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Text(
          '$avrageRating',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button.copyWith(fontSize: 10),
        ),
        SizedBox(
          width: 1,
        ),
        Icon(
          Icons.star,
          size: 10,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    ),
  );
}

Widget buildIconButton(IconData icon, BuildContext context,
    {Function onpressed, int type}) {
  return GestureDetector(
    onTap: () {
      onpressed();
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(20),
      //     border: Border.all(color: type==1?kMainColor:kRedColor, width: 0)),
      child: Icon(
        icon,
        color: type == 1 ? kMainColor : kRedColor,
        size: 16,
      ),
    ),
  );
}

class GUIDGen {
  static String generate() {
    Random random = new Random(DateTime.now().millisecondsSinceEpoch);

    final String hexDigits = "0123456789abcdef";
    final List<String> uuid = new List<String>(36);

    for (int i = 0; i < 36; i++) {
      final int hexPos = random.nextInt(16);
      uuid[i] = (hexDigits.substring(hexPos, hexPos + 1));
    }

    int pos = (int.parse(uuid[19], radix: 16) & 0x3) |
        0x8; // bits 6-7 of the clock_seq_hi_and_reserved to 01

    uuid[14] = "4"; // bits 12-15 of the time_hi_and_version field to 0010
    uuid[19] = hexDigits.substring(pos, pos + 1);

    uuid[8] = uuid[13] = uuid[18] = uuid[23] = "-";

    final StringBuffer buffer = new StringBuffer();
    buffer.writeAll(uuid);
    return buffer.toString();
  }
}


Widget buildGridShView() {
  return ListView.builder(
      itemCount: 6,
      shrinkWrap: true,
      primary: false,
      // physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius:
              BorderRadius.circular(5)),
          margin: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Shimmer(
                      duration:
                      Duration(seconds: 3),
                      color: Colors.white,
                      enabled: true,
                      direction:
                      ShimmerDirection
                          .fromLTRB(),
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Colors
                                .grey[300],
                            borderRadius:
                            BorderRadius
                                .circular(
                                10)),
                      )),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets
                      .symmetric(
                      horizontal: 5,
                      vertical: 5),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceEvenly,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                            horizontal: 10),
                        child: Shimmer(
                            duration: Duration(
                                seconds: 3),
                            color: Colors.white,
                            enabled: true,
                            direction:
                            ShimmerDirection
                                .fromLTRB(),
                            child: Container(
                              height: 15,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors
                                      .grey[
                                  300],
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      10)),
                            )),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                            horizontal: 10),
                        child: Shimmer(
                            duration: Duration(
                                seconds: 3),
                            color: Colors.white,
                            enabled: true,
                            direction:
                            ShimmerDirection
                                .fromLTRB(),
                            child: Container(
                              height: 20,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors
                                      .grey[
                                  300],
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      10)),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                            horizontal: 10),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            Shimmer(
                                duration:
                                Duration(
                                    seconds:
                                    3),
                                color: Colors
                                    .white,
                                enabled: true,
                                direction:
                                ShimmerDirection
                                    .fromLTRB(),
                                child:
                                Container(
                                  height: 20,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Colors
                                          .grey[
                                      300],
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                              5),
                                          topLeft:
                                          Radius.circular(5))),
                                )),
                            Shimmer(
                                duration:
                                Duration(
                                    seconds:
                                    3),
                                color: Colors
                                    .white,
                                enabled: true,
                                direction:
                                ShimmerDirection
                                    .fromLTRB(),
                                child:
                                Container(
                                  height: 42,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      color: Colors
                                          .grey[
                                      300],
                                      borderRadius:
                                      BorderRadius.circular(
                                          30)),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      });
}


Widget buildSingleScreenView(BuildContext context){
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 100,
          margin:
          const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.centerRight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width *
                    0.40,
                margin: const EdgeInsets.symmetric(
                    horizontal: 5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 5),
                height: 120,
                decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius:
                    BorderRadius.circular(5)),
                child: Shimmer(
                    duration: Duration(seconds: 3),
                    color: Colors.white,
                    enabled: true,
                    direction:
                    ShimmerDirection.fromLTRB(),
                    child: Container(
                      height: 120,
                      width: MediaQuery.of(context)
                          .size
                          .width *
                          0.40 -
                          10,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                          BorderRadius.circular(5)),
                    )),
              );
            },
            itemCount: 10,
          ),
        ),
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: kWhiteColor),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)),
                child: Container(
                  width: 120,
                  height: 100,
                  child: Shimmer(
                      duration: Duration(seconds: 3),
                      color: Colors.white,
                      enabled: true,
                      direction:
                      ShimmerDirection.fromLTRB(),
                      child: Container(
                        height: 100,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                            BorderRadius.only(
                                bottomLeft:
                                Radius.circular(
                                    5),
                                topLeft:
                                Radius.circular(
                                    5))),
                      )),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context)
                          .size
                          .width *
                          0.5,
                      height: 13,
                      child: Shimmer(
                          duration: Duration(seconds: 3),
                          color: Colors.white,
                          enabled: true,
                          direction:
                          ShimmerDirection.fromLTRB(),
                          child: Container(
                            height: 100,
                            width: 10,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                BorderRadius.only(
                                    bottomLeft: Radius
                                        .circular(5),
                                    topLeft: Radius
                                        .circular(
                                        5))),
                          )),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context)
                          .size
                          .width *
                          0.5,
                      height: 13,
                      child: Shimmer(
                          duration: Duration(seconds: 3),
                          color: Colors.white,
                          enabled: true,
                          direction:
                          ShimmerDirection.fromLTRB(),
                          child: Container(
                            height: 100,
                            width: 10,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                BorderRadius.only(
                                    bottomLeft: Radius
                                        .circular(5),
                                    topLeft: Radius
                                        .circular(
                                        5))),
                          )),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context)
                          .size
                          .width *
                          0.5,
                      height: 13,
                      child: Shimmer(
                          duration: Duration(seconds: 3),
                          color: Colors.white,
                          enabled: true,
                          direction:
                          ShimmerDirection.fromLTRB(),
                          child: Container(
                            height: 100,
                            width: 10,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                BorderRadius.only(
                                    bottomLeft: Radius
                                        .circular(5),
                                    topLeft: Radius
                                        .circular(
                                        5))),
                          )),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 52,
              margin: const EdgeInsets.symmetric(
                  horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: kWhiteColor),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    height: 52,
                    width: MediaQuery.of(context)
                        .size
                        .width *
                        0.3,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: MediaQuery.of(context)
                          .size
                          .width *
                          0.24,
                      height: 20,
                      child: Shimmer(
                          duration: Duration(seconds: 3),
                          color: Colors.white,
                          enabled: true,
                          direction:
                          ShimmerDirection.fromLTRB(),
                          child: Container(
                            height: MediaQuery.of(context)
                                .size
                                .width *
                                0.22,
                            width: 15,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                BorderRadius.circular(
                                    5)),
                          )),
                    ),
                  );
                },
              ),
            ),
            buildGridShView()
          ],
        ),
        SizedBox(
          height: 18,
        ),
        Container(
          margin:
          const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: kWhiteColor),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer(
                      duration: Duration(seconds: 3),
                      color: Colors.white,
                      enabled: true,
                      direction:
                      ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: 120,
                        height: 15,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                            BorderRadius.circular(
                                10)),
                      )),
                  Shimmer(
                      duration: Duration(seconds: 3),
                      color: Colors.white,
                      enabled: true,
                      direction:
                      ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: 120,
                        height: 15,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                            BorderRadius.circular(
                                10)),
                      ))
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Divider(
                thickness: 1.5,
                height: 1.5,
                color:
                kButtonBorderColor.withOpacity(0.5),
              ),
              SizedBox(
                height: 10,
              ),
              Shimmer(
                  duration: Duration(seconds: 3),
                  color: Colors.white,
                  enabled: true,
                  direction: ShimmerDirection.fromLTRB(),
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context)
                        .size
                        .width *
                        0.9,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                        BorderRadius.circular(10)),
                  ))
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin:
          const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: kWhiteColor),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer(
                      duration: Duration(seconds: 3),
                      color: Colors.white,
                      enabled: true,
                      direction:
                      ShimmerDirection.fromLTRB(),
                      child: Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                            BorderRadius.circular(
                                10)),
                      )),
                  Shimmer(
                      duration: Duration(seconds: 3),
                      color: Colors.white,
                      enabled: true,
                      direction:
                      ShimmerDirection.fromLTRB(),
                      child: Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                            BorderRadius.circular(
                                10)),
                      ))
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Divider(
                thickness: 1.5,
                height: 1.5,
                color:
                kButtonBorderColor.withOpacity(0.5),
              ),
              SizedBox(
                height: 8,
              ),
              GridView.builder(
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: 10,
                  shrinkWrap: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
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
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(10),
                            child: Shimmer(
                                duration:
                                Duration(seconds: 3),
                                color: Colors.white,
                                enabled: true,
                                direction:
                                ShimmerDirection
                                    .fromLTRB(),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors
                                          .grey[300],
                                      borderRadius: BorderRadius.only(
                                          bottomLeft:
                                          Radius
                                              .circular(
                                              5),
                                          topLeft: Radius
                                              .circular(
                                              5))),
                                )),
                          ),
                          //   child:Image.asset('assets/icon.png'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Shimmer(
                            duration:
                            Duration(seconds: 3),
                            color: Colors.white,
                            enabled: true,
                            direction: ShimmerDirection
                                .fromLTRB(),
                            child: Container(
                              height: 10,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius:
                                  BorderRadius.only(
                                      bottomLeft: Radius
                                          .circular(
                                          5),
                                      topLeft: Radius
                                          .circular(
                                          5))),
                            ))
                      ],
                    );
                  }),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
