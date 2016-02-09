#ifndef _SOUND_RECORDING
#define _SOUND_RECORDING

#include "ofMain.h"

#include "WavFile.h"
#import <AVFoundation/AVFoundation.h>


class soundRecording {
    
public:
    soundRecording();
    
    void init();
    void draw();
    void reset();
    
    void play();
    void stop();
    
    ofSoundPlayer* getPlayer(){return &sound;};
    void setName(string _name){name = _name;};
    void setIndex(int _index){index = _index;};
    string getName(){return name;};
    int getIndex(){return index;};

    
    void loadAssets();
    void unloadAssets();
    
    void audioReceived( float * input, int bufferSize, int nChannels );
    void setFilePath(string str){ filePath = str; }
    void loadSample();
    
    void startRecording();
    void stopRecording();
    
    bool isRecording(){ return bIsRecording; }
    
    bool isPlaying() { return sound.isPlaying(); };
    
protected:
    
    void            loadAll();
    
    void            deleteAll();
    
    ofSoundStream   soundStream;
    WavFile         wavWriter;
    
    ofSoundPlayer   sound;// specific to my app
    bool            bHasSound; // specific to my app
    
    bool            bIsRecording;
    
    string          name;
    int             index;
    
    // file
    string          fileName;
    string          filePath;
    
    // timing
    double          timeStartedRecording;
    int             timeMillisMaxRecord;
    
    // audio vars
    float           * buffer;
    int             sampleRate;
    int             startBufferSize;
    
};
#endif