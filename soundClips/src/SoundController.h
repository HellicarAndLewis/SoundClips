//
//  SoundController.hpp
//  soundClips
//
//  Created by James Bentley on 1/12/16.
//
//

#ifndef SoundController_h
#define SoundController_h

#define NUM_CATEGORY_BUTTONS 9
#define NUM_SOUND_BUTTONS 9


//#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSKeyboard.h"
#include "soundRecorder.h"
#include "ofxIntegrator.h"


struct button {
    string name;
    ofRectangle bounds;
    int index;
    bool isInside(float _x, float _y) {
        return (_x > bounds.x && _x < (bounds.x + bounds.width)) && (_y > bounds.y && _y < (bounds.y + bounds.height));
    }
};

class SoundController {
private:
    ofSoundPlayer* player;
    soundRecorder* recorder;
    ofxiOSKeyboard* keyboard;
    string soundName, categoryName;
    int soundIndex;
    bool playingRecording;
    bool currentlyRecording;
    string beaconName;
    Integrator<float> x, y;
    Integrator<float> width, height;
    map<string, map<string, ofSoundPlayer*> >* allPlayers;
    vector<soundRecorder*>* allRecorders;
    int number;
    ofTrueTypeFont* numberFont;
    ofTrueTypeFont* listFont;
    
    button categoryButtons[NUM_CATEGORY_BUTTONS];
    button soundButtons[NUM_SOUND_BUTTONS];
    button edit;
    button record;
    
    ofImage* gear;
    ofImage* arrow;
    
    bool* allMuted;

    ofColor col;
    int mode;
    float smallX, smallY, smallHeight, smallWidth;
    float fullX, fullY, fullHeight, fullWidth;
    float buffer;
    
public:
    enum modes {
        IDLE,
        INACTIVE,
        PLAYING,
        SETUP
    };
    
    SoundController();
    
    //Setters
    void setPlayer(ofSoundPlayer* _input);
    void setRecorder(soundRecorder* _input);
    void setPlayers(map<string, map<string, ofSoundPlayer*> >* _players) {allPlayers = _players;};
    void setRecorders(vector<soundRecorder*>* _recorders) {allRecorders = _recorders;};
    void setBeaconName(string _name) {beaconName = _name;};
    void setNumber(int _number) {number = _number;};
    void setNumberFont(ofTrueTypeFont* _font) {numberFont = _font;};
    void setListFont(ofTrueTypeFont* _font) {listFont = _font;};
    void setArrow(ofImage* _arrow) {arrow = _arrow;};
    void setGear(ofImage* _gear) {gear = _gear;};
    void setKeyboard(ofxiOSKeyboard* _keyboard) {keyboard = _keyboard;};
    void setAllMuted(bool* _allMuted) {allMuted = _allMuted;};
    void setCategoryName(string _category) {categoryName = _category;};
    void setSoundName(string _sound) {soundName = _sound;};

    void setCol(ofColor _col) {col = _col;};
    void setMode(int _mode) {mode = _mode;};
    
    //Getters
    ofSoundPlayer* getPlayer() {return player;};
    soundRecorder* getRecorder() {return recorder;};
    string getBeaconName() {return beaconName;};
    int getMode() {return mode;};
    
    //functionality
    void setPosition(float _x, float _y, float _width, float _height);
    void onTouch(ofTouchEventArgs & touch);
    void onTouchUp(ofTouchEventArgs & touch);
    void onTouchMoved(ofTouchEventArgs & touch);
    void drawLists();

    void update();
    bool isInside(int _x, int _y, float boundsX, float boundsY, float width, float height);
    void play();
    void stop();
    void draw();
};

#endif /* SoundController_hpp */
