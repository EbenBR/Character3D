//---------------------------------------------------------
//---------------------------------------------------------
// A 3D humanoid character built from textured box primitives.
// Body parts are textured using a sprite sheet (texture atlas) with UV coordinates
// mapping specific regions to head, body, arms, and legs.
class TheEsteban {

  PImage PI_Esteban;  // Texture atlas containing all body part textures

  int    PSize;       // Base scale factor for all geometry

  // Rotation angles (radians) for each body part, set from Kinect skeleton tracking
  float  LeftArm_rx  = 0, LeftArm_ry  = 0, LeftArm_rz  = 0;
  float  RightArm_rx = 0, RightArm_ry = 0, RightArm_rz = 0;
  float  LeftLeg_rx  = 0, LeftLeg_ry  = 0, LeftLeg_rz  = 0;
  float  RightLeg_rx = 0, RightLeg_ry = 0, RightLeg_rz = 0;
  float  Head_rx = 0,     Head_ry = 0,     Head_rz = 0;  // Head/body tilt

  float  Esteban_x = 0, Esteban_y = 0, Esteban_z = 0;  // World position (from Kinect shoulder center)

  // Walk animation state (not currently used in main loop)
  float  rl_rx;       // Right leg rotation
  float  ll_rx;       // Left leg rotation
  float  anginc;      // Radians per degree conversion constant
  float  rl_inc, ll_inc;  // Increment direction for pendulum-like walk cycle

  //---------------------------------------------------------
  //---------------------------------------------------------
  TheEsteban(PImage PI_Body, int PScale) 
  {
    PI_Esteban = PI_Body;

    anginc = PI/180.0;  // Converts degrees to radians for walk animation
    rl_rx  = 0;
    ll_rx  = 0;
    rl_inc =  anginc;   // Right leg swings forward (positive rotation)
    ll_inc = -anginc;   // Left leg swings backward (opposite phase)
    PSize  = PScale;
    
  }

  //---------------------------------------------------------
  //---------------------------------------------------------
  void RotateLeftArm(float rx, float ry, float rz) 
  {
    LeftArm_rx = rx;
    LeftArm_ry = ry;
    LeftArm_rz = rz;
  }

  //---------------------------------------------------------
  //---------------------------------------------------------
  void RotateRightArm(float rx, float ry, float rz) 
  {
    RightArm_rx = rx;
    RightArm_ry = ry;
    RightArm_rz = rz;
  }

  //---------------------------------------------------------
  //---------------------------------------------------------
  void RotateLeftLeg(float rx, float ry, float rz) 
  {
    LeftLeg_rx = rx;
    LeftLeg_ry = ry;
    LeftLeg_rz = rz;
  }

  //---------------------------------------------------------
  //---------------------------------------------------------
  void RotateRightLeg(float rx, float ry, float rz) 
  {
    RightLeg_rx = rx;
    RightLeg_ry = ry;
    RightLeg_rz = rz;
  }
  
  //---------------------------------------------------------
  //---------------------------------------------------------
  void DrawPos(float x, float y, float z) 
  {
    Esteban_x = x;
    Esteban_y = y;
    Esteban_z = z;
  }

  //---------------------------------------------------------
  // Renders the complete character by drawing all body parts.
  // Transform hierarchy: translate to world position, apply head/body rotation,
  // then draw each limb (arms and legs apply their own rotations relative to the body).
  //---------------------------------------------------------
  void Draw() 
  {
    noStroke();
    fill(255);

    pushMatrix();
     translate(Esteban_x, Esteban_y, Esteban_z);
      rotateX(Head_rx);
      rotateY(Head_ry);
      //rotateZ(Head_rz);
      EstebanHead();
      EstebanBody();
      EstebanArm(0);
      EstebanArm(1);
      EstebanLeg(0);
      EstebanLeg(1);
    popMatrix();
  }
  
