uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;

attribute vec2 texCoord;
attribute vec2 heat;

smooth out vec4 vertColor;
smooth out vec4 vertTexCoord;
smooth out vec2 vertHeat;

void main() {
  gl_Position = transform * position;
  vertColor = color;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
  vertHeat = heat;
}
