import 'package:ASmartApp/constant/constant.dart';
import 'package:ASmartApp/models/rqrs/fit_and_firm/faf_activity_attachment_rs.dart';
import 'package:ASmartApp/models/rqrs/fit_and_firm/faf_activity_detail_rs.dart';
import 'package:ASmartApp/models/rqrs/fit_and_firm/faf_activity_goal_rs.dart';
import 'package:ASmartApp/models/rqrs/fit_and_firm/faf_activity_sum_detail_rs.dart';
import 'package:ASmartApp/models/rqrs/fit_and_firm/faf_time_duration_rs.dart';
import 'package:ASmartApp/services/baac_rest_api_service.dart';
import 'package:ASmartApp/services/rest_api.dart';
import 'package:ASmartApp/utils/dialog_util.dart';
import 'package:ASmartApp/utils/my_style.dart';
import 'package:ASmartApp/utils/shared_pref_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitAndFirmHome extends StatefulWidget {
  @override
  _FitAndFirmHomeState createState() => _FitAndFirmHomeState();
}

class _FitAndFirmHomeState extends State<FitAndFirmHome> {
  FAFActivityTimeDurationRs _activityTimeDurationRs;
  bool _loadFafConfigSuccess = false;

  Future<Null> readFafConfig() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String imei = preferences.getString('storeDeviceIMEI');
      String pass = preferences.getString('pass');
      BaacRestApiService service = BaacRestApiService();

      var timeDurationTask = service.fafActivityTimeDurations(imei, pass);
      var activityGoalTask = service.fafActivityGoals(imei, pass);
      // var activityAttachmentTask = service.fafActivityAttachment(imei, pass);
      var activityDetailListTask = service.fafActivityDetail(imei, pass);
      var activitySumDetailTask = service.fafActivitySumDetail(imei, pass);

      await Future.delayed(Duration(milliseconds: 5000));
      await Future.wait([
        timeDurationTask,
        activityGoalTask,
        activityDetailListTask,
        activitySumDetailTask,
        // activityAttachmentTask
      ]);

      _activityTimeDurationRs = await timeDurationTask;
      FAFActivityGoalRs activityGoalRs = await activityGoalTask;
      // FAFActivityAttachmentRs fafActivityAttachmentRs = await activityAttachmentTask;
      FAFActivityDetailRs fafActivityDetailRs = await activityDetailListTask;
      FAFActivitySumDetailRs fafActivitySumDetailRs = await activitySumDetailTask;

      await SharedPrefUtil.save(SharedPrefKey.FIT_AND_FIRM_TIME_DUTATION, _activityTimeDurationRs.toJson());
      await SharedPrefUtil.save(SharedPrefKey.FIT_AND_FIRM_GOAL, activityGoalRs.toJson());
      // await SharedPrefUtil.save(SharedPrefKey.FIT_AND_FIRM_ATTACHMENT, fafActivityAttachmentRs.toJson());
      await SharedPrefUtil.save(SharedPrefKey.FIT_AND_FIRM_DETAIL, fafActivityDetailRs.toJson());
      await SharedPrefUtil.save(SharedPrefKey.FIT_AND_FIRM_SUM, fafActivitySumDetailRs.toJson());

      setState(() {
        _loadFafConfigSuccess = true;
      });
    } catch (error, stackTrace) {
      await DialogUtil.showWarningDialog(context, 'เกิดข้อผิดพลาด', 'เกิดข้อผิดพลาดในการโหลดข้อมูล');
      setState(() {
        _loadFafConfigSuccess = false;
      });
      readFafConfig();
    }
  }

  @override
  void initState() {
    super.initState();
    readFafConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fit and Firm'),
        ),
        body: _loadFafConfigSuccess
            ? RefreshIndicator(
                onRefresh: readFafConfig,
                child: ListView(
                  children: [
                    buildGreenButton(
                      Icons.save,
                      'บันทึกผลการออกกำลังกาย',
                      () {
                        Navigator.pushNamed(context, '/fit_and_frim_save_activity');
                      },
                    ),
                    buildGreenButton(
                      Icons.info,
                      'การออกกำลังกายของฉัน',
                      () {
                        print('การออกกำลังกายของฉัน');
                        Navigator.pushNamed(context, '/fit_and_firm_info');
                      },
                      buttonColorLevel: 400,
                    ),
                    buildGreenButton(
                      Icons.rule,
                      'รายละเอียดภารกิจ',
                      () {
                        Navigator.pushNamed(context, '/fit_and_firm_goal');
                      },
                    ),
                    buildGreenButton(
                      Icons.app_registration,
                      'สมัครเลย',
                      () {
                        Navigator.pushNamed(context, '/fit_and_firm_register');
                      },
                      buttonColorLevel: 400,
                    ),
                  ],
                ),
              )
            : MyStyle().showProgress());
  }

  Widget buildGreenButton(IconData iconData, String text, final GestureTapCallback tapCallback, {int buttonColorLevel}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
      child: Card(
        color: Colors.green[buttonColorLevel ?? 600],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        elevation: 4.0,
        child: ListTile(
          leading: Icon(
            iconData,
            color: Colors.green[50],
          ),
          title: Text(
            text ?? '',
            style: TextStyle(color: Colors.white),
          ),
          onTap: tapCallback,
        ),
      ),
    );
  }
}
