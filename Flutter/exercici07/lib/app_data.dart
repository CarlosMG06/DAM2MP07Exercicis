import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'constants.dart';
import 'drawable.dart';
import 'selection.dart';

class AppData extends ChangeNotifier {
  String _responseText = "";
  bool _isLoading = false;
  bool _isInitial = true;
  http.Client? _client;
  IOClient? _ioClient;
  HttpClient? _httpClient;
  StreamSubscription<String>? _streamSubscription;

  final List<Drawable> drawables = [];

  final SelectionManager selectionManager = SelectionManager();
  Size? _canvasSize;

  String get responseText =>
      _isInitial ? "..." : (_isLoading ? "Esperant ..." : _responseText);

  bool get isLoading => _isLoading;

  AppData() {
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
  }

  void setCanvasSize(Size size) {
    _canvasSize = size;
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
    String infoText = "$name: $parameters";

    print(infoText);
    _responseText = "$_responseText\n$infoText";

    switch (name) {
      case 'draw_circle':
        if (parameters['x'] != null &&
            parameters['y'] != null) {
          _processDrawCircle(parameters);
        } else {
          print("Missing circle properties: $parameters");
        }
        break;

      case 'draw_line':
        if (parameters['startX'] != null &&
            parameters['startY'] != null &&
            parameters['endX'] != null &&
            parameters['endY'] != null) {
          _processDrawLine(parameters);
        } else {
          print("Missing line properties: $parameters");
        }
        break;

      case 'draw_rectangle':
        if (parameters['topLeftX'] != null &&
            parameters['topLeftY'] != null &&
            parameters['bottomRightX'] != null &&
            parameters['bottomRightY'] != null) {
          _processDrawRectangle(parameters);
        } else {
          print("Missing rectangle properties: $parameters");
        }
        break;
      
      case 'draw_text':
        if (parameters['text'] != null &&
            parameters['x'] != null &&
            parameters['y'] != null) {
          _processDrawText(parameters);
        } else {
          print("Missing text properties: $parameters");
        }
        break;
      
      case 'select_drawables':
        _processSelectDrawables(parameters);
        break;
        
      case 'delete_selected':
        _processDeleteSelected();
        break;
        
      case 'delete_drawables':
        _processDeleteDrawables(parameters);
        break;
        
      case 'modify_selected':
        _processModifySelected(parameters);
        break;
      
      case 'clear_selection':
        selectionManager.clearSelection();
        break;

      case 'get_canvas_info':
        _processGetCanvasInfo();
        break;

      default:
        print("Unknown function call: ${fixedJson['name']}");
    }
  }

  //================//
  // Function Calls //
  //    Dibuixar    //
  //================//

  void _processDrawCircle(dynamic parameters) {
    final dx = parseDouble(parameters['x']);
    final dy = parseDouble(parameters['y']);
    
    double radius = 10.0;
    if (parameters['radius'] != null) {
      radius = parseDouble(parameters['radius']);
    }

    double strokeWidth = 2.0;
    if (parameters['strokeWidth'] != null) {
      strokeWidth = parseDouble(parameters['strokeWidth']);
    }

    Color color = Colors.black; 
    if (parameters['colorRed'] != null ||
        parameters['colorGreen'] != null ||
        parameters['colorBlue'] != null) {
      final colorRed = parseDouble(parameters['colorRed']).toInt();
      final colorGreen = parseDouble(parameters['colorGreen']).toInt();
      final colorBlue = parseDouble(parameters['colorBlue']).toInt();
      color = Color.fromARGB(255, colorRed, colorGreen, colorBlue);
    }

    PaintingStyle style = PaintingStyle.stroke;
    if (parameters['fill'] != null) {
      final fill = parameters['fill'];
      style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    }

    addDrawable(Circle(
      center: Offset(dx, dy), radius: radius, 
      strokeWidth: strokeWidth, color: color, style: style
    ));
  }

  void _processDrawLine(dynamic parameters) {
    final startX = parseDouble(parameters['startX']);
    final startY = parseDouble(parameters['startY']);
    final endX = parseDouble(parameters['endX']);
    final endY = parseDouble(parameters['endY']);
    final start = Offset(startX, startY);
    final end = Offset(endX, endY);

    Color color = Colors.black;
    if (parameters['colorRed'] != null ||
        parameters['colorGreen'] != null ||
        parameters['colorBlue'] != null) {
      final colorRed = parseDouble(parameters['colorRed']).toInt();
      final colorGreen = parseDouble(parameters['colorGreen']).toInt();
      final colorBlue = parseDouble(parameters['colorBlue']).toInt();
      color = Color.fromARGB(255, colorRed, colorGreen, colorBlue);
    }

    double strokeWidth = 2.0;
    if (parameters['strokeWidth'] != null) {
      strokeWidth = parseDouble(parameters['strokeWidth']);
    }

    addDrawable(Line(
      start: start, end: end, 
      color: color, strokeWidth: strokeWidth
    ));
  }

