class Gpx {
  //formes du sol, des lignes et des épingles
  PShape track, posts, thumbtacks;

  //terrain que l'on utilise
  Map3D map;

  //sert à l'affichage de la description en cas de clic
  int pointSelection;

  JSONArray features;

  /**
   * Constructeur de la classe
   * @param map : terrain
   * @param FileName : nom du fichier dont on extrait le tracé
   */
  public Gpx(Map3D map, String FileName) {

    //erreur : le fichier n'existe pas
    File ressource = dataFile(FileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Trail file " + FileName + " not found.");
      exitActual();
    }

    this.map = map;
    this.pointSelection = -1;
    //hauteur épingles
    int height = 50;

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

    //tracé au sol
    this.track = createShape();
    this.track.beginShape();
    this.track.noFill();

    //épingle
    this.posts = createShape();
    this.posts.beginShape(LINES);
    this.thumbtacks = createShape();
    this.thumbtacks.beginShape(POINTS);


    this.track.strokeWeight(1.75); //Largeur de trait
    this.track.stroke(0, 0, 255); //Couleur
    this.posts.strokeWeight(1.5);
    this.posts.stroke(150, 150, 150);
    this.thumbtacks.strokeWeight(10);
    this.thumbtacks.stroke(0xFFFF3F3F);

    //Itération sur chaque élément du tracé Gpx -> on relie les points
    for (int f=0; f<features.size(); f++) {

      //vérification du fichier 
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

        //Le GPX de points d'intérêts (épingles) reliés par un tracé au sol (track)

      case "LineString":

        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null)
          for (int p=0; p < coordinates.size(); p++) {
            JSONArray point = coordinates.getJSONArray(p);
            Map3D.GeoPoint gp = this.map.new GeoPoint(point.getFloat(0), point.getFloat(1));
            Map3D.ObjectPoint mp = this.map.new ObjectPoint(gp);
            this.track.vertex(mp.x, mp.y, mp.z);
          }
        break;

      case "Point":

        // GPX WayPoint
        if (geometry.hasKey("coordinates")) {
          JSONArray point = geometry.getJSONArray("coordinates");
          String description = "Pas d'information.";
          if (feature.hasKey("properties")) {
            description = feature.getJSONObject("properties").getString("desc", description);
          }
          Map3D.GeoPoint gp = this.map.new GeoPoint(point.getFloat(0), point.getFloat(1));
          Map3D.ObjectPoint mp = this.map.new ObjectPoint(gp);
          this.posts.vertex(mp.x, mp.y, mp.z);
          this.posts.vertex(mp.x, mp.y, mp.z+height);
          this.thumbtacks.vertex(mp.x, mp.y, mp.z+height);
        }
        break;

        //erreur : le Gpx n'est pas constitué uniquement de points dintérêts et de tracés
      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
        break;
      }
    }
    this.track.endShape();
    this.posts.endShape();
    this.thumbtacks.endShape();
  }


  //Procédure d'affichage
  void update() {
    shape(this.track);
    shape(this.posts);
    shape(this.thumbtacks);
    //Si une épingle est sélectionnée, on affiche sa description
    if (this.pointSelection != -1) {
      description(this.pointSelection, camera);
    }
  }

  //Afficher / Enlever le Gpx
  void toggle() {
    this.track.setVisible(!this.track.isVisible());
    this.posts.setVisible(!this.posts.isVisible());
    this.thumbtacks.setVisible(!this.thumbtacks.isVisible());
  }


  //Procédure clic - on sélectionne l'épingle la + proche
  void clic(int mouseX, int mouseY) {
    //Initialisation de la distance minimale à la valeur max (taille de la map)
    float min_dist = dist(0, 0, (int)this.map.width, (int)this.map.height);

    //on itère sur chaque épingle -> déterminer la plus proche
    for (int v = 0; v < this.thumbtacks.getVertexCount(); v++) {
      PVector point = this.thumbtacks.getVertex(v);
      //calcul de la distance de l'épingle au clic
      float distMouse = dist(screenX(point.x, point.y, point.z), screenY(point.x, point.y, point.z), mouseX, mouseY );
      if (distMouse < min_dist) {
        //on mémorise la distance minimale 
        min_dist = distMouse;
        this.pointSelection = v;//Si une épingle est sélectionnée, on modifie la variable pointSelection
      }
    }

    //On modifie la couleur de l'épingle sélectionnée
    for (int w = 0; w < this.thumbtacks.getVertexCount(); w++) {
      if (w == this.pointSelection) {
        this.thumbtacks.setStroke(w, 0xFF3FFF7F);
      } else {
        this.thumbtacks.setStroke(w, 0xFFFF3F3F);
      }
    }
  }

  /** Procédure d'affichage de la description de l'épingle
   * @param vector
   * @param camera
   */
  void description(int vector, Camera camera) {
    //On initialise la description à vide
    String description = " ";
    description = this.features.getJSONObject(vector+1).getJSONObject("properties").getString("desc", description);
    pushMatrix();
    lights();
    //Couleur du texte : blanc
    fill(0xFFFFFFFF);
    //On enregistre l'épingle qui nous intéresse
    PVector point = this.thumbtacks.getVertex(vector);
    //On se place dans ses coordonnées
    translate(point.x, point.y, point.z + 10.0f);
    rotateZ(-camera.longitude-HALF_PI);
    rotateX(-camera.colatitude);
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    //On affiche le texte
    textMode(SHAPE);
    textSize(48);
    textAlign(LEFT, CENTER);
    text(description, 0, 0);
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    popMatrix();
  }
}
