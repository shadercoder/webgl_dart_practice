library wgl2;


import "dart:html";
import "package:vector_math/vector_math.dart";
import "dart:web_gl" as wgl;
import "dart:typed_data";  
import "dart:math";


CanvasElement glCanvas;
wgl.RenderingContext _gl;
int vpWidth;
int vpHeight;

// vertex data buffer
wgl.Buffer posBuffer;
wgl.Buffer normalBuffer;
wgl.Buffer texcoordBuffer;

// index buffer
wgl.Buffer indexBuffer;

wgl.Program shaderProgram;

int positionLoc;

// uniforms
wgl.UniformLocation worldMatrixLoc;
wgl.UniformLocation cameraMatrixLoc;
wgl.UniformLocation projectionMatrixLoc;
void init()
{
  glCanvas = document.querySelector("#drawArea");
  vpWidth = glCanvas.width;
  vpHeight = glCanvas.height;
  
  _gl = glCanvas.getContext("experimental-webgl");
  _gl.enable(wgl.RenderingContext.DEPTH_TEST);
  
  _initVertexBuffer();
  
  
}

void _initVertexBuffer()
{
   posBuffer = _gl.createBuffer();
   
   normalBuffer = _gl.createBuffer();
   
   texcoordBuffer = _gl.createBuffer();
   
   indexBuffer = _gl.createBuffer();
   
   List<double> positions;
   List<double> normals;
   List<double> texcoords;
   List<int> indices;
   
   
   // fill cube vertex position
   
   _gl.bindBuffer(wgl.RenderingContext.ARRAY_BUFFER, posBuffer);
   
   // all vertex defined in counter-clock wise order
   positions = 
   [
    // front
    -1.0,  -1.0, 1.0,    // index 0
     1.0,  -1.0, 1.0,    // index 1
     1.0,   1.0, 1.0,    // index 2
    -1.0,   1.0, 1.0,    // index 3
     
    // back
    -1.0, -1.0, -1.0,    // index 4
    -1.0,  1.0, -1.0,    // index 5
     1.0,  1.0, -1.0,    // index 6
     1.0, -1.0, -1.0,    // index 7
    
    // top
    -1.0,  1.0, -1.0,    // index 8
    -1.0,  1.0,  1.0,    // index 9
     1.0,  1.0,  1.0,    // index 10
     1.0,  1.0, -1.0,    // index 11
    
    // bottom
    -1.0, -1.0, -1.0,    // index 12
     1.0, -1.0, -1.0,    // index 13
     1.0, -1.0,  1.0,    // index 14
    -1.0, -1.0,  1.0,    // index 15

    
    // right
     1.0, -1.0, -1.0,    // index 16
     1.0,  1.0, -1.0,    // index 17
     1.0,  1.0,  1.0,    // index 18
     1.0, -1.0,  1.0,    // index 19
    
    // left
     -1.0, -1.0, -1.0,   // index 20
     -1.0, -1.0,  1.0,   // index 21
     -1.0,  1.0,  1.0,   // index 22
     -1.0,  1.0, -1.0,   // index 23
   ];
   
   // fill data to buffer
   _gl.bufferDataTyped(wgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(positions), wgl.STATIC_DRAW);
   
   
   
   // fill index buffer
   _gl.bindBuffer(wgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
   
   indices = 
   [ 0,  1,  2,    0,  2,  3, // front (two triangles)
     4,  5,  6,    4,  6,  7, // back
     8,  9, 10,    8, 10, 11, // top
     12, 13, 14,   12, 14, 15, // bottom
     16, 17, 18,   16, 18, 19, // right
     20, 21, 22,   20, 22, 23  // left
   ];
  
   _gl.bufferDataTyped(wgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(indices), wgl.RenderingContext.STATIC_DRAW);
   
   
}

void _initShader()
{
  String vs = 
  """
     attribute vec3 position;
     
     uniform mat4 worldMatrix;
     uniform mat4 cameraMatrix;
     uniform mat4 projectionMatrix;
     
     void main()
     {
        gl_Position = projectionMatrix * cameraMatrix * worldMatrix * vec4(position, 1.0);
     }

  """;
  
  
  String ps =
  """
     precision mediump float;
     void main()
     {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
     }
  """;
  
  wgl.Shader vertexShader = _gl.createShader(wgl.RenderingContext.VERTEX_SHADER);
  wgl.Shader pixelShader = _gl.createShader(wgl.RenderingContext.FRAGMENT_SHADER);
  
  // compile vertex shader
  _gl.shaderSource(vertexShader, vs);
  _gl.compileShader(vertexShader);
  
  // compile pixel shader
  _gl.shaderSource(pixelShader, ps);
  _gl.compileShader(pixelShader);
  
  
  // create program & combine vs and ps
  shaderProgram  = _gl.createProgram();
  _gl.attachShader(shaderProgram, vertexShader);
  _gl.attachShader(shaderProgram, pixelShader);
  _gl.linkProgram(shaderProgram);
  _gl.useProgram(shaderProgram);
  
  
  // logs of compiled status
  
  
  positionLoc = _gl.getAttribLocation(shaderProgram, "position");
  _gl.enableVertexAttribArray(positionLoc);
  
  
  worldMatrixLoc = _gl.getUniformLocation(shaderProgram, "worldMatrixLoc");
  cameraMatrixLoc = _gl.getUniformLocation(shaderProgram, "cameraMatrixLoc");
  projectionMatrixLoc = _gl.getUniformLocation(shaderProgram, "projectionMatrix");
  
  
  
}
void onFrame(time)
{
  
  _gl.viewport(0, 0, vpWidth, vpHeight);
  _gl.clear(wgl.RenderingContext.COLOR_BUFFER_BIT | wgl.RenderingContext.DEPTH_BUFFER_BIT);
  
  
  
  
  
  _renderFrame();
}


void _renderFrame()
{
  window.requestAnimationFrame((num time) 
      {
         onFrame(time);
      });
}
void main()
{
  init();
}