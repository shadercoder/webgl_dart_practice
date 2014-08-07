library webgl2;


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
  
}

void onFrame(time)
{
  
  _gl.viewport(0, 0, vpWidth, vpHeight);
  _gl.clear(wgl.RenderingContext.COLOR_BUFFER_BIT | wgl.RenderingContext.DEPTH_BUFFER_BIT);
  
}


void main()
{
  
}