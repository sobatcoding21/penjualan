class Order {
  int? id;
  String? invoice;
  String? tgl;
  int? total;

  Order(
      {this.id,
      this.invoice,
      this.tgl,
      this.total});
  Order.fromJson(Map json)
      : id = json['id'],
        invoice = json['invoice'],
        tgl = json['tgl'],
        total = json['total'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice': invoice,
        'tgl': tgl,
        'total': total,
      };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice': invoice,
      'tgl': tgl,
      'total': total
    };
  }

  @override
  String toString() {
    return 'Order{id: $id, invoice: $invoice, tgl: $tgl, total: $total}';
  }
}
