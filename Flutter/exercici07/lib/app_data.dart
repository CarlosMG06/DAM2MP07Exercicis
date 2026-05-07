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
  final StringBuffer _responseBuffer = StringBuffer();  // Optimización

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
    _responseBuffer.clear();  // Limpiar antes de nueva llamada
    _responseText = "";

    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.body =
          jsonEncode({'model': 'llama3.2:3b', 'prompt': question, 'stream': true});

      var streamedResponse = await _client!.send(request);
      int chunkCount = 0;
      _streamSubscription =
          streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var jsonResponse = jsonDecode(value);
        var jsonResponseStr = jsonResponse['response'];
        _responseBuffer.write(jsonResponseStr);
        
        // Actualizar UI cada 10 chunks para no sobrecargar
        chunkCount++;
        if (chunkCount % 10 == 0) {
          _responseText = _responseBuffer.toString();
          notifyListeners();
        }
      }, onError: (error) {
        if (error is http.ClientException &&
            error.message == 'Connection closed while receiving data') {
          _responseBuffer.write("\nRequest cancelled.");
        } else {
          _responseBuffer.write("\nError during streaming: $error");
        }
        _responseText = _responseBuffer.toString();
        setLoading(false);
        notifyListeners();
      }, onDone: () {
        // Actualizar con la respuesta final completa
        _responseText = _responseBuffer.toString();
        setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _responseBuffer.write("\nError during streaming.");
      _responseText = _responseBuffer.toString();
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
    _responseBuffer.clear();
    _responseText = "";

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
    _responseBuffer.write("\nRequest cancelled.");
    _responseText = _responseBuffer.toString();
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

  // Safe color extraction that handles null values
  Color extractColor(dynamic parameters) {
    final red = parseDouble(parameters['colorRed'] ?? parameters['r'] ?? 0).toInt().clamp(0, 255);
    final green = parseDouble(parameters['colorGreen'] ?? parameters['g'] ?? 0).toInt().clamp(0, 255);
    final blue = parseDouble(parameters['colorBlue'] ?? parameters['b'] ?? 0).toInt().clamp(0, 255);
    
    if (red != 0 || green != 0 || blue != 0) {
      return Color.fromARGB(255, red, green, blue);
    }
    return Colors.black; // default
  }

  void _processFunctionCall(Map<String, dynamic> functionCall) {
    final fixedJson = fixJsonInStrings(functionCall);
    final parameters = fixedJson['arguments'];

    String name = fixedJson['name'];
    String infoText = "$name: $parameters";

    print(infoText);
    _responseBuffer.write("\n$infoText");

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
    final dx = parseDouble(parameters['x'] ?? 0);
    final dy = parseDouble(parameters['y'] ?? 0);
    
    double radius = parseDouble(parameters['radius'] ?? 10.0);
    double strokeWidth = parseDouble(parameters['strokeWidth'] ?? 2.0);
    Color color = extractColor(parameters);
    
    PaintingStyle style = PaintingStyle.stroke;
    if (parameters['fill'] == true) {
      style = PaintingStyle.fill;
    }

    addDrawable(Circle(
      center: Offset(dx, dy), radius: radius, 
      strokeWidth: strokeWidth, color: color, style: style
    ));
  }

  void _processDrawLine(dynamic parameters) {
    final startX = parseDouble(parameters['startX'] ?? 0);
    final startY = parseDouble(parameters['startY'] ?? 0);
    final endX = parseDouble(parameters['endX'] ?? 100);
    final endY = parseDouble(parameters['endY'] ?? 100);
    final start = Offset(startX, startY);
    final end = Offset(endX, endY);

    Color color = extractColor(parameters);
    double strokeWidth = parseDouble(parameters['strokeWidth'] ?? 2.0);

    addDrawable(Line(
      start: start, end: end, 
      color: color, strokeWidth: strokeWidth
    ));
  }

  void _processDrawRectangle(dynamic parameters) {
    final topLeftX = parseDouble(parameters['topLeftX'] ?? 0);
    final topLeftY = parseDouble(parameters['topLeftY'] ?? 0);
    final bottomRightX = parseDouble(parameters['bottomRightX'] ?? 100);
    final bottomRightY = parseDouble(parameters['bottomRightY'] ?? 100);
    final topLeft = Offset(topLeftX, topLeftY);
    final bottomRight = Offset(bottomRightX, bottomRightY);

    double strokeWidth = parseDouble(parameters['strokeWidth'] ?? 2.0);
    Color color = extractColor(parameters);
    
    PaintingStyle style = PaintingStyle.stroke;
    if (parameters['fill'] == true) {
      style = PaintingStyle.fill;
    }

    addDrawable(Rectangle(
      topLeft: topLeft, bottomRight: bottomRight,
      strokeWidth: strokeWidth, color: color, style: style
    ));
  }

  void _processDrawText(dynamic parameters) {
    final text = parameters['text'] ?? 'Text';
    // Accept both 'x'/'y' and 'positionX'/'positionY' for flexibility
    final positionX = parseDouble(parameters['positionX'] ?? parameters['x'] ?? 0);
    final positionY = parseDouble(parameters['positionY'] ?? parameters['y'] ?? 0);
    final position = Offset(positionX, positionY);

    Color color = extractColor(parameters);
    double fontSize = parseDouble(parameters['fontSize'] ?? 14.0);
    
    FontWeight fontWeight = (parameters['bold'] == true) ? FontWeight.bold : FontWeight.normal;
    FontStyle fontStyle = (parameters['italic'] == true) ? FontStyle.italic : FontStyle.normal;
    String? fontFamily = (parameters['fontFamily'] != null) ? parameters['fontFamily'].toString() : null;
    
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
    
    // Select by color - only if at least one color component is provided
    if (arguments['colorRed'] != null || 
        arguments['colorGreen'] != null ||
        arguments['colorBlue'] != null) {
      final targetColor = extractColor(arguments);
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
    
    _responseBuffer.write("\nSelected ${toSelect.length} drawable(s).");
    _responseText = _responseBuffer.toString();
    notifyListeners();
  }
  
  void _processDeleteSelected() {
    final selected = selectionManager.getSelectedDrawables(drawables);
    drawables.removeWhere((d) => selectionManager.isSelected(d.id));
    selectionManager.clearSelection();
    _responseBuffer.write("\nDeleted ${selected.length} drawable(s).");
    _responseText = _responseBuffer.toString();
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
    
    // Delete by color - only if at least one color component is provided
    if (arguments['colorRed'] != null || arguments['colorGreen'] != null || arguments['colorBlue'] != null) {
      final targetColor = extractColor(arguments);
      toDelete.addAll(
        drawables.where((d) => d.color.toARGB32() == targetColor.toARGB32()).map((d) => d.id)
      );
    }
    
    drawables.removeWhere((d) => toDelete.contains(d.id));
    selectionManager.clearSelection();
    _responseBuffer.write("\nDeleted ${toDelete.length} drawable(s).");
    _responseText = _responseBuffer.toString();
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
      _responseBuffer.write("\nCanvas size not available for relative positioning.");
    }
    
    final selected = selectionManager.getSelectedDrawables(drawables);
    if (selected.isEmpty) {
      _responseBuffer.write("\nNo drawables selected to modify.");
      return;
    }
    
    for (var drawable in selected) {
      // Color - handle null gracefully
      if (arguments['colorRed'] != null || arguments['colorGreen'] != null || arguments['colorBlue'] != null) {
        drawable.color = extractColor(arguments);
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
        if (arguments['fill'] == true) {
          drawable.style = PaintingStyle.fill;
        }
        if (arguments['strokeWidth'] != null) {
          drawable.strokeWidth = parseDouble(arguments['strokeWidth']);
        }
      }
      
      if (drawable is Rectangle) {
        if (arguments['fill'] == true) {
          drawable.style = PaintingStyle.fill;
        }
        if (arguments['strokeWidth'] != null) {
          drawable.strokeWidth = parseDouble(arguments['strokeWidth']);
        }
      }
      
      if (drawable is TextElement) {
        if (arguments['fontSize'] != null) {
          drawable.fontSize = parseDouble(arguments['fontSize']);
        }
        if (arguments['bold'] == true) {
          drawable.fontWeight = FontWeight.bold;
        }
        if (arguments['italic'] == true) {
          drawable.fontStyle = FontStyle.italic;
        }
        if (arguments['text'] != null) {
          drawable.text = arguments['text'].toString();
        }
      }
    }
    
    _responseBuffer.write("\nModified ${selected.length} drawable(s).");
    _responseText = _responseBuffer.toString();
    notifyListeners();
  }


  void _processGetCanvasInfo() {
    if (_canvasSize == null) {
      _responseBuffer.write("\nCanvas size not available.");
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
    
    _responseBuffer.write("\nCanvas Info: ${jsonEncode(info)}");
    _responseText = _responseBuffer.toString();
    notifyListeners();
  }

}
