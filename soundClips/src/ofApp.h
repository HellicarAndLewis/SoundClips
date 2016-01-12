#pragma once

#include "ofxiOS.h"
#include "NearablesManager.h"
#include "soundMixer.h"
#include "SoundController.hpp"

#define NUM_CONTROLLERS 9

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
    
    SoundController controllers[NUM_CONTROLLERS];
    soundMixer* mixer;
    movementManager* manager;
    map<string, vector<ofSoundPlayer*> > players;
    map<string, soundRecorder*> recorders;
};


