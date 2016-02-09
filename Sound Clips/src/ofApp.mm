#include "ofApp.h"

#define WIDTH ofGetWidth()
#define HEIGHT ofGetHeight()

//--------------------------------------------------------------
void ofApp::setup(){
    
    //setup some initial booleans for control
    loaded = false;
    splashDrawn = false;
    wasSettingUpLastFrame = false;
    settingUp = false;
    
    //Load the splash screen image
    splashScreen.load("images/splashImage.png");
    
    //Save the screen width and screen height to be used for orientation changes (no longer useful but left in for convenience)
    screenWidth = ofGetWidth();
    screenHeight = ofGetHeight();
    
    //Set the orientation to default
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
    
    //set some graphics settings
    ofEnableAntiAliasing();
    ofSetCircleResolution(50);
}

//--------------------------------------------------------------
void ofApp::update(){
    //Check if everything has been loaded
    if(loaded) {
        
        //Check if any of the sound controllers are in setup mode abd update all of them
        settingUp = false;
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            controllers[i].update();
            if(controllers[i].getMode() == SoundController::modes::SETUP) {
                settingUp = true;
            }
        }
        
        //Also check if the preset controller is in setup mode and update it
        presetsController.update();
        if(presetsController.getMode() == PresetsController::modes::SETUP) {
            settingUp = true;
        }

        //Check if any of the controllers are in setup mode
        if(settingUp) {
            
            //Go through all the controllers and set them to inactive if another is in setup mode
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                if(controllers[i].getMode() != SoundController::modes::SETUP) controllers[i].setMode(SoundController::modes::INACTIVE);
            }
            
            //Do the same with the preset controller
            if(presetsController.getMode() != PresetsController::modes::SETUP) presetsController.setMode(PresetsController::modes::INACTIVE);
            
        //Check if we are were setting up in the last frame but are no longer setting up
        } else if(wasSettingUpLastFrame) {
            
            //Go through the controllers and set them from inactive to idle
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                if(controllers[i].getMode() == SoundController::modes::INACTIVE) controllers[i].setMode(SoundController::modes::IDLE);
            }
            
            //Do the same with the preset controller
            if(presetsController.getMode() == PresetsController::modes::INACTIVE) presetsController.setMode(PresetsController::modes::IDLE);
        }
        
        //Here we'll look to see if any of our beacons are moving
        //Get the list of nearables and whether or not they are moving
        map<string, bool>* list = manager->getNearables();
        //Iterate over the list and check if any of the beacons have turned on since last frame
        for(auto nearable = list->begin(); nearable != list->end(); nearable++) {
            //Is the beacon currently on?
            bool beaconCurrentlyOn = nearable->second;
            //Was the beacon on last frame?
            bool beaconOnLastFrame = beaconsLastFrame[nearable->first];
            //Check if the beacon has "turned on" ie it was off last frame and is now on
            if(beaconCurrentlyOn && !beaconOnLastFrame) {
                //If a beacon has changed then go through the controllers and find the controller connected to that beacon
                for(int i = 0; i < NUM_CONTROLLERS; i++) {
                    //Check if the controller is connected to that beacon
                    if(controllers[i].getBeaconName() == nearable->first){
                        //Check if the controller is in IDLE mode
                        if(controllers[i].getMode() == SoundController::modes::IDLE) {
                            //If it is in idle mode then play the sound!
                            controllers[i].play();
                        }
                    }
                }
            }
        }
        //Save the beacons list so we can compare it next time and look for any changes.
        beaconsLastFrame = *list;
    //If we havn't loaded everything then we gotta pass on to the draw() function to draw our splash screen then when we come back here we load everthing with the load() function and set loaded to true!
    } else if(splashDrawn) {
        load();
        loaded = true;
    }
    //Save whether or not we are setting up this frame
    wasSettingUpLastFrame = settingUp;
}

