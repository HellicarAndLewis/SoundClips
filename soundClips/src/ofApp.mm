#include "ofApp.h"

#define WIDTH ofGetWidth()
#define HEIGHT ofGetHeight()


//--------------------------------------------------------------
void ofApp::setup(){
    //Setup the movement Manager
    manager = new movementManager();
    manager->setup();
    
    //Set the variable to tell if any controllers are in setup mode
    settingUp = false;
    
    //Setup the sound Mixer
    mixer = new soundMixer();
    
    //mute All button
    muteAll.name = "Mute";
    muteAll.bounds = ofRectangle(WIDTH/2 - 50, HEIGHT/16 - 50, 100, 100);
    allMuted = false;
    
    //Load all the Preset sounds
    ofDirectory soundDir("sounds");
    soundDir.listDir();
    for(int i = 0; i < soundDir.size(); i++) {
        ofDirectory theme(soundDir.getPath(i));
        if(theme.isDirectory()) {
            map<string, ofSoundPlayer*> themePlayers;
            string themeName = ofSplitString(soundDir.getPath(i), "/")[1];
            theme.allowExt("mp3");
            theme.allowExt("wav");
            theme.listDir();
            for(int j = 0; j < theme.size(); j++) {
                ofSoundPlayer* player;
                player = new ofSoundPlayer;
                player->load(theme.getPath(j));
                player->setPaused(true);
                vector<string> split = ofSplitString(theme.getPath(j), "/");
                string soundName = split[2];
                vector<string> split2 = ofSplitString(soundName, ".");
                soundName = split2[0];
                themePlayers[soundName] = player;
                mixer->addPlayer(player);
            }
            players[themeName] = themePlayers;
        }
    }
    ofSoundStreamSetup(1, 1);
    
    numberFont.load("fonts/ITCAvantGardePro-Demi.otf", 100);
    listFont.load("fonts/Geo.otf", 32);
    
    cols[0] = ofColor(126, 166, 187);
    cols[1] = ofColor(188, 187, 22);
    cols[2] = ofColor(255, 192, 61);
    cols[3] = ofColor(234, 114, 0);
    cols[4] = ofColor(104, 93, 199);
    cols[5] = ofColor(190, 132, 203);
    cols[6] = ofColor(188, 90, 128);
    cols[7] = ofColor(191, 150, 91);
    cols[8] = ofColor(203, 170, 120);
    
    names[0] = "09af77b7addc328f";
    names[1] = "1c1f067c7123818c";
    names[2] = "25897c39e0aec284";
    names[3] = "25a2d32f97dc41cf";
    names[4] = "b566fbd88ea2be58";
    names[5] = "410d2e8026ed72dd";
    names[6] = "a9a068d3966fa705";
    names[7] = "e7738eeea0f135b3";
    names[8] = "fafe77815408205b";
    
    gear.load("images/gear.png");
    arrow.load("images/arrow.png");
    
    keyboard = new ofxiOSKeyboard(0,0,0,0);
    keyboard->setBgColor(0, 0, 0, 0);
    keyboard->setFontColor(0,0,0, 0);
    keyboard->setFontSize(0);
    
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        soundRecorder* recorder = new soundRecorder();
        recorder->setName("Empty " + ofToString(recorders.size()));
        recorders.push_back(recorder);
        mixer->addRecorder(recorder);
    }

    int buffer = 20;
    int upperBuffer = HEIGHT / 8;
    float width = (WIDTH - buffer*4) / 3;
    float height = width;
    for(int y = 0; y < NUM_CONTROLLERS/3; y++) {
        for(int x = 0; x < NUM_CONTROLLERS/3; x++) {
            int i = x + NUM_CONTROLLERS/3*y;
            controllers[i].setRecorders(&recorders);
            controllers[i].setPlayers(&players);
            controllers[i].setPlayer((i > 5) ? players["Space"]["Bon"] : players["Jungle"]["Coff"]);
            controllers[i].setBeaconName(names[i]);
            controllers[i].setNumber(i);
            controllers[i].setNumberFont(&numberFont);
            controllers[i].setListFont(&listFont);
            controllers[i].setCol(cols[i]);
            controllers[i].setArrow(&arrow);
            controllers[i].setGear(&gear);
            controllers[i].setKeyboard(keyboard);
            controllers[i].setAllMuted(&allMuted);
            controllers[i].setPosition(buffer * (x%3+1) + width*(x%3), upperBuffer + buffer * (y%3+1) + width*(y%3), width, height);
        }
    }
}

//--------------------------------------------------------------
void ofApp::update(){
    settingUp = false;
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].update();
        if(controllers[i].getMode() == SoundController::modes::SETUP) {
            settingUp = true;
        }
    }
    if(settingUp) {
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            if(controllers[i].getMode() != SoundController::modes::SETUP) controllers[i].setMode(SoundController::modes::INACTIVE);
        }
    } else {
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            if(controllers[i].getMode() == SoundController::modes::INACTIVE) controllers[i].setMode(SoundController::modes::IDLE);
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground(0);
    
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        if(controllers[i].getMode() != SoundController::modes::SETUP) controllers[i].draw();
    }
    if(settingUp) {
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            if(controllers[i].getMode() == SoundController::modes::SETUP) controllers[i].draw();
        }
    }
    if(!allMuted) {
        map<string, bool>* list = manager->getNearables();
        for(auto nearable = list->begin(); nearable != list->end(); nearable++) {
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                if(controllers[i].getBeaconName() == nearable->first && nearable->second) {
                    if(controllers[i].getMode() == SoundController::modes::IDLE) controllers[i].play();
                }
            }
        }
    }
    ofPushStyle();
    ofSetColor(127);
    ofDrawRectRounded(muteAll.bounds, 10);
    ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
//    if (touch.numTouches == 1) {
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].onTouch(touch);
    }
    if(muteAll.isInside(touch.x, touch.y)) {
        if(!allMuted) {
            allMuted = true;
            for(auto it = players.begin(); it != players.end(); it++) {
                for(auto soundIt = it->second.begin(); soundIt != it->second.end(); it++) {
                    soundIt->second->stop();
                }
            }
            for(int i = 0; i < recorders.size(); i++) {
                recorders[i]->stop();
            }
        } else {
            allMuted = false;
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].onTouchUp(touch);
    }
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
    for(int i = 0; i < recorders.size(); i++) {
        recorders[i]->fillRecording(input, bufferSize, nChannels);
    }
}

//--------------------------------------------------------------
void ofApp::audioOut( float * output, int bufferSize, int nChannels ) {
        mixer->outputMix(output, bufferSize, nChannels);
}