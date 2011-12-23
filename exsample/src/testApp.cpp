#include "testApp.h"

void testApp::setup() {	
	ofSetFrameRate(30);
	camWidth  = CAM_WIDTH;
	camHeight = CAM_HEIGHT;
	grabber.initGrabber(CAM_WIDTH,CAM_HEIGHT);
	saver.setup(CAM_WIDTH,CAM_HEIGHT,30);
}

void testApp::update() {
	grabber.grabFrame();
}

void testApp::draw() {
	ofSetColor(0xFF,0xFF,0xFF);
	if (grabber.isFrameNew()){
		if(saver.isRecording()) saver.writeRGB(grabber.getPixels());
	}
	grabber.draw(0,0);
}

void testApp::exit(){ 
	if(saver.isRecording()) saver.finishMovie();
}