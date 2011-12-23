#ifndef _OFX_QTKIT_VIDEO_SAVER
#define _OFX_QTKIT_VIDEO_SAVER

#include <stdint.h>
#include <string>


class ofxQTKitVideoSaver {
	private :
		void *saver;
		bool recording;
		int width;
		int height;
		int	framerate;
		int	frames;
		std::string filename;
		std::string type;
		int	quality;
	public :
		ofxQTKitVideoSaver();
		~ofxQTKitVideoSaver();
		Boolean isRecording();
	void setup(int $width,int $height,int $framerate,std::string $type="mp4v",int $quality=0x00000400);
		void writeRGB(unsigned char *$data);
		void writeRGBA(uint32_t *$data);
		void finishMovie();
};

#endif