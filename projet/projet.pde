WorkSpace workspace;
Camera camera;

void setup() {
// Gizmo
workspace = new WorkSpace(25000);
// Display setup
 fullScreen(P3D);
 smooth(8);
 frameRate(60);
 // Initial drawing
 background(0x40);
// 3D camera (X+ right / Z+ top / Y+ Front)
//camera(0, 2500, 1000,0, 0, 0,0, 0, -1);
camera = new Camera();
// Make camera move easier
hint(ENABLE_KEY_REPEAT);
camera.update();
 }

 void draw(){
 background(0x40);
 camera.update();
 workspace.update();



 }
 void keyPressed() {
   switch (key) {
     case 'w':
     case 'W':
     // Hide/Show grid & Gizmo
     this.workspace.toggle();
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
           this.camera.adjustRadius(0.01);

           break;
         case DOWN:
           this.camera.adjustRadius(-0.01);
           break;
         case LEFT:
             this.camera.adjustLongitude(-0.01);
             break;
         case RIGHT:
              this.camera.adjustLongitude(0.01);
              break;
       }
   }
   }
