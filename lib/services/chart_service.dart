import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopkeeper/app_config.dart';
import 'package:shopkeeper/services/auth_service.dart';
import 'package:dio/dio.dart' as DIO;

final JsonDecoder _decoder = new JsonDecoder();

class ChartService {
  var dio = DIO.Dio(
      DIO.BaseOptions(
          baseUrl: 'https://api-dot-activaciones.appspot.com/api'
      )
  );
  final storage = new FlutterSecureStorage();
  AuthService _authService = new AuthService();
  String urlApp = AppConfig.getInstance().apiBaseUrl;



  Future getChartsData(String initDate) async {
    String id = await storage.read(key: 'id');
    print(id);
    String token = await storage.read(key: 'token');
    print(token);
    Map obj = {"shopkeeper_id": id, "init_date": initDate};
    final response = await dio.post('/shopkeeper/summaryday', options: DIO.Options(
      headers: {'Content-type': 'application/json','Authorization': 'Bearer '+token},
    ), data: obj);
    return _handleRequest(response);
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    //
    // String url = '/api/shopkeeper/summaryday';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .post(uri, body: jsonEncode(obj), headers: headers)
    //     .then(_handleRequest);
  }

  Future getSales(String initDate) async {
    String id = await storage.read(key: 'id');
    String token = await storage.read(key: 'token');
    Map obj = {"shopkeeper_id": id, "init_date": initDate};
    final response = await dio.post('/shopkeeper/debt', options: DIO.Options(
      headers: {'Content-type': 'application/json','Authorization': 'Bearer '+token},
    ), data: obj);
    return _handleRequest(response);
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    //
    // String url = '/api/shopkeeper/debt';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .post(uri, body: jsonEncode(obj), headers: headers)
    //     .then(_handleRequest);
  }

  _handleRequest(DIO.Response response) {
    final int statusCode = response.statusCode;
    // print('Code: $statusCode Response $res');

    // if (statusCode == 401) {
    //   signOut();
    // }

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return response.data;
  }
}
