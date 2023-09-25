
const int potPin1 = A0;  // Pin analógico utilizado para el potenciómetro 1
const int potPin2 = A1;  // Pin analógico utilizado para el potenciómetro 2
const int potPin3 = A2;  // Pin analógico utilizado para el potenciómetro 3
const int buttonPin = 2; // Pin digital utilizado para el botón

const int LED_R = 9; 
const int LED_G = 10;
const int LED_B = 11; 

int buttonState = 0;     // Variable para almacenar el estado del botón
int potValue1 = 0;       // Variable para almacenar el valor del potenciómetro 1
int potValue2 = 0;       // Variable para almacenar el valor del potenciómetro 2
int potValue3 = 0;       // Variable para almacenar el valor del potenciómetro 3

void setup() {
  Serial.begin(115200);   // Inicializar la comunicación serial a 9600 bps
  pinMode(LED_R,   OUTPUT);
  pinMode(LED_G, OUTPUT);
  pinMode(LED_B,  OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP); // Configurar el pin del botón como entrada con resistencia pull-up interna
}

void loop() {
  setColor(255, 150, 0);
  
  buttonState = 1-  digitalRead(buttonPin); // Leer el estado del botón

  // Leer los valores de los potenciómetros
  potValue1 = analogRead(potPin1);
  potValue2 = analogRead(potPin2);
  potValue3 = analogRead(potPin3);

  // Enviar los valores a través del puerto serial separados por comas
  Serial.print(potValue1);
  Serial.print(",");
  Serial.print(potValue2);
  Serial.print(",");
  Serial.print(potValue3);
  Serial.print(",");
  Serial.println(buttonState);

  delay(100); // Pequeña pausa para evitar lecturas demasiado rápidas
}


void setColor(int R, int G, int B) {
  analogWrite(LED_R,   R);
  analogWrite(LED_G, G);
  analogWrite(LED_B,  B);
}
