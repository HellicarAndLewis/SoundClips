#pragma once

#include "ofxiOS.h"
#include "ofxiOSKeyboard.h"
#include "NearablesManager.h"
#include "soundMixer.h"
#include "SoundController.h"

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
    
    bool settingUp;

    ofTrueTypeFont numberFont;
    ofTrueTypeFont listFont;
    SoundController controllers[NUM_CONTROLLERS];
    soundMixer* mixer;
    movementManager* manager;
    map<string, map<string, ofSoundPlayer*> > players;
    vector<soundRecorder*> recorders;
    ofImage gear;
    ofImage arrow;
    ofxiOSKeyboard* keyboard;
    
    bool allMuted;
    
    button muteAll;
    
    ofColor cols[NUM_CONTROLLERS];
    string names[NUM_CONTROLLERS];
};

