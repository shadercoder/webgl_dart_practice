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
   List<double> indices;
   
   
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
   
   _gl.bufferDataTyped(wgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(positions), wgl.STATIC_DRAW);
  
}

void onFrame(time)
{
  
  _gl.viewport(0, 0, vpWidth, vpHeight);
  _gl.clear(wgl.RenderingContext.COLOR_BUFFER_BIT | wgl.RenderingContext.DEPTH_BUFFER_BIT);
  
}


void main()
{
  
}