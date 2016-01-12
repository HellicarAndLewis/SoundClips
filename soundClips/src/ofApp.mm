#include "ofApp.h"

#define WIDTH ofGetWidth()
#define HEIGHT ofGetHeight()

//--------------------------------------------------------------
void ofApp::setup(){
    //Setup the movement Manager
    manager = new movementManager();
    manager->setup();
    
    //Setup the sound Mixer
    mixer = new soundMixer();
    
    //Load all the Preset sounds
    ofDirectory soundDir("sounds");
    soundDir.listDir();
    for(int i = 0; i < soundDir.size(); i++) {
        ofDirectory theme(soundDir.getPath(i));
        if(theme.isDirectory()) {
            vector<ofSoundPlayer*> themePlayers;
            string themeName = ofSplitString(soundDir.getPath(i), "/")[1];
            theme.allowExt("mp3");
            theme.allowExt("wav");
            theme.listDir();
            for(int j = 0; j < theme.size(); j++) {
                ofSoundPlayer* player;
                player = new ofSoundPlayer;
                player->load(theme.getPath(j));
                player->setPaused(true);
                themePlayers.push_back(player);
                mixer->addPlayer(player);
            }
            players[themeName] = themePlayers;
        }
    }
    ofSoundStreamSetup(1, 1);

    int buffer = 20;
    float width = (WIDTH - buffer*4) / 3;
    float height = width;
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].setPlayers(&players);
        controllers[i].setPlayer(players["Space"][0]);
        controllers[i].setBeaconName("09af77b7addc328f");
        controllers[i].setup(buffer * (i%3+1) + width*(i%3), 100, width, height);
    }
}

//--------------------------------------------------------------
void ofApp::update(){

}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackgroundGradient(0, 100);

    map<string, bool>* list = manager->getNearables();
    int y = 20;
    for(auto nearable = list->begin(); nearable != list->end(); nearable++) {
        if(controllers[0].getBeaconName() == nearable->first && nearable->second) {
            controllers[0].play();
        }
        ofDrawBitmapStringHighlight(ofToString(nearable->first) + ": " + ofToString(nearable->second), 10, y);
        y+=20;
    }
    
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].draw();

    }
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    controllers[0].play();
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
    for(auto recorder = recorders.begin(); recorder != recorders.end(); recorder++) {
        recorder->second->fillRecording(input, bufferSize, nChannels);
    }
//    if(recorders.size() == 2) {
//        recorders[0]->fillRecording(input, bufferSize, nChannels);
//        recorders[1]->fillRecording(input, bufferSize, nChannels);
//    }
}

//--------------------------------------------------------------
void ofApp::audioOut( float * output, int bufferSize, int nChannels ) {
        mixer->outputMix(output, bufferSize, nChannels);
        //        for(int i = 0; i < bufferSize*nChannels; i++) {
        //            //output[i] += 0.1;
        //        }
        //        recorders[0]->outputRecording(output, bufferSize, nChannels);
        //        recorders[1]->outputRecording(output, bufferSize, nChannels);
}