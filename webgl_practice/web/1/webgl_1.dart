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

void init()
{
  glCanvas = querySelector("#drawArea");
  
  vpWidth = glCanvas.width;
  vpHeight = glCanvas.height;
  
  _glContext = glCanvas.getContext("experimental-webgl");
  
  
  
  
}

void main()
{
  init();
}

