import unlekker.moviemaker.*;
import ddf.minim.*;
import processing.opengl.*;
import codeanticode.syphon.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

//Syphon variables
PGraphics canvas;
SyphonClient client;

//Face detection variables
OpenCV opencv;
int faceDuration = 0;

//AudioVisual variables
int movieFrameRate;
Minim minim;
AudioInput audioIn;
AudioRecorder audioRecorder;
AudioPlayer audioPlayer;
UMovieMaker videoRecorder;
Movie videoPlayer;

//Statemachine variables
int currState = 0;
int currQuestionIndex;
int currAnswerIndex;

//General variables
int startTime;

void setup()
{
	//Initialize variables
	size(640, 480, P3D);
	currQuestionIndex = 1;
	currAnswerIndex = 1;
	movieFrameRate = 10;
	currState = 0;

	//Initialize audio/video recorders
	minim = new Minim(this);
	audioIn = minim.getLineIn();

	//Initialize openCV
	opencv = new OpenCV(this, 320, 240);
	opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
	faceDuration = 0;

	//Initialize syphon
	client = new SyphonClient(this, "IPCAM2SYPHON","ipcam0");
 	background(0);
}

void draw()
{
	switch(currState)
	{
		case 0:
			if (currQuestionIndex % 4 == 0)	//Answer quota is complete
			{
				currState = 3;
				startTime = millis();
			}
			else if (currQuestionIndex % 1 == 0) //Initial bait sequence for participants
			{
				if (faceDetection())
					println("I have a question for you!");
				else 
				{
					videoPlayer = new Movie(this, "question"+str(currQuestionIndex)+".mp4");
					videoPlayer.play();	//Start dialogue
					currState = 1;
				}
			}
			else //Begin dialogue for other questions
			{
				videoPlayer = new Movie(this, "question"+str(currQuestionIndex)+".mp4");
				videoPlayer.play(); //Start dialogue
				currState = 1;
			}
			break;
		case 1:
			//Display video question
			background(0);
			image(videoPlayer, 0, 0, width, height);

			//Move on to next sequence if question is complete
			if (getFrame() >= getLength()-1)
				currState = 2;
			break;
		case 2: //Record answers
			if (client.available())
			{
				canvas = client.getGraphics(canvas);
				image(canvas, 0, 0, width, height);
				recordParticipant("answer"+currAnswerIndex+".mp4");

				if (videoRecorder != null)
					videoRecorder.addFrame();

			}
			break;
		case 3: //Record question
			break;
	}
}

boolean faceDetection()
{
	if (client.available())
	{
		canvas = client.getGraphics(canvas);
		opencv.loadImage(canvas);
		Rectangle[] faces = opencv.detect();
		
		if (faces.length > 0)
			faceDuration++;
		else 
			faceDuration = 0;

		if (faceDuration > 1000)
			return true;
		else 
			return false;
	}
}

int elapsedTimeSeconds()
{
	int duration = millis() - startTime;
	return (duration/1000);
}

int getFrame()
{    
  return ceil(videoPlayer.time() * movieFrameRate) - 1;
}

int getLength()
{
  return int(videoPlayer.duration() * movieFrameRate);
}

void recordParticipant(String inputFilename)
{
	if (videoRecorder == null)
	{
		//Save uncompressed video
		videoRecorder = new UMovieMaker(this, sketchPath(inputFilename+".mp4"), width, height, movieFrameRate);
		audioRecorder = minim.createRecorder(audioIn, inputFilename+".mp4");
		audioRecorder.beginRecord();
		startTime = millis();
		println("Recording started...");
	}
	else 
	{
		if (elapsedTimeSeconds > 10)
		{
			videoRecorder.finish();
			audioRecorder.save();
			audioRecorder.endRecord();
			println("Recording complete!");
		}
	}
}  