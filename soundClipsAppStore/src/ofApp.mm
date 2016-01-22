#include "ofApp.h"

#define WIDTH ofGetWidth()
#define HEIGHT ofGetHeight()

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
    
    //Setup the movement Manager
    manager = new movementManager();
    manager->setup();
    
    //Set the variable to tell if any controllers are in setup mode
    settingUp = false;
    
    //Setup the sound Mixer
//    mixer = new soundMixer();
    
    //mute All button
    muteAll.name = "Mute";
    muteAll.bounds = ofRectangle(WIDTH/2 - 50, HEIGHT/16 - 50, 100, 100);
    allMuted = false;
    
    //Presets cycle button
    
    //Settings which sound is connected to which beacons
    //    for(int i = 0; i < NUM_CONTROLLERS; i++) {
    //        string number = "0" + ofToString(i+1);
    //        settings.setValue("settings:"+number+":Category", "Jungle");
    //        settings.setValue("settings:"+number+":Sound", "Bon");
    //    }
        
    string message = "";
    
    if( settings.loadFile(ofxiOSGetDocumentsDirectory() + "settings.xml") ){
        message = "settings.xml loaded from documents folder!";
    }else if( settings.loadFile("settings/settings.xml") ){
        message = "settings.xml loaded from data folder!";
    }else{
        message = "unable to load settings.xml check data/ folder";
    }
    cout<<message<<endl;
    
    message = "";
    if( recorderNames.loadFile(ofxiOSGetDocumentsDirectory() + "recorderNames.xml") ){
        message = "recorderNames.xml loaded from documents folder!";
    }else if( recorderNames.loadFile("settings/recorderNames.xml") ){
        message = "recorderNames.xml.xml loaded from data folder!";
    }else{
        message = "unable to load recorderNames.xml.xml check data/ folder";
    }
    cout<<message<<endl;
    
    //Load all the Preset sounds
    ofDirectory soundDir("sounds");
    soundDir.listDir();
    for(int i = 0; i < soundDir.size(); i++) {
        ofDirectory theme(soundDir.getPath(i));
        if(theme.isDirectory()) {
            map<string, ofSoundPlayer*> themePlayers;
            string themeName = ofSplitString(soundDir.getPath(i), "/")[1];
            vector<string> themeSplit = ofSplitString(soundDir.getPath(i), "/");
            themes.push_back(themeSplit[1]);
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
            }
            players[themeName] = themePlayers;
        }
    }
    themes.push_back("Recordings");
    ofSoundStreamSetup(1, 0);
    
    themeNum = 0;
    
    numberFontLarge.load("fonts/ITCAvantGardePro-Demi.otf", 146);
    numberFontSmall.load("fonts/ITCAvantGardePro-Demi.otf", 113);
    categoryFont.load("fonts/Geo_Oblique.otf", 24);
    soundFont.load("fonts/Geo.otf", 20);
    
    cols[0] = ofColor(126, 166, 187);
    cols[1] = ofColor(188, 187, 22);
    cols[2] = ofColor(255, 192, 61);
    cols[3] = ofColor(234, 114, 0);
    cols[4] = ofColor(104, 93, 199);
    cols[5] = ofColor(190, 132, 203);
    cols[6] = ofColor(188, 90, 128);
    cols[7] = ofColor(191, 150, 91);
    cols[8] = ofColor(203, 170, 120);
    
    smallEditImage.load("images/arrowDown.png");
    largeEditImage.load("images/arrowUp.png");
    heirarchyArrowMain.load("images/Heirachy_Arrow_Small.png");
    heirarchyArrowList.load("images/Selector_Arrow.png");
    
    keyboard = new ofxiOSKeyboard(0,0,0,0);
    keyboard->setMaxChars(11);
    keyboard->setBgColor(0, 0, 0, 0);
    keyboard->setFontColor(0,0,0, 0);
    keyboard->setFontSize(0);
    
    recorderNames.pushTag("RECORDERS");
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        soundRecording* recorder = new soundRecording();
        recorder->setName(recorderNames.getValue("NAME", "Empty", i));
        recorder->setIndex(i);
        recorder->setFilePath(ofxiOSGetDocumentsDirectory() + ofToString(i) + ".wav");
        recorder->loadSample();
        recorders.push_back(recorder);
    }
    
    int buffer = 20;
    int upperBuffer = HEIGHT / 8;
    float width = (WIDTH - buffer*4) / 3;
    float height = width;
    for(int y = 0; y < NUM_CONTROLLERS/3; y++) {
        for(int x = 0; x < NUM_CONTROLLERS/3; x++) {
            int i = x + (int)(3*y);
            controllers[i].setRecorders(&recorders);
            controllers[i].setPlayers(&players);
            controllers[i].setNumber(i+1);
            controllers[i].setNumberFontLarge(&numberFontLarge);
            controllers[i].setNumberFontSmall(&numberFontSmall);
            controllers[i].setFromXml(&settings);
            controllers[i].setMovementManager(manager);
            controllers[i].setCatFont(&categoryFont);
            controllers[i].setSoundFont(&soundFont);
            controllers[i].setCol(cols[i]);
            controllers[i].setSmallEditImage(&smallEditImage);
            controllers[i].setLargeEditImage(&largeEditImage);
            controllers[i].setHeirarchyArrowMain(&heirarchyArrowMain);
            controllers[i].setHeirarchyArrowList(&heirarchyArrowList);
            controllers[i].setKeyboard(keyboard);
            controllers[i].setAllMuted(&allMuted);
            controllers[i].setPosition(buffer * (x%3+1) + width*(x%3), upperBuffer + buffer * (y%3+1) + width*(y%3), width, height);
        }
    }
    
    presetsController.setColor(ofColor(127));
    presetsController.setFont(&categoryFont);
    presetsController.setPresetNames(&themes);
    presetsController.setAcceptImage(&largeEditImage);
    presetsController.setControllers(&controllers[0]);
    presetsController.setTitleFont(&numberFontSmall);
    presetsController.setPosition(20 + (WIDTH - 20*4) / 6 - 50, HEIGHT/16 - 50, 100, 100);
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
    if(presetsController.getMode() == PresetsController::modes::SETUP) {
        settingUp = true;
    }
    if(settingUp) {
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            if(controllers[i].getMode() != SoundController::modes::SETUP) controllers[i].setMode(SoundController::modes::INACTIVE);
        }
        if(presetsController.getMode() != PresetsController::modes::SETUP) presetsController.setMode(PresetsController::modes::INACTIVE);
    } else {
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            if(controllers[i].getMode() == SoundController::modes::INACTIVE) controllers[i].setMode(SoundController::modes::IDLE);
        }
        if(presetsController.getMode() == PresetsController::modes::INACTIVE) presetsController.setMode(PresetsController::modes::IDLE);

    }
    presetsController.update();
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofEnableSmoothing();
    ofBackground(0);
    if(!allMuted) {
        map<string, bool>* list = manager->getNearables();
        for(auto nearable = list->begin(); nearable != list->end(); nearable++) {
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                if(controllers[i].getBeaconName() == nearable->first && nearable->second) {
                    if(controllers[i].getMode() == SoundController::modes::IDLE) {
                        controllers[i].play();
                    }
                }
            }
        }
    }
    presetsController.draw();
    ofPushStyle();
    if(allMuted) {
        ofSetColor(127);
        ofDrawRectRounded(muteAll.bounds, 10);
        ofSetColor(255);
        categoryFont.drawString("Unmute", muteAll.bounds.x + muteAll.bounds.width/2 - categoryFont.getStringBoundingBox("Unmute", 0, 0).width / 2, muteAll.bounds.y + muteAll.bounds.height/2 + categoryFont.getStringBoundingBox("Unmute", 0, 0).height / 2);
    } else {
        ofSetColor(127);
        ofDrawRectRounded(muteAll.bounds, 10);
        ofSetColor(255);
        categoryFont.drawString("Mute", muteAll.bounds.x + muteAll.bounds.width/2 - categoryFont.getStringBoundingBox("Mute", 0, 0).width / 2, muteAll.bounds.y + muteAll.bounds.height/2 + categoryFont.getStringBoundingBox("Mute", 0, 0).height / 2);
    }
    
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        if(controllers[i].getMode() != SoundController::modes::SETUP) controllers[i].draw();
    }
    if(settingUp) {
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            if(controllers[i].getMode() == SoundController::modes::SETUP) controllers[i].draw();
        }
    }
    if(presetsController.getMode() == PresetsController::modes::SETUP) {
        presetsController.draw();
    }
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
                for(auto soundIt = it->second.begin(); soundIt != it->second.end(); soundIt++) {
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
    presetsController.onTouch(touch);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].onTouchMoved(touch);
    }
    presetsController.onTouchMoved(touch);
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
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].saveToXml(&settings);
    }
    for(int i = 0; i < 9; i++) {
        recorderNames.setValue("NAME", recorders[i]->getName(), i);
    }
    recorderNames.save(ofxiOSGetDocumentsDirectory() + "recorderNames.xml");
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
        recorders[i]->audioReceived(input, bufferSize, nChannels);
    }
}

////--------------------------------------------------------------
//void ofApp::audioOut( float * output, int bufferSize, int nChannels ) {
//    //mixer->outputMix(output, bufferSize, nChannels);
//}

//--------------------------------------------------------------
void ofApp::popupDismissed() {
    cout<<"dismissed"<<endl;
}

//--------------------------------------------------------------
void ofApp::popupAccepted() {
    presetsController.onAccept();
}