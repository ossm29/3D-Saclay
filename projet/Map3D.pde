/**
 * Map3D Class
 * @version  1.0.0
 * @author   Yves BLAKE (2021/Jan/30)
 * Handles Elevation 3D Map computations from IGN RGE Alti open data.
 * @see https://geoservices.ign.fr/ressources_documentaires/Espace_documentaire/MODELES_3D/RGE_ALTI/DC_RGEALTI_2-0.pdf
 * Convert coordinates beetween WGS84 GPS geographic coordinates, Lambert93 map projection coordinates and Object space coordinates systems
 * @see http://pp.ige-grenoble.fr/pageperso/picardgh/enseignement/fichiers/Teledetection_M1/ResumeCours/intro-gis.pdf
 */

public class Map3D {

  /**
   * Elevation data cell size, in meters
   */
  final static double cellSize = 5.00d;
  /**
   * Number of cells columns
   */
  final static int columns = 1000;
  /**
   * Map width
   */
  final static double width = Map3D.columns * Map3D.cellSize;
  /**
   * Number of cells rows
   */
  final static int rows = 600;
  /**
   * Map height
   */
  final static double height = Map3D.rows *  Map3D.cellSize; 
  /**
   * Lower left X origin
   */
  final static double xllCorner = 637500.00d;
  /**
   * Lower Left Y origin 
   */
  final static double yllCorner = 6844000.00d;
  /**
   * Default value when no elevation data found
   */
  final static double noData = -327.68d;
  /**
   * Object height scale applied to real elevation data
   */
  final static float heightScale = 2.5f;
  /**
   * Elevation data
   */
  final byte data[];
  /**
   * Set 3D (true) or 2D (false) mode
   */
  final boolean mode3D;

  /**
   * Returns a Map3D object. 
   * 
   * @param  fileName  IGN Alti data file name 
   */
  Map3D(String fileName) {

    // Check ressources
    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Map3D elevation file " + fileName + " not found.");
      exitActual();
    }

    // Load RGE Alti elevation heightmap
    this.data = loadBytes(fileName);
    
