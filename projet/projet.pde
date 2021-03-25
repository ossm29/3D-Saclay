WorkSpace workspace;

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
camera(0, 2500, 1000,0, 0, 0,0, 0, -1);

 }

 void draw(){
 workspace.update();


 }
 void keyPressed() {
   switch (key) {
     case 'w':
     case 'W':
     // Hide/Show grid & Gizmo
     this.workspace.toggle();
     break;
     }
   }
