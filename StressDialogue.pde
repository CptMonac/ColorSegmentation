//import codeanticode.gsvideo.*;
import ddf.minim.*;
//import processing.opengl.*;
//import codeanticode.syphon.*;
import gab.opencv.*;
//import processing.video.*;
import java.awt.*;
import ipcapture.*;

//Syphon variables
//PGraphics canvas;


//Camera variables
IPCapture inputCamera;
PImage img;
PFont font;

//Face detection variables
OpenCV opencv;
int faceDuration = 0;

//AudioVisual variables
int movieFrameRate;
Minim minim;
AudioInput audioIn;
boolean recordingComplete;
AudioRecorder audioRecorder;
AudioPlayer audioPlayer;



//Statemachine variables
int currState = 0;
int currQuestionIndex;
int currAnswerIndex;
//State machine constants
final int InitiationState = 0;
final int QuestionState = 1;
final int AnswerState = 2;
final int AddQuestionState = 3;
final int GoodbyeState = 4;

//General variables
int startTime;
int participantNumber;

void setup()
{
  //Initialize variables
  size(640, 480,P3D);
  currQuestionIndex = 1;
  participantNumber = 0;
  currAnswerIndex = 1;
  movieFrameRate = 10;
  recordingComplete = false;
  currState = InitiationState;
  audioRecorder = null;
 
  //Initialize audio/video recorders
  minim = new Minim(this);
  audioIn = minim.getLineIn();

  //Initialize openCV
  opencv = new OpenCV(this, 160, 120);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  faceDuration = 0;

  
  //Initialize camera
  inputCamera = new IPCapture(this, "http://mawcam_02.wv.cc.cmu.edu:80/video.cgi", "admin", "powerful");
  inputCamera.start();
  background(128);
  font = loadFont("Arial-Black-40.vlw");
  textFont(font);
}

void draw()
{
  switch(currState)
  {
    case InitiationState:
      if (currQuestionIndex == (participantNumber+3))  //Answer quota is complete
      {
        if (!faceDetected())
          displayPrompt("Now it's your turn. Record a question about stress for the next person.");
        else 
        {
          currState = AddQuestionState;
          startTime = millis();
        }
      }
      else if (currQuestionIndex == 1) //Initial bait sequence for participants
      {
        if (!faceDetected())
          displayPrompt("I have a question for you!");
        else 
        {
          
          participantNumber++;
          currQuestionIndex = participantNumber;
          println("loading image...");
          img = loadImage("question"+str(currQuestionIndex)+".png");
          //videoPlayer = new Movie(this, "question"+str(currQuestionIndex)+".mov");
          audioPlayer = minim.loadFile("question"+str(currQuestionIndex)+".wav");
          //videoPlayer.play();  //Start dialogue
          audioPlayer.play();
          currState = QuestionState;
        }
      }
      else //Begin dialogue for other questions
      {
        if (!faceDetected())
          displayPrompt("Interesting... Here's another question for you!");
        else 
        {
          img = loadImage("question"+str(currQuestionIndex)+".png");
          //videoPlayer = new Movie(this, "question"+str(currQuestionIndex)+".mov");
         audioPlayer = minim.loadFile("question"+str(currQuestionIndex)+".wav");
     
          //videoPlayer.play(); //Start dialogue
          audioPlayer.play();
          currState = QuestionState;
        }
      }
      break;
    case QuestionState:
      //Display video question
      background(0);
      //videoPlayer.read();
      
      image(img, 0, 0, width, height);

      //Move on to next sequence if question is complete
      if (audioPlayer.isPlaying()==false)
        {currState = AnswerState;
        startTime = millis();}
      break;
    case AnswerState: //Record answers
      if (inputCamera.isAvailable())
      {
        println("answerState");
        inputCamera.read();
        image(inputCamera, 0, 0, width, height);
        String fileName = "answer"+currAnswerIndex+"(question"+currQuestionIndex+")";
        recordParticipant(fileName);
        fill(230,0,0);
        float rectHeight= map(elapsedTimeSeconds(),0,10,height,0);
        rect(width-30,height-rectHeight,30,rectHeight);
        if (recordingComplete)
        {
          currQuestionIndex++;
          currAnswerIndex++;
          recordingComplete = false;
          audioRecorder = null;
          currState = InitiationState;
        }
      }
      break;
    case AddQuestionState: //Record question
      if (inputCamera.isAvailable())
      {
        //canvas = client.getGraphics(canvas);
        inputCamera.read();
        image(inputCamera, 0, 0, width, height);
        recordParticipant("question"+currQuestionIndex);
         float rectHeight= map(elapsedTimeSeconds(),0,10,height,0);
         fill(230,0,0);
         rect(width-30,height-rectHeight,30,rectHeight);
        if(recordingComplete)
        {
          recordingComplete = false;
          audioRecorder = null;
          currQuestionIndex = 1;
          currState = GoodbyeState;
          startTime = millis();
        }
        
      }
      break;
    case GoodbyeState: //Goodbye
      if (elapsedTimeSeconds() > 2)
        currState = InitiationState;
      else
        displayPrompt("Have a stress free day :)");
      break;
  }
}

boolean faceDetected()
{
  if (inputCamera.isAvailable())
  {
    inputCamera.read();
    opencv.loadImage(inputCamera);
    Rectangle[] faces = opencv.detect();
    //println(faceDuration);  
    if (faces.length > 0)
      faceDuration++;
    else 
      faceDuration = 0;

    if (faceDuration > 5)
    {
      faceDuration = 0;
      return true;
    }
    else 
      return false;
  }
  else
    return false;
}

int elapsedTimeSeconds()
{
  int duration = millis() - startTime;
  return (duration/1000);
}



void recordParticipant(String inputFilename)
{
  if (audioRecorder == null)
  { 
    //Save uncompressed video
    //videoRecorder = new GSMovieMaker(this, width, height,"data/"+inputFilename+".ogg", GSMovieMaker.THEORA,GSMovieMaker.MEDIUM, 30);
    println("start recording");
    //videoRecorder.setQueueSize(50, 10);
    //videoRecorder.start();
    audioRecorder = minim.createRecorder(audioIn, "data/"+inputFilename+".wav");
    audioRecorder.beginRecord();
    startTime = millis();
    
    recordingComplete = false;
    println("Recording started...");
  }
  else 
  {
    if (elapsedTimeSeconds() > 10)
    {
      //videoRecorder.finish();
      saveFrame("data/"+inputFilename+".png");
      audioRecorder.save();
      audioRecorder.endRecord();
      println("Recording complete!");
      recordingComplete = true;
    }
    
  }
} 

void displayPrompt(String inputPrompt)
{
  background(128);
  textSize(40);
  fill(0, 102, 153);
  text(inputPrompt, (width/2) - 300, height/2-40, 600, height/2);
} 
