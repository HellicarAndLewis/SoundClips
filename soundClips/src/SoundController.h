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

#define WIDTH ofGetWidth()
#define HEIGHT ofGetHeight()


//#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSKeyboard.h"
#include "soundRecording.h"
#include "ofxIntegrator.h"
#include "ofxXmlSettings.h"
#include "NearablesManager.h"



struct button {
    string name;
    ofRectangle bounds;
    ofRectangle savedBounds;
    int index;
    bool active = false;
    bool isInside(float _x, float _y) {
        return (_x > bounds.x && _x < (bounds.x + bounds.width)) && (_y > bounds.y && _y < (bounds.y + bounds.height));
    }
};

class SoundController : public button {
private:
    ofSoundPlayer* player;
    soundRecording* recorder;
    ofxiOSKeyboard* keyboard;
    string soundName, categoryName;
    int soundIndex;
    bool playingRecording;
    bool currentlyRecording;
    bool changingEstimote;
    string beaconName;
    string newBeacon;
    Integrator<float> x, y;
    Integrator<float> width, height;
    map<string, map<string, ofSoundPlayer*> >* allPlayers;
    vector<soundRecording*>* allRecorders;
    int number;
    ofTrueTypeFont* numberFontLarge;
    ofTrueTypeFont* numberFont;
    ofTrueTypeFont* catFont;
    ofTrueTypeFont* soundFont;
    
    button categoryButtons[NUM_CATEGORY_BUTTONS];
    button soundButtons[NUM_SOUND_BUTTONS];
    button edit;
    button record;
    button mute;
    button changeEstimote;
    
    movementManager* estimotes;
    
    ofImage* smallEditImage;
    ofImage* largeEditImage;
    ofImage* heirarchyArrowMain;
    ofImage* heirarchyArrowList;
    ofImage* inactiveImage;
    ofImage* muteImage;
    
    
    bool* allMuted;
    bool* settingUp;
    
    ofColor col;
    int mode, lastMode;
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
    void setRecorder(soundRecording* _input);
    void setPlayers(map<string, map<string, ofSoundPlayer*> >* _players) {allPlayers = _players;};
    void setRecorders(vector<soundRecording*>* _recorders) {allRecorders = _recorders;};
    void setBeaconName(string _name) {beaconName = _name;};
    void setNumber(int _number) {number = _number;};
    void setNumberFontLarge(ofTrueTypeFont* _font) {numberFontLarge = _font;};
    void setNumberFontSmall(ofTrueTypeFont* _font) {numberFont = _font;};

    void setCatFont(ofTrueTypeFont* _font) {catFont = _font;};
    void setSoundFont(ofTrueTypeFont* _font) {soundFont = _font;};
    void setSmallEditImage(ofImage* _img) {smallEditImage = _img;};
    void setLargeEditImage(ofImage* _img) {largeEditImage = _img;};
    void setHeirarchyArrowMain(ofImage* _img) {heirarchyArrowMain = _img;};
    void setHeirarchyArrowList(ofImage* _img) {heirarchyArrowList = _img;};
    void setInactiveImage(ofImage* _img) {inactiveImage = _img;};
    void setMuteImage(ofImage* _img) {muteImage = _img;};

    void setKeyboard(ofxiOSKeyboard* _keyboard) {keyboard = _keyboard;};
    void setAllMuted(bool* _allMuted) {allMuted = _allMuted;};
    void setCategoryName(string _category) {categoryName = _category;};
    void setSoundName(string _sound) {soundName = _sound;};
    void setMovementManager(movementManager* _manager) {estimotes = _manager;};
    void setSettingUpVariable(bool* _settingUp) {settingUp = _settingUp;};
    
    void setCol(ofColor _col) {col = _col;};
    void setMode(int _mode) {mode = _mode;};
    
    void setIsPlayingRecording(bool isPlayingRecording) { playingRecording = isPlayingRecording;};
    
    //Getters
    ofSoundPlayer* getPlayer() {return player;};
    soundRecording* getRecorder() {return recorder;};
    string getBeaconName() {return beaconName;};
    int getMode() {return mode;};
    map<string, map<string, ofSoundPlayer*> >* getPlayers() { return allPlayers;};
    vector<soundRecording*>* getRecorders() { return allRecorders;};
    
    //functionality
    void setPosition(float _x, float _y, float _width, float _height);
    void onTouch(ofTouchEventArgs & touch);
    void onTouchUp(ofTouchEventArgs & touch);
    void onTouchMoved(ofTouchEventArgs & touch);
    void onDoubleTouch(ofTouchEventArgs & touch);
    void drawLists();
    void setFromXml(ofxXmlSettings* settings);
    void saveToXml(ofxXmlSettings* settings);
    void drawEstimoteSetup();
    
    void update();
    bool isInside(int _x, int _y, float boundsX, float boundsY, float width, float height);
    void play();
    void stop();
    void draw();
};

#endif /* SoundController_hpp */