  //---------------------------------------------------------
  // Draws the head as a textured box. The texture atlas (PI_Esteban) is divided into
  // a grid where specific regions map to each face of the cube:
  //   Row 0 (y: 0-7): top face    |  Row 1 (y: 8-16): side faces  |  Row 2 (y: 16-20): body cap
  //   Columns map to: left(0-7), front(8-15), right(16-23), back(24-31)
  //---------------------------------------------------------
  void EstebanHead() {
    
    int h1, w1, l1;
    int h2, w2, l2;
    int x1, x2;
    int y1, y2;

    pushMatrix();
  
    //translate(Esteban_x, Esteban_y, Esteban_z);
    translate(0, 0, 0);
  
    beginShape(QUADS);
  
    texture(PI_Esteban);
  
    // Box dimensions: width=8, height=8, depth=6 (all scaled by PSize)
    w1 = -4*PSize;  w2 = 4*PSize;
    h1 = -4*PSize;  h2 = 4*PSize;
    l1 = -3*PSize;  l2 = 3*PSize;
  
    // -X "left" face - samples from atlas columns 0-7, rows 8-16
    x1 = 0;       x2 = 7*PSize;
    y1 = 8*PSize; y2 = 16*PSize;
    
    vertex(w1, h1, l1, x1, y1);
    vertex(w1, h1, l2, x2, y1);
    vertex(w1, h2, l2, x2, y2);
    vertex(w1, h2, l1, x1, y2);
  
    // +Z "front" face - samples from atlas columns 8-15, rows 8-16
    x1 = 8*PSize; x2 = 16*PSize;
    vertex(w1, h1, l2, x1, y1);
    vertex(w2, h1, l2, x2, y1);
    vertex(w2, h2, l2, x2, y2);
    vertex(w1, h2, l2, x1, y2);
  
    // +X "right" face - samples from atlas columns 16-23, rows 8-16
    x1 = 16*PSize; x2 = 24*PSize;
    vertex(w2, h1, l2, x1, y1);
    vertex(w2, h1, l1, x2, y1);
    vertex(w2, h2, l1, x2, y2);
    vertex(w2, h2, l2, x1, y2);
  
    // -Z "back" face - samples from atlas columns 24-31, rows 8-16
    x1 = 24*PSize; x2 = 32*PSize;
    vertex(w2, h1, l1, x1, y1);
    vertex(w1, h1, l1, x2, y1);
    vertex(w1, h2, l1, x2, y2);
    vertex(w2, h2, l1, x1, y2);
  
    // -Y "top" face - samples from atlas columns 8-15, rows 0-7
    x1 = 8*PSize; x2 = 16*PSize;
    y1 = 0*PSize; y2 =  7*PSize;
    vertex(w1, h1, l1, x1, y1);
    vertex(w2, h1, l1, x2, y1);
    vertex(w2, h1, l2, x2, y2);
    vertex(w1, h1, l2, x1, y2);
  
    // +Y "bottom" face - samples from atlas columns 16-23, rows 0-7
    x1 = 16*PSize; x2 = 24*PSize;
    vertex(w1, h2, l2, x1, y1);
    vertex(w2, h2, l2, x2, y1);
    vertex(w2, h2, l1, x2, y2);
    vertex(w1, h2, l1, x1, y2);
  
    endShape();
    
    popMatrix();
    
  }
  
