#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width,  in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

// declare an SSD1306 display object connected to I2C
Adafruit_SSD1306 oled(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------

// Includes the Servo library
#include <Servo.h>
// Defines Tirg and Echo pins of the Ultrasonic Sensor
const int trigPin = 10;
const int echoPin = 11;
// Variables for the duration and the distance
long duration;
Servo myServo; // Creates a servo object for controlling the servo motor
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------

// Current position
int current_angle = 0;
//Next position
int set_angle = 0;

// Calculated distance
int calculated_distance = 0;

// Physical limits
int max_angle = 180;
int min_angle = 0;

// Object Memory
int object_memory = 5;   // Forgets the object after n - angles //Default 5
int object_memmory_counter = 0;    

// Object_trigger
int object_trigger = 0;

// Threashold closeness
int threashold_closeness = 60; //Default 20

// Direction (+1) => CW , (-1) => CCW
int rotational_direction = 1;

// Delay
int dilay_milli_seconds = 15;

// Pulse counter : to avoid noises or outliers
int object_width_counter = 0;
int minimum_object_width = 3;  //Def 5

// Set the speed
float rotational_speed = 1 ;
int max_rotational_speed = 17;       // delayTime(ms) * (0.5) ~ Max allowed 60 degrees in 0.12S

//----------------------------------------------------------------------------------------------------
// ---------------------------------------INITIALIZATION----------------------------------------------
//----------------------------------------------------------------------------------------------------
void setup()
{
  // Setup Max rotational Speed
  max_rotational_speed = dilay_milli_seconds*0.5;

  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
  Serial.begin(9600);
  myServo.attach(12); // Defines on which pin is the servo motor attached

  // Reset SErvo
  current_angle = 0;
  set_angle = 0;
  set_servo_angle();
}

//----------------------------------------------------------------------------------------------------
// ---------------------------------------MAIN LOOP---------------------------------------------------
//----------------------------------------------------------------------------------------------------
void loop()
{

  // Calculate Ultrasond distance
  calculateDistance();

  // If a obstracal noted -> always reset the memory counter
  if(calculated_distance< threashold_closeness)
  {
    // If the object is not triggered yet
    if(object_trigger == 0)    {
      // Set the object trigger
      object_trigger = 1;
      set_display();
    }
    // Set the memory counter 
    object_memmory_counter = object_memory;

    // Update the object width
    object_width_counter = object_width_counter + 1 ;

    // Increase the speed                                 --------------------------------------------------(Updated)
    set_rotational_speed(1);
  } 

  // If no obstracal is detected
  if(calculated_distance >= threashold_closeness)
  {
  
    // If object is triggered
    if(object_trigger == 1)
    {
      // If exceeds the memmory boundary , flip the direction
      if(object_memmory_counter == 0)
      {
        // Flip the rotational direction if an object with required minimum width
        if(object_width_counter>= minimum_object_width)
        {
          rotational_direction = rotational_direction*(-1);
        }        
        // Reset the object trigger
        object_trigger == 0;
      }      
      // Reduce the object memmory
      object_memmory_counter = object_memmory_counter -1;
    }
    //                                                        --------------------------------------------------(Updated)
    set_rotational_speed(-1);
  }
  

  // Next position
  set_angle = current_angle + rotational_direction*rotational_speed;  

  // Reset if meet the boundary conditions
  if(set_angle<= min_angle)
  {
    set_angle = min_angle;
    rotational_direction = 1;
    object_memmory_counter = 0;
    object_trigger = 0;
  }
  if(set_angle > max_angle)
  {
    set_angle = max_angle;
    rotational_direction = -1;
    object_memmory_counter = 0;
    object_trigger = 0;
  }

  // Rotate the servo
  set_servo_angle();
  // Delay
  
  delay(dilay_milli_seconds);
  
}
















//--------------------------------------------DISTANCE CALCULATION-----------------------------------------------------------------
// Function for calculating the distance measured by the Ultrasonic sensor
void calculateDistance() {

  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH stayfor 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH); // Reads the echoPin, returns the sound wave travel time in microseconds

  calculated_distance = duration * 0.017; //0.34/2

  if (calculated_distance<threashold_closeness)
  {
      Serial.println(" ");
      Serial.print("Calculated Distance: ");
      Serial.print(calculated_distance);
      Serial.println(" ");

  }

}


//--------------------------------------------------------------------------------------------------------------
// Set servo angle
void set_servo_angle()
{
  myServo.write(set_angle);
  current_angle = set_angle;

}

void set_rotational_speed(int mode)
{
  // pass +1 for increase
  // pass -1 for decrease
  // Pass 0 for reset
  // Speed Increase
  if(mode == 1 )
  {
    // Increase if does not exceed the max speed
    if (rotational_speed < max_rotational_speed)
    {
      rotational_speed = rotational_speed+0.05;
    }
    // Decrease the speed
  } else if (mode == -1)
  {
    if(rotational_speed>1.05)
    {
      rotational_speed = rotational_speed-0.05;
    }
  }else if (mode == 0)
  {
    rotational_speed = 1.0;
  }
}


/// Display Module
void set_display()
{
  // clear display
  oled.clearDisplay(); 
  // text size
  oled.setTextSize(1);   
  // text color
  oled.setTextColor(WHITE);  
  // position to display
  // text to display
  oled.setCursor(0, 10); 
  // Print the mode
  if(object_trigger == 1)
  {
    oled.println("Tracking Mode!"); 
  } else
  {
    oled.println("Scaning..."); 
  }      
  
  // Print the distance
  oled.setCursor(0, 25);
  oled.print("Distance(cm) :");        
  oled.print(calculated_distance);
  // Print speeed 
  oled.setCursor(0, 40);        
  oled.print("Speed :");        
  //oled.print(speed_calculation());
  // show on OLED
  oled.display();              

}

// Speed Calculation
int speed_calculation()
{
  return calculated_distance*rotational_speed*3.14/180;
}
