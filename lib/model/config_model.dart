
import 'dart:convert';

import 'package:flutter/services.dart';

class JsonConfigModel{
  String? signPublicKey;
  String? machineName;
  String? publicKey;
  String? version;

  JsonConfigModel(this.machineName, this.publicKey, this.signPublicKey, this.version);
  factory JsonConfigModel.fromJson(dynamic json){
    return JsonConfigModel(json['machineName'], json['publicKey'], json['signPublicKey'], json['version']);
  }




}