    // Force flat projection if false (for debug purposes)
    this.mode3D = true;

  }

  /**
   * Retrieve elevation found at map projection coordinates.
   * @param  xm        X coordinate, Lambert 93 projection (meters)
   * @param  ym        Y coordinate, Lambert 93 projection (meters)
   * @return           Elevation (meters)
   */
  private double getElevation(double xm, double ym) {
    int column = (int) ((xm - Map3D.cellSize/2.0d - Map3D.xllCorner) / Map3D.cellSize);
    int row = (int) ((ym - Map3D.cellSize/2.0d - Map3D.yllCorner) / Map3D.cellSize);
    if (row < 0 || row >= Map3D.rows || column < 0 || column >= Map3D.columns)
      return Map3D.noData;
    else {
      if (this.mode3D) {
        // Default mode 3D heightmap (Big-endian)
        int index = 2 * ((row * Map3D.columns) + column);
        return (double)((Map3D.this.data[index] << 8) | (Map3D.this.data[index+1] & 0xFF))/100.0d;
      } else
        // 2D near flat simulation (debug)
        return 0.01d;
    }
  }

  /**
   * GeoPoint class. 
   * WGS84 Geographic coordinates
   * The WGS84 coordinates system is used by GPS
   * French RGF93 coordinate system is equivalent
   */
  class GeoPoint {

    /**
     * WGS84 longitude, in decimal degrees
     */
    double longitude;
    /**
     * WGS84 latitude, in decimal degrees
     */
    double latitude;
    /**
     * Elevation, in meters. Contains noData value when not found.
     */
    double elevation;

    /**
     * Create Geographic coordinates from WGS84 longitude and latitude
     * Elevation is retrieved from IGN data
     * @param  longitude   Longitude (DD decimal degrees)
     * @param  latitude    Latitude (DD decimal degrees)
     */
    GeoPoint(double longitude, double latitude) {
      this(longitude, latitude, 0.0d);
    }

    /**
     * Create Geographic coordinates object from WGS84 longitude, latitude and elevation
     * When not specified, elevation is retrieved from IGN data
     * @param  longitude  Longitude (DD decimal degrees)
     * @param  latitude   Latitude (DD decimal degrees)
     * @param  elevation  Elevation (meters)
     */
    GeoPoint(double longitude, double latitude, double elevation) {
      this.longitude = longitude;
      this.latitude = latitude;
      if (elevation > 0.0d)
        this.elevation = elevation;
      else {
        this.elevation = 0;
        MapPoint mp = new MapPoint(this);
        this.elevation = mp.em;
      }
    }

    /**
     * Create Geographic coordinates object from Map projection coordinates
     * When not specified, elevation is retrieved from IGN data
     * @param  mp        Map projection coordinates
     */
    GeoPoint(MapPoint mp) {
      double[] gps = Geodesie.wgs84(mp.xm, mp.ym);
      this.longitude = Math.round(gps[0] * 1e7d) / 1e7d;
      this.latitude = Math.round(gps[1] * 1e7d) / 1e7d;
      if (mp.em > 0.0d)
        this.elevation = mp.em;
      else
        mp = new MapPoint(mp.xm, mp.ym);
      this.elevation = mp.em;
    }

    /**
     * Create Geographic coordinates from Object space coordinates
     * When not specified, elevation is retrieved from IGN data
     * @param  op        Object space coordinates
     */
    GeoPoint(ObjectPoint op) {
      this(new MapPoint(op));
    }

    /**
     * Check if current point is inside valid Geographic coordinates area
     * @return           true if current point is inside Map
     */
    boolean inside() {
      return new MapPoint(this).inside();
    }

    /**
     * String representation
     * @return           GeoPoint String representation
     */
    public String toString() {
      return "longitude = " 
        + String.valueOf(Math.round(this.longitude * 1e7)/1e7) 
        + ", latitude = " 
        + String.valueOf(Math.round(this.latitude * 1e7)/1e7)
        + ", elevation = " 
        + String.valueOf(Math.round(this.elevation * 1e7)/1e7);
    }
  }

  /**
   * MapPoint class. 
   * Lambert93 projection coordinates, 
   * X/Y Origins are LowerLeft coordinates (xllCorner, yllCorner) 
   */
  class MapPoint {

    /**
     * Lambert93 X coordinate, in meters
     */
    double xm;
    /**
     * Lambert93 Y coordinate, in meters
     */
    double ym;
    /**
     * Elevation, in meters. Contains noData value when not found.
     */
    double em;

    /**
     * Create Map projection coordinates object from tiles column and row
     * Elevation is retrieved from IGN data
     * @param  column    0 based column index (0 to columns-1)
     * @param  row       0 based row index (0 to rows-1)
     */
    MapPoint(int column, int row) {
      this(
        Map3D.xllCorner + (double)column * Map3D.cellSize, 
        Map3D.yllCorner + (double)row * Map3D.cellSize, 
        0.0d
        );
    }

    /**
     * Create Map projection coordinates object from projection X, Y coordinates
     * Elevation is retrieved from IGN data
     * @param  xm        X coordinate, Lambert 93 projection (meters)
     * @param  ym        Y coordinate, Lambert 93 projection (meters)
     */
    MapPoint(double xm, double ym) {
      this(xm, ym, 0.0d);
    }

    /**
     * Create Map projection coordinates object from projection X, Y coordinates & height
     * When not specified, elevation is retrieved from IGN data
     * @param  xm        X coordinate, Lambert 93 projection (meters)
     * @param  ym        Y coordinate, Lambert 93 projection (meters)
     * @param  em        Elevation (meters)
     */
    MapPoint(double xm, double ym, double em) {
      this.xm = xm;
      this.ym = ym;
      if (em > 0.0d)
        this.em = em;
      else
        this.em = Map3D.this.getElevation(this.xm, this.ym);
    }

    /**
     * Create Map projection coordinates object from WGS84 Geographic coordinates
     * When not specified, elevation is retrieved from IGN data
     * @param  gp        Geographic coordinates object
     */
    MapPoint(GeoPoint gp) {
      double[] lambert93 = Geodesie.lambert93(gp.longitude, gp.latitude);
      this.xm = Math.round(lambert93[0] * 1e2d) / 1e2d; 
      this.ym = Math.round(lambert93[1] * 1e2d) / 1e2d;
      if (gp.elevation > 0.0d)
        this.em = gp.elevation;
      else
        this.em = Map3D.this.getElevation(this.xm, this.ym);
    }

    /**
     * Create Map projection coordinates object from Object coordinates
     * When not specified, elevation is retrieved from IGN data
     * @param  op        Object coordinates object
     */
    MapPoint(ObjectPoint op) {
      this.xm = (double)op.x + Map3D.xllCorner + Map3D.width/2.0d;
      this.ym = Map3D.yllCorner - (double)op.y + Map3D.height/2.0d;
      if (op.z > 0.0f)
        this.em = Math.round(100.0d * (double)op.z / Map3D.heightScale) / 100.0d;
      else
        this.em = Map3D.this.getElevation(this.xm, this.ym);
    }

    /**
     * Check if current point is inside valid Map projection coordinates area
     * @return           true if current point is inside Map
     */
    boolean inside() {
      return 
        this.xm >= Map3D.xllCorner
        && this.xm < Map3D.xllCorner + Map3D.width 
        && this.ym >= Map3D.yllCorner
        && this.ym < Map3D.yllCorner + Map3D.height;
    }

    /**
     * String representation
     * @return           MapPoint String representation
     */
    public String toString() {
      return "xm = " 
        + String.valueOf(Math.round(this.xm * 1e7)/1e7) 
        + ", ym = " 
        + String.valueOf(Math.round(this.ym * 1e7)/1e7)
        + ", em = " 
        + String.valueOf(Math.round(this.em * 1e7)/1e7);
    }
  }

  /**
   * ObjectPoint class. 
   * Object space coordinates, centered at 0,0,0
   * Visible viewport bounds :
   * X from -map width/2 (left) to +map width/2 (right)
   * Y from -map height/2 (front) to +map height/2 (rear)
   * Z from 0 (bottom) to maximum visible (up)
   */
  class ObjectPoint {

    /**
     * Object space X coordinate, in meters
     */
    float x;
    /**
     * Object space Y coordinate, in meters
     */
    float y;
    /**
     * Scaled elevation, in meters. Contains noData value when not found.
     */
    float z;

    /**
     * Create Object space coordinates object from x,y coordinates
     * elevation is retrieved and scaled from IGN data
     * @param  x         Object space x
     * @param  y         Object space y
     */
    ObjectPoint(float x, float y) {
      this(x, y, 0.0f);
    }

    /**
     * Create Object space coordinates object from x,y,z coordinates
     * When not specified, elevation is retrieved and scaled from IGN data
     * @param  x         Object space x
     * @param  y         Object space y
     * @param  z         Object space z
     */
    ObjectPoint(float x, float y, float z) {
      this.x = x;
      this.y = y;
      if (z > 0.0f)
        this.z = z;
      else {
        this.z = 0;
        MapPoint mp = new MapPoint(this);
        this.z = (float)(Map3D.heightScale * mp.em);
      }
    }

    /**
     * Create Object space coordinates object from Geographic coordinates
     * elevation is scaled from IGN data
     * @param  gp        Geographic coordinates object
     */
    ObjectPoint(GeoPoint gp) {
      this(new MapPoint(gp));
    }

    /**
     * Create Object space coordinates object from Map projection coordinates
     * elevation is scaled from IGN data
     * @param  mp        Map projection coordinates object
     */
    ObjectPoint(MapPoint mp) {
      this.x = (float)(mp.xm - Map3D.xllCorner - Map3D.width/2.0d);
      this.y = (float)(-mp.ym + Map3D.yllCorner + Map3D.height/2.0d);
      this.z = (float)(Map3D.heightScale * mp.em);
    }

    /**
     * Returns Object space coordinates object as a PVector
     * @return           Object space coordinates as PVector
     */
    PVector toVector() {
      return new PVector(this.x, this.y, this.z);
    }

    /**
     * Returns Object space normalized coordinates object as a PVector
     * @return           Object space normalized coordinates as PVector
     */
    PVector toNormal() {
      return new PVector(this.x, this.y, this.z).normalize();
    }

    /**
     * Check if current point is inside valid Object space area 
     * @return           true if current point is inside Map
     */
    boolean inside() {
      return new MapPoint(this).inside();
    }

    /**
     * String representation
     * @return           ObjectPoint String representation
     */
    public String toString() {
      return "x = " 
        + String.valueOf(Math.round(this.x * 1e2)/1e2) 
        + ", y = " 
        + String.valueOf(Math.round(this.y * 1e2)/1e2)
        + ", z = " 
        + String.valueOf(Math.round(this.z * 1e2)/1e2);
    }
  }
}

