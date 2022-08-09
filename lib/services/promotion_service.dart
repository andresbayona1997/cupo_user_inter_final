import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopkeeper/app_config.dart';
import 'package:shopkeeper/config.dart';
import 'package:shopkeeper/services/auth_service.dart';
import 'package:shopkeeper/utils/options.dart';
import 'package:dio/dio.dart' as DIO;

final JsonDecoder _decoder = new JsonDecoder();

class PromotionService {
  var dio = DIO.Dio(
      DIO.BaseOptions(
          baseUrl: 'https://api-dot-activaciones.appspot.com/api'
      )
  );
  final storage = new FlutterSecureStorage();
  AuthService _authService = new AuthService();
  String urlApp = AppConfig.getInstance().apiBaseUrl;

  Future register(String username, String password) async {
    Map user = {
      "username": username,
      "client_secret": clientSecret,
      "role_id": roleId,
      "role_name": roleName,
      "email": username,
      "password": password
    };
    final response = await dio.post('/register/users', options: DIO.Options(
      headers: {'Content-type': 'application/json'},
    ), data: user);
    return _handleRequest(response);
    // Map user = {
    //   "username": username,
    //   "client_secret": clientSecret,
    //   "role_id": roleId,
    //   "role_name": roleName,
    //   "email": username,
    //   "password": password,
    // };
    //
    // Map<String, String> headers = {'Content-type': 'application/json'};
    //
    // String url = '/api/register/users';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .post(uri, body: jsonEncode(user), headers: headers)
    //     .then(_handleRequest);
  }

  Future reedemPromotion(String reedemCode) async {
    String token = await storage.read(key: 'token');
    String id = await storage.read(key: 'id');
    Map data = {'redeem_code': reedemCode, 'shopkeeper_id': id};
    final response = await dio.post('/redeem/promotions', options: DIO.Options(
      headers: {'Content-type': 'application/json','Authorization': 'Bearer '+token},
    ), data: data).onError((error, stackTrace) {
      print(error);
    });
    return _handleRequest(response);
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    //
    // Map data = {'redeem_code': reedemCode, 'shopkeeper_id': id};
    //
    // String url = '/api/redeem/promotions';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .post(uri, body: jsonEncode(data), headers: headers)
    //     .then(_handleRequest);
  }

  Future getPromotion(String promotionCode) async {
    String token = await storage.read(key: 'token');
    final response = await dio.get('/get/promotions/$promotionCode', options: DIO.Options(
        headers: {'Authorization': 'Bearer '+token, 'Content-type': 'application/json'}
    )).onError((error, stackTrace) {
      print(error);
    });
    return _handleRequest(response);
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    //
    // String url = '/api/get/promotions/$promotionCode';
    // Uri uri = Uri.https(urlApp, url);
    // return await http.get(uri, headers: headers).then(_handleRequest);
  }

  Future acceptPromotion(String promotionCode) async {
    String token = await storage.read(key: 'token');
    String shopkeeperId = await storage.read(key: 'id');
    String companyId = await storage.read(key: 'company_id');
    Map data = {
      "promotion_code": promotionCode,
      "shopkeeper_id": shopkeeperId,
      "company_id": companyId,
      "status": true
    };
    final response = await dio.post('/promotions/accepted', options: DIO.Options(
      headers: {'Content-type': 'application/json','Authorization': 'Bearer '+token},
    ), data: data).onError((error, stackTrace) {
      print(error);
    });
    return _handleRequest(response);
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    //
    // Map data = {
    //   "promotion_code": promotionCode,
    //   "shopkeeper_id": shopkeeperId,
    //   "company_id": companyId,
    //   "status": true
    // };
    //
    // String url = '/api/promotions/accepted';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .post(uri, body: jsonEncode(data), headers: headers)
    //     .then(_handleRequest);
  }

  signOut() async {
    try {
      await _authService.signOut();
      await storage.deleteAll();
      navigatorKey.currentState.pushReplacementNamed('/chooseMode');
    } catch (e) {
      print('SignuotError $e');
    }
  }

  _handleRequest(DIO.Response response) {
    final int statusCode = response.statusCode;
    // print('Code: $statusCode Response $res');

    if (statusCode == 401) {
      signOut();
    }

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return response.data;
  }
}
