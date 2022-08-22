import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/listorder.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int totalHarga = 0;
  List<ListOrder> orderList = [];

  void hitungTotal() {
    for (var list in orderList) {
      setState(() {
        totalHarga = totalHarga + int.parse(list.total.toString());
      });
    }
  }

  Future<void> getListOrder() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var listOrder = pref.getString("orderList");
    var orderListMap = ListOrder.decode(listOrder.toString());

    debugPrint(listOrder.toString());

    for (var order in orderListMap) {
      setState(() {
        orderList.add(ListOrder(
            id: order.id,
            nama: order.nama,
            foto: order.foto,
            qty: order.qty,
            harga: int.parse(order.harga.toString()),
            total: int.parse(order.total.toString())));

        totalHarga = totalHarga + int.parse(order.total.toString());
      });
    }
  }

  Future<void> updateListOrder(orderList) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("orderList", ListOrder.encode(orderList));
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
              // ignore: prefer_interpolation_to_compose_strings
              NetworkImage(
                  'https://farizan.my.id/foto/' + item.foto.toString()),
        ),
        title:
            Text(item.nama.toString(), style: const TextStyle(fontSize: 18.0)),
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
                          //update qty
                          item.total = item.qty! * item.harga!;
                          item.qty = item.qty! - 1;
                          if (item.qty == 0) {
                            //remove list
                            orderList.remove(item);
                          }
                          //update total
                          totalHarga =
                              totalHarga - int.parse(item.total.toString());
                          updateListOrder(orderList);
                        });
                      },
                      icon: const Icon(Icons.remove)))
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
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
                            height: 100, //screenSize.height / 4,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rp. $totalHarga",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      null;
                                    },
                                    child: const Text("SIMPAN"))
                              ],
                            )))
                  ],
                )
              : const Center(child: Text("Data order masih kosong")),
        ));
  }
}
