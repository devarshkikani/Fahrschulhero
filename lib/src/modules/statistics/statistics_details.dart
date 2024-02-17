import 'package:collection/collection.dart';
import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatisticsDetails extends StatefulWidget {
  StatisticsDetails({Key? key}) : super(key: key);

  @override
  State<StatisticsDetails> createState() => _StatisticsDetailsState();
}

class _StatisticsDetailsState extends State<StatisticsDetails>
    with SingleTickerProviderStateMixin {
  TabController? timeTabController;
  RxList userRankList = [].obs;
  RxList userRankListMonth = [].obs;
  RxList<OrdinalSales> monthData = <OrdinalSales>[].obs;
  RxList<OrdinalSales> weekData = <OrdinalSales>[].obs;
  RxString currentChapter = ''.obs;
  RxDouble allChapterCorrectQuestionsPercent = 0.0.obs;
  RxInt currentChapterCorrectQuestions = 0.obs;
  RxInt currentChapterAttemptedQuestions = 0.obs;
  RxInt currentChapterQuestionsLength = 0.obs;
  DatabaseHelper databaseHelper = DatabaseHelper();
  final NetworkRepository _networkRepository = locator<NetworkRepository>();

  @override
  void initState() {
    super.initState();
    timeTabController = TabController(length: 2, vsync: this);
    getDataFromDatabase();
    if (!isInternetOn.value) {
      if (GetStorage().read('userRankHistory') != null) {
        statiscs(GetStorage().read('userRankHistory'));
      }
    } else {
      getUserRanksHistory();
    }
  }

  getDataFromDatabase() async {
    Map currentChapterMap = Get.find<HomeController>()
        .allChapters[Get.find<HomeController>().currentChapterIndex.value];
    List allQuestions = await databaseHelper.getAllQuestions();
    allChapterCorrectQuestionsPercent.value =
        allQuestions.where((p) => p['correct'] > 0).toList().length /
            allQuestions.length *
            100;
    currentChapter.value =
        '${currentChapterMap['id']} ${currentChapterMap['name']}';
    currentChapterCorrectQuestions.value = allQuestions
        .where((p) =>
            p['correct'] > 0 && currentChapterMap['id'] == p['chapterId'])
        .toList()
        .length;
    currentChapterAttemptedQuestions.value = allQuestions
        .where(
            (p) => p['times'] > 0 && currentChapterMap['id'] == p['chapterId'])
        .toList()
        .length;
    currentChapterQuestionsLength.value = allQuestions
        .where((p) => currentChapterMap['id'] == p['chapterId'])
        .toList()
        .length;
    setState(() {});
  }

  getUserRanksHistory() async {
    final ranksHistory = await _networkRepository.getUserRanksHistory(null);
    if (ranksHistory['statusCode'] == 200 && ranksHistory['data'][0] != null) {
      userRankList.value = ranksHistory['data'];
      userRankList.sort((a, b) {
        return b['startDate'].compareTo(a['startDate']);
      });
      GetStorage().write('userRankHistory', userRankList);
      statiscs(userRankList);
    }
  }

  String weekTitle(DateTime dateTime) {
    Duration date = DateTime.now().difference(dateTime);
    if ((date.inDays / 7).floor() == 0) {
      return currentLanguage['stat_thisWeek'];
    } else if ((date.inDays / 7).floor() == 1) {
      return currentLanguage['stat_weekNo1'];
    } else {
      return currentLanguage['stat_weekNo']
          .toString()
          .replaceAll('{0}', "${(date.inDays / 7).floor()}");
    }
  }

  void statiscs(List data) {
    print(data);
    for (int i = 0; i < data.length; i++) {
      DateTime date = DateFormat("yyyy-MM-dd").parse(data[i]['startDate']);
      data[i]['month'] = date.month;
      if (i < 7) {
        weekData.add((OrdinalSales(weekTitle(date), data[i]['points'])));
      }
    }
    final showdata = groupBy(data, (e) {
      Map data = e as Map;
      return data['month'];
    });
    for (int i = 0; i < showdata.keys.length; i++) {
      int totalPoints = 0;
      for (var item in showdata.values.toList()[i]) {
        totalPoints = totalPoints + int.parse('${item['points']}');
      }
      if (i < 7) {
        monthData.add(
            OrdinalSales(getMonth(showdata.keys.toList()[i]), totalPoints));
      }
    }
    weekData.value = weekData.reversed.toList();
    monthData.value = monthData.reversed.toList();
    if (mounted) setState(() {});
  }

  String getMonth(int currentMonthIndex) {
    return DateFormat('MMM').format(DateTime(0, currentMonthIndex)).toString();
  }

  @override
  void dispose() {
    timeTabController!.dispose();
    Get.closeCurrentSnackbar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 48.0, right: 48.0, top: 18.0, bottom: 18),
            child: getRadialGauge(),
          ),
          Obx(
            () => Text(
              currentChapter.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: tabBarText,
                fontSize: 28,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 14, 0, 26),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(
                  () => answerRatio(
                    centerText: '${currentChapterAttemptedQuestions.value}',
                    value: (currentChapterAttemptedQuestions.value /
                            currentChapterQuestionsLength.value) *
                        100,
                    lable: currentLanguage['stat_questionAnswered'],
                    color: appColor,
                  ),
                ),
                Obx(
                  () => answerRatio(
                    centerText: '${currentChapterCorrectQuestions.value}',
                    value: (currentChapterCorrectQuestions.value /
                            currentChapterQuestionsLength.value) *
                        100,
                    lable: currentLanguage['stat_questionCorrect'],
                    color: purpalColor,
                  ),
                ),
              ],
            ),
          ),
          analytics(),
        ],
      ),
    );
  }

  Widget answerRatio({
    required String centerText,
    required double value,
    required String lable,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          height: 120,
          width: Get.width / 3.5,
          child: SfRadialGauge(
            animationDuration: 500,
            enableLoadingAnimation: true,
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                showLabels: false,
                showTicks: false,
                startAngle: 270,
                endAngle: 270,
                axisLineStyle: AxisLineStyle(
                  color: color.withOpacity(0.20),
                  thickness: 16,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: value,
                    cornerStyle: value <= 15.0
                        ? CornerStyle.bothFlat
                        : value == 100.0
                            ? CornerStyle.bothFlat
                            : CornerStyle.bothCurve,
                    width: 16,
                    sizeUnit: GaugeSizeUnit.logicalPixel,
                    color: color,
                  ),
                  if (value <= 15.0 && value != 100.0)
                    MarkerPointer(
                      value: value,
                      color: value == 0.0 ? Colors.transparent : color,
                      offsetUnit: GaugeSizeUnit.factor,
                      markerType: MarkerType.circle,
                      markerHeight: 16,
                      markerWidth: 16,
                    ),
                  if (value <= 15.0 && value != 100.0)
                    MarkerPointer(
                      value: 0,
                      color: value == 0.0 ? Colors.transparent : color,
                      offsetUnit: GaugeSizeUnit.factor,
                      markerType: MarkerType.circle,
                      markerHeight: 16,
                      markerWidth: 16,
                    ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    positionFactor: 0.15,
                    widget: Text(
                      centerText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            width: 120,
            child: Text(
              lable,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget analytics() {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            child: TextAndStyle(
              title: currentLanguage['stat_bottomTitle'],
              color: whiteColor,
            ),
          ),
          Container(
            height: 45,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Obx(() => TabBar(
                  controller: timeTabController,
                  labelColor: primaryWhite,
                  unselectedLabelColor: primaryWhite,
                  labelStyle: TextStyle(
                    fontFamily: "Rubik",
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    fontSize: 12.0,
                  ),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      16.0,
                    ),
                    color: darkBlue,
                  ),
                  tabs: [
                    Tab(
                      text: currentLanguage['stat_week'],
                    ),
                    Tab(
                      text: currentLanguage['stat_month'],
                    ),
                  ],
                )),
          ),
          Expanded(
            child: TabBarView(
              controller: timeTabController,
              children: [
                Column(
                  children: [
                    Container(
                      height: 250,
                      width: Get.width,
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: weekData.isNotEmpty
                          ? charts.BarChart(
                              _createSampleData(weekData),
                              primaryMeasureAxis: charts.NumericAxisSpec(
                                renderSpec: charts.GridlineRendererSpec(
                                  labelStyle: charts.TextStyleSpec(
                                      fontSize: 12,
                                      fontFamily: 'Rubik',
                                      color: charts.MaterialPalette.white),
                                  lineStyle: charts.LineStyleSpec(
                                      color: charts.MaterialPalette.white),
                                ),
                              ),
                              domainAxis: charts.OrdinalAxisSpec(
                                renderSpec: charts.SmallTickRendererSpec(
                                  labelStyle: charts.TextStyleSpec(
                                      fontSize: 12,
                                      fontFamily: 'Rubik',
                                      color: charts.MaterialPalette.white),
                                  labelRotation: 50,
                                  lineStyle: charts.LineStyleSpec(
                                      color: charts.MaterialPalette.white),
                                ),
                              ),
                              defaultInteractions: true,
                              animate: true,
                            )
                          : Center(
                              child: TextAndStyle(
                                title: 'You have not answer any questions',
                                color: whiteColor,
                              ),
                            ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 250,
                      width: Get.width,
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: monthData.isNotEmpty
                          ? charts.BarChart(
                              _createSampleData(monthData),
                              primaryMeasureAxis: charts.NumericAxisSpec(
                                  renderSpec: charts.GridlineRendererSpec(
                                      labelStyle: charts.TextStyleSpec(
                                          fontSize: 14,
                                          fontFamily: 'Rubik',
                                          color: charts.MaterialPalette.white),
                                      lineStyle: charts.LineStyleSpec(
                                          color:
                                              charts.MaterialPalette.white))),
                              domainAxis: charts.OrdinalAxisSpec(
                                renderSpec: charts.SmallTickRendererSpec(
                                  labelStyle: charts.TextStyleSpec(
                                      fontSize: 14,
                                      fontFamily: 'Rubik',
                                      color: charts.MaterialPalette.white),
                                  lineStyle: charts.LineStyleSpec(
                                      color: charts.MaterialPalette.white),
                                ),
                              ),
                              defaultInteractions: true,
                              animate: true,
                            )
                          : Center(
                              child: TextAndStyle(
                                title: 'You have not answer any questions',
                                color: whiteColor,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<charts.Series<OrdinalSales, String>> _createSampleData(
      List<OrdinalSales> data) {
    return [
      charts.Series<OrdinalSales, String>(
        id: 'statistics',
        colorFn: (datum, index) => charts.Color(r: 255, g: 255, b: 255),
        patternColorFn: (_, __) => charts.Color(r: 255, g: 255, b: 255),
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      ),
    ];
  }

  Widget getRadialGauge() {
    return Container(
      height: 220,
      margin: EdgeInsets.only(top: 16),
      child: Obx(
        () => SfRadialGauge(
          animationDuration: 500,
          enableLoadingAnimation: true,
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 100,
              showLabels: false,
              showTicks: false,
              axisLineStyle: AxisLineStyle(
                cornerStyle: CornerStyle.bothCurve,
                color: Colors.black12,
                thickness: 16,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: allChapterCorrectQuestionsPercent.value < 1.0 &&
                          allChapterCorrectQuestionsPercent.value > 0.0
                      ? allChapterCorrectQuestionsPercent.value.ceilToDouble()
                      : allChapterCorrectQuestionsPercent.value < 100.0 &&
                              allChapterCorrectQuestionsPercent.value > 99.0
                          ? allChapterCorrectQuestionsPercent.value
                              .floorToDouble()
                          : allChapterCorrectQuestionsPercent.value,
                  cornerStyle: CornerStyle.bothCurve,
                  width: 16,
                  sizeUnit: GaugeSizeUnit.logicalPixel,
                  color: allChapterCorrectQuestionsPercent.value == 0.0
                      ? Colors.transparent
                      : appColor,
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  positionFactor: 0.1,
                  widget: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        alignment: Alignment(-0.05, -0.25),
                        child: SvgPicture.asset(
                          'assets/icons/svg_icons/style.svg',
                          width: 150,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (allChapterCorrectQuestionsPercent.value < 1.0 &&
                                        allChapterCorrectQuestionsPercent
                                                .value >
                                            0.0
                                    ? allChapterCorrectQuestionsPercent
                                        .ceil()
                                        .toString()
                                    : allChapterCorrectQuestionsPercent.value <
                                                100.0 &&
                                            allChapterCorrectQuestionsPercent
                                                    .value >
                                                99.0
                                        ? allChapterCorrectQuestionsPercent
                                            .value
                                            .floor()
                                            .toString()
                                        : allChapterCorrectQuestionsPercent
                                            .value
                                            .round()
                                            .toString()) +
                                '%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: tabBarText,
                            ),
                          ),
                          Text(
                            currentLanguage['stat_allQuestion'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Rubik",
                              letterSpacing: 0.2,
                              color: bluishgrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrdinalSales {
  final String year;
  final int sales;
  OrdinalSales(this.year, this.sales);
}
