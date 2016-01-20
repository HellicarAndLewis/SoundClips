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
    numPlayingInputs = 0;
}

void soundMixer::outputMix(float * output, int bufferSize, int nChannels) {
//    numPlayingInputs = 0;
//    for(int i = 0; i < bufferSize; i++) {
//        output[i] = 0;
//    }
//    for(int i = 0; i < recorders.size(); i++) {
//        recorders[i]->outputRecording(output, bufferSize, nChannels);
//        if(recorders[i]->isPlaying()) {
//            numPlayingInputs++;
//        }
//    }
    //    for(int i = 0; i < players.size(); i++) {
    //        if(players[i]->isPlaying()) {
    //            numPlayingInputs++;
    //        }
    //    }
    ////    if(numPlayingInputs > 1) {
    //        for(int i = 0; i < bufferSize; i++) {
    //            output[i] /= numPlayingInputs;
    //        }
    //        for(int i = 0; i < players.size(); i++) {
    //            players[i]->setVolume(1.0f/(float)numPlayingInputs);
    //        }
    //    }
}

//void soundMixer::addRecorder(soundRecorder* recorder) {
//    recorders.push_back(recorder);
//    numInputs++;
//}

void soundMixer::addPlayer(ofSoundPlayer* player) {
    players.push_back(player);
    numInputs++;
}