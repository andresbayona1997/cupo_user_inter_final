import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shopkeeper/app_config.dart';
import 'package:shopkeeper/config.dart';
import 'package:shopkeeper/pages/choose_mode_page.dart';
import 'package:shopkeeper/services/auth_service.dart';
import 'package:shopkeeper/utils/options.dart';
import 'package:dio/dio.dart' as DIO;

final JsonDecoder _decoder = new JsonDecoder();

class UserService {
  final storage = new FlutterSecureStorage();
  AuthService _authService = new AuthService();
  String urlApp = AppConfig.getInstance().apiBaseUrl;
  var dio = DIO.Dio(
      DIO.BaseOptions(
          baseUrl: 'https://api-dot-activaciones.appspot.com/api'
      )
  );
  signOut() async {
    try {
      await _authService.signOut();
      await logout();
      await storage.deleteAll();
      navigatorKey.currentState.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ChooseModePage()), (Route<dynamic> route) => false);
    } catch (e) {
      print('SignuotError $e');
    }
  }

  Future register(String username, String password, String referredCode) async {
    Map user = {
      "username": username,
      "client_secret": clientSecret,
      "role_id": roleId,
      "role_name": roleName,
      "email": username,
      "password": password
    };
    if (referredCode != null && referredCode.isNotEmpty)
      user["referred_code"] = referredCode;
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
    //   "password": password
    // };
    //
    // if (referredCode != null && referredCode.isNotEmpty)
    //   user["referred_code"] = referredCode;
    //
    // Map<String, String> headers = {'Content-type': 'application/json'};
    //
    // String url = '/api/register/users';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .post(uri, body: jsonEncode(user), headers: headers)
    //     .then(_handleRequest);
  }

  Future getStatusStore() async {
    String token = await storage.read(key: 'token');
    final response = await dio.get('/status/shopkeepers', options: DIO.Options(
        headers: {'Authorization': 'Bearer '+token, 'Content-type': 'application/json'}
    ));
    return _handleRequest(response);
  }

  Future changeStatusStore() async{
    Map info = {
      "status": "OPEN_SHOP",
      "status_profile": "SHOPKEEPERS_ENABLED"
    };

    String token = await storage.read(key: 'token');
    final response = await dio.put('/status/shopkeepers', options: DIO.Options(
      headers: {'Content-type': 'application/json','Authorization': 'Bearer '+token},
    ), data: info);

    return _handleRequest(response);
  }

  Future getUserById(String id) async {
    String token = await storage.read(key: 'token');
    final response = await dio.get('/users/$id', options: DIO.Options(
        headers: {'Authorization': 'Bearer '+token, 'Content-type': 'application/json'}
    ));
    return _handleRequest(response);
    // print(token);
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    // String url = '/api/users/$id';
    // Uri uri = Uri.https(urlApp, url);
    // return await http.get(uri, headers: headers).then(_handleRequest);
  }

  Future updateShopkeeper(String id, Map shopkeeper) async {
    String token = await storage.read(key: 'token');
    final response = await dio.put('/shopkeepers/$id', options: DIO.Options(
      headers: {'Content-type': 'application/json','Authorization': 'Bearer '+token},
    ), data: shopkeeper);
    return _handleRequest(response);
    // print(id);
    //
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    // String url = '/api/shopkeepers/$id';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .put(uri, headers: headers, body: jsonEncode(shopkeeper))
    //     .then(_handleRequest);
  }

  Future recoverPassword(String email) async{
    Map user = {
      "email": email
    };
    final response = await dio.post('/restore/password', options: DIO.Options(
      headers: {'Content-type': 'application/json'},
    ), data: user).onError((error, stackTrace) {
      print(error);
    });
    return _handleRequest(response);
  }

  Future login(String username, String uuid) async {
    //String token = await storage.read(key: 'token');
    Map user = {
      "username": username,
      "uuid": uuid,
      "client_secret": clientSecret
    };
    final response = await dio.post('/auth/login', options: DIO.Options(
      headers: {'Content-type': 'application/json'},
    ), data: user);
    return _handleRequest(response);
    // Map user = {
    //   "username": username,
    //   "uuid": uuid,
    //   "client_secret": clientSecret
    // };
    //
    // Map<String, String> headers = {'Content-type': 'application/json'};
    //
    // String url = '/api/auth/login';
    // Uri uri = Uri.https(urlApp, url);
    // return await http
    //     .post(uri, body: jsonEncode(user), headers: headers)
    //     .then(_handleRequest);
  }

  Future logout() async {
    String token = await storage.read(key: 'token');
    final response = await dio.post('/auth/logout', options: DIO.Options(
      headers: {'Content-type': 'application/json','Authorization': 'Bearer '+token},
    ), );
    return _handleRequest(response);

    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    // String url = '/api/auth/logout';
    // Uri uri = Uri.https(urlApp, url);
    // return await http.post(uri, headers: headers).then(_handleRequest);
  }

  Future getTypologies() async {

    String token = await storage.read(key: 'token');
    final response = await dio.get('/typologies', options: DIO.Options(
        headers: {'Authorization': 'Bearer '+token, 'Content-type': 'application/json'}
    ));
    return _handleRequest(response);
    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    // String url = '/api/typologies';
    // Uri uri = Uri.https(urlApp, url);
    // return await http.get(uri, headers: headers).then(_handleRequest);
  }

  Future getCountries() async {
    String token = await storage.read(key: 'token');
    final response = await dio.get('/countries/es', options: DIO.Options(
        headers: {'Authorization': 'Bearer '+token, 'Content-type': 'application/json'}
    ));
    return _handleRequest(response);

    // Map<String, String> headers = {
    //   'Content-type': 'application/json',
    //   'Authorization': 'Bearer $token'
    // };
    // String url = '/api/countries/es';
    // Uri uri = Uri.https(urlApp, url);
    // return await http.get(uri, headers: headers).then(_handleRequest);
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
