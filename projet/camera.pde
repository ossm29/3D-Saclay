class Camera 
{
  
   float radius;
   float longitude;
   float colatitude;
   float x,y,z; 
   boolean lighting;
  
   public  Camera(float longitude, float colatitude, float radius)
   {
     this.longitude = longitude;
     this.colatitude = colatitude;
     this.radius = radius;
     this.x = this.radius * sin(colatitude) * cos(longitude);
     this.y = this.radius * sin(colatitude) * sin(longitude);
     this.z = this.radius * cos(colatitude);
     this.lighting = false;
     
   }
   
   public void update(){
    camera(
      this.x, -this.y, this.z,
      0, 0, 0,
      0, 0, -1
      );
    ambientLight(0x7F, 0x7F, 0x7F);
    if (lighting)
     directionalLight(0xA0, 0xA0, 0xA0, 0, 0, -1);
    lightFalloff(0.0f, 0.0f, 1.0f);
    lightSpecular(0.0f, 0.0f, 0.0f);
  }
   
   public void adjustRadius(float offset)
   {
     if (this.radius+offset < width*0.75 && this.radius+offset > width*0.75){
      this.radius = this.radius+offset;
      this.x = radius * sin(colatitude) * cos(longitude);
      this.y = radius * sin(colatitude) * sin(longitude);
      this.z = radius * cos(colatitude);
    }
   }
   
   public void adjustLongitude(float delta)
   {
     if (this.longitude+delta > -3*PI/2 && this.longitude+delta < PI/2){
      this.longitude = this.longitude+delta;
      this.x = radius * sin(colatitude) * cos(longitude);
      this.y = radius * sin(colatitude) * sin(longitude);
    }
   }
   
   public void adjustColatitude(float delta)
   {
     if (this.colatitude+delta >= pow(10,-6) && this.colatitude+delta < PI/2){
      this.colatitude += delta;
      this.x = radius*sin(colatitude)*cos(longitude);
      this.y = radius*sin(colatitude)*sin(longitude);
      this.z = radius*cos(colatitude);
    }
   }
  
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
     } 
     else 
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
