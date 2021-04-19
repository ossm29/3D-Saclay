#ifdef GL_ES
  precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

smooth in vec4 vertColor;
smooth in vec4 vertTexCoord;

smooth in vec2 vertHeat;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  if (vertHeat[0] != 0 && vertHeat[1] != 0) {
    gl_FragColor.r += 255.0/(5*vertHeat[0]+1);
    gl_FragColor.g += 255.0/(5*vertHeat[1]+1);
  }
}
