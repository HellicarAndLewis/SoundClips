//
//  SoundController.cpp
//  soundClips
//
//  Created by James Bentley on 1/12/16.
//
//

#include "SoundController.h"

SoundController::SoundController() {
    playingRecording = false;
    currentlyRecording = false;
    mode = modes::IDLE;
    soundIndex = 0;
    recorder = NULL;
    player = NULL;
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
    int CategoryY = ofGetHeight() / 8 + buffer + listFont->getStringBoundingBox(allPlayers->begin()->first, 0, 0).height + numberBoundingBox.height;
    int CategoryButtonWidth = ( fullWidth - buffer*2 ) / 2;
    int CategoryButtonHeight = ( fullHeight - numberBoundingBox.height - buffer*4 ) / 9;
    
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        categoryButtons[i].bounds = ofRectangle(CategoryX, CategoryY, CategoryButtonWidth, CategoryButtonHeight);
        soundButtons[i].bounds = ofRectangle(CategoryX + CategoryButtonWidth, CategoryY,  CategoryButtonWidth, CategoryButtonHeight);
        soundButtons[i].index = i;
        CategoryY += CategoryButtonHeight;
    }
    int i = 0;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        categoryButtons[i].name = it->first;
        i++;
    }
    categoryButtons[i].name = "Recordings";
    
    i = 0;
    for(auto soundIt = (*allPlayers)[categoryName].begin(); soundIt != (*allPlayers)[categoryName].end(); soundIt++) {
        soundButtons[i].name = soundIt->first;
        i++;
    }
    edit.name = "Edit";
    edit.bounds = ofRectangle(smallX + smallWidth - 60, smallY + buffer/2, 60, 60);
    
    record.name = "Record";
    record.bounds = ofRectangle(ofGetWidth() - buffer*2 - 50 - width.val/2, buffer*2, 100, 100);
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

void SoundController::setRecorder(soundRecorder* _input) {
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
}

void SoundController::draw() {
    ofPushStyle();
    ofSetColor(col.r, col.g, col.b);
    ofFill();
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 10);
    ofSetColor(255);
    numberFont->drawString("0" + ofToString(number), x.val + buffer, y.val + numberFont->getStringBoundingBox("0", 0, 0).height + 10);
    if(mode != modes::SETUP && width.val - 5 <= smallWidth) {
        listFont->drawString(categoryName,  x.val + buffer, y.val + numberFont->getStringBoundingBox("0", 0, 0).height + listFont->getStringBoundingBox("d", 0, 0).height + buffer*2);
        listFont->drawString(soundName, x.val + buffer, y.val + numberFont->getStringBoundingBox("0", 0, 0).height + listFont->getStringBoundingBox("d", 0, 0).height + buffer + listFont->getStringBoundingBox("d", 0, 0).height + buffer*3);
        gear->draw(edit.bounds);
    }
    ofPopStyle();
    if(mode == modes::PLAYING) {
        if(categoryName != "Recordings") {
            ofDrawRectRounded(x.val + buffer, y.val + height.val - buffer - 10, ofMap(player->getPosition(), 0, 1.0, 0, width.val - buffer*2), 10, 10);
        } else {
            ofDrawRectRounded(x.val + buffer, y.val + height.val - buffer - 10, ofMap(recorder->getPlayPos(), 0, recorder->getRecPos(), 0, width.val - buffer*2), 10, 10);
        }
    }
    if(mode == modes::SETUP && width.val + 5 >= fullWidth) {
        listFont->drawString(categoryName,  x.val + 2*buffer + numberFont->getStringBoundingBox("22", 0, 0).width , y.val + listFont->getStringBoundingBox("d", 0, 0).height + buffer);
        listFont->drawString(soundName, x.val + 2*buffer + numberFont->getStringBoundingBox("22", 0, 0).width, y.val + listFont->getStringBoundingBox("d", 0, 0).height + buffer*3 + listFont->getStringBoundingBox("d", 0, 0).height);
        drawLists();
        ofSetColor(255);
        arrow->draw(edit.bounds);
    }
    if(mode == modes::SETUP && width.val + 5 >= fullWidth && categoryName == "Recordings") {
        ofPushStyle();
        ofSetColor(255, 0, 0);
        ofDrawRectRounded(record.bounds, 10);
        ofSetColor(255);
        listFont->drawString("Rec", record.bounds.x + record.bounds.width/2 - listFont->getStringBoundingBox("Rec", 0, 0).width / 2, record.bounds.y + record.bounds.height/2 + listFont->getStringBoundingBox("Rec", 0, 0).height / 2);
//        ofDrawRectangleRo(record.bounds);
        ofPopStyle();
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
                    (*allRecorders)[i]->record();
                    break;
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
        }
        currentlyRecording = false;
        for(int i = 0; i < allRecorders->size(); i++) {
            if((*allRecorders)[i]->getIndex() == soundIndex) {
                (*allRecorders)[i]->stopRecording();
                break;
            }
        }
    }
}

