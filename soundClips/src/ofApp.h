#pragma once

#include "ofxiOS.h"
#include "ofxiOSKeyboard.h"
#include "NearablesManager.h"
#include "soundRecording.h"
#include "SoundController.h"
#include "ofxXmlSettings.h"
#include "PresetsController.h"
#import <AVFoundation/AVFoundation.h>

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
    void load();

    void popupDismissed();
    void popupAccepted();
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void audioIn( float * input, int bufferSize, int nChannels );
    
    bool settingUp, wasSettingUpLastFrame;
    
    ofTrueTypeFont numberFontLarge, numberFontSmall, categoryFont, soundFont, presetsTitleFont;
    SoundController controllers[NUM_CONTROLLERS];
    movementManager* manager;
    map<string, map<string, ofSoundPlayer*> > players;
    vector<string> themes;
    int themeNum;
    vector<soundRecording*> recorders;
    ofImage smallEditImage, largeEditImage, heirarchyArrowMain, heirarchyArrowList, splashScreen, background, crossImage, muteImage;
    ofxiOSKeyboard* keyboard;
        
    PresetsController presetsController;
    
    ofSoundStream stream;
        
    UILongPressGestureRecognizer* lpgr;
    
    map<string, bool> beaconsLastFrame;
    
    bool loaded, splashDrawn;
        
    bool allMuted;
    
    button muteAll;
    
    ofxXmlSettings settings, recorderNames;
    
    ofColor cols[NUM_CONTROLLERS];
};


