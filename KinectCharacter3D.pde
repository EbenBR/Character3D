import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

//--------------------------------------------------------------------------------------------------------------------------------
Kinect    kinect;
ArrayList <SkeletonData> bodies;
ArrayList <PImage> PI_Esteban;
ArrayList <TheEsteban> Esteban;
PImage    PI_Back;
int       Esteban_Sz = 10;
float     toang = 180.0/PI; // Conversion factor: radians to degrees (for debug output)
// Bitmask controlling which debug layers are visible:
//   bit 0 (1) = 3D character,  bit 1 (2) = skeleton wireframe
//   bit 2 (4) = RGB image,     bit 3 (8) = depth,  bit 4 (16) = player mask
int       view_itens = 1;

//--------------------------------------------------------------------------------------------------------------------------------
void setup()
{
  //size(800, 600, P3D);
  fullScreen(P3D);
  
  lights();
  smooth();
  frameRate(30);
  
  kinect   = new Kinect(this);
  bodies   = new ArrayList<SkeletonData>();
  PI_Esteban = new ArrayList<PImage>();
  Esteban    = new ArrayList<TheEsteban>();
  
  // Load texture atlases and upscale them by Esteban_Sz factor for sharper rendering
  PImage p1 = loadImage("tico.png");
  AmpImage(p1, p1, Esteban_Sz);
  PI_Esteban.add(p1);
  
  PImage p2 = loadImage("Esteban_skin.png");
  AmpImage(p2, p2, Esteban_Sz);
  PI_Esteban.add(p2);

  PImage p3 = loadImage("miguelito.png");
  AmpImage(p3, p3, Esteban_Sz);
  PI_Esteban.add(p3);

  PImage p4 = loadImage("paco.png");
  AmpImage(p4, p4, Esteban_Sz);
  PI_Esteban.add(p4);
  
  TheEsteban s;
  
  for (int i = 0; i < PI_Esteban.size(); i++)
  {
    s = new TheEsteban(PI_Esteban.get(i), Esteban_Sz);
    Esteban.add(s);
  }
  
  for (int i = 0; i < Esteban.size(); i++) 
    Esteban.get(i).DrawPos(width/2, height/2-100, 0);

  PI_Back = loadImage("Back.jpg");


}

//--------------------------------------------------------------------------------------------------------------------------------
void draw()
{
  background(0);

  pushMatrix();
    translate(-256, -384, -300);
    image(PI_Back, 0, 0, 2048, 1536);
  popMatrix();

  int EstebanIdx = 0;
  
  // Toggle debug overlays based on bitmask flags
  if ((view_itens & 4)>0)   // bit 2: RGB camera feed
    image(kinect.GetImage(), 0, 0, 320, 240);
  
  if ((view_itens & 8)>0)   // bit 3: depth map
    image(kinect.GetDepth(), 0, 0, 320, 240);

  if ((view_itens & 16)>0)  // bit 4: player segmentation mask
    image(kinect.GetMask(), 0, 0, 320, 240);
 
  for (int i=0; i<bodies.size (); i++) 
  {
    
    if ((view_itens & 2)>0)  // bit 1: skeleton wireframe
    {
      drawSkeleton(bodies.get(i));
    }
    
    // Wrap character index so multiple skeletons reuse available character models
    if (i<Esteban.size()) EstebanIdx = i;
    else 
    {
      int d = i%Esteban.size();
      if (d<Esteban.size()) EstebanIdx = d;
      else EstebanIdx = 0;
    }
  
    EstebanPos(bodies.get(i), EstebanIdx);
    // op codes: 1=right arm, 2=left arm, 3=left leg, 4=right leg
    EstebanAngles(bodies.get(i), Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT,  Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 2, EstebanIdx);  // Left Arm    
    EstebanAngles(bodies.get(i), Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 1, EstebanIdx); // Right Arm
    EstebanAngles(bodies.get(i), Kinect.NUI_SKELETON_POSITION_HIP_LEFT,  Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 3, EstebanIdx);        // Left Leg
    EstebanAngles(bodies.get(i), Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 4, EstebanIdx);       // Right Leg

    EstebanBodyRotate(bodies.get(i), EstebanIdx);
    //println("SRotate:"+Esteban.get(EstebanIdx).Head_rx+", "+Esteban.get(EstebanIdx).Head_ry+", "+Esteban.get(EstebanIdx).Head_rz);
    
    if ((view_itens & 1)>0)  // bit 0: 3D character
    {
      // Only draw if skeleton is actively tracked (trackingState 2 = tracked)
      if (bodies.get(i).trackingState==2)
      {
        //Esteban.get(EstebanIdx).Walk(1);
        Esteban.get(EstebanIdx).Draw();
        //println("Skeleton:"+i+", "+bodies.get(i).trackingState);
      }
    }
  }


}

