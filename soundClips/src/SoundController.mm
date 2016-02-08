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
    lastMode = IDLE;
    radius = 0;
    circleX = 0;
    circleY = 0;
    numMoving = 0;
}

void SoundController::setPosition(float _x, float _y, float _width, float _height) {
    buffer = HEIGHT*0.01;
    
    maxRadius =  (int)(HEIGHT*0.10);

    x.set(_x);//buffer * (1+1) + _width*(1));
    y.set(_y + HEIGHT);//HEIGHT/16 + buffer * (1+1) + _width*(1));
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
        
    fullX = buffer;
    fullY = HEIGHT / 8 + buffer;
    fullWidth = WIDTH - buffer*2;
    fullHeight = fullWidth;
    
    x.target(_x);
    y.target(_y);
    
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
    
    float topButtonHeight = HEIGHT*0.1;
    
    edit.name = "Edit";
    edit.bounds = ofRectangle(smallX + smallWidth - HEIGHT*0.03 - buffer, smallY + buffer, HEIGHT*0.03, HEIGHT*0.03);
    edit.savedBounds = ofRectangle(fullX + fullWidth - HEIGHT*0.06 - buffer, fullY + buffer, HEIGHT*0.06, HEIGHT*0.06);
    
    mute.name = "Mute";
    mute.bounds = ofRectangle(smallX + smallWidth - HEIGHT*0.03 - buffer, smallY + smallHeight - HEIGHT*0.03 - buffer, HEIGHT*0.03, HEIGHT*0.03);
    
    record.name = "Record";
    record.bounds = ofRectangle( buffer*3 + _width*2, buffer, _width, topButtonHeight);
    
    changeEstimote.name = "changeEstimote";
    changeEstimote.bounds = ofRectangle(buffer, buffer, _width, topButtonHeight);
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
                break;
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
    lastMode = mode;
}

