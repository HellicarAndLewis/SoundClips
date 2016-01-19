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
    recorder1->open(ofxiOSGetDocumentsDirectory() + "sound.wav", 2);
    recorders.push_back(recorder1);
    recorders.push_back(recorder2);
        
    for(int i = 0; i < recorders.size(); i++) {
        mixer.addRecorder(recorders[i]);
    }
    
    string message = "";
    if( settings.loadFile(ofxiOSGetDocumentsDirectory() + "settings.xml") ){
        message = "settings.xml loaded from documents folder!";
    }else if( settings.loadFile("settings/settings.xml") ){
        message = "settings.xml loaded from data folder!";
    }else{
        message = "unable to load settings.xml check data/ folder";
    }
    cout<<message<<endl;
    
    //recorders[0]->load(ofxiOSGetDocumentsDirectory() + "sound.wav");
    
    //ofSoundBuffer buffer;
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
    if(touch.numTouches == 2) {
        recorders[0]->record();
        cout<<"Recording 1..."<<endl;
    } else if(touch.numTouches == 3) {
        recorders[0]->play();
        cout<<"Playing 1..."<<endl;
    } else if(touch.numTouches == 4) {
        recorders[0]->write(ofxiOSGetDocumentsDirectory() + "sound.wav");
//        if( settings.saveFile(ofxiOSGetDocumentsDirectory() + "settings.xml") ) {
//            cout<<"Saved successfully!"<<endl;
//        }
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    //player.setPaused(true);
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
//    if(player.isPlaying()) {
//        player.setPaused(true);
//    } else {
//        player.setPaused(false);
//    }
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
    }
}

//--------------------------------------------------------------
void ofApp::audioOut( float * output, int bufferSize, int nChannels ) {
    if(recorders.size() == 2) {
        mixer.outputMix(output, bufferSize, nChannels);
    }
}