//--------------------------------------------------------------------------------------------------------------------------------
void drawPosition(float posx, float posy, float posz) 
{
  noStroke();
  fill(255, 100, 255);
  text("(" + posx + ", " + posy + ", " + posz + ")", posx, posy);
}

//--------------------------------------------------------------------------------------------------------------------------------
// Maps the Kinect's normalized skeleton coordinates (0..1) to screen space.
// Uses shoulder center as the character's anchor point.
void EstebanPos(SkeletonData _s, int idx)
{
  float   sx = width;    // Scale X from Kinect [0..1] to screen width
  float   sy = height;   // Scale Y from Kinect [0..1] to screen height
  float   sz = 1e-3;     // Z scale factor (Kinect depth is in meters, compressed for display)

  //int     _j1 = Kinect.NUI_SKELETON_POSITION_HEAD;
  int     _j1 = Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER;

  if ( _s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED ) 
  {
      float x1 = _s.skeletonPositions[_j1].x*sx;
      float y1 = _s.skeletonPositions[_j1].y*sy;
      float z1 = _s.skeletonPositions[_j1].z*sz;
      Esteban.get(idx).DrawPos(x1, y1, z1);
  }
  
}

//--------------------------------------------------------------------------------------------------------------------------------
// Calculates body rotation (tilt) by comparing shoulder and hip joint positions.
// Head_ry (Y-axis rotation) is derived from the shoulder-to-shoulder vector's Z component,
// which indicates how much the user is turning left/right.
// Head_rx (X-axis rotation) is derived from the shoulder-to-hip vector's Z component,
// indicating forward/backward lean.
void EstebanBodyRotate(SkeletonData _s, int idx)
{
  float   the = 0;
  float   sx  = 1;
  float   sy  = 1;
  float   sz  = 0.1e-3;  // Z is compressed more here than position scaling for subtle rotation effect

  int _j1 = Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT;
  int _j2 = Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT;
  
  if ( _s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED && 
       _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) 
  {
      float x1 = _s.skeletonPositions[_j1].x*sx;
      float y1 = _s.skeletonPositions[_j1].y*sy;
      float z1 = _s.skeletonPositions[_j1].z*sz;
      
      float x2 = _s.skeletonPositions[_j2].x*sx;
      float y2 = _s.skeletonPositions[_j2].y*sy;
      float z2 = _s.skeletonPositions[_j2].z*sz;
      
      PVector p1  = new PVector(x1, y1, z1);
      PVector p2  = new PVector(x2, y2, z2);
      PVector v1  = new PVector(x2-x1, y2-y1, z2-z1);

      float   m = v1.mag();
      // asin of the normalized Z component gives the rotation angle around the Y axis
      // (how much the shoulders are tilted in depth)
      Esteban.get(idx).Head_ry = asin(v1.z/m);
      //println("V1:"+v1.x/m+", "+v1.y/m+", "+v1.z/m);
      
  }

  _j1 = Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER;
  _j2 = Kinect.NUI_SKELETON_POSITION_HIP_CENTER;
  
  if ( _s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED && 
       _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) 
  {
      float x1 = _s.skeletonPositions[_j1].x*sx;
      float y1 = _s.skeletonPositions[_j1].y*sy;
      float z1 = _s.skeletonPositions[_j1].z*sz;
      
      float x2 = _s.skeletonPositions[_j2].x*sx;
      float y2 = _s.skeletonPositions[_j2].y*sy;
      float z2 = _s.skeletonPositions[_j2].z*sz;
      
      PVector p1  = new PVector(x1, y1, z1);
      PVector p2  = new PVector(x2, y2, z2);
      PVector v1  = new PVector(x2-x1, y2-y1, z2-z1);

      float   m = v1.mag();
      // Negative sign because forward lean (positive Z) should tilt the character forward (negative X rotation)
      Esteban.get(idx).Head_rx = -asin(v1.z/m);
      
  }
  
}

