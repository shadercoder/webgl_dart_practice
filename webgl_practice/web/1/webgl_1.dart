 /*
  * written by peter (shader coder)
  * 
*/


import "dart:html";
import "package:vector_math/vector_math.dart";
import "dart:web_gl" as WebGL;
import "dart:typed_data";  

CanvasElement glCanvas;

// viewport resolution 
int vpWidth = 0;
int vpHeight = 0;
WebGL.RenderingContext _glContext;

WebGL.Buffer triVertexBuffer;
WebGL.Buffer quadVertexBuffer;

void init()
{
  glCanvas = querySelector("#drawArea");
  
  vpWidth = glCanvas.width;
  vpHeight = glCanvas.height;
  
  _glContext = glCanvas.getContext("experimental-webgl");
  
  
  
  
  
  
}

void createVetexBuffer()
{
  // create triangle & quad vertex buffr
  triVertexBuffer = _glContext.createBuffer();
  
  quadVertexBuffer = _glContext.createBuffer();
  
  
  // filling triangle data to vertex buffer
  List<double> vertices;
  _glContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, triVertexBuffer);
  
  // real vertex data (include only position)
  vertices =
  [
   0.0, 1.0, 0.0,
   -1.0,-1.0, 0.0,
   1.0, -1.0, 0.0
  ];
  
  // fill data to allocated buffer in gpu memory.
  _glContext.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), WebGL.RenderingContext.STATIC_DRAW);
  
  
}


void createShader()
{
  WebGL.Shader vertexShader = _glContext.createShader(WebGL.RenderingContext.VERTEX_SHADER);
  WebGL.Shader fragmentShader = _glContext.createShader(WebGL.RenderingContext.FRAGMENT_SHADER);
  
  // vertex shader source..
  String vs = """
  attribute vec3 position;
  
  uniform mat4 mvMatrix;
  uniform mat4 projMatrix;
  
  void main()
  { 
      gl_position = projMatrix * mvMatrix * vec4(position, 1.0);
  }

  """;
  
  String ps = """
  precision mediump float;
  
  void main()
  {
     gl_FragColor = vec4(1.0, 1.0, 0.0, 0.0);
  }
  """;
  
  
  // compile shaders
  
  _glContext.shaderSource(vertexShader, vs);
  _glContext.compileShader(vertexShader);
  
  _glContext.shaderSource(fragmentShader, ps);
  _glContext.compileShader(fragmentShader);
  
  
}
void main()
{
  init();
}

