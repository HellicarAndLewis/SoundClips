#include "ofApp.h"

#define FRAMES_PER_BUFFER 256
#define BUFFER_LENGTH 441000 // 10 seconds
#define NUM_BYTES_PER_FLOAT 4
//--------------------------------------------------------------
void ofApp::setup(){
    ofSetLogLevel(OF_LOG_VERBOSE);
    phase = 0;
    ofSoundStreamSetup(1, 1);
    soundRecorder* recorder1 = new soundRecorder();
    soundRecorder* recorder2 = new soundRecorder();
    recorders.push_back(recorder1);
    recorders.push_back(recorder2);
    
    player.load("sounds/CC01.mp3");
    player.setPaused(false);
    player.play();
    
    for(int i = 0; i < recorders.size(); i++) {
        mixer.addRecorder(recorders[i]);
    }
    
    ofSoundBuffer buffer;
    //recorder = new soundRecorder();
//    buffer.allocate(BUFFER_LENGTH, 1);
//    buffer.fillWithTone();
//    cout<<buffer.getNumFrames()<<endl;
//    recPos = 0;
//    playPos = 0;
}

//--------------------------------------------------------------
void ofApp::update(){
    
}

//--------------------------------------------------------------
void ofApp::draw(){
	
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    if(touch.numTouches == 1) {
        recorders[0]->record();
        cout<<"Recording 1..."<<endl;
    }
    else if(touch.numTouches == 2 ) {
        recorders[1]->record();
        cout<<"Recording 2..."<<endl;

    } else if(touch.numTouches == 3) {
        recorders[0]->play();
        recorders[1]->play();
        cout<<"Playing 1 & 2..."<<endl;
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
//--------------------------------------------------------------
void ofApp::audioIn( float * input, int bufferSize, int nChannels ) {
    if(recorders.size() == 2) {
        recorders[0]->fillRecording(input, bufferSize, nChannels);
        recorders[1]->fillRecording(input, bufferSize, nChannels);
    }
}

//--------------------------------------------------------------
void ofApp::audioOut( float * output, int bufferSize, int nChannels ) {
    if(recorders.size() == 2) {
        mixer.outputMix(output, bufferSize, nChannels);
        for(int i = 0; i < bufferSize*nChannels; i++) {
            output[i] =
        }
//        recorders[0]->outputRecording(output, bufferSize, nChannels);
//        recorders[1]->outputRecording(output, bufferSize, nChannels);
    }
}
