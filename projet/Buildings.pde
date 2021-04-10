class Buildings {
  PShape buildings;

  Map3D map;
  JSONArray features;
  int pointSelection;

  public Buildings(Map3D map){
    this.buildings = createShape(GROUP);
    this.map = map;

}

public void add(String FileName, int building_color){
    //exception
    File ressource = dataFile(FileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: file " + FileName + " not found.");
      exitActual();
    }



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

    for (int f=0; f<features.size(); f++) {


      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
    //this.railways.noFill();
    float laneWidth = 3;
    JSONObject geometry = feature.getJSONObject("geometry");
    JSONObject properties = feature.getJSONObject("properties");
      //switch (geometry.getString("type", "undefined")) {

        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null){
          for (int p=0; p < coordinates.size(); p++) {
            JSONArray coord_points = coordinates.getJSONArray(p);

            PShape ground = createShape();
            PShape walls = createShape();
            PShape roof = createShape();
            for (int j=0; j < coord_points.size()-1; j++) {
            JSONArray point1 = coord_points.getJSONArray(j);

            JSONArray point2 = coord_points.getJSONArray(j+1);

            Map3D.GeoPoint gp1 = this.map.new GeoPoint(point1.getFloat(0), point1.getFloat(1));
            Map3D.GeoPoint gp2 = this.map.new GeoPoint(point2.getFloat(0), point2.getFloat(1));


            if(gp1.inside() && gp2.inside() ){
              gp1.elevation += 7.5d;
              gp2.elevation += 7.5d;
              Map3D.ObjectPoint mp1 = this.map.new ObjectPoint(gp1);
              Map3D.ObjectPoint mp2 = this.map.new ObjectPoint(gp2);


              int levels = properties.getInt("building:levels", 1);
              float top = Map3D.heightScale * 3.0f * (float)levels;

              //creation du sol
              ground.beginShape();
              ground.fill(building_color);
              ground.vertex(mp1.x, mp1.y, mp1.z);
              ground.vertex(mp2.x, mp2.y, mp2.z);

              //creation des murs
              walls.beginShape(QUADS);
              walls.fill(building_color);
              walls.vertex(mp1.x, mp1.y, mp1.z);
              walls.vertex(mp2.x, mp2.y, mp2.z);
              walls.vertex(mp2.x, mp2.y, mp2.z+10);
              walls.vertex(mp1.x, mp1.y, mp1.z+10);
              walls.emissive(0x30);

              //creation du toît
              roof.beginShape();
              roof.fill(building_color);
              roof.vertex(mp1.x, mp1.y, mp1.z+10);
              roof.vertex(mp2.x, mp2.y, mp2.z+10);
              roof.emissive(0x60);



            }

          }

          ground.endShape(CLOSE);
          walls.endShape();
          roof.endShape(CLOSE);
          buildings.addChild(ground);
          buildings.addChild(walls);
          buildings.addChild(roof);





    }
  }
}



  }

  void update(){
    shape(this.buildings);

  }

  void toggle(){
    this.buildings.setVisible(!this.buildings.isVisible());

  }

}