bool SoundController::isInside(int _x, int _y, float boundsX, float boundsY, float width, float height) {
    return (_x > boundsX && _x < (boundsX + width)) && (_y > boundsY && _y < (boundsY + height));
}

void SoundController::onTouchMoved(ofTouchEventArgs & touch) {
    if(mode == modes::SETUP) {
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
            ofDrawRectangle(categoryButtons[i].bounds);
            ofPopStyle();
        }
        listFont->drawString(it->first, categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height - categoryButtons[i].bounds.height/4);
        i++;
    }
    if(categoryName == "Recordings") {
        ofPushStyle();
        ofSetColor(255);
        ofFill();
        ofDrawRectangle(categoryButtons[i].bounds);
        ofPopStyle();
    }
    listFont->drawString("Recordings", categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height - categoryButtons[i].bounds.height/4);
    if(categoryName != "Recordings") {
        i = 0;
        for(auto it = (*allPlayers)[categoryName].begin(); it != (*allPlayers)[categoryName].end(); it++) {
            if(it->first == soundName) {
                ofPushStyle();
                ofSetColor(255);
                ofFill();
                ofDrawRectangle(soundButtons[i].bounds);
                ofPopStyle();
            }
            listFont->drawString(it->first, soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height - soundButtons[i].bounds.height/4);
            i++;
        }
    } else {
        for(int i = 0; i < allRecorders->size(); i++) {
            if((*allRecorders)[i]->getIndex() == soundIndex) {
                ofPushStyle();
                ofSetColor(255);
                ofFill();
                ofDrawRectangle(soundButtons[i].bounds);
                ofPopStyle();
            }
            listFont->drawString((*allRecorders)[i]->getName(), soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height - soundButtons[i].bounds.height/4);
        }
    }
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        ofDrawRectangle(categoryButtons[i].bounds);
        ofDrawRectangle(soundButtons[i].bounds);
    }
    ofPopStyle();
}

void SoundController::setSoundFromXml(ofxXmlSettings* settings) {
    //I am so so sorry for this...
    string num;
    switch (number) {
        case 1:
            num = "ONE";
            break;
        case 2:
            num = "TWO";
            break;
        case 3:
            num = "THREE";
            break;
        case 4:
            num = "FOUR";
            break;
        case 5:
            num = "FIVE";
            break;
        case 6:
            num = "SIX";
            break;
        case 7:
            num = "SEVEN";
            break;
        case 8:
            num = "EIGHT";
            break;
        case 9:
            num = "NINE";
            break;
        default:
            num = "";
            break;
    }
    if(num != "") {
        categoryName = settings->getValue("CONTROLLERS:"+num+":CATEGORY", "Space");
        soundName = settings->getValue("CONTROLLERS:"+num+":SOUND", "Coff");
        ofSoundPlayer* newPlayer = (*allPlayers)[categoryName][soundName];
        setPlayer(newPlayer);
    }
}

void SoundController::saveSoundToXml(ofxXmlSettings* settings) {
    string num;
    switch (number) {
        case 1:
            num = "ONE";
            break;
        case 2:
            num = "TWO";
            break;
        case 3:
            num = "THREE";
            break;
        case 4:
            num = "FOUR";
            break;
        case 5:
            num = "FIVE";
            break;
        case 6:
            num = "SIX";
            break;
        case 7:
            num = "SEVEN";
            break;
        case 8:
            num = "EIGHT";
            break;
        case 9:
            num = "NINE";
            break;
        default:
            num = "";
            break;
    }
    if(num != "") {
        if(categoryName == "Recordings") {
            settings->setValue("CONTROLLERS:"+num+":CATEGORY", allPlayers->begin()->first);
            settings->setValue("CONTROLLERS:"+num+":SOUND", allPlayers->begin()->second.begin()->first);
        } else {
            settings->setValue("CONTROLLERS:"+num+":CATEGORY", categoryName);
            settings->setValue("CONTROLLERS:"+num+":SOUND", soundName);
        }
        settings->saveFile(ofxiOSGetDocumentsDirectory() + "settings.xml");
    }
}