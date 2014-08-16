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
int texcoordLoc;

// uniforms
wgl.UniformLocation worldMatrixLoc;
wgl.UniformLocation cameraMatrixLoc;
wgl.UniformLocation projectionMatrixLoc;
wgl.UniformLocation albedoSamplerLoc;

// matrix
Matrix4 worldMatrix;
Matrix4 cameraMatrix;
Matrix4 projectionMatrix;

double lasttime = 0.0;
double rot_y = 0.0;

// textur
wgl.Texture albedoTex;

void init()
{
  glCanvas = document.querySelector("#drawArea");
  vpWidth = glCanvas.offset.width;
  vpHeight = glCanvas.offset.height;
  
  _gl = glCanvas.getContext("webgl");
  _gl.enable(wgl.RenderingContext.DEPTH_TEST);
  
  _initVertexBuffer();
  _initShader();
  _initTexture();
  
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
   
   // fill position to buffer
   _gl.bufferDataTyped(wgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(positions), wgl.STATIC_DRAW);
   
   // fill texture coordinates
   _gl.bindBuffer(wgl.RenderingContext.ARRAY_BUFFER, texcoordBuffer);
   
   texcoords = 
   [
    // front
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,
  
    // back
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
  
    // top
    0.0, 1.0,
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,
  
    // bottom
    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
    1.0, 0.0,
  
    // right
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
  
    // left
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,
   ];
   
   // fill texcoords to buffer
   _gl.bufferDataTyped(wgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(texcoords), wgl.RenderingContext.STATIC_DRAW);
   
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

void _initTexture()
{
  albedoTex = _gl.createTexture();
  
  ImageElement diff = new Element.tag("img");
  
  diff.onLoad.listen((Event e)
  {
     _handleTexture(albedoTex, diff);
  });
  
  diff.src = "./texture/crate.gif";
}

void _handleTexture(wgl.Texture tex, ImageElement img)
{
  _gl.bindTexture(wgl.RenderingContext.TEXTURE_2D, tex);
  _gl.texImage2D(wgl.RenderingContext.TEXTURE_2D, 0, wgl.RenderingContext.RGBA, wgl.RenderingContext.RGBA, wgl.RenderingContext.UNSIGNED_BYTE, img);
  _gl.texParameteri(wgl.RenderingContext.TEXTURE_2D, wgl.RenderingContext.TEXTURE_MAG_FILTER, wgl.RenderingContext.LINEAR);
  _gl.texParameteri(wgl.RenderingContext.TEXTURE_2D, wgl.RenderingContext.TEXTURE_MIN_FILTER, wgl.RenderingContext.LINEAR_MIPMAP_NEAREST);
  _gl.generateMipmap(wgl.RenderingContext.TEXTURE_2D);
  
  
  // finish texture building
  _gl.bindTexture(wgl.RenderingContext.TEXTURE_2D, null);
  
}
void _initShader()
{
  String vs = 
  """
     attribute vec3 position;
     attribute vec2 uv;
     uniform mat4 worldMatrix;
     uniform mat4 cameraMatrix;
     uniform mat4 projectionMatrix;
     
     varying vec2 uv1;
     void main()
     {
        gl_Position = projectionMatrix * cameraMatrix * worldMatrix * vec4(position, 1.0);
        
        uv1 = uv;
     }

  """;
  
  
  String ps =
  """
     precision mediump float;
     uniform sampler2D albedo;
     varying vec2 uv1;
     void main()
     {
        gl_FragColor = texture2D(albedo, uv1);
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
  
  
  // logs of compiled & link status
  if (!_gl.getShaderParameter(vertexShader, wgl.RenderingContext.COMPILE_STATUS)) { 
    print(_gl.getShaderInfoLog(vertexShader));
  }
  
  if (!_gl.getShaderParameter(pixelShader, wgl.RenderingContext.COMPILE_STATUS)) { 
    print(_gl.getShaderInfoLog(pixelShader));
  }
  
  if (!_gl.getProgramParameter(shaderProgram, wgl.RenderingContext.LINK_STATUS)) { 
    print(_gl.getProgramInfoLog(shaderProgram));
  }
  
  positionLoc = _gl.getAttribLocation(shaderProgram, "position");
  _gl.enableVertexAttribArray(positionLoc);
  
  texcoordLoc = _gl.getAttribLocation(shaderProgram, "uv");
  _gl.enableVertexAttribArray(texcoordLoc);
  
  
  worldMatrixLoc = _gl.getUniformLocation(shaderProgram, "worldMatrix");
  cameraMatrixLoc = _gl.getUniformLocation(shaderProgram, "cameraMatrix");
  projectionMatrixLoc = _gl.getUniformLocation(shaderProgram, "projectionMatrix");
  albedoSamplerLoc = _gl.getUniformLocation(shaderProgram, "albedo");
  
  
  
}

void _onAnimate(double time)
{
  if(lasttime != 0.0)
  {
    double delta = time - lasttime;
    
    rot_y += 40.0 * delta / 1000.0;
  }
  
  lasttime = time;
}

double _degToRad(double degrees) {
  return degrees * PI / 180;
}

void onFrame(double time)
{
  
  _gl.viewport(0, 0, vpWidth, vpHeight);
  _gl.clearColor(0,  0, 0, 255);
  _gl.clear(wgl.RenderingContext.COLOR_BUFFER_BIT | wgl.RenderingContext.DEPTH_BUFFER_BIT);
  
  _onAnimate(time);
  _gl.bindBuffer(wgl.RenderingContext.ARRAY_BUFFER, posBuffer);
  _gl.vertexAttribPointer(positionLoc, 3, wgl.RenderingContext.FLOAT, false, 0, 0);
  
  _gl.bindBuffer(wgl.RenderingContext.ARRAY_BUFFER, texcoordBuffer);
  _gl.vertexAttribPointer(texcoordLoc, 2, wgl.RenderingContext.FLOAT, false, 0, 0);
 
  projectionMatrix = makePerspectiveMatrix(radians(45.0), vpWidth / vpHeight, 0.1, 10000.0);
  
  worldMatrix  = new Matrix4.identity();
  
  double angle1 = radians(rot_y);
  worldMatrix.rotateY(angle1);
  
  cameraMatrix = makeViewMatrix(new Vector3(0.0, 5.0, 8.0), new Vector3.zero(), new Vector3(0.0, 1.0, 0.0));
  
  // set matrix uniforms.
  Float32List mat = new Float32List(16);
  
  // pass matrices to shader variable
  worldMatrix.copyIntoArray(mat);
  _gl.uniformMatrix4fv(worldMatrixLoc, false, mat);
  
  cameraMatrix.copyIntoArray(mat);
  _gl.uniformMatrix4fv(cameraMatrixLoc, false, mat);
  
  projectionMatrix.copyIntoArray(mat);
  _gl.uniformMatrix4fv(projectionMatrixLoc, false, mat);
  
  // set texture
  _gl.uniform1i(albedoSamplerLoc, 0);
  _gl.activeTexture(wgl.RenderingContext.TEXTURE0);
  _gl.bindTexture(wgl.RenderingContext.TEXTURE_2D, albedoTex);
  
  
  // draw elements
  _gl.bindBuffer(wgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
  _gl.drawElements(wgl.RenderingContext.TRIANGLES, 36, wgl.RenderingContext.UNSIGNED_SHORT, 0);
  
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
  
  _renderFrame();
}