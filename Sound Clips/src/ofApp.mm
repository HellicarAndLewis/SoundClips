#include "ofApp.h"

#define WIDTH ofGetWidth()
#define HEIGHT ofGetHeight()

//--------------------------------------------------------------
void ofApp::setup(){
    
    loaded = false;
    splashDrawn = false;
    wasSettingUpLastFrame = false;
    
    splashScreen.load("images/splashImage.png");
    screenWidth = ofGetWidth();
    screenHeight = ofGetHeight();
    
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
}

//--------------------------------------------------------------
void ofApp::update(){
    if(loaded) {
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
        } else if(wasSettingUpLastFrame) {
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                if(controllers[i].getMode() == SoundController::modes::INACTIVE) controllers[i].setMode(SoundController::modes::IDLE);
            }
            if(presetsController.getMode() == PresetsController::modes::INACTIVE) presetsController.setMode(PresetsController::modes::IDLE);
        }
        presetsController.update();
    } else if(splashDrawn) {
        load();
        loaded = true;
    }
    wasSettingUpLastFrame = settingUp;
}

//--------------------------------------------------------------
void ofApp::draw(){
    if(!loaded) {
        splashScreen.load("images/splashImage.png");
        splashScreen.draw(0, 0, screenWidth, screenHeight);
        splashDrawn = true;
    } else {
        background.draw(0, 0, screenWidth, screenHeight);
        ofEnableSmoothing();
        if(!allMuted) {
            map<string, bool>* list = manager->getNearables();
            for(auto nearable = list->begin(); nearable != list->end(); nearable++) {
                for(int i = 0; i < NUM_CONTROLLERS; i++) {
                    bool beaconCurrentlyOn = nearable->second;
                    bool beaconOnLastFrame = beaconsLastFrame[nearable->first];
                    if(controllers[i].getBeaconName() == nearable->first && beaconCurrentlyOn && !beaconOnLastFrame) {
                        if(controllers[i].getMode() == SoundController::modes::IDLE) {
                            controllers[i].play();
                        }
                    }
                }
            }
            beaconsLastFrame = *list;
        }
        if(!settingUp || presetsController.getMode() == PresetsController::modes::SETUP) {
            presetsController.draw();

        }
        ofPushStyle();
        if(allMuted) {
            ofSetColor(127);
            ofDrawRectRounded(muteAll.bounds, 20);
            ofSetColor(255);
            ofNoFill();
            ofSetLineWidth(5);
            ofDrawRectRounded(muteAll.bounds, 20);
            categoryFont.drawString("UNMUTE", muteAll.bounds.x + muteAll.bounds.width/2 - categoryFont.getStringBoundingBox("UNMUTE", 0, 0).width / 2, muteAll.bounds.y + muteAll.bounds.height/2 + categoryFont.getStringBoundingBox("UNMUTE", 0, 0).height / 2);
        } else {
            ofSetColor(127);
            ofDrawRectRounded(muteAll.bounds, 20);
            ofSetColor(255);
            ofSetColor(255);
            ofNoFill();
            ofSetLineWidth(5);
            ofDrawRectRounded(muteAll.bounds, 20);
            categoryFont.drawString("MUTE", muteAll.bounds.x + muteAll.bounds.width/2 - categoryFont.getStringBoundingBox("MUTE", 0, 0).width / 2, muteAll.bounds.y + muteAll.bounds.height/2 + categoryFont.getStringBoundingBox("MUTE", 0, 0).height / 2);
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
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].onTouch(touch);
    }
    if(muteAll.isInside(touch.x, touch.y) && !settingUp) {
        if(!allMuted) {
            allMuted = true;
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                controllers[i].setMode(SoundController::modes::INACTIVE);
            }
            for(auto it = players.begin(); it != players.end(); it++) {
                for(auto soundIt = it->second.begin(); soundIt != it->second.end(); soundIt++) {
                    soundIt->second->stop();
                }
            }
            for(int i = 0; i < recorders.size(); i++) {
                recorders[i]->stop();
            }
        } else {
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                if(controllers[i].getMode() == SoundController::modes::INACTIVE) controllers[i].setMode(SoundController::modes::IDLE);
            }
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
    for(int i = 0; i < recorders.size(); i++) {
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
//    cout<<"width: "<<ofGetWidth()<<endl;
//    cout<<"height: "<<ofGetHeight()<<endl;
    
//    int temp = screenWidth;
//    screenWidth = screenHeight;
//    screenHeight = temp;
//    //It looks like when this is called ofGetWidth and ofGetHeight are still the same as in the previous orientation
//    int buffer = screenWidth*0.01;
//    int upperBuffer = screenHeight / 8;
//    float width = (screenWidth - buffer*4) / 3;
//    float height = (screenHeight - buffer*4 - upperBuffer*2) / 3;
//    float topButtonHeight = 0.1 * screenHeight;
//    for(int y = 0; y < NUM_CONTROLLERS/3; y++) {
//        for(int x = 0; x < NUM_CONTROLLERS/3; x++) {
//            int i = x + (int)(3*y);
//            controllers[i].setPosition(buffer * (x%3+1) + width*(x%3), upperBuffer + buffer * (y%3+1) + height*(y%3), width, height, screenWidth, screenHeight);
//        }
//    }
//    presetsController.setPosition(buffer, buffer, width, topButtonHeight, screenWidth, screenHeight);
//    muteAll.bounds = ofRectangle(buffer*2 + width, buffer, width, topButtonHeight);
}

//--------------------------------------------------------------
void ofApp::audioIn( float * input, int bufferSize, int nChannels ) {
    for(int i = 0; i < recorders.size(); i++) {
        recorders[i]->audioReceived(input, bufferSize, nChannels);
    }
}

//--------------------------------------------------------------
void ofApp::popupDismissed() {
    presetsController.onCancel();
}

//--------------------------------------------------------------
void ofApp::popupAccepted() {
    presetsController.onAccept();
}

void ofApp::load() {
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
    
    ofBackground(0);
    
    //Setup the movement Manager
    manager = new movementManager();
    manager->setup();
    
    //Set the variable to tell if any controllers are in setup mode
    settingUp = false;
    
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
    
    ofSoundStreamSetup(0, 1);
    //stream.setup(0, 1, 44100, 512, 4);
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];

    themeNum = 0;
    
    numberFontLarge.load("fonts/ITCAvantGardePro-Demi.otf", HEIGHT*0.143);
    numberFontSmall.load("fonts/ITCAvantGardePro-Demi.otf", HEIGHT*0.110);
    categoryFont.load("fonts/Geo_Oblique.otf", HEIGHT*0.020);
    presetsFont.load("fonts/Geo_Oblique.otf", HEIGHT*0.03);
    soundFont.load("fonts/Geo.otf", HEIGHT*0.022);
    presetsTitleFont.load("fonts/ITCAvantGardePro-Demi.otf", HEIGHT*0.062);
    
    cols[0] = ofColor(158, 200, 215);
    cols[1] = ofColor(140, 215, 63);
    cols[2] = ofColor(247, 184, 70);
    cols[3] = ofColor(240, 84, 35);
    cols[4] = ofColor(69, 114, 184);
    cols[5] = ofColor(208, 161, 202);
    cols[6] = ofColor(155, 54, 148);
    cols[7] = ofColor(228, 119, 37);
    cols[8] = ofColor(244, 202, 146);
    
    smallEditImage.load("images/arrowSmallUp.png");
    largeEditImage.load("images/arrowLargeDown.png");
    heirarchyArrowMain.load("images/Selector_Arrow.png");
    heirarchyArrowList.load("images/Selector_Arrow.png");
    background.load("images/background.png");
    crossImage.load("images/muteCross.png");
    muteImage.load("images/buttonCross.png");
    tick.load("images/tick.png");
    tooManyMoving.load("images/tooManyMovingCross.png");
    
    keyboard = new ofxiOSKeyboard(0,0,0,0);
    keyboard->setMaxChars(9);
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
    
    int buffer = screenHeight*0.01;
    int upperBuffer = screenHeight / 8;
    float width = (screenWidth - buffer*4) / 3;
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
            controllers[i].setInactiveImage(&crossImage);
            controllers[i].setSettingUpVariable(&settingUp);
            controllers[i].setMuteImage(&muteImage);
            controllers[i].setTickImage(&tick);
            controllers[i].setTooManyMovingImage(&tooManyMoving);
            controllers[i].setPosition(buffer * (x%3+1) + width*(x%3), upperBuffer + buffer * (y%3+1) + height*(y%3), width, height, screenWidth, screenHeight);
        }
    }
        
    //mute All button
    muteAll.name = "Mute";
    float topButtonHeight = 0.1 * HEIGHT;
    muteAll.bounds = ofRectangle(buffer*2 + width, buffer, width, topButtonHeight);
    allMuted = false;
    
    presetsController.setColor(ofColor(127));
    presetsController.setFont(&categoryFont);
    presetsController.setListFont(&presetsFont);
    presetsController.setPresetNames(&themes);
    presetsController.setAcceptImage(&largeEditImage);
    presetsController.setControllers(&controllers[0]);
    presetsController.setTitleFont(&presetsTitleFont);
    presetsController.setPlayers(&players);
    presetsController.setPosition(buffer, buffer, width, topButtonHeight, screenWidth, screenHeight);

}