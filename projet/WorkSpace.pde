


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

/*
void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        adjustRadius(0.01);
        break;
      case DOWN:
        adjustRadius(-0.01);
        break;
        case LEFT:
          adjustLongitude(-0.01);
          break;
    case RIGHT:
      adjustLongitude(0.01);
      break;
    }
} else {
switch (key) {
  case '+':
      adjustColatitude(0.01);
      break;
  case '-':
      adjustColatitude(-0.01);
break;
    }
  }
}
*/
