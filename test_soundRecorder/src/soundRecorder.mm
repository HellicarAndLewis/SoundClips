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
    buffer =  new float[bufferLength];
    memset(buffer, 0, bufferLength * sizeof(float));
    wavWriter.setFormat(1, 44100, 32);
    wavWriter.setData(buffer, bufferLength);
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
    //buffer.clear();
    //buffer.setNumChannels(bufferLength);
    //buffer.set(0);
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
//        for(int i = 0; i < bufferSize*nChannels; i++) {
//            if(recPos < bufferLength) {
//                recPos++;
//                //buffer[recPos++] = input[i];
//                //memcpy(&buffer.getBuffer(), input, bufferSize* NUM_BYTES_PER_FLOAT);
//            }
//        }
        wavWriter.write(input, bufferSize*nChannels);
    }
}

void soundRecorder::outputRecording( float * output, int bufferSize, int nChannels ) {
    if(playing) {
        for(int i = 0; i < bufferSize*nChannels; i++) {
            if(playPos < wavWriter.getLength()) {
                //float val = wavWriter.data[playPos++];
                //if(val > 0) cout<<val<<endl;
                //output[i] += val;//buffer[playPos++];
            } else {
                stop();
            }
        }
    }
}

void soundRecorder::write(string _path) {
    wavWriter.save(_path);
}

void soundRecorder::load(string _path) {
    wavWriter.load(_path);
}

float* soundRecorder::getData() {
    return wavWriter.getData();
}
