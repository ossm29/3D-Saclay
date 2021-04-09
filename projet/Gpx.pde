class Gpx {

  PShape track, posts,thumbtracks;
  Map3D map;
  int pointSelection;
  JSONArray features;

  public Gpx(Map3D map, String FileName){

    //exception
    File ressource = dataFile(FileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Trail file " + FileName + " not found.");
      exitActual();
    }

    this.map = map;
    this.pointSelection = -1;
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

    this.track = createShape();
    this.track.beginShape();
    this.track.noFill();

    this.posts = createShape();
    this.posts.beginShape(LINES);
    this.thumbtracks = createShape();
    this.thumbtracks.beginShape(POINTS);

    this.track.strokeWeight(1.75);
    this.track.stroke(0, 0, 255);
    this.posts.strokeWeight(1.5);
    this.posts.stroke(150,150,150);
    this.thumbtracks.strokeWeight(10);
    this.thumbtracks.stroke(0xFFFF3F3F);


    for (int f=0; f<features.size(); f++) {

      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

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
          this.thumbtracks.vertex(mp.x, mp.y, mp.z+height);
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
        break;
      }
    }
    this.track.endShape();
    this.posts.endShape();
    this.thumbtracks.endShape();

  }

  void update(){
    shape(this.track);
    shape(this.posts);
    shape(this.thumbtracks);
    if (this.pointSelection != -1) {
      description(this.pointSelection, camera);
    }
  }

  void toggle(){
    this.track.setVisible(!this.track.isVisible());
    this.posts.setVisible(!this.posts.isVisible());
    this.thumbtracks.setVisible(!this.thumbtracks.isVisible());
  }

  void clic(int mouseX, int mouseY) {
    float min_dist = dist(0, 0, (int)this.map.width, (int)this.map.height);

    for (int v = 0; v < this.thumbtracks.getVertexCount(); v++){
      PVector point = this.thumbtracks.getVertex(v);
      float distMouse = dist(screenX(point.x, point.y, point.z), screenY(point.x, point.y, point.z), mouseX, mouseY );
      if (distMouse < min_dist) {
        min_dist = distMouse;
        this.pointSelection = v;
      }
    }
    for (int w = 0; w < this.thumbtracks.getVertexCount(); w++){
      if (w == this.pointSelection){
          this.thumbtracks.setStroke(w, 0xFF3FFF7F);
      } else {
          this.thumbtracks.setStroke(w, 0xFFFF3F3F);
      }
    }

  }

  void description(int vector, Camera camera){
    String description = "//";
    description = this.features.getJSONObject(vector+1).getJSONObject("properties").getString("desc", description);
    pushMatrix();
    lights();
    fill(0xFFFFFFFF);
    PVector point = this.thumbtracks.getVertex(vector);
    translate(point.x, point.y, point.z + 10.0f);
    rotateZ(-camera.longitude-HALF_PI);
    rotateX(-camera.colatitude);
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    textMode(SHAPE);
    textSize(48);
    textAlign(LEFT, CENTER);
    text(description, 0, 0);
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    popMatrix();
  }

}
