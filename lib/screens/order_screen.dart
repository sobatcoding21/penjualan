import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tokokue/screens/home_screen.dart';

//import '../models/detailpost.dart';
import '../models/listorder.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = false;
  int totalHarga = 0;
  int totalQty = 0;
  String textCatatan = '';
  String textAlamat = '';
  String? idUser;
  List<ListOrder> orderList = [];
  TextEditingController? catatan;
  TextEditingController? alamat;

  Future<void> getListOrder() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var listOrder = pref.getString("orderList");
    var totQty = pref.getInt("qty");
    var id = pref.getString("id_user");

    setState(() {
      idUser = id;
    });

    if (listOrder != null) {
      var orderListMap = ListOrder.decode(listOrder.toString());
      for (var order in orderListMap) {
        setState(() {
          totalQty = totQty!;
          orderList.add(ListOrder(
              id: order.id,
              nama: order.nama,
              foto: order.foto,
              qty: order.qty,
              harga: int.parse(order.harga.toString()),
              total_harga: int.parse(order.total_harga.toString())));

          totalHarga = totalHarga + int.parse(order.total_harga.toString());
        });
      }
    }
  }

  Future<void> updateListOrder(orderList, qty) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("orderList", ListOrder.encode(orderList));
    await preferences.setInt("qty", qty);
  }

  Future<bool> toHomeScreen() async {
    if (!isLoading) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );

      return true;
    } else {
      return false;
    }
  }

  Future<void> simpanOrder() async {
    setState(() {
      isLoading = true;
    });

    try {

      var postData = jsonEncode({
            "user_id": idUser,
            "total_qty": totalQty,
            "total_harga": totalHarga,
            "catatan": textCatatan,
            "alamat_antar": textAlamat,
            "order": ListOrder.encode(orderList)
          });

      debugPrint(postData.toString());
      final response = await http.post(
          Uri.parse("https://farizan.my.id/api/order/store"),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: postData);

      if (!mounted) return;
      final data = jsonDecode(response.body);
      debugPrint(data.toString());

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        //
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Order berhasil'),
            content: Text(data['message']),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  await pref.remove("orderList");
                  //clear pref
                  toHomeScreen();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Info'),
            content: Text(data['message']),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('$e');
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Info'),
          content: Text('$e'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    getListOrder();
    super.initState();
  }

  Widget buildListOrder(index) {
    var item = orderList[index];
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              NetworkImage('https://farizan.my.id/foto/${item.foto}'),
        ),
        title:
            Text(item.nama.toString(), style: const TextStyle(fontSize: 18.0)),
        subtitle: Text("${item.qty} PCS"),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.harga.toString(),
                  style: const TextStyle(fontSize: 18.0)),
              const SizedBox(width: 8),
              CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                      onPressed: () {
                        //
                        setState(() {
                          totalQty--;

                          item.qty = item.qty! - 1;
                          item.total_harga = item.qty! * item.harga!;
                          if (item.qty == 0) {
                            totalHarga =
                                totalHarga - int.parse(item.harga.toString());
                            //remove list
                            orderList.remove(item);
                          }
                          //update total
                          totalHarga =
                              totalHarga - int.parse(item.total_harga.toString());
                          updateListOrder(orderList, totalQty);
                        });
                      },
                      icon: const Icon(Icons.remove)))
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => toHomeScreen(),
      child: Scaffold(
          appBar: AppBar(
              title: const Text('Detail Order'), actions: const <Widget>[]),
          body: Container(
            margin: const EdgeInsets.all(0),
            child: orderList.isNotEmpty
                ? Stack(
                    children: [
                      ListView.builder(
                          itemCount: orderList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return buildListOrder(index);
                          }),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              height: screenSize.height / 3.5,
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: isLoading ? Container(
                                    margin: const EdgeInsets.all(0),
                                    height: 80,
                                    child: Center(
                                      child: Column(children: const [
                                        CircularProgressIndicator(
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 10),
                                        Text("Proses menyimpan ...")
                                      ]),
                                    ),
                                  ) : Column(
                                children: [
                                  const Text("Tambah catatan :"),
                                  TextField(
                                    controller: catatan,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '...',
                                    ),
                                    onChanged: (text) {
                                      textCatatan = text;
                                    },
                                  ),
                                  const Text("Alamat antar:"),
                                  TextField(
                                    controller: catatan,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '...',
                                    ),
                                    onChanged: (text) {
                                      textAlamat = text;
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Rp. $totalHarga",
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            simpanOrder();
                                          },
                                          child: const Text("SIMPAN"))
                                    ],
                                  ),
                                ],
                              )))
                    ],
                  )
                : const Center(child: Text("Data order masih kosong")),
          )),
    );
  }
}
