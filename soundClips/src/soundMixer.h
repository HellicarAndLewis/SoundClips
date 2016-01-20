//
//  soundMixer.h
//  soundRecorder
//
//  Created by James Bentley on 1/11/16.
//
//

#ifndef __soundRecorder__soundMixer__
#define __soundRecorder__soundMixer__

#include "ofMain.h"

class soundMixer {
private:
    int numInputs, numPlayingInputs;
//    vector<soundRecorder*> recorders;
    vector<ofSoundPlayer*> players;
public:
    soundMixer();
    
    //Setters and Getters
//    int getNumRecorders() { return recorders.size(); };
    int getNumplayers() { return players.size(); };
    int getNumInputs() { return players.size(); };
    
//    soundRecorder* getSoundRecorder(int i) { return recorders[i]; };
    ofSoundPlayer* getSoundPlayer(int i) { return players[i]; };
    
    //functionality
    void outputMix( float * output, int bufferSize, int nChannels );
//    void addRecorder(soundRecorder* recorder);
    void addPlayer(ofSoundPlayer* player);
};

#endif /* defined(__soundRecorder__soundMixer__) */