  //---------------------------------------------------------
  // Draws the torso as a textured box, offset 10*PSize below the head.
  // Texture atlas regions: body uses columns 16-40, rows 16-32 (different from head).
  //---------------------------------------------------------
  void EstebanBody() {
    
    int h1, w1, l1;
    int h2, w2, l2;
    int x1, x2;
    int y1, y2;
  
    pushMatrix();
  
    //translate(Esteban_x, Esteban_y+10, Esteban_z);
    translate(0, 10*PSize, 0);
  
    beginShape(QUADS);
  
    texture(PI_Esteban);
  
    l1 = -2*PSize; l2 =  2*PSize;
    w1 = -4*PSize; w2 =  4*PSize; 
    h1 = -6*PSize; h2 =  6*PSize;

    // -X "left" face
    x1 = 16*PSize; x2 = 20*PSize;
    y1 = 20*PSize; y2 = 32*PSize;
    vertex(w1, h1, l1, x1, y1);
    vertex(w1, h1, l2, x2, y1);
    vertex(w1, h2, l2, x2, y2);
    vertex(w1, h2, l1, x1, y2);

    // +Z "front" face
    x1 = 20*PSize; x2 = 28*PSize;
    vertex(w1, h1, l2, x1, y1);
    vertex(w2, h1, l2, x2, y1);
    vertex(w2, h2, l2, x2, y2);
    vertex(w1, h2, l2, x1, y2);

    // +X "right" face
    x1 = 28*PSize; x2 = 32*PSize;
    vertex( w2, h1, l2, x1, y1);
    vertex( w2, h1, l1, x2, y1);
    vertex( w2, h2, l1, x2, y2);
    vertex( w2, h2, l2, x1, y2);
  
    // -Z "back" face
    x1 = 32*PSize; x2 = 40*PSize;
    vertex(w2, h1, l1, x1, y1);
    vertex(w1, h1, l1, x2, y1);
    vertex(w1, h2, l1, x2, y2);
    vertex(w2, h2, l1, x1, y2);
  
    // -Y "top" face
    x1 = 20*PSize; x2 = 28*PSize;
    y1 = 16*PSize; y2 = 20*PSize;
    vertex(w1, h1, l1, x1, y1);
    vertex(w2, h1, l1, x2, y1);
    vertex(w2, h1, l2, x2, y2);
    vertex(w1, h1, l2, x1, y2);
  
    // +Y "bottom" face
    x1 = 28*PSize; x2 = 36*PSize;
    vertex(w1, h2, l2, x1, y1);
    vertex(w2, h2, l2, x2, y1);
    vertex(w2, h2, l1, x2, y2);
    vertex(w1, h2, l1, x1, y2);
  
    endShape();
    
    popMatrix();
    
  }
  
  //---------------------------------------------------------
  // Draws an arm as a textured box. op=0 for left arm, op=1 for right arm.
  // Arms are positioned at shoulder offsets (dd = 6*PSize from center) and
  // rotated independently based on Kinect tracking data.
  //---------------------------------------------------------
  void EstebanArm(int op) {
    
    int h1, w1, l1;
    int h2, w2, l2;
    int x1, x2;
    int y1, y2;
  
    float dd = 6.0*PSize;  // Shoulder offset from body center (half of body width)
  
    pushMatrix();

    // Position at shoulder joint and apply limb rotation from Kinect data
    if (op==0)
    {
      translate(dd, dd, 0);
      rotateX(LeftArm_rx);
      rotateY(LeftArm_ry);
      rotateZ(LeftArm_rz);
    }
    else
    {
      translate(-dd, dd, 0);
      rotateX(RightArm_rx);
      rotateY(RightArm_ry);
      rotateZ(RightArm_rz);
    }
    
    beginShape(QUADS);
  
    texture(PI_Esteban);
  
    l1 = -2*PSize;   l2 =  2*PSize;
    w1 = -2*PSize;   w2 =  2*PSize; 
    h1 = -2*PSize;   h2 =  10*PSize;
  
    // -Z "back" face
    x1 = 40*PSize; x2 = 44*PSize;
    y1 = 20*PSize; y2 = 32*PSize;
    vertex(w2,  h1, l1, x1, y1);
    vertex(w1,  h1, l1, x2, y1);
    vertex(w1,  h2, l1, x2, y2);
    vertex(w2,  h2, l1, x1, y2);
  
    // -X "left" face
    x1 = 44*PSize; x2 = 48*PSize;
    vertex(w1, h1, l1, x1, y1);
    vertex(w1, h1, l2, x2, y1);
    vertex(w1, h2, l2, x2, y2);
    vertex(w1, h2, l1, x1, y2);
  
    // +Z "front" face
    x1 = 48*PSize; x2 = 52*PSize;
    vertex(w1, h1, l2, x1, y1);
    vertex(w2, h1, l2, x2, y1);
    vertex(w2, h2, l2, x2, y2);
    vertex(w1, h2, l2, x1, y2);
  
    // +X "right" face
    x1 = 52*PSize; x2 = 56*PSize;
    vertex(w2, h1, l2, x1, y1);
    vertex(w2, h1, l1, x2, y1);
    vertex(w2, h2, l1, x2, y2);
    vertex(w2, h2, l2, x1, y2);
  
    // -Y "top" face
    y1 = 16*PSize;  y2 = 20*PSize;
    x1 = 44*PSize;  x2 = 48*PSize;
    vertex(w1, h1, l1, x1, y1);
    vertex(w2, h1, l1, x2, y1);
    vertex(w2, h1, l2, x2, y2);
    vertex(w1, h1, l2, x1, y2);
  
    // +Y "bottom" face
    x1 = 48*PSize;  x2 = 52*PSize;
    vertex(w1, h2, l2, x1, y1);
    vertex(w2, h2, l2, x2, y1);
    vertex(w2, h2, l1, x2, y2);
    vertex(w1, h2, l1, x1, y2);
  
    endShape();

    popMatrix();
    
  }
  