  void _processDrawRectangle(dynamic parameters) {
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
    if (parameters['colorRed'] != null ||
        parameters['colorGreen'] != null ||
        parameters['colorBlue'] != null) {
      final colorRed = parseDouble(parameters['colorRed']).toInt();
      final colorGreen = parseDouble(parameters['colorGreen']).toInt();
      final colorBlue = parseDouble(parameters['colorBlue']).toInt();
      color = Color.fromARGB(255, colorRed, colorGreen, colorBlue);
    }

    PaintingStyle style = PaintingStyle.stroke;
    if (parameters['fill'] != null) {
      final fill = parameters['fill'];
      style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    }

    addDrawable(Rectangle(
      topLeft: topLeft, bottomRight: bottomRight,
      strokeWidth: strokeWidth, color: color, style: style
    ));
  }

  void _processDrawText(dynamic parameters) {
    final text = parameters['text'];
    final positionX = parseDouble(parameters['positionX']);
    final positionY = parseDouble(parameters['positionY']);
    final position = Offset(positionX, positionY);

    Color color = Colors.black; 
    if (parameters['colorRed'] != null ||
        parameters['colorGreen'] != null ||
        parameters['colorBlue'] != null) {
      final colorRed = parseDouble(parameters['colorRed']).toInt();
      final colorGreen = parseDouble(parameters['colorGreen']).toInt();
      final colorBlue = parseDouble(parameters['colorBlue']).toInt();
      color = Color.fromARGB(255, colorRed, colorGreen, colorBlue);
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
  }

  //================//
  // Function Calls //
  //   Seleccionar  //
  //   Modificar    //
  //   Eliminar     //
  //================//

  void _processSelectDrawables(Map<String, dynamic> arguments) {
    if (drawables.isEmpty) return;
    
    final bool add = arguments['add'] == true;
    final bool invert = arguments['invert'] == true;
    
    Set<String> toSelect = {};
    
    // Select by type
    if (arguments['type'] != null) {
      final type = arguments['type'].toString().toLowerCase();
      for (var i = 0; i < drawables.length; i++) {
        final d = drawables[i];
        bool matches = false;
        if (type == 'circle' && d is Circle) matches = true;
        if (type == 'line' && d is Line) matches = true;
        if (type == 'rectangle' && d is Rectangle) matches = true;
        if (type == 'text' && d is TextElement) matches = true;
        if (matches) toSelect.add(d.id);
      }
    }
    
    // Select by color
    if (arguments['colorRed'] != null || 
        arguments['colorGreen'] != null ||
        arguments['colorBlue'] != null) {
      final targetColor = Color.fromARGB(
        255,
        parseDouble(arguments['colorRed']).toInt(),
        parseDouble(arguments['colorGreen']).toInt(),
        parseDouble(arguments['colorBlue']).toInt(),
      );
      toSelect.addAll(
        drawables.where((d) => d.color.toARGB32() == targetColor.toARGB32()).map((d) => d.id)
      );
    }
    
    // If no criteria, select all
    if (toSelect.isEmpty) {
      toSelect.addAll(drawables.map((d) => d.id));
    }
    
    if (invert) {
      final allIds = drawables.map((d) => d.id).toSet();
      toSelect = allIds.difference(toSelect);
    }
    
    if (!add) {
      selectionManager.clearSelection();
    }
    
    for (var id in toSelect) {
      selectionManager.select(id, multiSelect: true);
    }
    
    _responseText += "\nSelected ${toSelect.length} drawable(s).";
    notifyListeners();
  }
  
  void _processDeleteSelected() {
    final selected = selectionManager.getSelectedDrawables(drawables);
    drawables.removeWhere((d) => selectionManager.isSelected(d.id));
    selectionManager.clearSelection();
    _responseText += "\nDeleted ${selected.length} drawable(s).";
    notifyListeners();
  }
  
  void _processDeleteDrawables(Map<String, dynamic> arguments) {
    Set<String> toDelete = {};
    
    if (arguments['type'] != null) {
      final type = arguments['type'].toString().toLowerCase();
      for (var i = 0; i < drawables.length; i++) {
        final d = drawables[i];
        bool matches = false;
        if (type == 'circle' && d is Circle) matches = true;
        if (type == 'line' && d is Line) matches = true;
        if (type == 'rectangle' && d is Rectangle) matches = true;
        if (type == 'text' && d is TextElement) matches = true;
        if (matches) toDelete.add(d.id);
      }
    }
    
    if (arguments['colorRed'] != null && arguments['colorGreen'] != null && arguments['colorBlue'] != null) {
      final targetColor = Color.fromARGB(
        255,
        parseDouble(arguments['colorRed']).toInt(),
        parseDouble(arguments['colorGreen']).toInt(),
        parseDouble(arguments['colorBlue']).toInt(),
      );
      toDelete.addAll(
        drawables.where((d) => d.color.toARGB32() == targetColor.toARGB32()).map((d) => d.id)
      );
    }
    
    drawables.removeWhere((d) => toDelete.contains(d.id));
    selectionManager.clearSelection();
    _responseText += "\nDeleted ${toDelete.length} drawable(s).";
    notifyListeners();
  }
  

// Mètode auxiliar per convertir percentatges a píxels absoluts
  double resolvePositionValue(dynamic value, double canvasDimension, {bool isX = true}) {
    if (value is String) {
      // Percentatges
      if (value.endsWith('%')) {
        final percentage = double.tryParse(value.replaceAll('%', '')) ?? 0;
        return canvasDimension * percentage / 100;
      }

      // Intentar parsejar com un número
      return double.tryParse(value) ?? 0;
    }
    
    if (value is num) {
      return value.toDouble();
    }
    
    // Valor de fallback
    return 0;
  }

  void _processModifySelected(Map<String, dynamic> arguments) {
    if (_canvasSize == null) {
      _responseText += "\nCanvas size not available for relative positioning.";
    }
    
    final selected = selectionManager.getSelectedDrawables(drawables);
    if (selected.isEmpty) {
      _responseText += "\nNo drawables selected to modify.";
      return;
    }
    
    for (var drawable in selected) {
      // Color
      if (arguments['colorRed'] != null && arguments['colorGreen'] != null && arguments['colorBlue'] != null) {
        drawable.color = Color.fromARGB(
          255,
          parseDouble(arguments['colorRed']).toInt(),
          parseDouble(arguments['colorGreen']).toInt(),
          parseDouble(arguments['colorBlue']).toInt(),
        );
      }
      
      // Moviment
      if (arguments['moveX'] != null || arguments['moveY'] != null) {
        double deltaX = 0, deltaY = 0;
        
        if (arguments['moveX'] != null && _canvasSize != null) {
          deltaX = resolvePositionValue(arguments['moveX'], _canvasSize!.width);
        }
        if (arguments['moveY'] != null && _canvasSize != null) {
          deltaY = resolvePositionValue(arguments['moveY'], _canvasSize!.height);
        }
        
        drawable.updatePosition(Offset(deltaX, deltaY), false);
      }
      
      // Posicionament absolut
      if (arguments['setX'] != null || arguments['setY'] != null) {
        double newX = 0, newY = 0;
        
        if (arguments['setX'] != null && _canvasSize != null) {
          newX = resolvePositionValue(arguments['setX'], _canvasSize!.width);
        }
        if (arguments['setY'] != null && _canvasSize != null) {
          newY = resolvePositionValue(arguments['setY'], _canvasSize!.height);
        }
        drawable.updatePosition(Offset(newX, newY), true);
      }
      
      // Propietats específiques de cada tipus de Drawable
      if (drawable is Line) {
        if (arguments['strokeWidth'] != null) {
          drawable.strokeWidth = parseDouble(arguments['strokeWidth']);
        }
      }

      if (drawable is Circle) {
        if (arguments['radius'] != null) {
          drawable.radius = max(0.0, parseDouble(arguments['radius']));
        }
        if (arguments['fill'] != null) {
          drawable.style = arguments['fill'] ? PaintingStyle.fill : PaintingStyle.stroke;
        }
        if (arguments['strokeWidth'] != null) {
          drawable.strokeWidth = parseDouble(arguments['strokeWidth']);
        }
      }
      
      if (drawable is Rectangle) {
        if (arguments['fill'] != null) {
          drawable.style = arguments['fill'] ? PaintingStyle.fill : PaintingStyle.stroke;
        }
        if (arguments['strokeWidth'] != null) {
          drawable.strokeWidth = parseDouble(arguments['strokeWidth']);
        }
      }
      
      if (drawable is TextElement) {
        if (arguments['fontSize'] != null) {
          drawable.fontSize = parseDouble(arguments['fontSize']);
        }
        if (arguments['bold'] != null) {
          drawable.fontWeight = arguments['bold'] ? FontWeight.bold : FontWeight.normal;
        }
        if (arguments['italic'] != null) {
          drawable.fontStyle = arguments['italic'] ? FontStyle.italic : FontStyle.normal;
        }
        if (arguments['text'] != null) {
          drawable.text = arguments['text'].toString();
        }
      }
    }
    
    _responseText += "\nModified ${selected.length} drawable(s).";
    notifyListeners();
  }


  void _processGetCanvasInfo() {
    if (_canvasSize == null) {
      _responseText += "\nCanvas size not available.";
      return;
    }
    
    final info = {
      'canvas_width': _canvasSize!.width,
      'canvas_height': _canvasSize!.height,
      'drawable_count': drawables.length,
      'selected_count': selectionManager.getSelectedDrawables(drawables).length,
      'drawables_by_type': {
        'circles': drawables.whereType<Circle>().length,
        'lines': drawables.whereType<Line>().length,
        'rectangles': drawables.whereType<Rectangle>().length,
        'texts': drawables.whereType<TextElement>().length,
      }
    };
    
    _responseText += "\nCanvas Info: ${jsonEncode(info)}";
    notifyListeners();
  }

}
