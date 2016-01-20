//
//  soundRecorder.cpp
//  soundRecorder
//
//  Created by James Bentley on 1/11/16.
//
//

#include "soundRecorder.h"
#define SAMPLES_PER_SECOND 44100

soundRecorder::soundRecorder() {
    playPos = 0;
    recPos = 0;
    length = 0;
    playing = false;
    recording = false;
    bufferLength = SAMPLES_PER_SECOND * 10; // 10 seconds
    buffer.allocate(bufferLength, 1);
    buffer.set(0);
}

void soundRecorder::play() {
    playPos = 0;
    playing = true;
    recording = false;
}

void soundRecorder::record() {
    recPos = 0;
    playing = false;
    recording = true;
}

void soundRecorder::setDuration(float seconds) {
    bufferLength = seconds * SAMPLES_PER_SECOND;
    buffer.setNumChannels(bufferLength);
}

float soundRecorder::getDuration() {
    return bufferLength / SAMPLES_PER_SECOND;
}

void soundRecorder::stop() {
    playPos = 0;
    playing  = false;
}

void soundRecorder::stopRecording() {
    recording = false;
}

void soundRecorder::fillRecording( float * input, int bufferSize, int nChannels ) {
    if(recording) {
        for(int i = 0; i < bufferSize*nChannels; i++) {
            if(recPos < bufferLength) {
                buffer[recPos++] = input[i];
            }
        }
    }
}

void soundRecorder::outputRecording( float * output, int bufferSize, int nChannels ) {
    if(playing) {
        for(int i = 0; i < bufferSize*nChannels; i++) {
            if(playPos < recPos) {
                output[i] += buffer[playPos++];
            } else {
                stop();
            }
        }
    }
}