//--------------------------------------------------------------------------------------------------------------------------------
// Calculates limb rotation angles from two tracked joints (e.g., shoulder-to-wrist).
// The 'op' parameter selects which body part to rotate: 1=right arm, 2=left arm, 3=left leg, 4=right leg.
// The angle is computed using atan2 on the limb vector, offset by 1.5*PI to align with Processing's rotation convention.
void EstebanAngles(SkeletonData _s, int _j1, int _j2, int op, int idx)
{
  //float   rho = 0;
  float   phi = 0; 
  float   the = 0;
  float   sx = width>>1;   // Kinect X is normalized [0..1], centered around width/2
  float   sy = height>>1;  // Kinect Y is normalized [0..1], centered around height/2
  float   sz = 1e-3;

  // Left Arm   //DrawBone(_s, Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, Kinect.NUI_SKELETON_POSITION_WRIST_LEFT); //mod.
  // Right Arm  //DrawBone(_s, Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT); //mod.
  // Left Leg   //DrawBone(_s, Kinect.NUI_SKELETON_POSITION_HIP_LEFT,   Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT); //mod.
  // Right Leg  //DrawBone(_s, Kinect.NUI_SKELETON_POSITION_HIP_RIGHT,   Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT); //mod.
  
  if ( _s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED && 
       _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) 
  {
      float x1 = _s.skeletonPositions[_j1].x*sx;
      float y1 = _s.skeletonPositions[_j1].y*sy;
      float z1 = _s.skeletonPositions[_j1].z*sz;
      
      float x2 = _s.skeletonPositions[_j2].x*sx;
      float y2 = _s.skeletonPositions[_j2].y*sy;
      float z2 = _s.skeletonPositions[_j2].z*sz;
      
      PVector p1  = new PVector(x1, y1, z1);
      PVector p2  = new PVector(x2, y2, z2);
      PVector v1  = new PVector(x2-x1, y2-y1, z2-z1);

      // 1.5*PI offset rotates the coordinate system so that the limb hangs downward at rest (0 angle)
      the = 1.5*PI + atan2(v1.y, v1.x);
      
      switch(op)
      {
        case 1: Esteban.get(idx).RotateLeftArm (0, phi, the);  break;
        case 2: Esteban.get(idx).RotateRightArm(0, phi, the);  break;
        case 3: Esteban.get(idx).RotateLeftLeg (0, phi, the);  break;
        case 4: Esteban.get(idx).RotateRightLeg(0, phi, the);  break;
      }
      
  }
  
}

//--------------------------------------------------------------------------------------------------------------------------------
void drawSkeleton(SkeletonData _s) 
{
  // Body
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_HEAD,            Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT,   Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_SPINE,           Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
  
  // Left Arm
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, Kinect.NUI_SKELETON_POSITION_WRIST_LEFT); //mod.
  // Right Arm
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT); //mod.

  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_HIP_LEFT,   Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
  
  // Left Leg
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_HIP_LEFT,   Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT); //mod.
  // Right Leg
  DrawBone(_s, Kinect.NUI_SKELETON_POSITION_HIP_RIGHT,   Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT); //mod.
  
}