void SoundController::draw() {
    ofPushStyle();
    if(mode == modes::SETUP && width.val + 5 >= fullWidth) {
        if(estimotes->getNearables()->size() && !changingEstimote) {
            ofSetColor(127);
            ofDrawRectRounded(changeEstimote.bounds, 20);
            ofSetColor(255);
            string title = "CHANGE BEACON";
            catFont->drawString(title, changeEstimote.bounds.x + changeEstimote.bounds.width/2 - catFont->getStringBoundingBox(title, 0, 0).width / 2, changeEstimote.bounds.y + changeEstimote.bounds.height/2 + catFont->getStringBoundingBox(title, 0, 0).height / 2);
        } else if(estimotes->getNearables()->size()) {
            ofSetColor(127);
            ofDrawRectRounded(changeEstimote.bounds, 20);
            ofSetColor(255);
            string title = "CHANGE SOUND";
            catFont->drawString(title, changeEstimote.bounds.x + changeEstimote.bounds.width/2 - catFont->getStringBoundingBox(title, 0, 0).width / 2, changeEstimote.bounds.y + changeEstimote.bounds.height/2 + catFont->getStringBoundingBox(title, 0, 0).height / 2);
        }
    }
    if(mode == modes::SETUP && width.val + 5 >= fullWidth && categoryName == "Recordings") {
        ofPushStyle();
        ofSetColor(255, 0, 0);
        if(currentlyRecording) {
            ofSetColor(0);
            ofDrawRectRounded(record.bounds, 20);
            ofSetColor(255, 0, 0);
            ofSetLineWidth(10);
            ofNoFill();
        }
        else {
            ofFill();
        }
        ofDrawRectRounded(record.bounds, 20);
        ofSetColor(255);
        string title = "REC";
        catFont->drawString(title, record.bounds.x + record.bounds.width/2 - catFont->getStringBoundingBox(title, 0, 0).width / 2, record.bounds.y + record.bounds.height/2 + catFont->getStringBoundingBox(title, 0, 0).height / 2);
        ofPopStyle();
    }
    if(mode == INACTIVE) {
        ofSetColor(col.r, col.g, col.b, 127);
    }
    else ofSetColor(col.r, col.g, col.b, 255);
    ofFill();
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 20);
    ofSetColor(255);
    numberFont->drawString("0" + ofToString(number), x.val + buffer, y.val + numberFont->getStringBoundingBox("0", 0, 0).height + 10);
    if(mode != modes::SETUP && ofDist(x.val, y.val, smallX, smallY) < 2) {
        ofSetColor(0);
        soundFont->drawString(soundName, x.val + buffer, y.val + height.val - buffer);
        ofSetColor(255);
        catFont->drawString(categoryName,  x.val + buffer, y.val + height.val - soundFont->getStringBoundingBox("d", 0, 0).getHeight() - buffer*2);
        ofPushStyle();
        ofSetRectMode(OF_RECTMODE_CENTER);
//        heirarchyArrowMain->draw(x.val + buffer*2 + catFont->getStringBoundingBox(categoryName, 0, 0).getWidth(), y.val + height.val - soundFont->getStringBoundingBox("D", 0, 0).getHeight() - catFont->getStringBoundingBox("D", 0, 0).getHeight() - buffer*2 + buffer/2, 0.02*WIDTH, 0.015*HEIGHT);
        ofPopStyle();
        smallEditImage->draw(edit.bounds);
        muteImage->draw(mute.bounds);
    }
    ofPopStyle();
    ofPushStyle();
    if(mode == modes::PLAYING) {
        ofFill();
        if(categoryName != "Recordings") {
            ofDrawRectRounded(x.val + buffer, y.val + buffer + numberFont->getStringBoundingBox("0", 0, 0).height + buffer, ofMap(player->getPosition(), 0, 1.0, 0, width.val - buffer*2), 3, buffer);
        } else {
            ofDrawRectRounded(x.val + buffer, y.val + buffer + numberFont->getStringBoundingBox("0", 0, 0).height + buffer, ofMap(recorder->getPlayer()->getPosition(), 0, 1.0, 0, width.val - buffer*2), 3, buffer);
        }
    }
    ofPopStyle();
    if(mode == modes::SETUP && width.val + 5 >= fullWidth) {
        catFont->drawString(categoryName,  x.val + 2*buffer + numberFont->getStringBoundingBox("22", 0, 0).width , y.val + catFont->getStringBoundingBox("d", 0, 0).height + buffer);
        ofPushStyle();
        ofSetRectMode(OF_RECTMODE_CENTER);
//        heirarchyArrowMain->draw(x.val + buffer*3 + numberFont->getStringBoundingBox("22", 0, 0).width + catFont->getStringBoundingBox(categoryName, 0, 0).getWidth(), y.val + buffer + catFont->getStringBoundingBox("D", 0, 0).height/2, 0.02*WIDTH, 0.015*HEIGHT);
        ofPopStyle();
        ofSetColor(0);
        soundFont->drawString(soundName, x.val + 2*buffer + numberFont->getStringBoundingBox("22", 0, 0).width, y.val + catFont->getStringBoundingBox("d", 0, 0).height + soundFont->getStringBoundingBox("d", 0, 0).height + buffer + buffer);
        ofSetColor(255);
        ofDrawRectangle(x.val + buffer, y.val + 2* buffer + numberFont->getStringBoundingBox("0", 0, 0).getHeight(), width.val - buffer*2, 3);
        if(!changingEstimote) {
            drawLists();
            ofSetColor(255);
            largeEditImage->draw(edit.bounds);
        } else {
            drawEstimoteSetup();
            largeEditImage->draw(edit.bounds);
        }
    }
    if(mode == INACTIVE) {
        ofPushStyle();
        ofSetColor(col.r, col.g, col.b, 190);
        inactiveImage->draw(x.val, y.val, width.val, height.val);
        ofPopStyle();
    }
}

