//
//  soundMixer.cpp
//  soundRecorder
//
//  Created by James Bentley on 1/11/16.
//
//

#include "soundMixer.h"

soundMixer::soundMixer() {
    numInputs = 0;
}

void soundMixer::outputMix(float * output, int bufferSize, int nChannels) {
    for(int i = 0; i < recorders.size(); i++) {
        recorders[i]->outputRecording(output, bufferSize, nChannels);
    }
    for(int i = 0; i < bufferSize; i++) {
        output[i] /= numInputs;
    }
}

void soundMixer::addRecorder(soundRecorder* recorder) {
    recorders.push_back(recorder);
    numInputs++;
}

void soundMixer::addPlayer(ofSoundPlayer* player) {
    players.push_back(player);
    numInputs++;
}