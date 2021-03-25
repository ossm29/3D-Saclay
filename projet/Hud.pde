class Hud {
private PMatrix3D hud;
Hud() {
// Should be constructed just after P3D size() or fullScreen()
this.hud = g.getMatrix((PMatrix3D) null);
}
private void begin() {
g.noLights();
g.pushMatrix(); g.hint(PConstants.DISABLE_DEPTH_TEST);
 g.resetMatrix();
g.applyMatrix(this.hud);
}
private void end() {
  g.hint(PConstants.ENABLE_DEPTH_TEST);
  g.popMatrix();
  }
private void displayFPS() {
// Bottom left area
noStroke();
fill(96);
rectMode(CORNER);
rect(10, height-30, 60, 20, 5, 5, 5, 5); // Value
fill(0xF0);
textMode(SHAPE);
textSize(14);
textAlign(CENTER, CENTER);
 text(String.valueOf((int)frameRate) + " fps", 40, height-20);
  }

 public void update(Camera camera){
   this.begin();
    this.displayFPS();
    this.displayCamera(camera);
    this.end();

 }

 void displayCamera(Camera camera){
   noStroke();
   fill(96);
   rectMode(CORNER);
   rect(10, 0, 150, 65, 5, 5, 5, 5); // Value
   fill(0xF0);
   textMode(SHAPE);
   textSize(14);
   textAlign(LEFT, LEFT);
    text("longitude:" + String.valueOf((float)(camera.longitude*180/PI)), 20, 20);
    text("latitude:" + String.valueOf((float)((2*PI-camera.colatitude)*180/PI)), 20, 40);
    text("rayon:" + String.valueOf((float)(camera.radius)), 20, 60);
     }
 }
