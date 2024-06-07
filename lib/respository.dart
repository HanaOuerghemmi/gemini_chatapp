import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
 import 'package:dash_chat_2/dash_chat_2.dart';

  
  
  final ourUrl="https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyCYOTTS5ioHEQ_gDTD404N_1wAwikltb5o";
  final header={
    'Content-Type': 'application/json'
  };
