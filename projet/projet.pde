WorkSpace workspace;
Camera camera;
Hud hud;
Map3D map;
Land land;
Gpx gpx;
Railways railways;
Roads roads;
Buildings buildings;

void setup() {
  // Display setup
  fullScreen(P3D);
  workspace = new WorkSpace(25000);
  
  // Initial drawing
  background(0x40);
  
  // Setup Head Up Display
  this.hud = new Hud();
  smooth(4);
  frameRate(60);


  this.camera = new Camera(-PI/2, 1.1, 3000);
  this.camera.update();

  // Make camera move easier
  hint(ENABLE_KEY_REPEAT);
  camera.update();

  // Load Height Map
  this.map = new Map3D("paris_saclay.data");
  this.land = new Land(this.map,"paris_saclay.jpg");
  this.gpx = new Gpx(this.map, "trail.geojson");
  this.railways = new Railways(this.map, "railways.geojson");
  this.roads = new Roads(this.map, "roads.geojson");
  //this.buildings = new Buildings(this.map, "buildings.geojson");
  // Prepare buildings
  this.buildings = new Buildings(this.map);
  this.buildings.add("buildings_city.geojson", 0xFFaaaaaa);
  this.buildings.add("buildings_IPP.geojson", 0xFFCB9837);
  this.buildings.add("buildings_EDF_Danone.geojson", 0xFF3030FF);
  this.buildings.add("buildings_CEA_algorithmes.geojson", 0xFF30FF30);
  this.buildings.add("buildings_Thales.geojson", 0xFFFF3030);
  this.buildings.add("buildings_Paris_Saclay.geojson", 0xFFee00dd);
}

void draw(){
  background(0x40);
  this.camera.update();
  this.workspace.update();
  this.camera.update();
  this.land.update();
  this.gpx.update();
  this.railways.update();
  this.roads.update();
  this.buildings.update();
  this.hud.update(this.camera);

}

void keyPressed() {
  if (key == CODED){
    switch(keyCode){
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
        // Hide/Show grid & Gizmo
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
        this.railways.toggle();
        this.roads.toggle();
        break;
      case 'X':
      case 'x':
        this.gpx.toggle();
        break;
      case 'b':
      case 'B':
        this.buildings.toggle();
        break;
        
      }
    }

}

void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
