import 'package:ASmartApp/models/register_model.dart';
import 'package:ASmartApp/screens/onboarding/onboarding_screen.dart';
import 'package:ASmartApp/services/rest_api.dart';
import 'package:ASmartApp/utils/dialog_util.dart';
import 'package:ASmartApp/utils/normal_dialog.dart';
import 'package:ASmartApp/utils/utility.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentScreen extends StatefulWidget {

  final Map<String, dynamic> registerRq;

  ConsentScreen(this.registerRq);

  @override
  _ConsentScreenState createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // กดย้อนกลับ
            }),
        title: Text('ข้อตกลงและเงื่อนไข'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: Column(
              children: [
                Text(
                    "1.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
                SizedBox(height: 5),
                Text(
                    "2.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
                SizedBox(height: 5),
                Text(
                    "3.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
                SizedBox(height: 5),
                Text(
                    "4.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
                SizedBox(height: 5),
                Text(
                    "5.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
                SizedBox(height: 5),
                Text(
                    "6.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        _register();
                      },
                      child: Text(
                        "ยอมรับ",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      color: Colors.green,
                    ),
                    SizedBox(width: 10),
                    RaisedButton(
                      onPressed: () async {
                        // Navigator.pushNamed(context, '/register');

                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.clear();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnboardingScreen(),
                            ),
                            (route) => false);
                      },
                      child: Text(
                        "ปฎิเสธ",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      color: Colors.red,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register() async {
    // เช็คว่าเครื่องผู้ใช้ online หรือ offline
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      // ถ้า offline อยู่
      print('คุณยังไม่ได้เชื่อมต่ออินเตอร์เน็ต');
      // แสดง alert popup
      Utility.getInstance().showAlertDialog(context, 'ออฟไลน์', 'คุณยังไม่ได้เชื่อมต่ออินเตอร์เน็ต');
    } else {
      // ถ้า online แล้ว
      // เรียกต่อ API ลงทะเบียน
      DialogUtil.showLoadingDialog(context);
      var response = await CallAPI().postData(widget.registerRq, 'Register/');
      // print('########## response ===>>> $response ############');

      Navigator.pop(context);

      for (var json in response) {
        RegisterBaacModel model = RegisterBaacModel.fromJson(json);

        if (model.statusCode == '01') {
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

          sharedPreferences.setString('storeDeviceIMEI', widget.registerRq['IMEI']); // เก็บ EMEI
          sharedPreferences.setString('storeEmpID', widget.registerRq['EmpID']); // รหัสพนักงาน
          sharedPreferences.setString('EmpName', model.empName); // ชื่อพนักงาน
          sharedPreferences.setInt('storeStep', 1);

          Navigator.pushReplacementNamed(context, '/pincode');
        } else {
          normalDialog(context, model.statusDesc);
        }
      }

      // เช็คว่าถ้าลงทะเบียนสำเร็จจะส่งไปหน้า consent

      //#######################################################
      // if (body['code'] == '200') {
      //   //  if (true) {
      //   // ส่งไปหน้า consent
      //   // สร้างตัวแปรประเภท SharedPrefference เก็บข้อมูลในแอพ

      //   // เก็บค่าที่ต้องการลง SharedPrefference

      //   sharedPreferences.setString('storeIMEI', _imeiNumber); // เก็บ EMEI
      //   sharedPreferences.setString('storePass', 'baac'); // เก็บ Pass

      //   sharedPreferences.setString('storeMac', _macAddress); // เก็บ MacAddress

      //   sharedPreferences.setString(
      //       'storeCizID', body['data']['cizid']); // บัตรประชาชน

      //   sharedPreferences.setString('storePrename', body['data']['prename']);
      //   sharedPreferences.setString(
      //       'storeFirstname', body['data']['firstname']);
      //   sharedPreferences.setString('storeLastname', body['data']['lastname']);
      //   sharedPreferences.setString('storePosition', body['data']['position']);
      //   sharedPreferences.setString('storeAvatar', body['data']['avatar']);

      //   //#########################################################
      // } else {
      //   Utility.getInstance().showAlertDialog(
      //       context, 'มีข้อผิดพลาด', 'ข้อมูลลงทะเบียนไม่ถูกต้อง ลองใหม่');
      // }
    }
  }
}