//--------------------------------------------------------------
void ofApp::draw(){
    //Check if we've loaded everything
    if(!loaded) {
        //If we have loaded everything then draw the splash image and tell the update() function that we drew our splash image so it will load everything next frame
        splashScreen.draw(0, 0, screenWidth, screenHeight);
        splashDrawn = true;
    //If we have loaded everything then we'll do our drawing!
    } else {
        //Start by drawing our background Image
        background.draw(0, 0, screenWidth, screenHeight);
        //Enable smoothing and anti-aliasing
        ofEnableSmoothing();
        ofEnableAntiAliasing();
        //Check if we aren't setting up a controller. This is the only time we want to draw the presets controller UNLESS the preset controller is in setup mode causing "setting up" to be true
        if(!settingUp || presetsController.getMode() == PresetsController::modes::SETUP) {
            presetsController.draw();
        }
        
        ofPushStyle();
        //Here we draw the mute button
        //Draw the background
        ofSetColor(127);
        ofDrawRectRounded(muteAll.bounds, 20);
        ofSetColor(255);
        ofNoFill();
        ofSetLineWidth(5);
        ofDrawRectRounded(muteAll.bounds, 20);
        //Check if allMuted is set to true and change the text displayed in the mute button
        if(allMuted) {
            categoryFont.drawString("UNMUTE", muteAll.bounds.x + muteAll.bounds.width/2 - categoryFont.getStringBoundingBox("UNMUTE", 0, 0).width / 2, muteAll.bounds.y + muteAll.bounds.height/2 + categoryFont.getStringBoundingBox("UNMUTE", 0, 0).height / 2);
        } else {
            categoryFont.drawString("MUTE", muteAll.bounds.x + muteAll.bounds.width/2 - categoryFont.getStringBoundingBox("MUTE", 0, 0).width / 2, muteAll.bounds.y + muteAll.bounds.height/2 + categoryFont.getStringBoundingBox("MUTE", 0, 0).height / 2);
        }
        
        //Go through all the controllers and draw them if they aren't in setup mode
        for(int i = 0; i < NUM_CONTROLLERS; i++) {
            if(controllers[i].getMode() != SoundController::modes::SETUP) controllers[i].draw();
        }
        //If one of our controllers is in setup mode draw it last so it's ontop of the other ones
        if(settingUp) {
            for(int i = 0; i < NUM_CONTROLLERS; i++) {
                if(controllers[i].getMode() == SoundController::modes::SETUP) controllers[i].draw();
            }
        }
        //Draw the presets controller last if it's in setup mode
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
    //Go through all the controllers and call their onTouch methods with the current touch
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].onTouch(touch);
    }
    //Check if the mute button is pressed and control the mute button
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
    //Pass the touch to the presets controller
    presetsController.onTouch(touch);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    //PAss the touch to the onTouchMoved methods of the presetsController and the soundControllers
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].onTouchMoved(touch);
    }
    presetsController.onTouchMoved(touch);
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    //Pass the touch to the controllers touchUp method
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
    //Save the settings to the Documents Directory when the app is closed
    //Save the settings for each controller
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        controllers[i].saveToXml(&settings);
    }
    //Save the names of the recorders
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

}

//--------------------------------------------------------------
void ofApp::audioIn( float * input, int bufferSize, int nChannels ) {
    //Pass the audio-in to the recorders
    for(int i = 0; i < recorders.size(); i++) {
        recorders[i]->audioReceived(input, bufferSize, nChannels);
    }
}

//--------------------------------------------------------------
void ofApp::popupDismissed() {
    //When the cancel confirm popup is dismissed call the presetscontroller onCancel method
    presetsController.onCancel();
}

//--------------------------------------------------------------
void ofApp::popupAccepted() {
    //When the cancel confirm popup is accepted call the presetscontroller onAccept method
    presetsController.onAccept();
}

