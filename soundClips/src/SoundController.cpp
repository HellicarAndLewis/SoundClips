//
//  SoundController.cpp
//  soundClips
//
//  Created by James Bentley on 1/12/16.
//
//

#include "SoundController.hpp"

SoundController::SoundController() {
    playingRecording = false;
}

void SoundController::setup(float _x, float _y, float _width, float _height) {
    x.set(_x);
    y.set(_y);
    width.set(_width);
    height.set(_height);
}

void SoundController::play() {
    if(playingRecording) {
        if(!recorder->isPlaying()) {
            recorder->play();
        }
    } else {
        if(!player->isPlaying()) {
            player->play();
            player->setPaused(false);
        }
    }
}

void SoundController::stop() {
    if(playingRecording) {
        if(recorder->isPlaying()) {
            recorder->stop();
        }
    } else {
        if(player->isPlaying()) {
            player->stop();
        }
    }
}

void SoundController::draw() {
    ofPushStyle();
    ofSetColor(255, 0, 0);
    ofFill();
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 10);
    ofNoFill();
    ofSetColor(255);
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 10);
    ofPopStyle();
}