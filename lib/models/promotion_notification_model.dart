import 'package:firebase_database/firebase_database.dart';

class PromotionNotificationModel {
  String key;
  String categoryNotificationId;
  String company;
  String companyId;
  String dateEnd;
  String dateInit;
  String description;
  String endHour;
  String initHour;
  String name;
  String promotionCode;
  bool status;
  List stores;
  String timestamp;
  dynamic unixTimestamp;

  PromotionNotificationModel.fromSnapshot(DataSnapshot snapshot)
              : key = snapshot.key,
                categoryNotificationId = snapshot.value["category_notification_id"],
                company = snapshot.value["company"],
                dateInit = snapshot.value["date_init"],
                dateEnd = snapshot.value["date_end"],
                description = snapshot.value["description"],
                initHour = snapshot.value["init_hour"],
                endHour = snapshot.value["end_hour"],
                name = snapshot.value["name"],
                promotionCode = snapshot.value["promotion_code"],
                status = snapshot.value["status"],
                stores = snapshot.value["stores"],
                timestamp = snapshot.value["timestamp"],
                unixTimestamp = snapshot.value["unix_timestamp"]; 

  toJson() {
    return {
      "categoryNotificationId": categoryNotificationId,
      "company": company,
      "dateInit": dateInit,
      "dateEnd": dateEnd,
      "description": description,
      "initHour": initHour,
      "endHour": endHour,
      "name": name,
      "promotionCode": promotionCode,
      "status": status,
      "stores": stores,
      "timestamp": timestamp,
      "unixTimestamp": unixTimestamp
    };
  }
}
