#ifndef _TEST_APP
#define _TEST_APP

#include "ofMain.h"
#include "ofxQTKitVideoGrabber.h"
#include "ofxQTKitVideoSaver.h"

#define CAM_WIDTH  640
#define CAM_HEIGHT 480

class testApp : public ofBaseApp{
  public:
	void setup();
	void update();
	void draw();
	void exit();
	ofxQTKitVideoGrabber grabber;
	ofxQTKitVideoSaver	 saver;
};

#endif	
