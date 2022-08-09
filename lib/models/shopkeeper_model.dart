import 'package:shopkeeper/config.dart' as config;

class ShopkeeperModel {
  String businessName;
  String typology;
  String address;
  String city;
  String location;
  String phone;
  String cellPhone;
  String telephoneCode;
  String baseCity;
  String daysAttention;
  String initHourAttention;
  String endHourAttention;
  String statusId;
  String email;
  String username;
  String password;

  ShopkeeperModel({
    String businessName,
    String typology,
    String address,
    String city,
    String location,
    String phone,
    String cellPhone,
    String telephoneCode,
    String baseCity,
    String daysAttention,
    String initHourAttention,
    String endHourAttention,
    String statusId,
    String email,
    String username,
    String password,
  }) {
    this.businessName = businessName;
    this.typology = typology;
    this.address = address;
    this.city = city;
    this.location = location;
    this.phone = phone;
    this.cellPhone = cellPhone;
    this.telephoneCode = telephoneCode;
    this.baseCity = baseCity;
    this.daysAttention = daysAttention;
    this.initHourAttention = initHourAttention;
    this.endHourAttention = endHourAttention;
    this.statusId = statusId;
    this.email = email;
    this.username = username;
    this.password = password;
  }

  toJson() {
    return {
      "business_name": this.businessName,
      "typology": this.typology,
      "address": this.address,
      "city": this.city,
      "location": this.location,
      "phone": this.phone,
      "cell_phone": this.cellPhone,
      "base_city": this.baseCity,
      "telephone_code": this.telephoneCode,
      "days_attention": this.daysAttention,
      "init_hour_attention": this.initHourAttention,
      "end_hour_attention": this.endHourAttention,
      "status_id": this.statusId,
      "client_secret": config.clientSecret,
      "email": this.email,
      "username": this.username,
      "password": this.password,
    };
  }
}
