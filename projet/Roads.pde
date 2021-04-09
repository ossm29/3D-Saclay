class Roads {
  PShape roads;

  Map3D map;
  JSONArray features;
  int pointSelection;

  public Roads(Map3D map, String FileName){

    //exception
    File ressource = dataFile(FileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: file " + FileName + " not found.");
      exitActual();
    }

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

    this.roads = createShape(GROUP);


    //this.railways.noFill();
    float laneWidth = 3;

    String laneKind = "unclassified";
    color laneColor = 0xFFFF0000;
     double laneOffset = 1.50d;


    for (int f=0; f<features.size(); f++) {
      PShape lane;
      lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.stroke(255, 255, 255);
      lane.fill(255, 255, 255);

      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
        JSONObject properties = feature.getJSONObject("properties");
        laneKind = properties.getString("highway", "unclassified");
        switch (laneKind) {
        case "motorway":
        laneColor = 0xFFe990a0;
        laneOffset = 3.75d;
        laneWidth = 8.0f;
        break;

        case "trunk":
        laneColor = 0xFFfbb29a;
        laneOffset = 3.60d;
        laneWidth = 7.0f;
        break;

        case "trunk_link":
        case "primary":
        laneColor = 0xFFfdd7a1;
        laneOffset = 3.45d;
        laneWidth = 6.0f; break;
        case "secondary":
        case "primary_link":

        laneColor = 0xFFf6fabb;
        laneOffset = 3.30d;
        laneWidth = 5.0f;
        break;
        case "tertiary":
        case "secondary_link":
        laneColor = 0xFFE2E5A9;
        laneOffset = 3.15d;
        laneWidth = 4.0f; break;
        case "tertiary_link":
        case "residential":
        case "construction":
        case "living_street":

        laneColor = 0xFFB2B485;
        laneOffset = 3.00d;
        laneWidth = 3.5f;
        break;

        case "corridor":
        case "cycleway":
        case "footway":
         case "path":
        case "pedestrian":
        case "service":
        case "steps":
        case "track":
        case "unclassified":
        laneColor = 0xFFcee8B9;
        laneOffset = 2.85d;
        laneWidth = 1.0f; break;

        default:
        laneColor = 0xFFFF0000;
        laneOffset = 1.50d;
        laneWidth = 0.5f;

        println("WARNING: Roads kind not handled : ", laneKind);
         break;
        }
        // Display threshold (increase if more performance needed...) if (laneWidth < 1.0f)
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

      case "LineString":

        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null)
          for (int p=0; p < coordinates.size()-1; p++) {
            JSONArray point1 = coordinates.getJSONArray(p);
            Map3D.GeoPoint gp1 = this.map.new GeoPoint(point1.getFloat(0), point1.getFloat(1));
            //Map3D.ObjectPoint mp1 = this.map.new ObjectPoint(gp1);

            JSONArray point2 = coordinates.getJSONArray(p+1);
            Map3D.GeoPoint gp2 = this.map.new GeoPoint(point2.getFloat(0), point2.getFloat(1));
            //Map3D.ObjectPoint mp2 = this.map.new ObjectPoint(gp2);
            if(gp1.inside() && gp2.inside() ){
              gp1.elevation += 7.5d;
              gp2.elevation += 7.5d;
              Map3D.ObjectPoint mp1 = this.map.new ObjectPoint(gp1);
              Map3D.ObjectPoint mp2 = this.map.new ObjectPoint(gp2);
              //this.railways.vertex(mp.x, mp.y, mp.z);
              PVector Va = new PVector(mp1.y - mp2.y, mp2.x - mp1.x).normalize().mult(laneWidth/2.0f);
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

      roads.addChild(lane);
    }




  }

  void update(){
    shape(this.roads);

  }



}