void SoundController::onTouch(ofTouchEventArgs & touch) {
    if((mode == modes::IDLE || mode == modes::PLAYING) && lastMode != INACTIVE) {
        if(isInside(touch.x, touch.y, x.val, y.val, width.val, height.val) && !edit.isInside(touch.x, touch.y) && !mute.isInside(touch.x, touch.y)) {
            stop();
            play();
        }else if(edit.isInside(touch.x, touch.y)) {
            mode = modes::SETUP;
            x.target(fullX);
            y.target(fullY);
            width.target(fullWidth);
            height.target(fullHeight);
            edit.bounds = ofRectangle(fullX + fullWidth - HEIGHT*0.06 - buffer, fullY + buffer, HEIGHT*0.06, HEIGHT*0.06);
            if(playingRecording) {
                recorder->stop();
            } else {
                player->stop();
            }
        } else if(mute.isInside(touch.x, touch.y)) {
            onDoubleTouch(touch);
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
                    if(categoryName != "Recordings") {
                        int j = 0;
                        for(auto soundIt = (*allPlayers)[categoryName].begin(); soundIt != (*allPlayers)[categoryName].end(); soundIt++) {
                            soundButtons[j].name = soundIt->first;
                            j++;
                        }
                    } else {
                        for(int j = 0; j < allRecorders->size(); j++) {
                            soundButtons[j].name = (*allRecorders)[i]->getName();
                        }
                    }
                    soundName = soundButtons[i].name;
                    soundIndex = soundButtons[i].index;
                }
            }
            if(edit.isInside(touch.x, touch.y)) {
                x.target(smallX);
                y.target(smallY);
                width.target(smallWidth);
                height.target(smallHeight);
                edit.bounds = ofRectangle(smallX + smallWidth - WIDTH*0.041 - buffer, smallY + buffer, HEIGHT*0.03, HEIGHT*0.03);
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
            if(edit.isInside(touch.x, touch.y)) {
                x.target(smallX);
                y.target(smallY);
                width.target(smallWidth);
                height.target(smallHeight);
                changingEstimote = false;
                edit.bounds = ofRectangle(smallX + smallWidth - WIDTH*0.041 - buffer, smallY + buffer, HEIGHT*0.03, HEIGHT*0.03);
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
            if (changeEstimote.isInside(touch.x, touch.y) && estimotes->getNearables()->size()) {
                if(!changingEstimote) {
                    changingEstimote = true;
                    newBeacon = "";
                } else {
                    changingEstimote = false;
                    if(newBeacon != "") {
                        newBeacon = "";
                    }
                }
            }
            if(changingEstimote && ofDist(touch.x, touch.y, circleX, circleY + maxRadius + buffer) < maxRadius) {
                if(numMoving == 1) {
                    beaconName = newBeacon;
                }
            }
        }
    } else if(mode == INACTIVE && !(*settingUp)) {
        if(mute.isInside(touch.x, touch.y)) {
            onDoubleTouch(touch);
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
                    if(categoryName != "Recordings") {
                        int j = 0;
                        for(auto soundIt = (*allPlayers)[categoryName].begin(); soundIt != (*allPlayers)[categoryName].end(); soundIt++) {
                            soundButtons[j].name = soundIt->first;
                            j++;
                        }
                    } else {
                        for(int j = 0; j < allRecorders->size(); j++) {
                            soundButtons[j].name = (*allRecorders)[i]->getName();
                        }
                    }
                    soundName = soundButtons[i].name;
                    soundIndex = soundButtons[i].index;
                }
            }
        }
    }
}

void SoundController::onDoubleTouch(ofTouchEventArgs & touch) {
    if(isInside(touch.x, touch.y, x.val, y.val, width.val, height.val)) {
        if(mode == PLAYING || mode == IDLE) {
            if(!playingRecording) player->stop();
            else recorder->stop();
            mode = INACTIVE;
        } else if(mode == INACTIVE) {
            mode = IDLE;
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
            ofSetColor(255, 255, 255, 51);
            ofFill();
            ofDrawRectRounded(categoryButtons[i].bounds, 20);
            ofSetColor(255, 255, 255, 127);
            heirarchyArrowList->draw(categoryButtons[i].bounds.x + categoryButtons[i].bounds.width - 0.04*WIDTH - buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 - 0.02*HEIGHT*1.5/2, 0.04*WIDTH, 0.03*HEIGHT);
            ofPopStyle();
        }
        ofPushStyle();
        ofSetColor(255);
        catFont->drawString(it->first, categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 + catFont->getStringBoundingBox(it->first, 0, 0).height/2);
        ofPopStyle();
        i++;
    }
    if(categoryName == "Recordings") {
        ofPushStyle();
        ofSetColor(255, 255, 255, 51);
        ofFill();
        ofDrawRectRounded(categoryButtons[i].bounds, 20);
        ofSetColor(255);
        heirarchyArrowList->draw(categoryButtons[i].bounds.x + categoryButtons[i].bounds.width - buffer*2, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 - 0.02*HEIGHT*1.5/2, 0.04*WIDTH, 0.03*HEIGHT);
        ofPopStyle();
    }
    ofPushStyle();
    ofSetColor(255);
    catFont->drawString("Recordings", categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height - categoryButtons[i].bounds.height/4);
    ofPopStyle();
    if(categoryName != "Recordings") {
        i = 0;
        for(auto it = (*allPlayers)[categoryName].begin(); it != (*allPlayers)[categoryName].end(); it++) {
            if(it->first == soundName) {
                ofPushStyle();
                ofSetColor(255, 255, 255, 51);
                ofFill();
                ofDrawRectRounded(soundButtons[i].bounds, 20);
                ofPopStyle();
            }
            soundFont->drawString(it->first, soundButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 + soundFont->getStringBoundingBox(it->first, 0, 0).height/2);
            i++;
        }
    } else {
        for(int i = 0; i < allRecorders->size(); i++) {
            if((*allRecorders)[i]->getIndex() == soundIndex) {
                ofPushStyle();
                ofSetColor(255, 255, 255, 51);
                ofFill();
                ofDrawRectRounded(soundButtons[i].bounds, 20);
                ofPopStyle();
            }
            soundFont->drawString((*allRecorders)[i]->getName(), soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height - soundButtons[i].bounds.height/4);
        }
    }
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        ofPushStyle();
        if(soundButtons[i].active) {
            ofSetColor(255, 0, 0);
            ofFill();
            ofDrawRectRounded(soundButtons[i].bounds, 20);
            ofSetColor(255);
            soundFont->drawString("Recording...", soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height - soundButtons[i].bounds.height/4);
        }
        ofPopStyle();
    }
    ofPopStyle();
}

