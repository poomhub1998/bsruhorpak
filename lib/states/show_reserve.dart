import 'package:bsru_horpak/models/sqlite_model.dart';
import 'package:bsru_horpak/utility/sqlite_heiper.dart';
import 'package:bsru_horpak/widgets/show_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ShowReserve extends StatefulWidget {
  const ShowReserve({Key? key}) : super(key: key);

  @override
  State<ShowReserve> createState() => _ShowReserveState();
}

class _ShowReserveState extends State<ShowReserve> {
  List<SQLiteModel> sqliteModels = [];
  bool load = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    processReadSQLite();
  }

  Future<Null> processReadSQLite() async {
    await SQLiteHelper().readSQLite().then((value) {
      setState(() {
        load = false;
        sqliteModels = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reserve'),
      ),
      body: load
          ? Text('ยังไม่ได้จองหอพัก')
          : ListView.builder(
              itemCount: sqliteModels.length,
              itemBuilder: (context, index) => Text(sqliteModels[index].name),
            ),
    );
  }
}
