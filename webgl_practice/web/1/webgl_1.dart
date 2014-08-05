 /*
  * written by peter (shader coder)
  * 
*/
library wgl1;

import "dart:html";
import "package:vector_math/vector_math.dart";
import "dart:web_gl" as wgl;
import "dart:typed_data";  

CanvasElement glCanvas;

// viewport resolution 
int vpWidth = 0;
int vpHeight = 0;
wgl.RenderingContext _gl;

wgl.Buffer triVertexBuffer;
wgl.Buffer quadVertexBuffer;
wgl.Program shaderProgram;
int positionLoc = -1;
wgl.UniformLocation mvMatrixLoc;
wgl.UniformLocation projMatrixLoc;

Matrix4 projMatrix;
Matrix4 mvMatrix;

void init()
{
  glCanvas = querySelector("#drawArea");
  
  vpWidth = glCanvas.width;
  vpHeight = glCanvas.height;
  
  _gl = glCanvas.getContext("experimental-webgl");
  
  createVertexBuffer();
  
  createShader();
  
  _gl.enable(wgl.RenderingContext.DEPTH_TEST);
 
}

void createVertexBuffer()
{
  // create triangle & quad vertex buffr
  triVertexBuffer = _gl.createBuffer();
  
  quadVertexBuffer = _gl.createBuffer();
  
  
  // filling triangle data to vertex buffer
  List<double> vertices;
  _gl.bindBuffer(wgl.RenderingContext.ARRAY_BUFFER, triVertexBuffer);
  
  // real vertex data (include only position)
  vertices =
  [
   0.0, 1.0, 0.0,
   -1.0,-1.0, 0.0,
   1.0, -1.0, 0.0
  ];
  
  // fill data to allocated buffer in gpu memory.
  _gl.bufferDataTyped(wgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), wgl.RenderingContext.STATIC_DRAW);
  
  
}


void createShader()
{
  wgl.Shader vertexShader = _gl.createShader(wgl.RenderingContext.VERTEX_SHADER);
  wgl.Shader fragmentShader = _gl.createShader(wgl.RenderingContext.FRAGMENT_SHADER);
  
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
  
  _gl.shaderSource(vertexShader, vs);
  _gl.compileShader(vertexShader);
  
  _gl.shaderSource(fragmentShader, ps);
  _gl.compileShader(fragmentShader);
  
  // create program
  shaderProgram = _gl.createProgram();
  _gl.attachShader(shaderProgram, vertexShader);
  _gl.attachShader(shaderProgram, fragmentShader);
  _gl.linkProgram(shaderProgram);
 
  
  // check compile & link status
  
  if(!_gl.getShaderParameter(vertexShader, wgl.RenderingContext.COMPILE_STATUS));
  {
    print(_gl.getShaderInfoLog(vertexShader));
  }
  
  if(!_gl.getShaderParameter(fragmentShader, wgl.RenderingContext.COMPILE_STATUS));
  {
    print(_gl.getShaderInfoLog(fragmentShader));
  }
  
  if(!_gl.getProgramParameter(shaderProgram,wgl.RenderingContext.LINK_STATUS))
  {
    print(_gl.getProgramInfoLog(shaderProgram));
  }
  
  positionLoc = _gl.getAttribLocation(shaderProgram, "position");
  
  _gl.enableVertexAttribArray(positionLoc);
  
  mvMatrixLoc = _gl.getUniformLocation(shaderProgram, "mvMatrix");
  projMatrixLoc = _gl.getUniformLocation(shaderProgram, "projMatrix");
  
}

void render()
{
  _gl.viewport(0, 0, vpWidth, vpHeight);
  _gl.clearColor(0, 0, 0, 255);
  _gl.clear(wgl.RenderingContext.COLOR_BUFFER_BIT | wgl.RenderingContext.DEPTH_BUFFER_BIT);
  
  _gl.useProgram(shaderProgram);
  // projection matrix
  projMatrix = makePerspectiveMatrix(radians(45.0), vpWidth / vpHeight, 0.01, 1000.0);
  
  // model view matrix
  mvMatrix = new Matrix4.identity();
  mvMatrix.translate(new Vector3(0.0, 1.0, -5.0));
  
  // bind buffer & set vertex attribute
  _gl.bindBuffer(wgl.RenderingContext.ARRAY_BUFFER, triVertexBuffer);
  _gl.vertexAttribPointer(positionLoc, 3, wgl.RenderingContext.FLOAT, false, 0, 0);
  
  
  Float32List matrixArray = new Float32List(16);
  projMatrix.copyIntoArray(matrixArray); 
  _gl.uniformMatrix4fv(projMatrixLoc, false, matrixArray);
  
  mvMatrix.copyIntoArray(matrixArray);
  _gl.uniformMatrix4fv(mvMatrixLoc, false, matrixArray);
  
  
  _gl.drawArrays(wgl.RenderingContext.TRIANGLES, 0, 3);
  
  
}
void main()
{
  init();
  
  render();
}

