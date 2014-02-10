/* --------------------------------------------------------------------------
 * ColorRegion
 * --------------------------------------------------------------------------
 * Selects dominant color from pre-defined image region
 * --------------------------------------------------------------------------
 * author: Ayo Olubeko
 * date:  01/29/2014
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import processing.video.*;

SimpleOpenNI  context;
PImage webcamImage;
boolean webcamEnabled;
Capture cam;
int[] midPoint;
int regionSize;

void setup()
{
  //Intialize variables
  regionSize  = 300;
   
  cam = new Capture(this);
  cam.start();
  midPoint = new int[2];
  size(640, 480);
  
  midPoint[0] =  width/2;
  midPoint[1] = height/2;
}

void draw()
{
  if (cam.available())
    cam.read();
  
  webcamImage = cam.get();
  image(webcamImage, 0, 0);
  
  noFill();
  ellipse(midPoint[0], midPoint[1], regionSize, regionSize);

  //color userColor = averageColor(webcamImage);
  //color userColor = representativeColor(webcamImage);
  //fill(userColor);
  //rect(webcamImage.width-100, 0, 100, 480);
}

color averageColor(PImage inputImage)
{
  int averageRed = 0;
  int averageGreen = 0;
  int averageBlue = 0;
  int OriginX = 0;
  int OriginY = 0;
  int OriginIndex = 0;

  if ((midPoint[0] - regionSize/2) < 0)
    OriginX = 0;
  else
    OriginX = (midPoint[0] - regionSize/2);

  if ((midPoint[1] - regionSize/2) < 0)
    OriginY = 0;
  else
    OriginY = (midPoint[1] - regionSize/2);
  OriginIndex = (OriginY * width) + OriginX;


  for(int i = 0; i < regionSize*regionSize; i++)
  {
    averageRed+= red(inputImage.pixels[i+OriginIndex]);
    averageGreen+= green(inputImage.pixels[i+OriginIndex]);
    averageBlue+= blue(inputImage.pixels[i+OriginIndex]);
  }
  averageRed = averageRed/(regionSize*regionSize);
  averageBlue = averageBlue/(regionSize*regionSize);
  averageGreen = averageGreen/(regionSize*regionSize);
  return color(averageRed, averageGreen, averageBlue);
}

color representativeColor(PImage inputImage)
{
  inputImage.loadPixels();
  int midPointIndex = (midPoint[1] * 480) + 680;
  return color(inputImage.pixels[midPointIndex]);
}

