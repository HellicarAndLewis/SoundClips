//
//  SoundController.mm
//  soundClips
//
//  Created by James Bentley on 1/12/16.
//
//

#include "SoundController.h"

SoundController::SoundController() {
    playingRecording = false;
    currentlyRecording = false;
    changingEstimote = false;
    mode = modes::IDLE;
    soundIndex = 0;
    recorder = NULL;
    player = NULL;
    newBeacon = "";
}

void SoundController::setPosition(float _x, float _y, float _width, float _height) {
    x.set(_x);
    y.set(_y);
    width.set(_width);
    height.set(_height);
    x.attraction = 0.1;
    y.attraction = 0.1;
    width.attraction = 0.1;
    height.attraction = 0.1;
    
    smallX = _x;
    smallY = _y;
    smallWidth = _width;
    smallHeight = _height;
    
    buffer = 10;
    
    fullX = buffer;
    fullY = ofGetHeight() / 8 + buffer;
    fullWidth = ofGetWidth() - buffer*2;
    fullHeight = fullWidth;
    
    ofRectangle numberBoundingBox = numberFont->getStringBoundingBox("0" + ofToString(number), 0, 0);
    int CategoryX = 2*buffer;
    int CategoryY = fullY + buffer+ catFont->getStringBoundingBox(allPlayers->begin()->first, 0, 0).height + numberBoundingBox.height;
    int CategoryButtonWidth = ( fullWidth - buffer*2 ) / 2;
    int CategoryButtonHeight = ( fullHeight - numberBoundingBox.height - buffer*4 ) / 9;
    
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        categoryButtons[i].bounds = categoryButtons[i].savedBounds = ofRectangle(CategoryX, CategoryY, CategoryButtonWidth, CategoryButtonHeight);
        soundButtons[i].bounds = soundButtons[i].savedBounds = ofRectangle(CategoryX + CategoryButtonWidth, CategoryY,  CategoryButtonWidth, CategoryButtonHeight);
        soundButtons[i].index = i;
        CategoryY += CategoryButtonHeight;
    }
    
    vector<string> catNames;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        catNames.push_back(it->first);
    }
    
    catNames.push_back("Recordings");
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        categoryButtons[i].name = catNames[i];
    }
    
    vector<string> soundNames;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        soundNames.push_back(it->first);
    }
    
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        soundButtons[i].name = soundNames[i];
    }
    
    edit.name = "Edit";
    edit.bounds = ofRectangle(smallX + smallWidth - 60, smallY + buffer/2, 60, 60);
    
    edit.savedBounds = ofRectangle(fullX + fullWidth - numberFont->getStringBoundingBox("0", 0, 0).height - buffer, fullY + buffer, numberFont->getStringBoundingBox("0", 0, 0).height, numberFont->getStringBoundingBox("0", 0, 0).height);
    
    record.name = "Record";
    record.bounds = ofRectangle(ofGetWidth() - buffer*2 - 50 - width.val/2, buffer*2, 100, 100);
    
    changeEstimote.name = "changeEstimote";
    changeEstimote.bounds= ofRectangle(20 + (ofGetWidth() - 20*4) / 6 - 50, ofGetHeight()/16 - 50, 100, 100);
}

void SoundController::setPlayer(ofSoundPlayer* _input) {
    player = _input;
    string category;
    string soundTitle;
    playingRecording = false;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        for(auto soundIt = it->second.begin(); soundIt != it->second.end(); soundIt++) {
            if(soundIt->second == player) {
                soundTitle = soundIt->first;
                category = it->first;
            }
        }
    }
    soundName = soundTitle;
    categoryName = category;
}

void SoundController::setRecorder(soundRecording* _input) {
    recorder = _input;
    categoryName = "Recordings";
    soundName = recorder->getName();
    soundIndex = recorder->getIndex();
}

void SoundController::play() {
    if(!(*allMuted)) {
        if(playingRecording) {
            if(recorder == NULL) {
                return;
            } else if(!recorder->isPlaying()) {
                recorder->play();
            }
        } else if(player == NULL) {
            return;
        } else if(!player->isPlaying()) {
            player->play();
            player->setPaused(false);
        }
        mode = modes::PLAYING;
    }
}

