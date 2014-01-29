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


SimpleOpenNI  context;
PImage webcamImage;
int[] midPoint;
int regionSize;
int imageWidth, imageHeight;

void setup()
{
  //Intialize variables
  regionSize  = 300;
  imageWidth  = 640;
  imageHeight = 480;
  
  midPoint = new int[2];
  size(imageWidth+100, imageHeight);
  context = new SimpleOpenNI(this);
  
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  context.setMirror(true);
  context.enableRGB();
  midPoint[0] = imageWidth/2;
  midPoint[1] = imageHeight/2;
}

void draw()
{
  context.update();                  //Update the cam
  webcamImage = context.rgbImage();
  image(webcamImage, 0, 0);         //Draw camera feed
  webcamImage.loadPixels();
  noFill();
  ellipse(midPoint[0], midPoint[1], regionSize, regionSize);

  //color userColor = averageColor(webcamImage);
  color userColor = representativeColor(webcamImage);
  fill(userColor);
  rect(webcamImage.width, 0, 100, 480);
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


  for(int i = 0; i < regionSize*2; i++)
  {
    averageRed+= red(inputImage.pixels[i+OriginIndex]);
    averageGreen+= green(inputImage.pixels[i+OriginIndex]);
    averageBlue+= blue(inputImage.pixels[i+OriginIndex]);
  }
  averageRed = averageRed/(regionSize*2);
  averageBlue = averageBlue/(regionSize*2);
  averageGreen = averageGreen/(regionSize*2);
  return color(averageRed, averageGreen, averageBlue);
}

color representativeColor(PImage inputImage)
{
  int midPointIndex = (midPoint[1] * imageWidth) + midPoint[0];
  return color(inputImage.pixels[midPointIndex]);
}

