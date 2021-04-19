#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

smooth in vec4 vertColor
smooth in vec4 verTexCoord;

smooth in vec2 vertHeat;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  gl_FragColor.r = 255/(25*verthHeat[0])
  gl_FragColor.v = 255/(25*verthHeat[1])
  gl_FragColor.b = 255/(25*verthHeat[2])

}
