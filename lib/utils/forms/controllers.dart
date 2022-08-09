import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Map myProfileControllers = {
  "business_name": {
    "controller": new TextEditingController(text: null),
    "icon": FontAwesomeIcons.store,
    "label": 'Nombre del comercio',
    "typeKeyboard": TextInputType.text,
    "isList": false,
    "isSelectTime": false
  },
  "address": {
    "controller": new TextEditingController(text: null),
    "icon": FontAwesomeIcons.addressCard,
    "label": "Dirección",
    "typeKeyboard": TextInputType.text,
    "isList": false,
    "isSelectTime": false
  },
  "city": {
    "controller": new TextEditingController(text: null),
    "icon": FontAwesomeIcons.city,
    "label": "Ciudad",
    "typeKeyboard": TextInputType.text,
    "isList": false,
    "isSelectTime": false
  },
  "phone": {
    "controller": new TextEditingController(text: null),
    "icon": FontAwesomeIcons.phone,
    "label": "Telefono fijo",
    "typeKeyboard": TextInputType.phone,
    "isList": false,
    "isSelectTime": false
  },
  "init_hour_attention": {
    "controller": new TextEditingController(text: null),
    "icon": FontAwesomeIcons.hourglassStart,
    "label": "Hora inicio de atención",
    "typeKeyboard": TextInputType.text,
    "isList": false,
    "isSelectTime": true
  },
  "end_hour_attention": {
    "controller": new TextEditingController(text: null),
    "icon": FontAwesomeIcons.hourglassEnd,
    "label": "Hora fin de atención",
    "typeKeyboard": TextInputType.text,
    "isList": false,
    "isSelectTime": true
  },
};