void SoundController::stop() {
    if(playingRecording) {
        if(recorder == NULL) {
            return;
        } else if(recorder->isPlaying()) {
            recorder->stop();
        }
    } else if (player == NULL) {
        return;
    } else if(player->isPlaying()) {
        player->stop();
    } if(mode != modes::SETUP) {
        mode = modes::IDLE;
    }
}

void SoundController::update() {
    x.update();
    y.update();
    width.update();
    height.update();
    if(mode == modes::PLAYING) {
        if(categoryName == "Recordings") {
            if(!recorder->isPlaying()) {
                mode = modes::IDLE;
            }
        } else {
            if(!player->isPlaying()) {
                mode = modes::IDLE;
            }
        }
    }
    if(mode == modes::SETUP && width.val - 5 <= smallWidth) {
        if(player->isPlaying()) {
            mode = modes::PLAYING;
        } else {
            mode = modes::IDLE;
        }
    }
    if(keyboard->isKeyboardShowing() && mode == modes::SETUP) {
        for(int i = 0; i < (*allRecorders).size(); i++) {
            if((*allRecorders)[i]->getIndex() == soundIndex) {
                (*allRecorders)[i]->setName(keyboard->getText());
                soundName = keyboard->getText();
                soundButtons[i].name = keyboard->getText();
            }
        }
    }
    if(!keyboard->isKeyboardShowing()) {
        keyboard->setText("");
    }
    if(mode == modes::SETUP) {
        edit.bounds.y = edit.savedBounds.y - (fullY - y.val);
        for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
            categoryButtons[i].bounds.y = categoryButtons[i].savedBounds.y - (fullY - y.val);
            soundButtons[i].bounds.y = soundButtons[i].savedBounds.y - (fullY - y.val);
        }
        if(!keyboard->isKeyboardShowing() && mode == modes::SETUP && width.val + 5 >= fullWidth) {
            y.target(fullY);
        }
    }
}

void SoundController::draw() {
    ofPushStyle();
    if(mode == modes::SETUP && width.val + 5 >= fullWidth) {
        ofSetColor(255);
        ofDrawRectRounded(changeEstimote.bounds, 10);
    }
    if(mode == modes::SETUP && width.val + 5 >= fullWidth && categoryName == "Recordings") {
        ofPushStyle();
        ofSetColor(255, 0, 0);
        if(currentlyRecording) {
            ofSetLineWidth(5);
            ofNoFill();
        }
        else {
            ofFill();
        }
        ofDrawRectRounded(record.bounds, 10);
        ofSetColor(255);
        catFont->drawString("Rec", record.bounds.x + record.bounds.width/2 - catFont->getStringBoundingBox("Rec", 0, 0).width / 2, record.bounds.y + record.bounds.height/2 + catFont->getStringBoundingBox("Rec", 0, 0).height / 2);
        ofPopStyle();
    }
    ofSetColor(col.r, col.g, col.b);
    ofFill();
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 10);
    ofSetColor(255);
    numberFont->drawString("0" + ofToString(number), x.val + buffer, y.val + numberFont->getStringBoundingBox("0", 0, 0).height + 10);
    if(mode != modes::SETUP && width.val - 5 <= smallWidth) {
        catFont->drawString(categoryName,  x.val + buffer, y.val + numberFont->getStringBoundingBox("0", 0, 0).height + catFont->getStringBoundingBox("d", 0, 0).height + buffer*2);
        soundFont->drawString(soundName, x.val + buffer, y.val + numberFont->getStringBoundingBox("0", 0, 0).height + catFont->getStringBoundingBox("d", 0, 0).height + buffer + soundFont->getStringBoundingBox("d", 0, 0).height + buffer*3);
        gear->draw(edit.bounds);
    }
    ofPopStyle();
    ofPushStyle();
    if(mode == modes::PLAYING) {
        ofFill();
        if(categoryName != "Recordings") {
            ofDrawRectRounded(x.val + buffer, y.val + height.val - buffer - 10, ofMap(player->getPosition(), 0, 1.0, 0, width.val - buffer*2), 10, 10);
        } else {
            ofDrawRectRounded(x.val + buffer, y.val + height.val - buffer - 10, ofMap(recorder->getPlayer()->getPosition(), 0, 1.0, 0, width.val - buffer*2), 10, 10);
        }
    }
    ofPopStyle();
    if(mode == modes::SETUP && width.val + 5 >= fullWidth) {
        catFont->drawString(categoryName,  x.val + 2*buffer + numberFont->getStringBoundingBox("22", 0, 0).width , y.val + catFont->getStringBoundingBox("d", 0, 0).height + buffer);
        soundFont->drawString(soundName, x.val + 2*buffer + numberFont->getStringBoundingBox("22", 0, 0).width, y.val + catFont->getStringBoundingBox("d", 0, 0).height + buffer*3 + soundFont->getStringBoundingBox("d", 0, 0).height);
        if(!changingEstimote) {
            drawLists();
            ofSetColor(255);
            arrow->draw(edit.bounds);
        } else {
            drawEstimoteSetup();
        }
    }
}

