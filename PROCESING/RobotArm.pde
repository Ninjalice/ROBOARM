import peasy.*;
import processing.core.*;
import processing.serial.*;

final float GROUND_LENGTH = 500;
final float SEG_LENGTH_OLD = 200;
final float POT_LENGTH = 20;
final float ROT_SPEED = radians(1);


final float SEG1_LENGTH = 70;
final float SEG2_LENGTH = 101;
final float SEG3_LENGTH = 100;

final float SEG_WIDTH = 20;
final float SEG_THINKESS = 3;

final float SCALE = 2;



final float[] SEG_LENGTH = {SEG1_LENGTH * SCALE,SEG2_LENGTH * SCALE,SEG3_LENGTH * SCALE};


Serial serial;

float pot1, pot2, pot3;
float angle1,angle2,angle3;
float click = 0;

float angle_correction2 = 0;
float angle_correction3 = 0;


final float[][] segmentTranslations = {
  {0, 0, SEG_LENGTH[0] },
  {-POT_LENGTH, 0, SEG_LENGTH[1]},
  {POT_LENGTH, 0, SEG_LENGTH[2]},
};
final float[][] segmentRotations = {
  {radians(-45), 0, 0},
  {radians(-45), 0, 0},
  {0, 0, radians(25)},
};
final Vec3 tipPos = new Vec3();

PeasyCam cam;
boolean isMousePressed = false;
Object grabbedObject = null;

Object boxObject; // Objeto box

void setup() {
  
  String[] sPorts = Serial.list();
  printArray(sPorts); //this way you can check in which index is the arduino PORT
  final int portIndex =0; 
  
  serial = new Serial(this, sPorts[portIndex], 115200); //be sure to match this baudrate to the Arduino Sketch
  serial.clear(); //clear things that could be on the buffer
  
  size(800, 600, P3D);
  float gravity = 0.5;
  
  cam = new PeasyCam(this, 0, 0, 0, 1300);
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(1000);
  cam.setPitchRotationMode();
  sphereDetail(6);

  rectMode(CENTER);
  fill(0);
  
  // Crear objeto box
  Vec3 boxPosition = new Vec3(150, 100, 100);
  Vec3 boxVelocity = new Vec3(0, 0, 0);
  Vec3 boxSize = new Vec3(70, 70, 70);
  int boxColor = color(0, 255, 0); // Color verde
  boxObject = new Object(this, boxPosition, boxVelocity, boxSize, boxColor , gravity);
  
}

void serialEvent(Serial p) {
  try {
    final String msg = p.readStringUntil('\n');
    
    if (msg != null) {  
      final String[] parts = msg.trim().split(",");
      pot1 = Float.parseFloat(parts[0]);
      pot2 = Float.parseFloat(parts[2]);
      pot3 = Float.parseFloat(parts[1]);
      click = Float.parseFloat(parts[3]);
      // Convertir los valores de los potenciómetros a ángulos
      angle1 = map(pot1, 0, 1023, 0, 300);
      angle2 = map(pot2, 0, 1023, 0, 300) + angle_correction2;
      angle3 = map(pot3, 0, 1023, 0, 300) + angle_correction3;
      
      // Hacer algo con los ángulos leídos
      // Por ejemplo, mostrarlos en la consola
      System.out.print("Ángulos: ");
      System.out.print(angle1);
      System.out.print(" , ");
      System.out.print(angle2);
      System.out.print(" , ");
      System.out.print(angle3);
      System.out.print(" , ");
      System.out.println(click);
      
     
      
      // Aquí puedes realizar cualquier acción adicional con los ángulos obtenidos
    }
  } catch (Exception e) {
    System.out.println("Fallo en el bloque try-catch");
  }
}
void draw() {
 
  
  rotateX(radians(45));
  background(24, 24, 35);
  stroke(255);
  lights();

  fill(83, 127, 231);

  // Ground
  pushMatrix();
  translate(0, 0, -1);
  box(GROUND_LENGTH, GROUND_LENGTH, 1);
  popMatrix();

  // Robot segments
  pushMatrix();
  fill(233, 248, 249);
  box(POT_LENGTH); // Base
  final int nSegs = segmentTranslations.length;
  for (int i = nSegs - 1; i >= 0; i--) {
    final float[] trans = segmentTranslations[i];
    final float[] rot = segmentRotations[i];
    rotateX(rot[0]);
    rotateY(rot[1]);
    rotateZ(rot[2]);

    translate(trans[0] / 2, trans[1] / 2, trans[2] / 2);
    box(POT_LENGTH, POT_LENGTH, SEG_LENGTH[i]);
    translate(trans[0] / 2, trans[1] / 2, trans[2] / 2);
  }
  popMatrix();

  // Tip
  tipPos.reset();
  for (int i = 0; i < nSegs; i++) {
    final float[] trans = segmentTranslations[i];
    final float[] rot = segmentRotations[i];
    tipPos.trans(trans);
    tipPos.rot(rot);
  }

  pushMatrix();
  fill(233, 248, 24);
  
  
  if (click == 1.0 && boxObject.isInsideObject(tipPos)) {
    boxObject.position = tipPos;
  } else {
    translate(tipPos.x, tipPos.y, tipPos.z);
    boxObject.update();
  }
  
  sphere(POT_LENGTH);
  popMatrix();
  
  // Actualizar y
  // Actualizar y dibujar el objeto box
  
  boxObject.draw();
  
  segmentRotations[2][2] = radians(angle1);
  segmentRotations[0][0] = radians(angle2);
  segmentRotations[1][0] = radians(angle3);
  
  if (keyPressed) {
    if (key == 'e') {
      segmentRotations[0][0] -= ROT_SPEED;
    } else if (key == 'q') {
      segmentRotations[0][0] += ROT_SPEED;
    } else if (key == 'w') {
      segmentRotations[1][0] -= ROT_SPEED;
    } else if (key == 's') {
      segmentRotations[1][0] += ROT_SPEED;
    } else if (key == 'd') {
      segmentRotations[2][2] -= ROT_SPEED;
    } else if (key == 'a') {
      segmentRotations[2][2] += ROT_SPEED;
    } else if (key == 'r') {
      angle_correction2 =  360 - angle2;
      angle_correction3 =  360 - angle3;
      
    }
  }

}

