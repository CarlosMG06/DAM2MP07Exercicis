// Defineix les eines/funcions que hi ha disponibles a flutter
const tools = [
  {
    "type": "function",
    "function": {
      "name": "draw_circle",
      "description":
          """Draw a circle with a certain radius.
          If the radius is missing, use 10 as a default. If the radius must be random, use a random number between 10 and 25.
          Only specify width and color when prompted. Give color in RGB (3 values (R, G and B) between 0 and 255), specifying all 3 color values, including values at 0.
          If the circle must be filled in, fill = 'true'. Otherwise, fill = 'false'.""",
      "parameters": {
        "type": "object",
        "properties": {
          "x": {"type": "number"},
          "y": {"type": "number"},
          "radius": {"type": "number"},
          "strokeWidth": {"type": "number"},
          "colorR": {"type": "number"},
          "colorG": {"type": "number"},
          "colorB": {"type": "number"},
          "fill": {"type": "boolean"}
        },
        "required": ["x", "y", "radius"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_line",
      "description":
          """Draw a line between two points. If position is unspecified, choose two random points between x=10, y=10 and x=100, y=100.
          Only specify width and color when prompted. Give color in RGB (3 values (R, G and B) between 0 and 255), specifying all 3 color values, including values at 0.""",
      "parameters": {
        "type": "object",
        "properties": {
          "startX": {"type": "number"},
          "startY": {"type": "number"},
          "endX": {"type": "number"},
          "endY": {"type": "number"},
          "strokeWidth": {"type": "number"},
          "colorR": {"type": "number"},
          "colorG": {"type": "number"},
          "colorB": {"type": "number"},
        },
        "required": ["startX", "startY", "endX", "endY"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_rectangle",
      "description":
          """Draw a rectangle defined by the top-left and bottom-right points. 
          Only specify width and color when prompted. Give color in RGB (3 values (R, G and B) between 0 and 255), specifying all 3 color values, including values at 0.
          If the rectangle must be filled in, fill = 'true'. Otherwise, fill = 'false'.""",
      "parameters": {
        "type": "object",
        "properties": {
          "topLeftX": {"type": "number"},
          "topLeftY": {"type": "number"},
          "bottomRightX": {"type": "number"},
          "bottomRightY": {"type": "number"},
          "strokeWidth": {"type": "number"},
          "colorR": {"type": "number"},
          "colorG": {"type": "number"},
          "colorB": {"type": "number"},
          "fill": {"type": "boolean"}
        },
        "required": ["topLeftX", "topLeftY", "bottomRightX", "bottomRightY"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_text",
      "description":
          """Draw text at a certain position.
          Only specify size and color when prompted. Give color in RGB (3 values (R, G and B) between 0 and 255), specifying all 3 color values, including values at 0.
          Only specify bold, italic and the font family when prompted.""",
      "parameters": {
        "type": "object",
        "properties": {
          "text": {"type": "string"},
          "positionX": {"type": "number"},
          "positionY": {"type": "number"},
          "colorR": {"type": "number"},
          "colorG": {"type": "number"},
          "colorB": {"type": "number"},
          "fontSize": {"type": "number"},
          "bold": {"type": "boolean"},
          "italic": {"type": "boolean"},
          "fontFamily": {"type": "string"}
        },
        "required": ["text", "positionX", "positionY"]
      }
    }
  }
];