/**
 * Geodesie Class
 * Calculs de conversion longitude, latitude WGS84 - X, Y Lambert93
 * @see https://geodesie.ign.fr/contenu/fichiers/documentation/algorithmes/notice/NTG_71.pdf
 */
static class Geodesie {

  /**
   * Projection Class
   */
  static class Projection {
    /**
     * Paramètres de l'ellipsoïde de référence RGF93 (IAG GRS 80)
     */
    // 1/2 grand axe de l'ellipsoïde (mètre)
    static double ra = 6378137.0d;
    // Facteur d'aplatissement
    static double rf = 1.0d / 298.257222101d;
    // 1/2 petit axe de l'ellipsoïde (mètre) - Non utilisé directement
    static double rb = Projection.ra * (1.0d - Projection.rf);
    // Première excentricité de l'ellipsoïde de référence
    static double e = Math.sqrt((Math.pow(Projection.ra, 2.0d) - Math.pow(Projection.rb, 2.0d)) / Math.pow(Projection.ra, 2.0d));
    // Hauteur au dessus de l'ellipsoïde (en mètre)
    //static double rh;
    /**
     * Paramètres de la projection Lambert93
     * False Easting : Xo = 700 000 m (3° Est Greenwich)
     * False Northing : Yo = 6 600 000 m (46°30' N)
     */
    // Exposant de la projection
    static double n = 0.725607765d;
    // Constante de la projection
    static double c = 11754255.426d;
    // Coordonnées en projection du pôle
    static double xs = 700000.0d, ys = 12655612.05d;
    // Latitude du méridien d'origine
    //static double phi0 = Math.toRadians(46.5d); // latitude origine 46° 30' 0.0" N
    // Longitude du méridien d'origine 
    static double lambda0 = Math.toRadians(3.0d); // Méridien central
    // Longitude du 1er parallèle automécoïque
    //static double phi1 = Math.toRadians(44.0d); // Parrallèle 1 44° 0' 0.0" N
    // Longitude du 2ème parallèle automécoïque
    //static double phi2  = Math.toRadians(49.0d); // Parrallèle 2 49° 0' 0.0" N
  }

