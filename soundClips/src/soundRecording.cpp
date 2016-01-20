#include "soundRecording.h"

//--------------------------------------------------------------
soundRecording::soundRecording(){
    // vars
    startBufferSize = 256;
    sampleRate = 44100;
    
    buffer = new float[startBufferSize];
    memset(buffer, 0, startBufferSize * sizeof(float));
    
    // file names
    // fileNames[0]="secret.wav";
    // specific to my app so delete above
    
//    wavWriter.setData(buffer, startBufferSize);
    
        bHasSound=false;
}

//--------------------------------------------------------------
void soundRecording::init(){
    // output
    wavWriter.setFormat(1, sampleRate, 16);
    
}

//--------------------------------------------------------------
void soundRecording::audioReceived( float * input, int bufferSize, int nChannels ){
    
    if(bIsRecording){
        if( startBufferSize != bufferSize ){
            ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", startBufferSize, bufferSize);
            return;
        }
        
        // samples are "interleaved"
        for (int i = 0; i < bufferSize; i++){
            buffer[i] = input[i];
        }
        
        wavWriter.write(buffer, bufferSize);
        
    }
}
//--------------------------------------------------------------
void soundRecording::draw(){
    
    ofNoFill();
    
    // draw the input:
    ofSetColor(0, 0, 0);
    ofDrawRectangle(70,100,startBufferSize,200);
    
    for (int i = 0; i < startBufferSize; i++){
        ofDrawLine(70+i,200,70+i,200+buffer[i]*100.0f);
    }
    
    char temp[200];
    
    sprintf(temp, "bIsRecording = %i", (int)bIsRecording);
    ofDrawBitmapString(temp, 70, 320);
    
    sprintf(temp, "length = %i", (int)wavWriter.getLength());
    ofDrawBitmapString(temp, 70, 340);
    
}
//--------------------------------------------------------------
void soundRecording::reset(){
    bIsRecording = false;
}
//--------------------------------------------------------------
void soundRecording::startRecording(){
    
    if(!bIsRecording){
        
        string realfile = filePath + fileName;
//        printf("start recording!\n");
//        printf("file = %s\n", realfile.c_str());
        
        wavWriter.open(realfile, WAVFILE_WRITE);
        
        bIsRecording = true;
    }
    
}
//--------------------------------------------------------------
void soundRecording::stopRecording(){
    
    if(bIsRecording){
        
        wavWriter.close();
        
        bIsRecording = false;
        
        loadSample();
    }
}
//--------------------------------------------------------------
void soundRecording::loadAssets(){
    loadAll();
}
//--------------------------------------------------------------
void soundRecording::unloadAssets(){
    
}
//--------------------------------------------------------------
void soundRecording::loadAll(){
    
    for(int i=0; i<15; i++){
        //loadSample(i);
    }
}
//--------------------------------------------------------------
void soundRecording::loadSample(){
    
    bHasSound=false;
    sound.unload();
    
    string realfile = filePath + fileName;
//    printf("load sound = %s\n", realfile.c_str());  
    
    sound.load(realfile);
}  
//--------------------------------------------------------------  
void soundRecording::deleteAll(){  
    
}

//--------------------------------------------------------------
void soundRecording::play() {
    sound.play();
    sound.setPaused(false);
}

//--------------------------------------------------------------
void soundRecording::stop() {
    sound.stop();
}