 /*
  * written by peter (shader coder)
  * 
*/
library webgl1;

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
WebGL.Program shaderProgram;
int positionLoc = -1;
WebGL.UniformLocation mvMatrixLoc;
WebGL.UniformLocation projMatrixLoc;

Matrix4 projMatrix;
Matrix4 mvMatrix;

void init()
{
  glCanvas = querySelector("#drawArea");
  
  vpWidth = glCanvas.width;
  vpHeight = glCanvas.height;
  
  _glContext = glCanvas.getContext("experimental-webgl");
  
  createVertexBuffer();
  
  createShader();
  
  _glContext.enable(WebGL.RenderingContext.DEPTH_TEST);
 
}

void createVertexBuffer()
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
      gl_Position = projMatrix * mvMatrix * vec4(position, 1.0);
  }

  """;
  
  String ps = """
  precision mediump float;
  
  void main()
  {
     gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  }
  """;
  
  
  // compile shaders
  
  _glContext.shaderSource(vertexShader, vs);
  _glContext.compileShader(vertexShader);
  
  _glContext.shaderSource(fragmentShader, ps);
  _glContext.compileShader(fragmentShader);
  
  // create program
  shaderProgram = _glContext.createProgram();
  _glContext.attachShader(shaderProgram, vertexShader);
  _glContext.attachShader(shaderProgram, fragmentShader);
  _glContext.linkProgram(shaderProgram);
  _glContext.useProgram(shaderProgram);
  
  // check compile & link status
  
  if(!_glContext.getShaderParameter(vertexShader, WebGL.RenderingContext.COMPILE_STATUS));
  {
    print(_glContext.getShaderInfoLog(vertexShader));
  }
  
  if(!_glContext.getShaderParameter(fragmentShader, WebGL.RenderingContext.COMPILE_STATUS));
  {
    print(_glContext.getShaderInfoLog(fragmentShader));
  }
  
  if(!_glContext.getProgramParameter(shaderProgram,WebGL.RenderingContext.LINK_STATUS))
  {
    print(_glContext.getProgramInfoLog(shaderProgram));
  }
  
  positionLoc = _glContext.getAttribLocation(shaderProgram, "position");
  
  _glContext.enableVertexAttribArray(positionLoc);
  
  mvMatrixLoc = _glContext.getUniformLocation(shaderProgram, "mvMatrix");
  projMatrixLoc = _glContext.getUniformLocation(shaderProgram, "projMatrix");
  
}

void render()
{
  _glContext.viewport(0, 0, vpWidth, vpHeight);
  _glContext.clearColor(0, 0, 0, 255);
  _glContext.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT | WebGL.RenderingContext.DEPTH_BUFFER_BIT);
  
  
  // projection matrix
  projMatrix = makePerspectiveMatrix(radians(45.0), vpWidth / vpHeight, 0.01, 1000.0);
  
  // model view matrix
  mvMatrix = new Matrix4.identity();
  mvMatrix.translate(new Vector3(0.0, 1.0, -5.0));
  
  // bind buffer & set vertex attribute
  _glContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, triVertexBuffer);
  _glContext.vertexAttribPointer(positionLoc, 3, WebGL.RenderingContext.FLOAT, false, 0, 0);
  
  
  Float32List matrixArray = new Float32List(16);
  projMatrix.copyIntoArray(matrixArray); 
  _glContext.uniformMatrix4fv(projMatrixLoc, false, matrixArray);
  
  mvMatrix.copyIntoArray(matrixArray);
  _glContext.uniformMatrix4fv(mvMatrixLoc, false, matrixArray);
  
  
  _glContext.drawArrays(WebGL.RenderingContext.TRIANGLES, 0, 3);
  
  
}
void main()
{
  init();
  
  render();
}

