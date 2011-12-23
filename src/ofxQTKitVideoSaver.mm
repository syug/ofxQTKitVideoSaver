#include "ofxQTKitVideoSaver.h"
#import "Cocoa/Cocoa.h"
#import "QTKit/QTKit.h"

typedef struct _QTKitVideoSaver {
	QTMovie *movie;
	NSImage *image;
	NSBitmapImageRep *bitmap;
} QTKitVideoSaver;

ofxQTKitVideoSaver::ofxQTKitVideoSaver() {
	printf("ofxQtKitVideoSaver\n");
	saver = (void *)malloc(sizeof(QTKitVideoSaver));
	QTKitVideoSaver *s = ((QTKitVideoSaver *)saver);
	(s->movie)  = nil;
	(s->image)  = nil;
	(s->bitmap) = nil;
}
ofxQTKitVideoSaver::~ofxQTKitVideoSaver() {
	printf("~ofxQtKitVideoSaver\n");
	QTKitVideoSaver *s = ((QTKitVideoSaver *)saver);
	if(recording==true) finishMovie();
	if((s->movie))  { [(s->movie)  release]; (s->movie)  = nil; }
	if((s->bitmap)) { [(s->bitmap) release]; (s->bitmap) = nil; }
	if((s->image))  { [(s->image)  release]; (s->image)  = nil; }
	free(saver);
}
		
Boolean ofxQTKitVideoSaver::isRecording() { return recording; }

// codecLosslessQuality = 0x00000400,codecMaxQuality = 0x000003FF,codecMinQuality = 0x00000000,codecLowQuality = 0x00000100,codecNormalQuality = 0x00000200,codecHighQuality = 0x00000300
void ofxQTKitVideoSaver::setup(int $width,int $height,int $framerate, std::string $type,int $quality) {
	printf("setup\n");
	QTKitVideoSaver *s = ((QTKitVideoSaver *)saver);
	width  = $width;
	height = $height;
	frames = 0;
	char $filename[1024];
	time_t now = time(NULL);
	struct tm *ts = localtime(&now);
	strftime($filename, sizeof($filename), "data/%Y_%m_%d_%H_%M_%S.mov", ts);
	printf("%s\n", $filename);
	filename   = $filename;
	framerate  = $framerate;
	if((s->movie))  { [(s->movie)  release]; (s->movie)  = nil; }
	if((s->bitmap)) { [(s->bitmap) release]; (s->bitmap) = nil; }
	if((s->image))  { [(s->image)  release]; (s->image)  = nil; }
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	(s->movie)  = [[QTMovie alloc] initToWritableData:[NSMutableData data] error:nil];
	(s->bitmap) = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:width pixelsHigh:height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:NULL bitsPerPixel:NULL];			
	(s->image)  = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
	[(s->image) addRepresentation:(s->bitmap)];
	type = $type;
	quality = $quality;
	recording = true;
	[pool release];
}

void ofxQTKitVideoSaver::writeRGB(unsigned char *$data) {
	if(recording) {
		QTKitVideoSaver *s = ((QTKitVideoSaver *)saver);
		uint32_t *ptr = (uint32_t *)[(s->bitmap) bitmapData];
		int rowBytes = [(s->bitmap) bytesPerRow]>>2;
		for(int i=0; i<height; i++) {
			uint32_t *src = ptr+i*rowBytes;
			for(int j=0; j<width; j++) {
				unsigned char r = *$data++;
				unsigned char g = *$data++;
				unsigned char b = *$data++;
				*src++ = b<<16|g<<8|r; // (A)BGR
			}
		}
		NSString *codectype = [NSString stringWithUTF8String:type.c_str()];
		[(s->movie) addImage:(s->image) forDuration:QTMakeTime(1,framerate) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:codectype,QTAddImageCodecType,[NSNumber numberWithInt:quality],QTAddImageCodecQuality,nil]];
		[(s->movie) setCurrentTime:QTMakeTime(frames++,framerate)];
	}
}

void ofxQTKitVideoSaver::writeRGBA(uint32_t *$data) {
	if(recording) {
		QTKitVideoSaver *s = ((QTKitVideoSaver *)saver);
		uint32_t *ptr = (uint32_t *)[(s->bitmap) bitmapData];
		int rowBytes = [(((QTKitVideoSaver *)saver)->bitmap) bytesPerRow]>>2;
		for(int i=0; i<height; i++) {
			uint32_t *src = ptr+i*rowBytes;
			for(int j=0; j<width; j++) {
				uint32_t rgba = *$data++;
				*src++ = (rgba&0xFF)<<24|(rgba&0xFF00)<<8|(rgba&0xFF0000)>>8|(rgba>>24)&0xFF; // ABGR
			}
		}
		NSString *codectype = [NSString stringWithUTF8String:type.c_str()];
		[(s->movie) addImage:(s->image) forDuration:QTMakeTime(1,framerate) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:codectype,QTAddImageCodecType,[NSNumber numberWithInt:quality],QTAddImageCodecQuality,nil]];
		[(s->movie) setCurrentTime:QTMakeTime(frames++,framerate)];
	}
}

void ofxQTKitVideoSaver::finishMovie() {
	printf("finishMovie\n");
	QTKitVideoSaver *s = ((QTKitVideoSaver *)saver);
	recording = false;
	NSString* sFile = [NSString stringWithUTF8String:filename.c_str()];
	NSString* sPath = [[[NSBundle mainBundle]bundlePath]stringByDeletingLastPathComponent];
	sPath = [ sPath stringByAppendingPathComponent:sFile ];
	[(s->movie) writeToFile:sPath withAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:QTMovieFlatten] error:nil];
	[(s->movie) release]; 
	(s->movie) = nil;
}