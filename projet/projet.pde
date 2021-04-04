WorkSpace workspace;
Camera camera;
Hud hud;
Map3D map;
Land land;

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
}

void draw(){
  background(0x40);
  this.camera.update();
  this.workspace.update();
  this.hud.update(this.camera);
  this.camera.update();
  this.land.update();
}

 void keyPressed() {
   switch (key) {
     case 'w':
     case 'W':
       // Hide/Show Land
       this.land.toggle();
       // Hide/Show grid & Gizmo
       //this.workspace.toggle();
       break;
     case '+':
         this.camera.adjustColatitude(0.01);
         break;
     case '-':
         this.camera.adjustColatitude(-0.01);
         break;

     }
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
   }
