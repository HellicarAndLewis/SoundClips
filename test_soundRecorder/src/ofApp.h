#pragma once

#include "ofxiOS.h"
#include "soundMixer.h"

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
        void audioOut( float * output, int bufferSize, int nChannels );
        void audioIn( float * input, int bufferSize, int nChannels );
        double phase;
    
        soundMixer mixer;
        vector<soundRecorder*> recorders;
    
        ofSoundPlayer player;

        ofSoundBuffer buffer;
        int recPos;
        int playPos;
        bool RMode = false;
        bool PMode = false;
};


