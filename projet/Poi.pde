
class Poi {

  //Carte que l'on utilise
  Map3D map;

  /** 
   * Constructeur de la classe
   * @param map : carte
   */
  Poi(Map3D map) {
    this.map = map;
  }

  /** liste de coordonnées d’aménagements pour un fichier donné.
   * @param fileName : nom du fichier (geojson)
   * @return : tableau des points d'intérêts du fichier
   */
  JSONArray getPoints(String fileName) {

    //erreur : fichier inexistant
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
    //ArrayList<PVector> points = new ArrayList<PVector>();
    JSONArray points = new JSONArray();

    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
    }
    if (features != null) {
      //itération sur les points du fichier : on les ajoute à notre Array
      for (int f = 0; f < features.size(); f++) {
        //
        JSONObject feature = features.getJSONObject(f);

        if (!feature.hasKey("geometry")) {
          break;
        }
        JSONArray point = feature.getJSONObject("geometry").getJSONArray("coordinates");
        Map3D.GeoPoint gp = this.map.new GeoPoint(point.getFloat(0), point.getFloat(1));
        Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
        JSONArray coord = new JSONArray();
        coord.append(op.x);
        coord.append(op.y);
        coord.append(op.z);
        points.append(coord);
      }
    }
    return points;
  }
  
  /** Fonction de calcul de la distance minimale
  * @param x,y,z : point
  * @param pos : tableau de coordonnées
  * @return : coordonnées les + proches du pt (x,y,z)
  */
  
  float mindist(float x, float y, float z, JSONArray pos) {
    float dist = 0;
    if (pos.size()>0) {
      dist = dist(x, y, z, pos.getJSONArray(0).getFloat(0), pos.getJSONArray(0).getFloat(1), pos.getJSONArray(0).getFloat(2));
    }
    float current;
    //itération sur le tableau de coordonnées -> déterminer la distance minimale
    for (int i = 1; i < pos.size(); i++) {
      current = dist(x, y, z, pos.getJSONArray(i).getFloat(0), pos.getJSONArray(i).getFloat(1), pos.getJSONArray(i).getFloat(2));
      if (current<dist) {
        dist = current;
      }
    }
    return dist;
  }  


  //void mindist() {

  //  ArrayList<PVector> bench = this.getPoints("bench.geojson");
  //  ArrayList<PVector> bicycle = this.getPoints("bicycle_parking.geojson");

  //  for(int i  = 0; i < this.land.satellite.getVertexCount();i++) {

  //    PVector coord = new PVector();
  //    this.land.satellite.getVertex(i,coord);
  //    float nearestPicNicTableDistance = 250; 
  //    float nearestBykeParkingDistance = 250;

  //    for(int j = 0; j < bench.size();j++) {
  //      PVector ip = bench.get(j);
  //      float dist = dist(coord.x,coord.y,ip.x,ip.y);
  //      if(dist < nearestPicNicTableDistance) {
  //        nearestPicNicTableDistance = dist;
  //      }
  //    }

  //    for(int j = 0; j < bicycle.size();j++) {
  //      PVector ip = bicycle.get(j);
  //      float dist = dist(coord.x,coord.y,ip.x,ip.y);
  //      if(dist < nearestBykeParkingDistance) {
  //        nearestBykeParkingDistance = dist;
  //      }
  //    }
  //    //this.land.satellite.setAttrib("heat",i,nearestBykeParkingDistance/250,nearestPicNicTableDistance/250);
  //  }
  //}
}