  //---------------------------------------------------------
  // Draws a leg as a textured box. op=0 for left leg, op=1 for right leg.
  // Legs are positioned at hip offsets (dd = 18*PSize below body center) and
  // rotated independently based on Kinect tracking data.
  //---------------------------------------------------------
  void EstebanLeg(int op) {
    
    int h1, w1, l1;
    int h2, w2, l2;
    int x1, x2;
    int y1, y2;
  
    float dd = 18.0*PSize;
  
    pushMatrix();
  
    if (op==0)
    {
      translate(-2*PSize, dd, 00);
      rotateX(LeftLeg_rx);
      rotateY(LeftLeg_ry);
      rotateZ(LeftLeg_rz);
      //translate(-2*PSize, dy, dz);
    }
    else
    {
      translate(2*PSize, dd, 00);
      rotateX(RightLeg_rx);
      rotateY(RightLeg_ry);
      rotateZ(RightLeg_rz);
      //translate(+2*PSize, dy, dz);
    }
  
    beginShape(QUADS);
  
    texture(PI_Esteban);
  
    l1 = -2*PSize;   l2 =  2*PSize;
    w1 = -2*PSize;   w2 =  2*PSize; 
    h1 = -2*PSize;   h2 =  10*PSize;
 
    // -Z "back" face
    y1 = 20*PSize; y2 = 32*PSize;
    x1 =  0*PSize; x2 =  4*PSize;
    vertex( w2, h1, l1, x1, y1);
    vertex( w1, h1, l1, x2, y1);
    vertex( w1, h2, l1, x2, y2);
    vertex( w2, h2, l1, x1, y2);
  
    // -X "left" face
    x1 = 4*PSize; x2 = 8*PSize;
    vertex( w1, h1, l1, x1, y1);
    vertex( w1, h1, l2, x2, y1);
    vertex( w1, h2, l2, x2, y2);
    vertex( w1, h2, l1, x1, y2);
  
    // +Z "front" face
    x1 = 8*PSize; x2 = 12*PSize;
    vertex( w1, h1, l2, x1, y1);
    vertex( w2, h1, l2, x2, y1);
    vertex( w2, h2, l2, x2, y2);
    vertex( w1, h2, l2, x1, y2);
  
    // +X "right" face
    x1 = 12*PSize; x2 = 16*PSize;
    vertex( w2, h1, l2, x1, y1);
    vertex( w2, h1, l1, x2, y1);
    vertex( w2, h2, l1, x2, y2);
    vertex( w2, h2, l2, x1, y2);
  
    // -Y "top" face
    y1 = 16*PSize; y2 = 20*PSize;
    x1 = 4*PSize;  x2 = 8*PSize;
    vertex( w1, h1, l1, x1, y1);
    vertex( w2, h1, l1, x2, y1);
    vertex( w2, h1, l2, x2, y2);
    vertex( w1, h1, l2, x1, y2);
  
    // +Y "bottom" face
    x1 = 8*PSize;  x2 = 12*PSize;
    vertex( w1, h2, l2, x1, y1);
    vertex( w2, h2, l2, x2, y1);
    vertex( w2, h2, l1, x2, y2);
    vertex( w1, h2, l1, x1, y2);
  
    endShape();
    
    popMatrix();
    
  }