void SoundController::onTouch(ofTouchEventArgs & touch) {
    if(mode == modes::IDLE || mode == modes::PLAYING) {
        if(isInside(touch.x, touch.y, x.val, y.val, width.val, height.val) && !edit.isInside(touch.x, touch.y)) {
            stop();
            play();
        }else if(edit.isInside(touch.x, touch.y)) {
            mode = modes::SETUP;
            x.target(fullX);
            y.target(fullY);
            width.target(fullWidth);
            height.target(fullHeight);
            edit.bounds = ofRectangle(fullX + fullWidth - numberFont->getStringBoundingBox("0", 0, 0).height - buffer, fullY + buffer, numberFont->getStringBoundingBox("0", 0, 0).height, numberFont->getStringBoundingBox("0", 0, 0).height);
        }
    } else if(mode == modes::SETUP) {
        if(!keyboard->isKeyboardShowing() && !changingEstimote) {
            for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
                if(isInside(touch.x, touch.y, categoryButtons[i].bounds.x, categoryButtons[i].bounds.y, categoryButtons[i].bounds.width, categoryButtons[i].bounds.height)) {
                    categoryName = categoryButtons[i].name;
                    if(categoryName != "Recordings") {
                        i = 0;
                        soundName = (*allPlayers)[categoryName].begin()->first;
                        for(auto soundIt = (*allPlayers)[categoryName].begin(); soundIt != (*allPlayers)[categoryName].end(); soundIt++) {
                            soundButtons[i].name = soundIt->first;
                            i++;
                        }
                    } else {
                        int i = 0;
                        soundName = (*allRecorders)[0]->getName();
                        soundIndex = (*allRecorders)[0]->getIndex();
                        for(; i < allRecorders->size(); i++) {
                            soundButtons[i].name = (*allRecorders)[i]->getName();
                        }
                        for(; i < NUM_SOUND_BUTTONS; i++) {
                            soundButtons[i].name = "";
                        }
                        
                    }
                } else if(isInside(touch.x, touch.y, soundButtons[i].bounds.x, soundButtons[i].bounds.y, soundButtons[i].bounds.width, soundButtons[i].bounds.height)) {
                    soundName = soundButtons[i].name;
                    soundIndex = soundButtons[i].index;
                }
            }
            if(edit.isInside(touch.x, touch.y)) {
                x.target(smallX);
                y.target(smallY);
                width.target(smallWidth);
                height.target(smallHeight);
                edit.bounds = ofRectangle(smallX + smallWidth - 60, smallY + buffer/2, 60, 60);
                if(categoryName == "Recordings") {
                    playingRecording = true;
                    for(int i = 0; i < allRecorders->size(); i++) {
                        if((*allRecorders)[i]->getIndex() == soundIndex) {
                            setRecorder((*allRecorders)[i]);
                            break;
                        }
                    }
                } else {
                    playingRecording = false;
                    stop();
                    for(auto it = (*allPlayers)[categoryName].begin(); it != (*allPlayers)[categoryName].end(); it++) {
                        if(it->first == soundName) {
                            player = it->second;
                        }
                    }
                }
            }
            if(categoryName == "Recordings" && record.isInside(touch.x, touch.y)) {
                currentlyRecording = true;
                for(int i = 0; i < allRecorders->size(); i++) {
                    if((*allRecorders)[i]->getIndex() == soundIndex) {
                        (*allRecorders)[i]->startRecording();
                        soundButtons[i].active = true;
                        break;
                    }
                }
            }
        }
        if(!keyboard->isKeyboardShowing()) {
            if (changeEstimote.isInside(touch.x, touch.y)) {
                if(!changingEstimote) {
                    changingEstimote = true;
                    newBeacon = "";
                } else {
                    changingEstimote = false;
                    if(newBeacon != "") {
                        beaconName= newBeacon;
                        newBeacon = "";
                    }
                }
            }
        }
    }
}

