
class Poi {

  Land land;

  Poi(Land land) {
    this.land = land;
  }

  //liste de coordonnées d’aménagements pour un fichier donné.
  ArrayList<PVector> getPoints(String fileName){

    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Trail file " + fileName + " not found.");
      exitActual();
    }



    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(fileName);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
    }

    // Parse features
    JSONArray features =  geojson.getJSONArray("features");
    ArrayList<PVector> points = new ArrayList<PVector>();
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
    }
    if (features != null) {
      
      for (int f = 0; f < features.size(); f++){
        JSONObject feature = features.getJSONObject(f);
        
        if (!feature.hasKey("geometry"))
          break;

         JSONArray point = feature.getJSONObject("geometry").getJSONArray("coordinates");
         Map3D.GeoPoint gp = this.land.map.new GeoPoint(point.getFloat(0), point.getFloat(1));
         Map3D.ObjectPoint op = this.land.map.new ObjectPoint(gp);
         points.add(op.toVector());
      }
    }
  return points;
  }
  
  void mindist() {
    
    ArrayList<PVector> bench = this.getPoints("bench.geojson");
    ArrayList<PVector> bicycle = this.getPoints("bicycle_parking.geojson");
      
    for(int i  = 0; i < this.land.satellite.getVertexCount();i++) {
   
      PVector coord = new PVector();
      this.land.satellite.getVertex(i,coord);
      float nearestPicNicTableDistance = 250; 
      float nearestBykeParkingDistance = 250;
      
      for(int j = 0; j < bench.size();j++) {
        PVector ip = bench.get(j);
        float dist = dist(coord.x,coord.y,ip.x,ip.y);
        if(dist < nearestPicNicTableDistance) {
          nearestPicNicTableDistance = dist;
        }
      }
      
      for(int j = 0; j < bicycle.size();j++) {
        PVector ip = bicycle.get(j);
        float dist = dist(coord.x,coord.y,ip.x,ip.y);
        if(dist < nearestBykeParkingDistance) {
          nearestBykeParkingDistance = dist;
        }
      }
      this.land.satellite.setAttrib("heat",i,nearestBykeParkingDistance/250,nearestPicNicTableDistance/250);
    }
  }
}
