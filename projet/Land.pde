/**
 * Retourne un objet Land.
 * Prepares land shadow, wireframe and textured shape
 * @param map Land associated elevation Map3D object * @return Land object
 */

class Land {
  //var
  Map3D map;
  //Ombre du terrain , maillage en fil de fer, texture satellite
  PShape shadow, wireFrame, satellite;

  /** Constructeur de la classe
   * @params map : carte de l'on utilise
   * @params Filename : nom du fichier
   */
  Land(Map3D map, String Filename) {

    //erreur : fichier inexistant
    File ressource = dataFile(Filename);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Land texture file " + Filename + " not found.");
      exitActual();
    }
    //On charge la texture depuis l'image
    PImage uvmap = loadImage(Filename);

    //taille des tuiles -> trop grand : mauvais rendu -- trop petit : lag
    final float tileSize = 20.0f;

    this.map = map;

    //On mémorise les dimensions de la carte
    float w = (float)Map3D.width;
    float h = (float)Map3D.height;

    //Forme de l'ombre
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F); 
    this.shadow.noStroke();
    this.shadow.vertex(- w/2, - h/2, -10.0f);
    this.shadow.vertex(- w/2, h/2, -10.0f);
    this.shadow.vertex(w/2, h/2, -10.0f);
    this.shadow.vertex(w/2, - h/2, -10.0f);
    this.shadow.endShape();

    //Forme du satellite
    this.satellite = createShape();
    this.satellite.beginShape(QUADS);
    this.satellite.texture(uvmap);
    this.satellite.noFill();
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);


    //Forme du maillage
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS); 
    this.wireFrame.noFill(); 
    this.wireFrame.stroke(#888888); 
    this.wireFrame.strokeWeight(0.5f);


    Poi poi = new Poi(map);
    JSONArray bench = poi.getPoints("bench.geojson");
    JSONArray bicycle = poi.getPoints("bicycle_parking.geojson");

    //coordonnee 1 texture
    int u = 0;
    for (int i = (int)(-w/(2*tileSize)); i < w/(2*tileSize); i++) {
      //coordonnee 2 texture
      int v = 0;
      for (int j = (int)(-h/(2*tileSize)); j < h/(2*tileSize); j++) {
        //On mémorise les quatres points
        Map3D.ObjectPoint frst = this.map.new ObjectPoint(i*tileSize, j*tileSize);
        Map3D.ObjectPoint scnd = this.map.new ObjectPoint((i+1)*tileSize, j*tileSize);
        Map3D.ObjectPoint thrd = this.map.new ObjectPoint((i+1)*tileSize, (j+1)*tileSize);
        Map3D.ObjectPoint frth = this.map.new ObjectPoint(i*tileSize, (j+1)*tileSize);

        //tracé des fils de fer (rectangle)
        this.wireFrame.vertex(frst.x, frst.y, frst.z);
        this.wireFrame.vertex(scnd.x, scnd.y, scnd.z);
        this.wireFrame.vertex(thrd.x, thrd.y, thrd.z);
        this.wireFrame.vertex(frth.x, frth.y, frth.z);
        
        //Calcul de la normale pour la lumière
        PVector nfrst = frst.toNormal();
        this.satellite.normal(nfrst.x, nfrst.y, nfrst.z);
        this.satellite.vertex(frst.x, frst.y, frst.z, u, v);

        PVector nscnd = scnd.toNormal();
        this.satellite.normal(nscnd.x, nscnd.y, nscnd.z);
        this.satellite.vertex(scnd.x, scnd.y, scnd.z, u+tileSize/5, v);

        PVector nthrd = thrd.toNormal();
        this.satellite.normal(nthrd.x, nthrd.y, nthrd.z);
        this.satellite.vertex(thrd.x, thrd.y, thrd.z, u+tileSize/5, v+tileSize/5);

        PVector nfrth = frth.toNormal();
        this.satellite.normal(nfrth.x, nfrth.y, nfrth.z);
        this.satellite.vertex(frth.x, frth.y, frth.z, u, v+tileSize/5);

        float nearestPicNicTableDistance = poi.mindist(frst.x, frst.y, frst.z, bench);
        float nearestBykeParkingDistance = poi.mindist(frst.x, frst.y, frst.z, bicycle);
        
        //Ajout de l'attribut "heat" pour le tracé de la heatmap
        this.satellite.attrib("heat", nearestPicNicTableDistance, nearestBykeParkingDistance);

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
  
  //Procédure d'affichage
  void update() {
    shape(this.shadow);
    //resetShader();
    shape(this.wireFrame);
    shape(this.satellite);
  }
  
  //Afficher / Enlever les shapes
  void toggle() {
    this.shadow.setVisible(!this.shadow.isVisible());
    this.wireFrame.setVisible(!this.wireFrame.isVisible());
    this.satellite.setVisible(!this.satellite.isVisible());
  }
}
