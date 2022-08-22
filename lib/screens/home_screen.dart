import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tokokue/screens/order_screen.dart';
import 'dart:convert';

import '../models/listorder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiUrl = "https://farizan.my.id/api/produk";
  List<ListOrder> orderList = [];

  void klikBeli(item) {
    setState(() {
      orderList.add(ListOrder(
          id: item['id'],
          nama: item['nama'],
          foto: item['foto'],
          qty: 1,
          harga: int.parse(item['harga']),
          total: int.parse(item['harga'])));

      addToChart(orderList);
    });
  }


  Future<void> getListOrder() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var listOrder = pref.getString("orderList");
    var orderListMap = ListOrder.decode(listOrder.toString());

    for(var order in orderListMap) {
      setState(() {
        orderList.add(ListOrder(
          id: order.id,
          nama: order.nama,
          foto: order.foto,
          qty: order.qty,
          harga: int.parse(order.harga.toString()),
          total: int.parse(order.total.toString())));
      });
    }

    debugPrint(listOrder.toString());
  }

  void addToChart(item) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("orderList", ListOrder.encode(item));
  }

  Widget shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topEnd(top: 0, end: 3),
      animationDuration: const Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        orderList.length.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      child: IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const OrderScreen(),
                ));
          }),
    );
  }

  Future<List<dynamic>> _fecthDataUsers() async {
    var result = await http.get(Uri.parse(apiUrl), headers: {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    });
    return json.decode(result.body);
  }

  @override
  void initState() {
    getListOrder();
    super.initState();
  }

  Widget buildListProduk(item) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              // ignore: prefer_interpolation_to_compose_strings
              NetworkImage('https://farizan.my.id/foto/' + item['foto']),
        ),
        title: Text(item['nama'].toString(),
            style: const TextStyle(fontSize: 18.0)),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item['harga'].toString(),
                  style: const TextStyle(fontSize: 18.0)),
              const SizedBox(width: 8),
              CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.amber,
                  child: IconButton(
                      onPressed: () {
                        //
                        klikBeli(item);
                      },
                      icon: const Icon(Icons.add))),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Daftar Produk'),
          actions: <Widget>[shoppingCartBadge()]),
      body: Container(
        margin: const EdgeInsets.all(0),
        child: FutureBuilder<List<dynamic>>(
          future: _fecthDataUsers(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    var item = snapshot.data[index];
                    return buildListProduk(item);
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
