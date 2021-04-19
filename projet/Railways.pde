class Railways {
  //forme de la voie ferrée
  PShape railways;

  Map3D map;
  JSONArray features;
  int pointSelection;

  /**
   * Constructeur de la classe
   * @param map : La carte sur laquelle on travaille
   * @param FileName : le nom du fichier de la voie ferrée (geojson)
   */
  public Railways(Map3D map, String FileName) {

    //erreur : fichier inexistant
    File ressource = dataFile(FileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: file " + FileName + " not found.");
      exitActual();
    }
    //On initialise la carte
    this.map = map;

    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(FileName);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      return;
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
      return;
    }

    // Parse features
    this.features =  geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      return;
    }

    //railways est un groupe de voies 
    this.railways = createShape(GROUP);

    //Largeur de la voie
    float laneWidth = 3;

    //On itère sur chaque élément du groupe pour le tracer
    for (int f=0; f<features.size(); f++) {
      PShape lane;
      lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.stroke(255, 255, 255);
      lane.fill(255, 255, 255);

      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

      case "LineString":

        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        
        //On trace les voies en utilisant la normale par rapport aux points voisins
        
        if (coordinates != null)
          for (int p=0; p < coordinates.size()-1; p++) {
            //1er point
            JSONArray point1 = coordinates.getJSONArray(p);
            Map3D.GeoPoint gp1 = this.map.new GeoPoint(point1.getFloat(0), point1.getFloat(1));
            //Map3D.ObjectPoint mp1 = this.map.new ObjectPoint(gp1);

            JSONArray point2 = coordinates.getJSONArray(p+1);
            Map3D.GeoPoint gp2 = this.map.new GeoPoint(point2.getFloat(0), point2.getFloat(1));

            //Si le point est bien dans la map :
            if (gp1.inside() && gp2.inside() ) {
              gp1.elevation += 7.5d;
              gp2.elevation += 7.5d;
              Map3D.ObjectPoint mp1 = this.map.new ObjectPoint(gp1);
              Map3D.ObjectPoint mp2 = this.map.new ObjectPoint(gp2);
              //this.railways.vertex(mp.x, mp.y, mp.z);
              PVector Va = new PVector(mp1.y - mp2.y, mp2.x - mp1.x).normalize().mult(laneWidth/2.0f);
              //tracé des lignes (voies)
              lane.normal(0.0f, 0.0f, 1.0f);
              lane.vertex(mp1.x - Va.x, mp1.y - Va.y, mp1.z);
              lane.normal(0.0f, 0.0f, 1.0f);
              lane.vertex(mp1.x + Va.x, mp1.y + Va.y, mp1.z);
              lane.normal(0.0f, 0.0f, 1.0f);
              lane.vertex(mp2.x - Va.x, mp2.y - Va.y, mp2.z);
              lane.normal(0.0f, 0.0f, 1.0f);
              lane.vertex(mp2.x + Va.x, mp2.y + Va.y, mp2.z);
            }
          }
        break;


      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
        break;
      }

      lane.fill(255, 255, 255);
      lane.endShape();

      railways.addChild(lane);
    }
  }
  
  //Procédure d'affichage
  void update() {
    shape(this.railways);
  }
  
  //Afficher - Enlever le tracé des voies ferrées 
  void toggle() {
    this.railways.setVisible(!this.railways.isVisible());
  }
}
