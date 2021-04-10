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
  // Gizmo
  workspace = new WorkSpace(25000);
  // Display setup
  fullScreen(P3D);

  // Setup Head Up Display this.hud = new Hud();
  this.hud = new Hud();
  smooth(4);
  frameRate(60);
  // Initial drawing
  background(0x40);

  // 3D camera (X+ right / Z+ top / Y+ Front)
  //camera(0, 2500, 1000,0, 0, 0,0, 0, -1);
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
  this.hud.update(this.camera);
  this.camera.update();
  this.land.update();
  this.gpx.update();
  this.railways.update();
  this.roads.update();
  this.buildings.update();
}

 void keyPressed() {
if (key == CODED) {
       switch (keyCode) {
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
 }
 switch (key) {
   case 'w':
   case 'W':
     // Hide/Show Land
     this.land.toggle();
     // Hide/Show grid & Gizmo
     //this.workspace.toggle();
     break;
   case 'G':
   this.gpx.toggle();
   break;
   case 'H':
   this.railways.toggle();
   break;
   case 'J':
   this.roads.toggle();
   break;
   case 'B':
   this.buildings.toggle();
   break;
   case '+':
       this.camera.adjustColatitude(0.01);
       break;
   case '-':
       this.camera.adjustColatitude(-0.01);
       break;

   }

}

void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
