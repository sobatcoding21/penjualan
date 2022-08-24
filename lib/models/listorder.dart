import 'dart:convert';

class ListOrder {
  String? id;
  String? invoice;
  String? nama;
  String? foto;
  int? qty;
  int? harga;
  int? total_harga;

  ListOrder(
      {this.id,
      this.invoice,
      this.nama,
      this.foto,
      this.qty,
      this.harga,
      this.total_harga});
  ListOrder.fromJson(Map json)
      : id = json['id'],
        invoice = json['invoice'],
        nama = json['nama'],
        foto = json['foto'],
        qty = json['qty'],
        harga = json['harga'],
        total_harga = json['total_harga'];

  static Map<String, dynamic> toMap(ListOrder orderlist) => {
        'id': orderlist.id,
        'invoice': orderlist.invoice,
        'nama': orderlist.nama,
        'foto': orderlist.foto,
        'qty': orderlist.qty,
        'harga': orderlist.harga,
        'total_harga': orderlist.total_harga
      };

  static String encode(List<ListOrder> orderlist) => json.encode(
        orderlist
            .map<Map<String, dynamic>>(
                (orderlist) => ListOrder.toMap(orderlist))
            .toList(),
      );
  static List decode(String order) =>
      (json.decode(order) as List<dynamic>)
          .map<ListOrder>((item) => ListOrder.fromJson(item))
          .toList();
}
