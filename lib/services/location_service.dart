import 'package:location/location.dart';
import 'package:flutter/services.dart';


class LocationService {

  Location _locationService = new Location();


  Future initPlatformState() async {
    await _locationService.changeSettings(accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      if (serviceStatus) {
        final _permission = await _locationService.requestPermission();
        if (_permission != null) {
          location = await _locationService.getLocation();
          String latitude = location.latitude.toString();
          String longitude = location.longitude.toString();
          return { 
            "status": true, 
            "coords": {
              "latitude": latitude,
              "longitude": longitude
            }  
          };
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        if (serviceStatusResult) {
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return { 
          "status": false,
          "msg": e.message
        };
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
       return { 
          "status": false,
          "msg": e.message
        };
      }
      location = null;
    }
  }
}