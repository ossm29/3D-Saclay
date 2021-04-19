class Camera 
{
  //Coordonnées
  float radius;
  float longitude;
  float colatitude;
  float x, y, z; 

  //variable d'éclairage (booléen)
  boolean lighting;

  /** 
   * Constructeur de la classe
   * @param longitude : coordonnée angulaire 1
   * @param colatitude : coordonnée angulaire 2
   * @param radius : distance 
   */
  public  Camera(float longitude, float colatitude, float radius)
  {
    this.longitude = longitude;
    this.colatitude = colatitude;
    this.radius = radius;
    //passage de coordonnées sphériques en coordonnées cartésiennes 
    this.x = this.radius * sin(colatitude) * cos(longitude);
    this.y = this.radius * sin(colatitude) * sin(longitude);
    this.z = this.radius * cos(colatitude);
    this.lighting = false;
  }

  //Procédure d'affichage
  public void update() {
    //Positionnement de la caméra avec les coordonnées cartésiennes de la classe
    camera(
      this.x, -this.y, this.z, 
      0, 0, 0, 
      0, 0, -1
      );
    ambientLight(0x7F, 0x7F, 0x7F);
    if (lighting) {
      directionalLight(0xA0, 0xA0, 0xA0, 0, 0, -1);
      lightFalloff(0.0f, 0.0f, 1.0f);
      lightSpecular(0.0f, 0.0f, 0.0f);
    }
  }

  /** Procédure d'ajustement de la distance de la caméra (zoom)
   * @param delta : variation du rayon
   */
  public void adjustRadius(float delta)
  {
    //on pose des bornes d'ajustement min et max -> impossible de trop s'éloigner / se rapprocher
    if (this.radius+delta < width*0.75 && this.radius+delta > width*0.75) {
      this.radius = this.radius+delta;
      //passage de coordonnées sphériques en coordonnées cartésiennes 
      this.x = radius * sin(colatitude) * cos(longitude);
      this.y = radius * sin(colatitude) * sin(longitude);
      this.z = radius * cos(colatitude);
    }
  }

  /** Procédure d'ajustement de la longitude
   * @param offset : variation de la longitude
   */
  public void adjustLongitude(float delta)
  {
    //on pose des bornes d'ajustement -> impossible de trop tourner
    if (this.longitude+delta > -3*PI/2 && this.longitude+delta < PI/2) {
      this.longitude = this.longitude+delta;
      //passage de coordonnées sphériques en coordonnées cartésiennes (z constant)
      this.x = radius * sin(colatitude) * cos(longitude);
      this.y = radius * sin(colatitude) * sin(longitude);
    }
  }

  /** Procédure d'ajustement de la colatitude 
   * @param delta : variation de la colatitude
   */
  public void adjustColatitude(float delta)
  {
    //on pose des bornes d'ajustement -> impossible dpasser sous le terrain
    if (this.colatitude+delta >= pow(10, -6) && this.colatitude+delta < PI/2) {
      this.colatitude += delta;
      //passage de coordonnées sphériques en coordonnées cartésiennes
      this.x = radius*sin(colatitude)*cos(longitude);
      this.y = radius*sin(colatitude)*sin(longitude);
      this.z = radius*cos(colatitude);
    }
  }

  //procédure activation / désactivation éclairage
  public void toggle()
  {
    this.lighting = (!this.lighting);
  }

  void keyPressed() 
  {

    if (key == CODED) 
    {
      switch (keyCode) 
      {
      case UP:
        adjustRadius(100);
        break;
      case DOWN:
        adjustRadius(-100);
        break;
      case LEFT:
        adjustLongitude(-100);
        break;
      case RIGHT:
        adjustLongitude(100);
        break;
      }
    } else 
    {
      switch (key) 
      {

      case '+':

        break;
      case '-':

        break;
      }
    }
  }
}
