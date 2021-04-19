/**
* Returns a Land object.
* Prepares land shadow, wireframe and textured shape
* @param map Land associated elevation Map3D object * @return Land object
*/

class Land {
  //var
  Map3D map;
  PShape shadow;
  PShape wireFrame;
  PShape satellite;
  
  Land(Map3D map, String Filename) {
    //exception
    File ressource = dataFile(Filename);
        if (!ressource.exists() || ressource.isDirectory()) {
          println("ERROR: Land texture file " + Filename + " not found.");
          exitActual();
        }
        PImage uvmap = loadImage(Filename);
      
    final float tileSize = 25.0f;
    this.map = map;
    float w = (float)Map3D.width;
    float h = (float)Map3D.height;
    
    // Shadow shape
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F); 
    this.shadow.noStroke();
    this.shadow.vertex(- w/2, - h/2, -10.0f);
    this.shadow.vertex(- w/2, h/2, -10.0f);
    this.shadow.vertex(w/2, h/2, -10.0f);
    this.shadow.vertex(w/2, - h/2, -10.0f);
    this.shadow.endShape();
    
    //Satellite shape
    this.satellite = createShape();
    this.satellite.beginShape(QUADS);
    this.satellite.texture(uvmap);
    this.satellite.noFill();
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);
    
        
    // Wireframe shape
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS); 
    this.wireFrame.noFill(); 
    this.wireFrame.stroke(#888888); 
    this.wireFrame.strokeWeight(0.5f);
    
    int u = 0;
    for (int i = (int)(-w/(2*tileSize)); i < w/(2*tileSize); i++){
      int v = 0;
      for (int j = (int)(-h/(2*tileSize)); j < h/(2*tileSize); j++){
        Map3D.ObjectPoint frst = this.map.new ObjectPoint(i*tileSize, j*tileSize);
        Map3D.ObjectPoint scnd = this.map.new ObjectPoint((i+1)*tileSize, j*tileSize);
        Map3D.ObjectPoint thrd = this.map.new ObjectPoint((i+1)*tileSize, (j+1)*tileSize);
        Map3D.ObjectPoint frth = this.map.new ObjectPoint(i*tileSize, (j+1)*tileSize);
        PVector nfrst = frst.toNormal();
        PVector nscnd = scnd.toNormal();
        PVector nthrd = thrd.toNormal();
        PVector nfrth = frth.toNormal();
        
        
        this.wireFrame.vertex(frst.x,frst.y, frst.z);
        this.wireFrame.vertex(scnd.x, scnd.y, scnd.z);
        this.wireFrame.vertex(thrd.x, thrd.y, thrd.z);
        this.wireFrame.vertex(frth.x, frth.y, frth.z);
        
        this.satellite.normal(nfrst.x, nfrst.y, nfrst.z);
        this.satellite.attrib("heat", 0.0f, 0.0f, 0.0f);
        this.satellite.vertex(frst.x, frst.y, frst.z, u, v);
        this.satellite.normal(nscnd.x, nscnd.y, nscnd.z);
        this.satellite.attrib("heat", 0.0f, 0.0f, 0.0f);
        this.satellite.vertex(scnd.x, scnd.y, scnd.z, u+tileSize/5, v);
        this.satellite.normal(nthrd.x, nthrd.y, nthrd.z);
        this.satellite.attrib("heat", 0.0f, 0.0f, 0.0f);
        this.satellite.vertex(thrd.x, thrd.y, thrd.z, u+tileSize/5, v+tileSize/5);
        this.satellite.normal(nfrth.x, nfrth.y, nfrth.z);
        this.satellite.attrib("heat", 0.0f, 0.0f, 0.0f);
        this.satellite.vertex(frth.x, frth.y, frth.z, u, v+tileSize/5);
        v += tileSize/5;
      }
      u += tileSize/5;
    }
    this.satellite.endShape();

    this.wireFrame.endShape();
    
    //Shapes initial visibility 
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(true);
    this.satellite.setVisible(true);

  }
  
  void update(){
    shape(this.shadow);
    shape(this.wireFrame);
    shape(this.satellite);
  }
  
  void toggle(){
    this.shadow.setVisible(!this.shadow.isVisible());
    this.wireFrame.setVisible(!this.wireFrame.isVisible());
    this.satellite.setVisible(!this.satellite.isVisible());

  }
}