void ofApp::load() {
    //Load all of the initial settings
    
    //Setup the movement Manager
    manager = new movementManager();
    manager->setup();
    
    //Load from the settings files. Try to load them from the Documents directory but if they have not been saved there load them from the data folder with default initial values.
    string message = "";
    if( settings.loadFile(ofxiOSGetDocumentsDirectory() + "settings.xml") ){
        message = "settings.xml loaded from documents folder!";
    }else if( settings.loadFile("settings/settings.xml") ){
        message = "settings.xml loaded from data folder!";
    }else{
        message = "unable to load settings.xml check data/ folder";
    }
    cout<<message<<endl;
    
    if( recorderNames.loadFile(ofxiOSGetDocumentsDirectory() + "recorderNames.xml") ){
        message = "recorderNames.xml loaded from documents folder!";
    }else if( recorderNames.loadFile("settings/recorderNames.xml") ){
        message = "recorderNames.xml.xml loaded from data folder!";
    }else{
        message = "unable to load recorderNames.xml check data/ folder";
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
    
    //open the sound stream
    ofSoundStreamSetup(0, 1);
    
    //Set the audio session category to "Playback" so we can connect to bluetooth audio
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    //Load allt he fonts
    numberFontLarge.load("fonts/ITCAvantGardePro-Demi.otf", HEIGHT*0.143);
    numberFontSmall.load("fonts/ITCAvantGardePro-Demi.otf", HEIGHT*0.110);
    categoryFont.load("fonts/Geo_Oblique.otf", HEIGHT*0.020);
    presetsFont.load("fonts/Geo_Oblique.otf", HEIGHT*0.03);
    soundFont.load("fonts/Geo.otf", HEIGHT*0.022);
    presetsTitleFont.load("fonts/ITCAvantGardePro-Demi.otf", HEIGHT*0.062);
    
    //Initialize all the colors
    ofColor cols[NUM_CONTROLLERS];
    cols[0] = ofColor(158, 200, 215);
    cols[1] = ofColor(140, 215, 63);
    cols[2] = ofColor(247, 184, 70);
    cols[3] = ofColor(240, 84, 35);
    cols[4] = ofColor(69, 114, 184);
    cols[5] = ofColor(208, 161, 202);
    cols[6] = ofColor(155, 54, 148);
    cols[7] = ofColor(244, 202, 146);
    cols[8] = ofColor(228, 119, 37);
    
    //Load all the images
    smallEditImage.load("images/arrowSmallUp.png");
    largeEditImage.load("images/arrowLargeDown.png");
    heirarchyArrowMain.load("images/Selector_Arrow.png");
    heirarchyArrowList.load("images/Selector_Arrow.png");
    background.load("images/background.png");
    crossImage.load("images/muteCross.png");
    muteImage.load("images/buttonCross.png");
    tick.load("images/tick.png");
    tooManyMoving.load("images/tooManyMovingCross.png");
    
    //Initialize the keyboard
    keyboard = new ofxiOSKeyboard(0,0,0,0);
    keyboard->setMaxChars(9);
    keyboard->setBgColor(0, 0, 0, 0);
    keyboard->setFontColor(0,0,0, 0);
    keyboard->setFontSize(0);
    
    //Load the recorders and their names
    recorderNames.pushTag("RECORDERS");
    for(int i = 0; i < NUM_CONTROLLERS; i++) {
        soundRecording* recorder = new soundRecording();
        recorder->setName(recorderNames.getValue("NAME", "Empty", i));
        recorder->setIndex(i);
        recorder->setFilePath(ofxiOSGetDocumentsDirectory() + ofToString(i) + ".wav");
        recorder->loadSample();
        recorders.push_back(recorder);
    }
    
    //Setup all the controllers
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
        
    //setup mute all button
    muteAll.name = "Mute";
    float topButtonHeight = 0.1 * HEIGHT;
    muteAll.bounds = ofRectangle(buffer*2 + width, buffer, width, topButtonHeight);
    allMuted = false;
    
    //Setup the presets controller
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