  /**
   * Convert WGS84 longitude, latitude (decimal degrees) to Lambert93 Map projection x,y (meters)
   * @param  longitude  WGS84 longitude (Decimal degrees)
   * @param  latitude   WGS84 latitude (Decimal degrees)
   * @return            Lambert93 coordinates array (meters)
   */
  static double[] lambert93(double longitude, double latitude) {
    double lambda = Math.toRadians(longitude);
    double phi = Math.toRadians(latitude);
    return alg03(lambda, phi, Projection.n, Projection.c, Projection.e, Projection.lambda0, Projection.xs, Projection.ys);
  }

  /**
   * Convert Lambert93 Map projection x,y (meters) into WGS84 longitude, latitude (decimal degrees)  
   * @param  xm :      X coordinate, Lambert 93 projection (meters)
   * @param  ym :      Y coordinate, Lambert 93 projection (meters)
   * @return           WGS84 coordinates array (Decimal degrees)
   */
  static double[] wgs84(double xm, double ym) {
    double[] ll = alg04(xm, ym, Projection.n, Projection.c, Projection.e, Projection.lambda0, Projection.xs, Projection.ys);
    ll[0] = Math.toDegrees(ll[0]);
    ll[1] = Math.toDegrees(ll[1]);
    return ll;
  }

  /**
   * Calcul de la latitude isométrique sur un ellipsoïde de première excentricité e au point de latitude ϕ.
   * @param    ϕ :  latitude.
   * @param    e :  première excentricité de l’ellipsoïde.
   * @return   L :  latitude isométrique.
   */
  static private double alg01(double phi, double e) {
    return Math.log( Math.tan(Math.PI/4.0d + phi/2.0d) * Math.pow((1.0d - e * Math.sin(phi)) / (1.0d + e * Math.sin(phi)), e/2.0d) );
  }