void SoundController::drawEstimoteSetup() {
    ofPushStyle();
    
    ofSetColor(255);
    int x, y;
    x = fullX + buffer;
    y = fullY + buffer*8 + numberFont->getStringBoundingBox("22", 0, 0).height;
    string message = "Connected Beacon Name: " + beaconName;
    
    ofPushStyle();
    ofSetColor(127, 127);
    ofDrawRectangle(x - buffer, fullY + buffer*7 + numberFont->getStringBoundingBox("22", 0, 0).height - catFont->getStringBoundingBox(message + "y", 0, 0).height, fullWidth, catFont->getStringBoundingBox(message + "y", 0, 0).height*5 + buffer*7);
    ofPopStyle();

    catFont->drawString(message, x, y);
    
    numMoving = 0;
    map<string, bool>* movers = estimotes->getNearables();
    for(auto it = movers->begin(); it != movers->end(); it++) {
        if(it->second) {
            newBeacon = it->first;
            numMoving++;
        }
    }
    
    y += buffer*2;
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "To connect a new beacon follow these steps:";
    catFont->drawString(message, x, y);
    
    y+=buffer*2;
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "1. Make sure all nearby beacons are still.";
    catFont->drawString(message, x, y);
    
    y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
    message = "2. Move the beacon you would like to connect to this controller.";
    catFont->drawString(message, x, y);
    
    ofSetCircleResolution(50);
    
    x = fullX + fullWidth/2;
    
    y += buffer*4;
    
    circleX = x;
    circleY = y;
    if(numMoving == 0) {
        ofNoFill();
        ofSetLineWidth(5);
        radius++;
        radius %= maxRadius;
        for(int i = 0; i < 10; i++) {
            ofSetColor(0, 0, 0, 0 + ofMap((radius + i * (int)(maxRadius) / 10)%(int)(maxRadius), 0, maxRadius, 255, 0));
            ofDrawCircle(x, y + maxRadius + buffer, (radius + i * (int)(maxRadius) / 10)%(int)(maxRadius));
        }
        
        ofSetColor(0);
        y += maxRadius*2 + buffer*6;
        message = "Searching For Moving Beacons...";
        catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    } else if(numMoving == 1) {
        radius = maxRadius;
        ofFill();
        ofSetColor(0, 255, 0);
        ofDrawCircle(x, y + maxRadius + buffer, radius);
        ofSetRectMode(OF_RECTMODE_CENTER);
        ofSetColor(255);
        tick->draw(x, y + maxRadius + buffer, WIDTH*0.26, HEIGHT*0.19);
        y += maxRadius*2 + buffer*4;
        message = "New Beacon Found!";
        ofSetColor(0);
        catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
        y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
        message = "Tap the green button to connect it to this controller.";
        catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    } else if(numMoving > 1) {
        radius = maxRadius;
        ofFill();
        ofSetColor(255, 0, 0);
        ofDrawCircle(x, y + maxRadius + buffer, radius);
        ofSetRectMode(OF_RECTMODE_CENTER);
        ofSetColor(255);
        tooManyMovingImg->draw(x, y + maxRadius + buffer, WIDTH*0.26, HEIGHT*0.19);
        y += maxRadius*2 + buffer*4;
        message = "Multiple Beacons Moving!";
        ofSetColor(0);
        catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
        y += catFont->getStringBoundingBox(message, 0, 0).height + buffer;
        message = "Only move the beacon you wish to connect to this controller.";
        catFont->drawString(message, x - catFont->getStringBoundingBox(message, 0, 0).width/2, y);
    }
    
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