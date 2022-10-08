import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:bsru_horpak/models/product_model.dart';
import 'package:bsru_horpak/models/sqlite_model.dart';
import 'package:bsru_horpak/models/user_model.dart';
import 'package:bsru_horpak/utility/my_constant.dart';
import 'package:bsru_horpak/utility/sqlite_heiper.dart';
import 'package:bsru_horpak/widgets/show_image.dart';
import 'package:bsru_horpak/widgets/show_progress.dart';
import 'package:bsru_horpak/widgets/show_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dio/dio.dart';

class ShowReserve extends StatefulWidget {
  const ShowReserve({Key? key}) : super(key: key);

  @override
  State<ShowReserve> createState() => _ShowReserveState();
}

class _ShowReserveState extends State<ShowReserve> {
  List<SQLiteModel> sqliteModels = [];
  bool load = true;
  UserModel? userModel;
  ProductModel? productModel;
  int? total;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    processReadSQLite();
    findDeraiIdOwner();
  }

  Future<Null> processReadSQLite() async {
    if (sqliteModels.isEmpty) {
      sqliteModels.clear();
    }
    await SQLiteHelper().readSQLite().then((value) {
      setState(() {
        load = false;
        sqliteModels = value;
        findDeraiIdOwner();
        // calculateTotal();
      });
    });
  }

  // void calculateTotal() async {
  //   for (var item in sqliteModels)
  //   int sumInt = int.parse(item.){

  //   }
  // }

  Future<void> findDeraiIdOwner() async {
    String idOwner = sqliteModels[0].idOwner;
    print('### idOwner ===> $idOwner');
    String apiGetUserWhereId =
        '${MyConstant.domain}/bsruhorpak/getProductWhereIdOwner.php?isAdd=true&idOwner=$idOwner';
    await Dio().get(apiGetUserWhereId).then((value) {
      for (var item in jsonDecode(value.data)) {
        setState(() {
          productModel = ProductModel.fromMap(item);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reserve'),
      ),
      body: load
          ? ShowProgress()
          : sqliteModels.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      child: ShowImage(
                        path: MyConstant.logo,
                      ),
                    ),
                    Center(
                      child: ShowTitle(
                        title: 'ยังไม่ได้จองหอพัก',
                        textStyle: MyConstant().h1Style(),
                      ),
                    ),
                  ],
                )
              : buildContent(),
    );
  }

  Column buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showHorpak(),
        buildHead(),
        listHorpak(),
        buildDivider(),
        buttonController(),
        Row(
          children: [
            Expanded(child: SizedBox()),
          ],
        )
      ],
    );
  }

  Future<void> confirmEmptyCart() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: ListTile(
                leading: ShowImage(path: MyConstant.logo),
                title: ShowTitle(
                  title: 'คุณต้องการจะ ลบ ',
                  textStyle: MyConstant().h1Style(),
                ),
                subtitle: ShowTitle(
                  title: 'หอพักทั้งหมด ?',
                  textStyle: MyConstant().h3Style(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await SQLiteHelper().emptySQLite().then((value) {
                      Navigator.pop(context);
                      processReadSQLite();
                    });
                  },
                  child: Text('ลบ'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ยกเลิก'),
                ),
              ],
            ));
  }

  Row buttonController() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Text('จอง'),
        ),
        Container(
          margin: EdgeInsets.only(left: 4, right: 8),
          child: ElevatedButton(
            onPressed: () => confirmEmptyCart(),
            child: Text('ลบทั้งหมด'),
          ),
        ),
      ],
    );
  }

  Divider buildDivider() {
    return Divider(
      color: MyConstant.dark,
    );
  }

  ListView listHorpak() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: sqliteModels.length,
      itemBuilder: (context, index) => Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ShowTitle(
                title: sqliteModels[index].name,
                textStyle: MyConstant().h3Style(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ShowTitle(
              title: sqliteModels[index].price,
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: ShowTitle(
              title: sqliteModels[index].phone,
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () async {
                int idSQLite = sqliteModels[index].id!;
                print('### You delete==> $idSQLite');
                await SQLiteHelper()
                    .deleteSQLiteWhereId(idSQLite)
                    .then((value) => processReadSQLite());
              },
              icon: Icon(
                Icons.delete_forever_outlined,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildHead() {
    return Container(
      decoration: BoxDecoration(color: Color.fromARGB(255, 111, 177, 232)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ShowTitle(
                  title: 'ชื่อหอพัก',
                  textStyle: MyConstant().h2Style(),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ShowTitle(
                title: 'ราคา',
                textStyle: MyConstant().h2Style(),
              ),
            ),
            Expanded(
              flex: 1,
              child: ShowTitle(
                title: 'เบอร์',
                textStyle: MyConstant().h2Style(),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Padding showHorpak() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ShowTitle(
        title: productModel == null ? '' : 'หอพักที่จอง',
        textStyle: MyConstant().h1Style(),
      ),
    );
  }
}
