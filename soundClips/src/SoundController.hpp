//
//  SoundController.hpp
//  soundClips
//
//  Created by James Bentley on 1/12/16.
//
//

#ifndef SoundController_hpp
#define SoundController_hpp

#include "ofMain.h"
#include "soundRecorder.h"
#include "ofxIntegrator.h"

class SoundController {
private:
    ofSoundPlayer* player;
    soundRecorder* recorder;
    bool playingRecording;
    string beaconName;
    Integrator<float> x, y;
    Integrator<float> width, height;
    map<string, vector<ofSoundPlayer*> >* allPlayers;
    vector<soundRecorder>* allRecorders;
public:
    SoundController();
    
    
    //Setters
    void setPlayer(ofSoundPlayer* _input) {player = _input;};
    void setRecorder(soundRecorder* _input) {recorder = _input;};
    void setPlayers(map<string, vector<ofSoundPlayer*> >* _players) {allPlayers = _players;};
    void setRecorders(vector<soundRecorder>* _recorders) {allRecorders = _recorders;};
    void setBeaconName(string _name) {beaconName = _name;};
    
    //Getters
    ofSoundPlayer* getPlayer() {return player;};
    soundRecorder* getRecorder() {return recorder;};
    string getBeaconName() {return beaconName;};
    
    //functionality
    void setup(float _x, float _y, float _width, float _height);
    void play();
    void stop();
    void draw();
};

#endif /* SoundController_hpp */
