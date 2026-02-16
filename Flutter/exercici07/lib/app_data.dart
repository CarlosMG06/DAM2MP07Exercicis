import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'constants.dart';
import 'drawable.dart';

class AppData extends ChangeNotifier {
  String _responseText = "";
  bool _isLoading = false;
  bool _isInitial = true;
  http.Client? _client;
  IOClient? _ioClient;
  HttpClient? _httpClient;
  StreamSubscription<String>? _streamSubscription;

  final List<Drawable> drawables = [];

  String get responseText =>
      _isInitial ? "..." : (_isLoading ? "Esperant ..." : _responseText);

  bool get isLoading => _isLoading;

  AppData() {
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addDrawable(Drawable drawable) {
    drawables.add(drawable);
    notifyListeners();
  }

  Future<void> callStream({required String question}) async {
    _isInitial = false;
    setLoading(true);

    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.body =
          jsonEncode({'model': 'llama3.2', 'prompt': question, 'stream': true});

      var streamedResponse = await _client!.send(request);
      _streamSubscription =
          streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var jsonResponse = jsonDecode(value);
        var jsonResponseStr = jsonResponse['response'];
        _responseText = "$_responseText\n$jsonResponseStr";
        notifyListeners();
      }, onError: (error) {
        if (error is http.ClientException &&
            error.message == 'Connection closed while receiving data') {
          _responseText += "\nRequest cancelled.";
        } else {
          _responseText += "\nError during streaming: $error";
        }
        setLoading(false);
        notifyListeners();
      }, onDone: () {
        setLoading(false);
      });
    } catch (e) {
      _responseText = "\nError during streaming.";
      setLoading(false);
      notifyListeners();
    }
  }

  dynamic fixJsonInStrings(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, fixJsonInStrings(value)));
    } else if (data is List) {
      return data.map(fixJsonInStrings).toList();
    } else if (data is String) {
      try {
        // Si és JSON dins d'una cadena, el deserialitzem
        final parsed = jsonDecode(data);
        return fixJsonInStrings(parsed);
      } catch (_) {
        // Si no és JSON, retornem la cadena tal qual
        return data;
      }
    }
    // Retorna qualsevol altre tipus sense canvis (números, booleans, etc.)
    return data;
  }

  dynamic cleanKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.trim()] = cleanKeys(v);
      });
      return result;
    }
    if (value is List) {
      return value.map(cleanKeys).toList();
    }
    return value;
  }

  Future<void> callWithCustomTools({required String userPrompt}) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    _isInitial = false;
    setLoading(true);

    final body = {
      "model": "llama3.2",
      "stream": false,
      "messages": [
        {"role": "user", "content": userPrompt}
      ],
      "tools": tools
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['message'] != null &&
            jsonResponse['message']['tool_calls'] != null) {
          final toolCalls = (jsonResponse['message']['tool_calls'] as List)
              .map((e) => cleanKeys(e))
              .toList();
          for (final tc in toolCalls) {
            if (tc['function'] != null) {
              _processFunctionCall(tc['function']);
            }
          }
        }
        setLoading(false);
      } else {
        setLoading(false);
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      print("Error during API call: $e");
      setLoading(false);
    }
  }

  void cancelRequests() {
    _streamSubscription?.cancel();
    _httpClient?.close(force: true);
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
    _responseText += "\nRequest cancelled.";
    setLoading(false);
    notifyListeners();
  }

  double parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  void _processFunctionCall(Map<String, dynamic> functionCall) {
    final fixedJson = fixJsonInStrings(functionCall);
    final parameters = fixedJson['arguments'];

    String name = fixedJson['name'];
    String infoText = "Draw $name: $parameters";

    print(infoText);
    _responseText = "$_responseText\n$infoText";

    switch (name) {
      case 'draw_circle':
        if (parameters['x'] != null &&
            parameters['y'] != null &&
            parameters['radius'] != null) {
          final dx = parseDouble(parameters['x']);
          final dy = parseDouble(parameters['y']);
          final radius = max(0.0, parseDouble(parameters['radius']));

          double strokeWidth = 2.0;
          if (parameters['strokeWidth'] != null) {
            strokeWidth = parseDouble(parameters['strokeWidth']);
          }

          Color color = Colors.black; 
          if (parameters['colorR'] != null &&
              parameters['colorG'] != null &&
              parameters['colorB'] != null) {
            final colorR = parseDouble(parameters['colorR']).toInt();
            final colorG = parseDouble(parameters['colorG']).toInt();
            final colorB = parseDouble(parameters['colorB']).toInt();
            color = Color.fromARGB(255, colorR, colorG, colorB);
          }

          PaintingStyle style = PaintingStyle.stroke;
          if (parameters['fill'] != null) {
            final fill = parameters['fill'];
            style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
          }

          addDrawable(Circle(center: Offset(dx, dy), radius: radius, strokeWidth: strokeWidth, color: color, style: style));
        } else {
          print("Missing circle properties: $parameters");
        }
        break;

      case 'draw_line':
        if (parameters['startX'] != null &&
            parameters['startY'] != null &&
            parameters['endX'] != null &&
            parameters['endY'] != null) {
          final startX = parseDouble(parameters['startX']);
          final startY = parseDouble(parameters['startY']);
          final endX = parseDouble(parameters['endX']);
          final endY = parseDouble(parameters['endY']);
          final start = Offset(startX, startY);
          final end = Offset(endX, endY);

          Color color = Colors.black;
          if (parameters['colorR'] != null &&
              parameters['colorG'] != null &&
              parameters['colorB'] != null) {
            final colorR = parseDouble(parameters['colorR']).toInt();
            final colorG = parseDouble(parameters['colorG']).toInt();
            final colorB = parseDouble(parameters['colorB']).toInt();
            color = Color.fromARGB(255, colorR, colorG, colorB);
          }

          double strokeWidth = 2.0;
          if (parameters['strokeWidth'] != null) {
            strokeWidth = parseDouble(parameters['strokeWidth']);
          }

          addDrawable(Line(start: start, end: end, color: color, strokeWidth: strokeWidth));
        } else {
          print("Missing line properties: $parameters");
        }
        break;

      case 'draw_rectangle':
        if (parameters['topLeftX'] != null &&
            parameters['topLeftY'] != null &&
            parameters['bottomRightX'] != null &&
            parameters['bottomRightY'] != null) {
          final topLeftX = parseDouble(parameters['topLeftX']);
          final topLeftY = parseDouble(parameters['topLeftY']);
          final bottomRightX = parseDouble(parameters['bottomRightX']);
          final bottomRightY = parseDouble(parameters['bottomRightY']);
          final topLeft = Offset(topLeftX, topLeftY);
          final bottomRight = Offset(bottomRightX, bottomRightY);

          double strokeWidth = 2.0;
          if (parameters['strokeWidth'] != null) {
            strokeWidth = parseDouble(parameters['strokeWidth']);
          }

          Color color = Colors.black; 
          if (parameters['colorR'] != null &&
              parameters['colorG'] != null &&
              parameters['colorB'] != null) {
            final colorR = parseDouble(parameters['colorR']).toInt();
            final colorG = parseDouble(parameters['colorG']).toInt();
            final colorB = parseDouble(parameters['colorB']).toInt();
            color = Color.fromARGB(255, colorR, colorG, colorB);
          }

          PaintingStyle style = PaintingStyle.stroke;
          if (parameters['fill'] != null) {
            final fill = parameters['fill'];
            style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
          }

          addDrawable(Rectangle(topLeft: topLeft, bottomRight: bottomRight, strokeWidth: strokeWidth, color: color, style: style));
        } else {
          print("Missing rectangle properties: $parameters");
        }
        break;
      case 'draw_text':
        if (parameters['text'] != null &&
            parameters['positionX'] != null &&
            parameters['positionY'] != null) {
          final text = parameters['text'];
          final positionX = parseDouble(parameters['positionX']);
          final positionY = parseDouble(parameters['positionY']);
          final position = Offset(positionX, positionY);

          Color color = Colors.black; 
          if (parameters['colorR'] != null &&
              parameters['colorG'] != null &&
              parameters['colorB'] != null) {
            final colorR = parseDouble(parameters['colorR']).toInt();
            final colorG = parseDouble(parameters['colorG']).toInt();
            final colorB = parseDouble(parameters['colorB']).toInt();
            color = Color.fromARGB(255, colorR, colorG, colorB);
          }

          double fontSize = 14.0;
          if(parameters['fontSize'] != null) {
            fontSize = parseDouble(parameters['fontSize']);
          }
          FontWeight fontWeight = FontWeight.normal;
          if (parameters['bold'] != null) {
            final bold = parameters['bold'];
            if (bold) fontWeight = FontWeight.bold;
          }
          FontStyle fontStyle = FontStyle.normal;
          if (parameters['italic'] != null) {
            final italic = parameters['italic'];
            if (italic) fontStyle = FontStyle.italic;
          }
          String? fontFamily;
          if (parameters['fontFamily'] != null) {
            fontFamily = parameters['fontFamily'].toString();
          }
          addDrawable(TextElement( 
            text: text, position: position, color: color, fontSize: fontSize, 
            fontWeight: fontWeight, fontStyle: fontStyle, fontFamily: fontFamily
          ));
        } else {
          print("Missing rectangle properties: $parameters");
        }
        break;
      default:
        print("Unknown function call: ${fixedJson['name']}");
    }
  }
}
