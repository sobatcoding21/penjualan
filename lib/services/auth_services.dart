import 'dart:convert';

import 'package:tokokue/Services/globals.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<http.Response> register(
      String nama, String email, String password, String no_wa, String alamat) async {
    Map data = {
      "nama": nama,
      "email": email,
      "password": password,
      "no_wa": no_wa,
      "alamat": alamat,
    };
    var body = json.encode(data);
    var url = Uri.parse(baseURL + 'register');
    //var url = Uri.parse(baseURL);
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.body);
    return response;
  }

  static Future<http.Response> login(String email, String password) async {
    Map data = {
      "email": email,
      "password": password,
    };
    var body = json.encode(data);
     var url = Uri.parse(baseURL + 'login');
    //var url = Uri.parse(baseURL + 'login');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.body);
    return response;
  }
}