void SoundController::onTouchUp(ofTouchEventArgs & touch) {
    if(categoryName == "Recordings" && currentlyRecording && mode == modes::SETUP) {
        if(!keyboard->isKeyboardShowing()) {
            keyboard->openKeyboard();
            keyboard->setVisible(true);
            y.target(buffer);
        }
        currentlyRecording = false;
        for(int i = 0; i < allRecorders->size(); i++) {
            (*allRecorders)[i]->stopRecording();
            soundButtons[i].active = false;
        }
    }
}

bool SoundController::isInside(int _x, int _y, float boundsX, float boundsY, float width, float height) {
    return (_x > boundsX && _x < (boundsX + width)) && (_y > boundsY && _y < (boundsY + height));
}

void SoundController::onTouchMoved(ofTouchEventArgs & touch) {
    if(mode == modes::SETUP) {
        if(!keyboard->isKeyboardShowing() && !changingEstimote) {
            for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
                if(isInside(touch.x, touch.y, categoryButtons[i].bounds.x, categoryButtons[i].bounds.y, categoryButtons[i].bounds.width, categoryButtons[i].bounds.height)) {
                    categoryName = categoryButtons[i].name;
                    if(categoryName != "Recordings") {
                        i = 0;
                        soundName = (*allPlayers)[categoryName].begin()->first;
                        for(auto soundIt = (*allPlayers)[categoryName].begin(); soundIt != (*allPlayers)[categoryName].end(); soundIt++) {
                            soundButtons[i].name = soundIt->first;
                            i++;
                        }
                    } else {
                        int i = 0;
                        soundName = (*allRecorders)[0]->getName();
                        for(; i < allRecorders->size(); i++) {
                            soundButtons[i].name = (*allRecorders)[i]->getName();
                        }
                        for(; i < NUM_SOUND_BUTTONS; i++) {
                            soundButtons[i].name = "";
                        }
                        
                    }
                } else if(isInside(touch.x, touch.y, soundButtons[i].bounds.x, soundButtons[i].bounds.y, soundButtons[i].bounds.width, soundButtons[i].bounds.height)) {
                    soundName = soundButtons[i].name;
                    soundIndex = soundButtons[i].index;
                }
            }
        }
    }
}

