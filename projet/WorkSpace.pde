


class WorkSpace{

PShape gizmo;
PShape grid;
  WorkSpace(int size){
    this.gizmo = createShape();
    this.gizmo.beginShape(LINES);
    this.gizmo.noFill();
    this.gizmo.strokeWeight(3.0f);


    // Red X
    this.gizmo.stroke(0xAAFF3F7F);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(500, 0, 0);

    this.gizmo.strokeWeight(1.0f);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(size/2., 0, 0);
    this.gizmo.strokeWeight(3.0f);
    // Green Y
    this.gizmo.stroke(0xAA3FFF7F);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(0, 500, 0);

    this.gizmo.strokeWeight(1.0f);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(0, size/2., 0);
    this.gizmo.strokeWeight(3.0f);

    // Blue Z
    this.gizmo.stroke(0xAA3F7FFF);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex( 0, 0, 500);

    this.gizmo.strokeWeight(1.0f);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(0,0, size/2);
    this.gizmo.strokeWeight(3.0f);

    this.gizmo.endShape();

    this.grid = createShape();
    this.grid.beginShape(QUADS);
    this.grid.noFill();
    this.grid.stroke(0x77836C3D);
    this.grid.strokeWeight(0.5f);


    translate(-342, 433);
    for (int j=-50; j<50; j++){
    for (int i=-50; i<50; i++){

    this.grid.vertex(i*(size/100), j*(size/100));
    this.grid.vertex((i+1)*(size/100), j*(size/100));
    this.grid.vertex((i+1)*(size/100), (j+1)*(size/100));
    this.grid.vertex(i*(size/100), (j+1)*(size/100));

  }
}


    this.grid.endShape();

  }


  void update(){
    shape(gizmo);
    shape(grid);
  }
  /**
  * Toggle Grid & Gizmo visibility. */
  void toggle(){
    this.gizmo.setVisible(!this.gizmo.isVisible());
    this.grid.setVisible(!this.grid.isVisible());
  }
}


class Camera{
  float longitude;
  float colatitude;
  float radius;
  float x = 0.;
  float y = 2500.;
  float z = 1000.;

  Camera(){
    this.longitude = 0;
    this.colatitude= acos(1000/longitude);
    this.radius = sqrt(0 + 2500^2 + 1000^2);
  }
  void update(){
    this.x = radius*sin(colatitude)*cos(longitude);
    this.y =radius*sin(colatitude)*cos(colatitude);
    this.z = radius*cos(colatitude);
    // 3D camera (X+ right / Z+ top / Y+ Front)
    camera(this.x, -this.y, this.z,
      0, 0, 0,
      0, 0, -1
      );
  }

   void adjustRadius(float offset){

   }

   void adjustLongitude(float delta){

   }

  void adjustColatitude(float delta){
    
  }
}