  //---------------------------------------------------------
  // Procedural walk animation: oscillates legs in opposite phases (pendulum motion)
  // and swings arms at 2x the leg amplitude for natural-looking gait.
  // op>0 enables animation, op=0 resets to standing pose.
  //---------------------------------------------------------
  void Walk(int op)
  {
    
    if (op>0)
    {
      rl_rx += rl_inc;
      ll_rx += ll_inc;
      
      // Bounce at 35-degree limit to create oscillating walk cycle
      if (abs(rl_rx)>(35*anginc)) rl_inc = -rl_inc;
      if (abs(ll_rx)>(35*anginc)) ll_inc = -ll_inc;
    }
    else
    {
      rl_rx = 0;  // Reset to standing pose
      ll_rx = 0;
    }

    LeftLeg_rx   = rl_rx;
    RightLeg_rx  = ll_rx;
   
    // Arms swing opposite to their respective legs at double amplitude
    LeftArm_rx   = 2.0*rl_rx;
    RightArm_rx  = 2.0*ll_rx;

    //LeftArm_rx   = 0*anginc;
    //LeftArm_ry   = 45*anginc;
    //LeftArm_rz   = -180*anginc;

    //RightArm_rx   = 0*anginc;
    //RightArm_ry   = 45*anginc;
    //RightArm_rz  = 30*anginc;
    
    //println("rl_rx: "+rl_rx+", rl_inc:"+rl_inc);
    //println("ll_rx: "+ll_rx+", ll_inc:"+ll_inc);
    //println("op: "+op);
    
  }
  
}

//---------------------------------------------------------
// Upscales a source image by 'psize' factor using nearest-neighbor interpolation.
// Each source pixel becomes a psize x psize block in the output, preserving sharp edges
// for the pixel-art style textures used by the character.
// Note: modifies 'Out' in-place by resizing and copying pixels from an intermediate PGraphics buffer.
//---------------------------------------------------------
void AmpImage(PImage In, PImage Out, int psize) 
{
  int   w = psize;
  color c = color(0);
    
  int isx = In.width;
  int isy = In.height;
  int osx = isx*w;
  int osy = isy*w;
  
  In.loadPixels();
  
  // Render upscaled image to an offscreen buffer first
  PGraphics pg = createGraphics(osx, osy, P2D);
  pg.beginDraw();
  pg.background(c);

  // Nearest-neighbor upscale: each source pixel becomes a psize x psize block
  for (int y = 0; y < isy; y++) 
  {
    for (int x = 0; x < isx; x++) 
    {
      int iloc  =  x +  y*isx;
      c = In.pixels[iloc];
      int ox = x*w, oy = y*w;
      pg.stroke(c);
      pg.fill(c);
      pg.rect(ox, oy, w, w);        
    }
  }
  
  pg.endDraw();
  pg.loadPixels();

  // Copy upscaled pixels from PGraphics buffer back to the output image
  // (can't assign directly because PImage reference is passed by value)
  //Out = createImage(osx, osy, RGB);
  Out.resize(osx, osy);
  Out.loadPixels();
  for (int k=0; k < pg.width*pg.height; k++) 
  {
      Out.pixels[k] = pg.pixels[k];
  }
  Out.updatePixels();    
  
}
