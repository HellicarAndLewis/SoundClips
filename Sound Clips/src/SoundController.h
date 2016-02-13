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

#include "ofxiOS.h"
#include "ofxiOSKeyboard.h"
#include "soundRecording.h"
#include "ofxIntegrator.h"
#include "ofxXmlSettings.h"
#include "NearablesManager.h"

//This is a struct which I use throughout the app. It's basically just a rectangle with an "isInside" method, and a few extra bits. I also save a secondary set of bounds to return to if the size changes and a name and index. The name is for the sound player buttons and the index is for the sound recording buttons. There is also an "active" boolean which we initialize to zero
//I could clean this struct up a bit but it works for this app, it's just a little bulky. I probably could use a smaller button struct with other types of buttons that inherit from it.
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

// sound cotrollers inherit from buttons for the "isInside" method primarily. Could also use bounds and savedBounds but instead I use nicely labeled values for the two bounds sets I need to save because it's easier on my brain. Thinking of it I may change this
class SoundController : public button {
private:
    ofSoundPlayer* player; // pointer to the current player
    soundRecording* recorder; // pointer to the current recorder
    ofxiOSKeyboard* keyboard; // pointer to the app keyboard
    string soundName, categoryName; // name of the current sound and current category (those associated with either "player" or "recorder"
    int soundIndex; // Index of the current sound for use with the recorders
    bool playingRecording; //bool to check if we're playing a recording instead of a normal player
    bool currentlyRecording; // bool to check if we are, at this moment, taking audio input
    bool changingEstimote; // bool to check if we are in the "change estimote" screen (only used when iBeacon is supported on the device)
    string beaconName; // name of the beacon, saved as a long string
    string newBeacon; // name of the new beacon we'd like to set if we are changing the beacon. This may be vestigial
    //These float integrators define the bounds. Important shizzle!
    Integrator<float> x, y;
    Integrator<float> width, height;
    map<string, map<string, ofSoundPlayer*> >* allPlayers; //This is a pointer to the list of all the sound players, it's a map of category names which are keys to maps of sound name and pointers to sound players. In this way each sound players address is associated with both it's name and it's category

    vector<soundRecording*>* allRecorders; //Just a straight up vector of recorder addresses, their names are irrelevant as they are keyed by their indices and their category is always "Recordings" so we don't need to key it.
    
    //This is the estimote manager, and so ends our journey through the useful parts of this class!
    movementManager* estimotes;
    
    int number; // This is the number that is displayed in the top left
    //These variables help with estimote setting
    int radius; // This is the current radius of the pulsing circle for estimote setting
    int numMoving; // This is the number of currently moving estimotes for estimote setting
    int maxRadius; // This is the maximum radius for estimote setting
    float circleX, circleY; // this is the position of the pulsing circle
    
    float timeLastPlayed;
    
    //Fonts for drawing
    ofTrueTypeFont* numberFontLarge;
    ofTrueTypeFont* numberFont;
    ofTrueTypeFont* catFont;
    ofTrueTypeFont* soundFont;
    
    //Several buttons which are pretty self-explanatory
    button categoryButtons[NUM_CATEGORY_BUTTONS];
    button soundButtons[NUM_SOUND_BUTTONS];
    button edit;
    button record;
    button mute;
    button changeEstimote;
    
    //Images for drawing buttons (barf)
    ofImage* smallEditImage;
    ofImage* largeEditImage;
    ofImage* heirarchyArrowMain;
    ofImage* heirarchyArrowList;
    ofImage* inactiveImage;
    ofImage* muteImage;
    ofImage* tick;
    ofImage* tooManyMovingImg;

    
    //Few cheaty pointers to external bools. It's possible life would be cleaner if I just had a pointer to the list of other sound controllers but this is a little faster as Ionly have to go through them once. it's a bit crap that I have this though, because you Need you updated these correctly outside of the class in order to use the class properly. Poor for modularity but technically faster in thsi context and because I don't think I'll really use this class again I think it's fine.
    bool* allMuted;
    bool* settingUp;
    
    //Color to color the beacon
    ofColor col;
    
    //Current mode (quite important)
    int mode, lastMode;
    
    //save the small and large positions so we can go to them later
    float smallX, smallY, smallHeight, smallWidth;
    float fullX, fullY, fullHeight, fullWidth;
    //Save the buffer so it;s uniform throughout the drawing process
    float buffer;
    
public:
    //Modes, these are public because we need to compare them against stuff.
    enum modes {
        IDLE,
        INACTIVE,
        PLAYING,
        SETUP
    };
    
    //Constructor
    SoundController();
    
    //Setters
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
    void setTickImage(ofImage* _tick) {tick = _tick;};
    void setTooManyMovingImage(ofImage* _img) {tooManyMovingImg = _img;};
    void setCol(ofColor _col) {col = _col;};
    void setMode(int _mode) {mode = _mode;};
    void setIsPlayingRecording(bool isPlayingRecording) {playingRecording = isPlayingRecording;};
    
    //Getters
    ofSoundPlayer* getPlayer() {return player;};
    soundRecording* getRecorder() {return recorder;};
    string getBeaconName() {return beaconName;};
    int getMode() {return mode;};
    map<string, map<string, ofSoundPlayer*> >* getPlayers() { return allPlayers;};
    vector<soundRecording*>* getRecorders() { return allRecorders;};
    float getTimeLastPlayed() { return timeLastPlayed; };
    
    //functionality
    void setPosition(float _x, float _y, float _width, float _height, float _fullWidth, float fullHeight); // I know this looks like a setter but it's a bit more than that as it sets a whole bunch of crap
    //These two are the same as above, setters but with a tiny bit of thinking.
    void setPlayer(ofSoundPlayer* _input);
    void setRecorder(soundRecording* _input);
    void onTouch(ofTouchEventArgs & touch);
    void onTouchUp(ofTouchEventArgs & touch);
    void onTouchMoved(ofTouchEventArgs & touch);
    void toggleMute();
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
