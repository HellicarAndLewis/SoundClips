//
//  soundRecorder.h
//  soundRecorder
//
//  Created by James Bentley on 1/11/16.
//
//

#ifndef __soundRecorder__soundRecorder__
#define __soundRecorder__soundRecorder__

#include "ofMain.h"

class soundRecorder {
private:
    int playPos, recPos;
    bool playing, recording;
    ofSoundBuffer buffer;
    int bufferLength;
    string name;
    int length;
    int index;
    
public:
    soundRecorder();
    
    void play();
    void record();
    void stop();
    void stopRecording();

    
    void fillRecording( float * input, int bufferSize, int nChannels );
    void outputRecording( float * output, int bufferSize, int nChannels );
    
    //Setters and Getters
    void setPlayPos(int pos = 0) { playPos = pos; };
    void setRecPos(int pos = 0) { recPos = pos; };
    void setDuration(float seconds);
    void setName(string _name) { name = _name; };
    void setIndex(int _index) {index = _index;};
    
    float getDuration();
    int getPlayPos(){ return playPos; };
    int getRecPos(){ return recPos; };
    string getName(){ return name; };
    bool isPlaying() { return playing; };
    bool isRecording() { return recording; };
    int getIndex() { return index; };
    
    ofSoundBuffer* getSoundBuffer() { return &buffer; };
};

#endif /* defined(__soundRecorder__soundRecorder__) */
