import 'package:blue/common/style.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyVerifyDialog extends StatefulWidget {
  const CompanyVerifyDialog({ Key? key }) : super(key: key);

  @override
  State<CompanyVerifyDialog> createState() => _CompanyVerifyDialogState();
}

class _CompanyVerifyDialogState extends State<CompanyVerifyDialog> {
  final HomeController homeCon = Get.put(HomeController());
  final ToastMessageController toastCon = Get.put(ToastMessageController());
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        title: const Text('企業コード登録'),
        titleTextStyle: const TextStyle(fontSize: 14.0,color: black,fontWeight: FontWeight.bold),
        alignment: Alignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Obx(
                ()=>TextFormField(
                  controller: homeCon.companyCodeTextController.value,
                  readOnly: false,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    label: const Text('企業コード'),
                    fillColor: white,
                    suffixIcon: IconButton(
                      onPressed: () {
                        homeCon.companyCodeTextController.value.clear();
                        setState(() {
                          homeCon.companyVerified.value=false;
                          homeCon.siteList.clear();
                          homeCon.resetSiteSelectionDD();
                          homeCon.initDropDownValue = homeCon.siteList[0];   
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: primaryColor)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: primaryColor)
                    ),
                    filled: true,
                    hintText: '企業コード',
                    hintStyle: const TextStyle(color: grey),
                    contentPadding: const EdgeInsets.only(
                      bottom: 10.0, 
                      left: 16.0, 
                      right: 0.0
                    ),
                  ),
                  onChanged: (text) async {
                    homeCon.companyVerified.value=false;
                    homeCon.siteList.clear();
                    homeCon.resetSiteSelectionDD();
                    homeCon.initDropDownValue = homeCon.siteList[0];
                  },
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Flexible(
              child: Obx(
                ()=>TextFormField(
                  controller: homeCon.companyPassCodeTextController.value,
                  readOnly: false,
                  textAlign: TextAlign.start,
                  obscureText: true,
                  decoration: InputDecoration(
                    label: const Text('パスコード'),
                    fillColor: white,
                    suffixIcon: IconButton(
                      onPressed: () {
                        homeCon.companyPassCodeTextController.value.clear();
                        setState(() {
                          homeCon.companyVerified.value=false;
                          homeCon.siteList.clear();
                          homeCon.resetSiteSelectionDD();
                          homeCon.initDropDownValue = homeCon.siteList[0];   
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: primaryColor)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: primaryColor)
                    ),
                    filled: true,
                    hintText: 'パスコード',
                    hintStyle: const TextStyle(color: grey),
                    contentPadding: const EdgeInsets.only(
                      bottom: 10.0, 
                      left: 16.0, 
                      right: 0.0
                    ),
                  ),
                  onChanged: (text) async {
                    homeCon.companyVerified.value=false;
                    homeCon.siteList.clear();
                    homeCon.resetSiteSelectionDD();
                    homeCon.initDropDownValue = homeCon.siteList[0];  
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('companyPassCode',text).toString();
                  },
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              // homeCon.companyPassCodeTextController.value.clear();
              Navigator.of(context).pop();
            },
            child: const Text('キャンセル'),
          ),
          OutlinedButton(
            onPressed: () async{
              if(homeCon.companyCodeTextController.value.text.toString().trim()!="" && homeCon.companyPassCodeTextController.value.text.toString().trim()!=""&& homeCon.companyVerified.value==false){
                setState(() {
                  homeCon.companyVerifying.value=true;
                });
                //to do verify company code
                homeCon.checkCompanyAndValidate(
                  homeCon.companyCodeTextController.value.text.toString().trim(),
                  homeCon.companyPassCodeTextController.value.text.toString().trim(),
                  context,
                  'fromCompanyVerfyDialog'
                );
              }
              else{
                if(homeCon.companyVerified.value==true){
                  toastCon.showCompanyAlreadyVerifiedMsg();
                }
                else if(homeCon.companyCodeTextController.value.text.toString().trim()==""){
                  toastCon.showRequireCompanyCodeMsg();
                }
                else if(homeCon.companyPassCodeTextController.value.text.toString().trim()==""){
                  toastCon.showRequirePassCodeEmptyMsg();
                }
              }
              FocusScope.of(context).unfocus();
            },
            child: GetBuilder<HomeController>(
              init: HomeController(),
              builder: (_){
                return homeCon.companyVerifying.value
                ?const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth :2.0)
                )
                :homeCon.companyVerifying.value == false && homeCon.companyVerified.value == true
                ?const Icon(Icons.check,color: green)
                :const Text('セット');
              }
            )
          ),
        ],
      ),
    );
  }
}