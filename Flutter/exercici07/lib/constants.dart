// Defineix les eines/funcions que hi ha disponibles a flutter
const tools = [
  {
    "type": "function",
    "function": {
      "name": "draw_circle",
      "description":
          """Draw a circle with a certain radius.
          Specify optional properties (width, color, fill) if and ONLY if prompted.
          Don't specify any others as null. Simply don't include them at all.""",
      "parameters": {
        "type": "object",
        "properties": {
          "x": {"type": "number"},
          "y": {"type": "number"},
          "radius": {"type": "number"},
          "strokeWidth": {"type": "number"},
          "colorRed": {"type": "number", "minimum": 0, "maximum": 255},
          "colorGreen": {"type": "number", "minimum": 0, "maximum": 255},
          "colorBlue": {"type": "number", "minimum": 0, "maximum": 255},
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
          Specify optional properties (width and color) if and ONLY if prompted. 
          Don't specify any others as null. Simply don't include them at all.""",
      "parameters": {
        "type": "object",
        "properties": {
          "startX": {"type": "number"},
          "startY": {"type": "number"},
          "endX": {"type": "number"},
          "endY": {"type": "number"},
          "strokeWidth": {"type": "number"},
          "colorRed": {"type": "number", "minimum": 0, "maximum": 255},
          "colorGreen": {"type": "number", "minimum": 0, "maximum": 255},
          "colorBlue": {"type": "number", "minimum": 0, "maximum": 255},
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
          Specify optional properties (width, color, fill) if and ONLY if prompted. 
          Don't specify any others as null. Simply don't include them at all.""",
      "parameters": {
        "type": "object",
        "properties": {
          "topLeftX": {"type": "number"},
          "topLeftY": {"type": "number"},
          "bottomRightX": {"type": "number"},
          "bottomRightY": {"type": "number"},
          "strokeWidth": {"type": "number"},
          "colorRed": {"type": "number", "minimum": 0, "maximum": 255},
          "colorGreen": {"type": "number", "minimum": 0, "maximum": 255},
          "colorBlue": {"type": "number", "minimum": 0, "maximum": 255},
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
          Specify optional properties (size, color, bold, italic, fontFamily) if and ONLY if prompted. 
          Don't specify any others as null. Simply don't include them at all.""",
      "parameters": {
        "type": "object",
        "properties": {
          "text": {"type": "string"},
          "x": {"type": "number"},
          "y": {"type": "number"},
          "colorRed": {"type": "number", "minimum": 0, "maximum": 255},
          "colorGreen": {"type": "number", "minimum": 0, "maximum": 255},
          "colorBlue": {"type": "number", "minimum": 0, "maximum": 255},
          "fontSize": {"type": "number"},
          "bold": {"type": "boolean"},
          "italic": {"type": "boolean"},
          "fontFamily": {"type": "string"}
        },
        "required": ["text", "positionX", "positionY"]
      }
    }
  },
    {
    "type": "function",
    "function": {
      "name": "select_drawables",
      "description": """Select drawables by various criteria.
      You can select by type or color.
      When selecting by color, specify ALL 3 RGB color values, including values at 0.
      If no criteria specified, selects all drawables.
      Use "invert": true to select every drawable EXCEPT for ones with certain criteria.
      Use "add": true to add to current selection instead of replacing.""",
      "parameters": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "enum": ["circle", "line", "rectangle", "text"],
            "description": "Select all drawables of this type"
          },
          "colorRed": {"type": "number", "minimum": 0, "maximum": 255},
          "colorGreen": {"type": "number", "minimum": 0, "maximum": 255},
          "colorBlue": {"type": "number", "minimum": 0, "maximum": 255},
          "radius": {"type": "number"},
          "invert": {"type": "boolean"},
          "add": {"type": "boolean"}
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "delete_selected",
      "description": "Delete all currently selected drawables.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "delete_drawables",
      "description": "Delete specific drawables by criteria (type or color).",
      "parameters": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "enum": ["circle", "line", "rectangle", "text"],
            "description": "Delete all drawables of this type"
          },
          "colorRed": {"type": "number", "minimum": 0, "maximum": 255},
          "colorGreen": {"type": "number", "minimum": 0, "maximum": 255},
          "colorBlue": {"type": "number", "minimum": 0, "maximum": 255}
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "modify_selected",
      "description": """Modify properties of all currently selected drawables.
      Specify properties if and ONLY if they are to be changed. Don't specify any others as null. Simply don't include them at all.
      When modifying color, specify ALL 3 RGB color values, including values at 0.
      Interpret words like "middle" (50%), "center" (50%), "top" (0% Y), "bottom" (100% Y), "left" (0% X), "right" (100% X).
      "diagonal" refers to a line from (0%,0%) to (100%,100%).""",
      "parameters": {
        "type": "object",
        "properties": {
          "colorRed": {"type": "number", "minimum": 0, "maximum": 255},
          "colorGreen": {"type": "number", "minimum": 0, "maximum": 255},
          "colorBlue": {"type": "number", "minimum": 0, "maximum": 255},
          "strokeWidth": {"type": "number"},
          "fill": {"type": "boolean"},
          "moveX": {
            "type": "number",
            "description": "Move horizontally. Can be absolute pixels or percentage (e.g., 10 or '10%')"
          },
          "moveY": {
            "type": "number", 
            "description": "Move vertically. Can be absolute pixels or percentage"
          },
          "setX": {
            "type": "number",
            "description": "Set absolute X position. Can be absolute pixels or percentage"
          },
          "setY": {
            "type": "number",
            "description": "Set absolute Y position. Can be absolute pixels or percentage"
          },
          "radius": {"type": "number"},
          "fontSize": {"type": "number"},
          "bold": {"type": "boolean"},
          "italic": {"type": "boolean"},
          "text": {"type": "string"}
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "clear_selection",
      "description": "De-select any drawable currently selected.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "get_canvas_info",
      "description": "Get information about the canvas size and current drawables. Useful for percentage-based positioning.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    }
  }
];
