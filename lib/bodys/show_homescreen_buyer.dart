import 'dart:convert';
import 'dart:ui';

import 'package:bsru_horpak/models/product_model.dart';
import 'package:bsru_horpak/models/sqlite_model.dart';
import 'package:bsru_horpak/models/user_model.dart';
import 'package:bsru_horpak/utility/my_constant.dart';
import 'package:bsru_horpak/utility/sqlite_heiper.dart';
import 'package:bsru_horpak/widgets/show_image.dart';
import 'package:bsru_horpak/widgets/show_progress.dart';
import 'package:bsru_horpak/widgets/show_signuot.dart';
import 'package:bsru_horpak/widgets/show_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //ตัวแปร
  bool load = true;
  bool? haveData;
  final formKey = GlobalKey<FormState>();

  List<UserModel> userModels = [];
  List<ProductModel> productModels = [];
  List<List<String>> lisImages = [];
  int indexImage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    if (productModels.length != 0) {
      productModels.clear();
    } else {}

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id')!;
    String apiGetProductWhereIdProduct =
        '${MyConstant.domain}/bsruhorpak/getProductWhereTypeOwner.php';
    await Dio().get(apiGetProductWhereIdProduct).then(
      (value) {
        // print('### หอทั้งหมด ==> $value');

        if (value.toString() == 'null') {
          // No Data

          setState(() {
            load = false;
            haveData = false;
          });
        } else {
          // Have Data
          for (var item in jsonDecode(value.data)) {
            ProductModel model = ProductModel.fromMap(item);
            String string = model.images;
            string = string.substring(1, string.length - 1);
            List<String> strings = string.split(',');
            int i = 0;
            for (var item in strings) {
              strings[i] = item.trim();
              i++;
            }
            lisImages.add(strings);

            setState(() {
              load = false;
              haveData = true;
              productModels.add(model);
            });
          }
        }
      },
    );
  }

  // Future<Null> userloadValueFromAPI() async {
  //   if (userModels.length != 0) {
  //     userModels.clear();
  //   } else {}

  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String id = preferences.getString('id')!;
  //   String apiGetProductWhereIdProduct =
  //       '${MyConstant.domain}/bsruhorpak/getUserWhereUser.php?isAdd=true&user=$id';
  //   await Dio().get(apiGetProductWhereIdProduct).then(
  //     (value) {
  //       print('### หอทั้งหมด ==> $value');

  //       if (value.toString() == 'null') {
  //         // No Data

  //         setState(() {
  //           load = false;
  //           haveData = false;
  //         });
  //       } else {
  //         // Have Data
  //         for (var item in jsonDecode(value.data)) {
  //           UserModel model = UserModel.fromMap(item);
  //           // String string = model.images;
  //           // string = string.substring(1, string.length - 1);
  //           // List<String> strings = string.split(',');
  //           int i = 0;
  //           // for (var item in strings) {
  //           //   strings[i] = item.trim();
  //           //   i++;
  //           // }
  //           // lisImages.add(strings);

  //           setState(() {
  //             load = false;
  //             haveData = true;
  //             userModels.add(model);
  //           });
  //         }
  //       }
  //     },
  //   );
  // }

  // Future<Null> readApiHorpak2() async {
  //   String urlAPI =
  //       '${MyConstant.domain}/bsruhorpak/getProductWhereTypeOwner.php';
  //   await Dio().get(urlAPI).then((value) {
  //     setState(() {
  //       load = false;
  //     });
  //     print('ค่า $value');
  //     var result = jsonDecode(value.data);
  //     // print(' =$result');
  //     for (var item in result) {
  //       // print('item == $item');
  //       ProductModel model = ProductModel.fromMap(item);
  //       // print('name ${model.name}');
  //       setState(() {
  //         productModels.add(model);
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.clear().then(
                    (value) => Navigator.pushNamedAndRemoveUntil(
                        context, MyConstant.routAuthen, (route) => false),
                  );
            },
          ),
        ],
        title: Text('หอพักทั้งหมด'),
      ),
      body: load
          ? ShowProgress()
          : haveData!
              ? GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(
                    FocusNode(),
                  ),
                  child: Form(
                    key: formKey,
                    child: Stack(
                      children: [
                        buildSearch(size),
                        Padding(
                          padding: const EdgeInsets.only(top: 75),
                          child: LayoutBuilder(
                            builder: (context, constraints) =>
                                buildListView(constraints),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShowTitle(
                          title: 'ไม่มีข้อมูลหอพักในขณะนี้',
                          textStyle: MyConstant().h1Style()),
                    ],
                  ),
                ),
    );
  }

  Row buildSearch(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: Colors.white,
          width: size * 0.90,
          height: size * 0.5,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 0),
            child: TextFormField(
              decoration: InputDecoration(
                labelStyle: TextStyle(color: MyConstant.primary),
                labelText: 'ค้นหา :',
                prefixIcon: Icon(Icons.search, color: MyConstant.primary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: MyConstant.primary,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String createUrl(String string) {
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url = '${MyConstant.domain}/bsruhorpak${strings[0]}';
    return url;
  }

  ListView buildListView(BoxConstraints constraints) {
    return ListView.builder(
      itemCount: productModels.length,
      itemBuilder: (context, index) => SingleChildScrollView(
        child: GestureDetector(
          onTap: () => {
            print('คลิก ${productModels[index].id}'),
            showAlerlDialog(
              productModels[index],
              lisImages[index],
            ),
          },
          child: Card(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  width: constraints.maxWidth * 0.5 - 4,
                  height: constraints.maxWidth * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: constraints.maxWidth * 0.4,
                        height: constraints.maxWidth * 0.4,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: createUrl(productModels[index].images),
                          placeholder: (context, url) => ShowProgress(),
                          errorWidget: (context, url, error) =>
                              ShowImage(path: MyConstant.logo),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: constraints.maxWidth * 0.5 - 4,
                  height: constraints.maxWidth * 0.5 - 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShowTitle(
                              title: 'ชื่อ: ${productModels[index].name}',
                              textStyle: MyConstant().h3Style()),
                        ],
                      ),
                      ShowTitle(
                          title: 'ราคา: ${productModels[index].price} บาท',
                          textStyle: MyConstant().h3Style()),
                      ShowTitle(
                          title: 'รายละเอียด:',
                          textStyle: MyConstant().h3Style()),
                      ShowTitle(
                          title: cutWrod('  ${productModels[index].detail}'),
                          textStyle: MyConstant().h3Style()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> showAlerlDialog(
      ProductModel productModels, List<String> images) async {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: ListTile(
                  leading: ShowImage(path: MyConstant.logo),
                  title: ShowTitle(
                    title: productModels.name,
                    textStyle: MyConstant().h2Style(),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            '${MyConstant.domain}/bsruhorpak${images[indexImage]}',
                        placeholder: (context, url) => ShowProgress(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  indexImage = 0;
                                  print('### indexImage = $indexImage');
                                });
                              },
                              icon: Icon(Icons.filter_1),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  indexImage = 1;
                                  print('### indexImage = $indexImage');
                                });
                              },
                              icon: Icon(Icons.filter_2),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  indexImage = 2;
                                  print('### indexImage = $indexImage');
                                });
                              },
                              icon: Icon(Icons.filter_3),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  indexImage = 3;
                                  print('### indexImage = $indexImage');
                                });
                              },
                              icon: Icon(Icons.filter_4),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ShowTitle(
                              title: 'ราคา :${productModels.price} บาท',
                              textStyle: MyConstant().h3Style()),
                        ],
                      ),
                      Row(
                        children: [
                          ShowTitle(
                              title: 'ที่อยูุ่ :${productModels.address} ',
                              textStyle: MyConstant().h3Style()),
                        ],
                      ),
                      Row(
                        children: [
                          ShowTitle(
                              title: 'รายละเอียด :',
                              textStyle: MyConstant().h3Style()),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                                width: 200,
                                child: ShowTitle(
                                    title: productModels.detail,
                                    textStyle: MyConstant().h3Style())),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ShowTitle(
                              title: 'เบอร์โทรศัพท์ : ${productModels.phone}',
                              textStyle: MyConstant().h3Style()),
                        ],
                      ),
                      Row(
                        children: [
                          ShowTitle(
                              title: 'ระยะทาง : ${productModels.lat}',
                              textStyle: MyConstant().h3Style()),
                        ],
                      ),

                      // IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.android),
                      // ),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () async {
                          String idOwner = productModels.idOwner;
                          String idProduct = productModels.id;
                          String name = productModels.name;
                          String phone = productModels.phone;
                          String price = productModels.price;
                          SQLiteModel sqLiteModel = SQLiteModel(
                              idOwner: idOwner,
                              idProduct: idProduct,
                              name: name,
                              phone: phone,
                              price: price);
                          print(
                              '### idOwner == $idOwner, idProduct ==$idProduct, name ==$name, phone ==$phone , price==$price');

                          await SQLiteHelper()
                              .insertValueToSQLite(sqLiteModel)
                              .then((value) {
                            Navigator.pop(context);
                          });
                        },
                        child: Text(
                          'จองหอพัก',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'ยกเลิก',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  String cutWrod(String string) {
    String result = string;
    if (result.length >= 100) {
      result = result.substring(0, 150);
      result = '$result....';
    }
    return result;
  }
}
