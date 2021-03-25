PShape gizmo;

void setup() {
// Gizmo

this.gizmo = createShape();
this.gizmo.beginShape(LINES);
this.gizmo.noFill();
this.gizmo.strokeWeight(3.0f);


// Red X
this.gizmo.stroke(0xAAFF3F7F);
this.gizmo.vertex(0, 0, 0);
this.gizmo.vertex(1000, 0, 0);

// Green Y
this.gizmo.stroke(0xAA3FFF7F);
this.gizmo.vertex(0, 0, 0);
this.gizmo.vertex(0, 1000, 0);

// Blue Z
this.gizmo.stroke(0xAA3F7FFFb);
this.gizmo.vertex(0, 0, 0);
this.gizmo.vertex( 0, 0, 1000);

this.gizmo.endShape();
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
   shape(gizmo);


 }