void SoundController::drawLists() {
    ofPushStyle();
    ofNoFill();
    ofSetColor(0);
    int i = 0;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        if(it->first == categoryName) {
            ofPushStyle();
            ofSetColor(255);
            ofFill();
            ofDrawRectRounded(categoryButtons[i].bounds, 10);
            ofPopStyle();
        }
        catFont->drawString(it->first, categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height - categoryButtons[i].bounds.height/4);
        i++;
    }
    if(categoryName == "Recordings") {
        ofPushStyle();
        ofSetColor(255);
        ofFill();
        ofDrawRectRounded(categoryButtons[i].bounds, 10);
        ofPopStyle();
    }
    catFont->drawString("Recordings", categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height - categoryButtons[i].bounds.height/4);
    if(categoryName != "Recordings") {
        i = 0;
        for(auto it = (*allPlayers)[categoryName].begin(); it != (*allPlayers)[categoryName].end(); it++) {
            if(it->first == soundName) {
                ofPushStyle();
                ofSetColor(255);
                ofFill();
                ofDrawRectRounded(soundButtons[i].bounds, 10);
                ofPopStyle();
            }
            soundFont->drawString(it->first, soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height - soundButtons[i].bounds.height/4);
            i++;
        }
    } else {
        for(int i = 0; i < allRecorders->size(); i++) {
            if((*allRecorders)[i]->getIndex() == soundIndex) {
                ofPushStyle();
                ofSetColor(255);
                ofFill();
                ofDrawRectRounded(soundButtons[i].bounds, 10);
                ofPopStyle();
            }
            soundFont->drawString((*allRecorders)[i]->getName(), soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height - soundButtons[i].bounds.height/4);
        }
    }
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
//        ofDrawRectangle(categoryButtons[i].bounds);
        ofPushStyle();
        if(soundButtons[i].active) {
            ofSetColor(255, 0, 0);
            ofFill();
            ofDrawRectRounded(soundButtons[i].bounds, 10);
            ofSetColor(255);
            soundFont->drawString("Recording...", soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height - soundButtons[i].bounds.height/4);
        }
//        ofDrawRectangle(soundButtons[i].bounds);

        ofPopStyle();
    }
    ofPopStyle();
}

void SoundController::drawEstimoteSetup() {
    ofPushStyle();
    ofSetColor(0);
    int x, y;
    x = fullX + fullWidth/2;
    y = fullY + buffer*4 + numberFont->getStringBoundingBox("22", 0, 0).height;
    string message = "Setting Up A New Beacon...";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "Current Beacon: " + beaconName;
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    int numMoving = 0;
    map<string, bool>* movers = estimotes->getNearables();
    for(auto it = movers->begin(); it != movers->end(); it++) {
        if(it->second) {
            newBeacon = it->first;
            numMoving++;
        }
    }
    if(numMoving > 1) {
        y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
        message = "More than One Beacon Moving!";
        newBeacon = "";
        catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    } else {
        y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
        message = "New Beacon: " + newBeacon;
        catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    }
    y += buffer*4;
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "To setup a new beacon:";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    y+=buffer*2;
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "Make sure all nearby beacons are still.";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    y+= buffer*2;
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "Move the Beacon you would like";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "to connect to this controller.";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    y+= buffer*2;
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "Once your new beacons name is displayed";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "press the button in the";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "top left corner again to save it.";
    catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    ofPopStyle();
    

}

void SoundController::setFromXml(ofxXmlSettings* settings) {
    categoryName = settings->getValue("CONTROLLER:CATEGORY", "Space", number-1);
    beaconName = settings->getValue("CONTROLLER:BEACON", "0", number-1);
    if(categoryName != "Recordings") {
        soundName = settings->getValue("CONTROLLER:SOUND", "Coff", number-1);
        ofSoundPlayer* newPlayer = (*allPlayers)[categoryName][soundName];
        setPlayer(newPlayer);
    } else {
        ofSoundPlayer* newPlayer = (*allPlayers)["Space"]["Coff"];
        setPlayer(newPlayer);
        categoryName = settings->getValue("CONTROLLER:CATEGORY", "Space", number-1);
        soundIndex = ofToInt(settings->getValue("CONTROLLER:SOUND", ofToString(1), number-1));
        for(int i = 0; i < allRecorders->size(); i++) {
            if((*allRecorders)[i]->getIndex() == soundIndex) {
                setRecorder((*allRecorders)[i]);
                soundName = (*allRecorders)[i]->getName();
                playingRecording = true;
                break;
            }
        }
    }
}

void SoundController::saveToXml(ofxXmlSettings* settings) {
    settings->setValue("CONTROLLER:CATEGORY", categoryName, number-1);
    if(categoryName == "Recordings") {
        settings->setValue("CONTROLLER:SOUND", ofToString(soundIndex), number-1);
    } else {
        settings->setValue("CONTROLLER:SOUND", soundName, number-1);
    }
    settings->setValue("CONTROLLER:BEACON", beaconName, number-1);
    settings->saveFile(ofxiOSGetDocumentsDirectory() + "settings.xml");
}