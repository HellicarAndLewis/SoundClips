//
//  PresetsController.hpp
//  soundClips
//
//  Created by James Bentley on 1/21/16.
//
//

#ifndef PresetsController_hpp
#define PresetsController_hpp

#include "ofMain.h"
#include "SoundController.h"
#include "ofxIntegrator.h"
#define NUM_PRESETS 9

#define WIDTH ofGetWidth()
#define HEIGHT ofGetHeight()

class PresetsController {
private:
    vector<string>* presets;
    SoundController* controllers;
    int presetNum = 0;
    button accept, cancel;
    int mode;
    ofTrueTypeFont* font;
    ofTrueTypeFont* titleFont;
    float smallX, smallY, smallHeight, smallWidth;
    float fullX, fullY, fullHeight, fullWidth;
    ofColor col;
    int buffer;
    button presetButtons[NUM_PRESETS];
    Integrator<float> x, y, width, height;
    ofImage* acceptImg;
    ofImage* cancelImg;
    map<string, map<string, ofSoundPlayer*> >* allPlayers;
    
public:
    PresetsController() { presets = NULL; mode = modes::IDLE; };
    void setPresetNames(vector<string>* _names) {presets = _names;};
    void setPosition(float _x, float _y, float _width, float _height);
    void setColor(ofColor _col) { col = _col;};
    void setFont(ofTrueTypeFont* _font) { font = _font; };
    void setTitleFont(ofTrueTypeFont* _font) { titleFont = _font; };
    void setAcceptImage(ofImage* img) { acceptImg = img; };
    void setMode(int _mode) { mode = _mode;};
    void setControllers(SoundController* _controllers) {controllers = _controllers;};
    void setPlayers(map<string, map<string, ofSoundPlayer*> >* _players) {allPlayers = _players;};
    
    void onAccept();
    void onCancel();

    void onTouch(ofTouchEventArgs & touch);
    void draw();
    int getMode() { return mode; };
    void update();
    void drawList();
    void onTouchMoved(ofTouchEventArgs & touch);
    enum modes {
        IDLE,
        INACTIVE,
        SETUP
    };
    bool isInside(int _x, int _y, float boundsX, float boundsY, float width, float height);
};

#endif /* PresetsController_hpp */
