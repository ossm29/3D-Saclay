class Hud {
  private PMatrix3D hud;
  Hud() {
    // Doit être construit just après P3D size() ou fullScreen()
    this.hud = g.getMatrix((PMatrix3D) null);
  }
  //On construit le Hud
  private void begin() {
    g.noLights();
    g.pushMatrix(); 
    //On le passe au premier plan
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    g.resetMatrix();
    g.applyMatrix(this.hud);
  }

  //On efface le hud
  private void end() {
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    g.popMatrix();
  }

  //Affichage de la framerate
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

  //Procédure d'affichage du hud
  public void update(Camera camera) {
    this.begin();
    this.displayFPS();
    this.displayCamera(camera);
    this.end();
  }

  /**Procédure d'affichage des données
   * @param camera : camera dont on affiche les infos
   */
  void displayCamera(Camera camera) {
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, 0, 200, 65, 5, 5, 5, 5); // Value
    fill(0xF0);
    textMode(SHAPE);
    textSize(14);
    textAlign(LEFT, LEFT);
    text("longitude:" + String.valueOf((float)(camera.longitude*180/PI)), 20, 20);
    text("latitude:" + String.valueOf((float)((2*PI-camera.colatitude)*180/PI)), 20, 40);
    text("rayon:" + String.valueOf((float)(camera.radius)), 20, 60);
  }
}
