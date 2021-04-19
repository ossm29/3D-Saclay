WorkSpace workspace; //Espace de travail grille et repère 
Camera camera; //camera
Hud hud; //panneau d'informations
Map3D map; //Carte
Land land;//terrain associé à la carte
Gpx gpx; //tracé des itinéraires
Railways railways;//tracé des voies ferrées
Roads roads;//tracé des routes
Buildings buildings;//tracé des batiments
Poi poi;//tracé des points d'intérêts pour la heatmap
PShader myshader;//shader associé au Poi

void setup() {
  //création de l'espace de travail
  workspace = new WorkSpace(25000);

  //Dessin initial (fond)
  background(0x40);

  //initialisation du shader depuis les fichiers glsl
  myshader = loadShader("fragment_shader.glsl", "vertex_shader.glsl");

  //Ajout de l'affichage tête haute
  this.hud = new Hud();
  smooth(4);
  frameRate(60);

  //mise en place de la camera
  this.camera = new Camera(-PI/2, 1.1, 3000);
  this.camera.update();

  //Rend la caméra plus fluide
  hint(ENABLE_KEY_REPEAT);
  camera.update();

  //Mise en place de la carte
  this.map = new Map3D("paris_saclay.data");

  //mise en place du terrain
  this.land = new Land(this.map, "paris_saclay.jpg");

  //Configuration Poi
  this.poi = new Poi(this.map);
  //Configuration gps
  this.gpx = new Gpx(this.map, "trail.geojson");
  //Configuration railways
  this.railways = new Railways(this.map, "railways.geojson");
  //Configuration roads
  this.roads = new Roads(this.map, "roads.geojson");

  // Preparation des batiments
  this.buildings = new Buildings(this.map);
  this.buildings.add("buildings_city.geojson", 0xFFaaaaaa);
  this.buildings.add("buildings_IPP.geojson", 0xFFCB9837);
  this.buildings.add("buildings_EDF_Danone.geojson", 0xFF3030FF);
  this.buildings.add("buildings_CEA_algorithmes.geojson", 0xFF30FF30);
  this.buildings.add("buildings_Thales.geojson", 0xFFFF3030);
  this.buildings.add("buildings_Paris_Saclay.geojson", 0xFFee00dd);

  //Affichage 
  fullScreen(P3D);
}

void draw() {
  background(0x40);
  //Appel des fonctions de mise à jour de chaque classe
  this.workspace.update();
  this.camera.update();
  //shader
  shader(myshader);
  this.land.update();
  resetShader();
  //
  this.gpx.update();
  this.railways.update();
  this.roads.update();
  this.buildings.update();
  this.hud.update(this.camera);
}

void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
    case UP:
      this.camera.adjustColatitude(-PI/100);
      break;
    case DOWN:
      this.camera.adjustColatitude(PI/100);
      break;
    case LEFT:
      this.camera.adjustLongitude(-PI/100);
      break;
    case RIGHT:
      this.camera.adjustLongitude(PI/100);
      break;
    }
  } else {
    switch (key) {
    case 'w':
    case 'W':
      //Afficher / enlever grille & Gizmo
      this.workspace.toggle();
      this.land.toggle();
      break;
    case '+':
    case 'p':
    case 'P':
      this.camera.adjustRadius(-60);
      break;
    case '-':
    case 'm':
    case 'M':
      this.camera.adjustRadius(60);
      break;
    case 'l':
    case 'L':
      this.camera.toggle();
      break;
    case 'r':
      //Afficher / enlever tracé routes et voies ferrées
      this.railways.toggle();
      this.roads.toggle();
      break;
    case 'X':
    case 'x':
    //Afficher / enlever tracé itinéraires
      this.gpx.toggle();
      break;
    case 'b':
    case 'B':
    //Afficher / enlever tracé batiments
      this.buildings.toggle();
      break;
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT)
  
    this.gpx.clic(mouseX, mouseY);
}