  /**
   * Calcul de la latitude ϕ à partir de la latitude isométrique L
   * @param    L :  latitude isométrique.
   * @param    e :  première excentricité de L’ellipsoïde.
   * @return   ϕ :  latitude en radian.
   */
  static private double alg02(double li, double e ) {
    double epsilon = 1.0E-10;
    double lic, lif;
    lic = (2.0d * Math.atan(Math.exp(li)) - Math.PI/2.0d);
    do {
      lif = lic;
      lic = 2.0d * Math.atan(Math.pow(((1.0d + e * Math.sin(lif)) / (1.0d - e * Math.sin(lif))), e / 2.0d) * Math.exp(li)) - Math.PI / 2.0d;
    } while (Math.abs(lic - lif) > epsilon);
    return lic;
  }

  /**
   * Transformation de coordonnées géographiques en projection conique conforme de Lambert
   * @param    λ : longitude par rapport au méridien origine.
   * @param    ϕ : latitude.
   * @param    n : exposant de la projection.
   * @param    c : constante de la projection.
   * @param    e : première excentricité de l’ellipsoïde.
   * @param    λ0 : longitude de l’origine par rapport au méridien origine.
   * @param    Xs, Ys : coordonnées en projection du pôle.
   * @return   X, Y : coordonnées en projection du point.
   */
  static private double[] alg03(double lambda, double phi, double n, double c, double e, double lambda0, double xs, double ys ) {
    double lat = alg01(phi, e);
    double x = xs + c * Math.exp(-n * lat) * Math.sin(n * (lambda - lambda0));
    double y = ys - c * Math.exp(-n * lat) * Math.cos(n * (lambda - lambda0));
    double[] xy={x, y};
    return xy;
  }

  /**
   * Passage d'une projection Lambert vers des coordonnées géographiques
   * @param    X, Y : coordonnées en projection conique conforme de Lambert du point.
   * @param    n : exposant de la projection.
   * @param    c : constante de la projection.
   * @param    e : première excentricité de l’ellipsoïde.
   * @param    λ0 : longitude de l’origine par rapport au méridien origine.
   * @param    Xs, Ys : coordonnées en projection du pôle.
   * @return   λ : longitude par rapport au méridien origine.
   * @return   ϕ : latitude.
   */
  static private double[] alg04(double x, double y, double n, double c, double e, double lambda0, double xs, double ys ) {
    double gamma = Math.atan((x - xs) / (ys - y));
    double longitude = lambda0 + gamma / n;
    double r = Math.sqrt(Math.pow(x - xs, 2.0d) + Math.pow(y - ys, 2.0d));
    double li =  (-1.0d / n) * Math.log(Math.abs(r / c));
    double latitude = alg02(li, e);
    double[] ll={longitude, latitude};
    return ll;
  }

  /**
   * Tests unitaires (algorithmes et interface)
   */
  //public void tests() {

  //  double[] xy, ll;

  //  // alg01 - Calcul de la latitude isométrique sur ellipsoide de 1ère excentricité e au point de latitude Phi
  //  System.out.println("Attendu -> 1.00552653648");
  //  System.out.println("Obtenu  -> " + truncate(alg01(0.872664626d, 0.08199188998d), 11)); 
  //  System.out.println("Attendu -> -0.3026169006");
  //  System.out.println("Obtenu  -> " + truncate(alg01(-0.29999999997d, 0.08199188998d), 11)); 
  //  System.out.println("Attendu -> 0.2");
  //  System.out.println("Obtenu  -> " + truncate(alg01(0.19998903369d, 0.08199188998d), 11)); 

  //  // alg02 - Calcul de la latitude à partir de la latitude isométrique
  //  System.out.println("Attendu -> 0.872664626");
  //  System.out.println("Obtenu  -> " + truncate(alg02(1.00552653648d, 0.08199188998d), 11)); 
  //  System.out.println("Attendu -> -0.29999999997");
  //  System.out.println("Obtenu  -> " + truncate(alg02(-0.3026169006d, 0.08199188998d), 11)); 
  //  System.out.println("Attendu -> 0.19998903369");
  //  System.out.println("Obtenu  -> " + truncate(alg02(0.2d, 0.08199188998d), 11)); 

  //  double e, n, c, lambda0, xs, ys;

  //  // alg03 - Transformation de coordonnées géographiques en projection conique conforme de Lambert
  //  e = 0.0824832568d;
  //  n = 0.760405966d;
  //  c = 11603796.9767d;
  //  lambda0 = 0.04079234433d;
  //  xs = 600000.0d;
  //  ys = 5657616.674d;
  //  xy = alg03(0.145512099d, 0.872664626d, n, c, e, lambda0, xs, ys);
  //  System.out.println("Attendu -> X : 1029705.0818 m, Y : 272723.851 m");
  //  System.out.println("Obtenu  -> X : " + truncate(xy[0], 4) + " m, Y : " + truncate(xy[1], 4)  + " m");