void mousePressed() {
  if (mouseButton == LEFT) {
    isMousePressed = true;
   
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    isMousePressed = false;
    if (grabbedObject != null) {
      grabbedObject.release();
      grabbedObject = null;
    }
  }
}


class Object {
  PApplet parent;
  Vec3 position;
  Vec3 velocity;
  Vec3 size;
  int colorObj;
  float gravity;

  Object(PApplet parent, Vec3 position, Vec3 velocity, Vec3 size, int colorObj , float gravity) {
    this.parent = parent;
    this.position = position;
    this.velocity = velocity;
    this.size = size;
    this.colorObj = colorObj;
    this.gravity = gravity;
  }

  void update() {
    if (position.z > 0 + size.z ) {
      velocity.z -= gravity;
      position = position.add(velocity);
    }
  }
  
  boolean isInsideObject(Vec3 position) {
    float halfWidth = size.x / 2;
    float halfHeight = size.y / 2;
    float halfDepth = size.z / 2;
  
    if (position.x > this.position.x - halfWidth && position.x < this.position.x + halfWidth &&
        position.y > this.position.y - halfHeight && position.y < this.position.y + halfHeight &&
        position.z > this.position.z - halfDepth && position.z < this.position.z + halfDepth) {
      return true;
    }
  
    return false;
  }


  void draw() {
    parent.pushMatrix();
    parent.translate(position.x, position.y, position.z);
    parent.fill(colorObj);
    parent.box(size.x, size.y, size.z);
    parent.popMatrix();
  }

  

  void release() {
    velocity = new Vec3();
  }
}
class Vec3 {
  float x, y, z;

  Vec3() {
    this(0, 0, 0);
  }

  Vec3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  void reset() {
    x = 0;
    y = 0;
    z = 0;
  }

  Vec3 add(Vec3 other) {
    return new Vec3(x + other.x, y + other.y, z + other.z);
  }

  void trans(float[] t) {
    x += t[0];
    y += t[1];
    z += t[2];
  }

  void rot(float[] r) {
    float nx = x * cos(r[2]) - y * sin(r[2]);
    float ny = x * sin(r[2]) + y * cos(r[2]);
    x = nx;
    y = ny;

    ny = y * cos(r[0]) - z * sin(r[0]);
    float nz = y * sin(r[0]) + z * cos(r[0]);
    y = ny;
    z = nz;

    nz = z * cos(r[1]) - x * sin(r[1]);
    nx = z * sin(r[1]) + x * cos(r[1]);
    z = nz;
    x = nx;
  }
}