//--------------------------------------------------------------------------------------------------------------------------------
// Draws a 3D line segment as an oriented box primitive.
// Converts the line direction to spherical coordinates (rho, phi, theta) to rotate
// a box into the correct orientation between two endpoints.
void DrawLine3D(float x1, float y1, float z1, float x2, float y2, float z2, float weight, color strokeColour)
{
  PVector p1 = new PVector(x1, y1, z1);
  PVector p2 = new PVector(x2, y2, z2);
  PVector v1 = new PVector(x2-x1, y2-y1, z2-z1);

  float   rho = v1.mag();           // Length of the line
  float   phi = acos(v1.z/rho);     // Polar angle from Z axis
  float   the = atan2(v1.y, v1.x);  // Azimuthal angle in XY plane
  
  v1.mult(0.5);  // Offset to midpoint for positioning the box
 
  pushMatrix();
  translate(x1, y1, z1);
  translate(v1.x, v1.y, v1.z);
  rotateZ(the);
  rotateY(phi);
  
  //noStroke();
  stroke(0,0,255);
  fill(strokeColour);
  box(weight, weight, p1.dist(p2));
  popMatrix();
  
  //drawPosition(x1, y1, z1);
  //noStroke();
  //fill(255, 100, 255);
  //text("(" + rho*toang + ", " + phi*toang + ", " + the*toang + ")", x1, y1, z1+100);
  
}

//--------------------------------------------------------------------------------------------------------------------------------
// Draws a single bone (line segment) between two Kinect skeleton joints.
// Only draws if both joints are tracked.
void DrawBone(SkeletonData _s, int _j1, int _j2) 
{
  float sx = width>>1;   // Kinect coords are normalized [0..1], centered to screen
  float sy = height>>1;
  float sz = 1e-3;       // Z scale (meters to pixels, compressed)
  
  noFill();
  stroke(255, 255, 255);
  if ( _s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
       _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
     
      DrawLine3D ( _s.skeletonPositions[_j1].x*sx, _s.skeletonPositions[_j1].y*sy, _s.skeletonPositions[_j1].z*sz, 
                   _s.skeletonPositions[_j2].x*sx, _s.skeletonPositions[_j2].y*sy, _s.skeletonPositions[_j2].z*sz,
                   22, color(255));  

      //println(_s.skeletonPositions[_j1].x*sx + ", " + _s.skeletonPositions[_j1].y*sy + ", " + _s.skeletonPositions[_j1].z*sz);
      
  }
}

//--------------------------------------------------------------------------------------------------------------------------------
void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }

  synchronized(bodies) 
  {
    bodies.add(_s);
  }
  
}

//--------------------------------------------------------------------------------------------------------------------------------
void disappearEvent(SkeletonData _s) 
{
  
  synchronized(bodies) 
  {
    for (int i=bodies.size()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.remove(i);
      }
    }
  }
  
}

//--------------------------------------------------------------------------------------------------------------------------------
void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  
  synchronized(bodies) 
  {
    for (int i=bodies.size()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.get(i).copy(_a);
        break;
      }
    }
  }
  
}

//---------------------------------------------------------
//---------------------------------------------------------
// Keyboard handler: toggles debug view layers using XOR (bit flip).
// Press 1-5 to toggle: 1=3D character, 2=skeleton, 3=RGB, 4=depth, 5=mask
void keyPressed() 
{
  switch (key)
  {
    case '1': view_itens ^= 1; break;  // Toggle bit 0: 3D character
    case '2': view_itens ^= 2; break;  // Toggle bit 1: skeleton wireframe
    case '3': view_itens ^= 4; break;  // Toggle bit 2: RGB camera feed
    case '4': view_itens ^= 8; break;  // Toggle bit 3: depth visualization
    case '5': view_itens ^= 16; break; // Toggle bit 4: player mask
  }
  
}