  //  // alg04 - Passage d'une projection Lambert vers des coordonnées géographiques
  //  e = 0.0824832568d;
  //  n = 0.760405966d;
  //  c = 11603796.9767d;
  //  lambda0 = 0.04079234433d;
  //  xs = 600000.0d;
  //  ys = 5657616.674d;
  //  ll = alg04(1029705.083d, 272723.849d, n, c, e, lambda0, xs, ys);
  //  System.out.println("Attendu -> Lon : 0.1455120993 , Lat : 0.8726646257");
  //  System.out.println("Obtenu  -> Lon : " + truncate(ll[0], 10) + " , Lat : " + truncate(ll[1], 10));

  //  // lambert93 : Convertit un geopoint longitude, latitude (degrés décimaux wgs84) en coordonnées projetées X,Y (mètres Lambert93)
  //  xy = lambert93(2.1504057d, 48.7201061d);
  //  System.out.println("Attendu -> X : 637500.0 m, Y : 6847000.0 m");
  //  System.out.println("Obtenu  -> X : " + truncate(xy[0], 2) + " m, Y : " + truncate(xy[1], 2)  + " m");

  //  // wgs84 - Convertit un point de coordonnées projetées X,Y (mètres Lambert93) en longitude, latitude (degrés décimaux WGS84)
  //  ll = wgs84(637500.0d, 6847000.0d);
  //  System.out.println("Attendu -> Lon : 2.1504057 , Lat : 48.7201061");
  //  System.out.println("Obtenu  -> Lon : " + truncate(ll[0], 7) + " , Lat : " + truncate(ll[1], 7));
  //}
  //
  //// Troncature de valeurs doubles à n décimales
  //private double truncate(double x, int decimals) {
  //  double s = Math.pow(10.0d, decimals);
  //  return ( Math.round(x*s)/s );
  //}
}

/**
 * Tests modulaires (changements de repères)
 */
//void test() {

//  MapPoint mp;
//  ObjectPoint op;
//  GeoPoint gp;
//  mp = new MapPoint(this.xllCorner, this.yllCorner);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  mp = new MapPoint((int)0, (int)0);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  op = new ObjectPoint(mp);
//  println("op: ", op.x, op.y, op.z);
//  mp = new MapPoint(op);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  gp = new GeoPoint(mp);
//  println("gp: ", gp.longitude, gp.latitude, gp.elevation);
//  gp = new GeoPoint(op);
//  println("gp: ", gp.longitude, gp.latitude, gp.elevation);
//  mp = new MapPoint(gp);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  gp = new GeoPoint(2.1508442d, 48.6931245d);
//  println("gp: ", gp.longitude, gp.latitude, gp.elevation);
//  op = new ObjectPoint(gp);
//  println("op: ", op.x, op.y, op.z);
//  op = new ObjectPoint(-2500.0f, +1500f);
//  println("op: ", op.x, op.y, op.z);
//  gp = new GeoPoint(op);
//  println("gp: ", gp.longitude, gp.latitude, gp.elevation);
//  println("-------------------------------------");
//  op = new ObjectPoint(+2500.0f, -1500f);
//  println("op: ", op.x, op.y, op.z);
//  gp = new GeoPoint(op);
//  println("gp: ", gp.longitude, gp.latitude, gp.elevation);
//  println("-------------------------------------");
//  mp = new MapPoint(this.xllCorner+this.width-this.cellSize, this.yllCorner+height-this.cellSize);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  mp = new MapPoint(this.columns-1, this.rows-1);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  op = new ObjectPoint(mp);
//  println("op: ", op.x, op.y, op.z);
//  mp = new MapPoint(op);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  gp = new GeoPoint(mp);
//  println("gp: ", gp.longitude, gp.latitude, gp.elevation);
//  op = new ObjectPoint(gp);
//  println("op: ", op.x, op.y, op.z);
//  gp = new GeoPoint(op);
//  println("gp: ", gp.longitude, gp.latitude, gp.elevation);
//  mp = new MapPoint(gp);
//  println("mp: ", mp.xm, mp.ym, mp.em);
//  println("-------------------------------------");
//}
