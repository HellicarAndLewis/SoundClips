  //
//  SoundController.mm
//  soundClips
//
//  Created by James Bentley on 1/12/16.
//
//

#include "SoundController.h"

SoundController::SoundController() {
    //A whole bunch of basicl initializers, most of them are redudant after claling setPosition because it sets them too but it's good practice to have these.
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

//This is like a big meaty-ass function that MUST be called after setting everything else because it uses a lot of stuff that is set by the setters. It should have a check on this but it doesn't because I'm lazy and bad at programming. Again not planning on useing this class again so it's all gewd... I think...
void SoundController::setPosition(float _x, float _y, float _width, float _height, float _screenWidth, float _screenHeight) {
    //Set the buffer (a little annoying I use this smae buffer throughout the whole project but I set it to this each time, should probably have a setter for this)
    buffer = _screenHeight*0.01;
    
    //Max radius of the pulsing circle in the setEstimote page
    maxRadius =  (int)(_screenHeight*0.10);
    
    //Ok here we go! The good stuff! Set up all the integrators just like in the presets controller
    x.set(_x);
    y.set(_y + _screenHeight);
    width.set(_width);
    height.set(_height);
    x.attraction = 0.1;
    y.attraction = 0.1;
    width.attraction = 0.1;
    height.attraction = 0.1;
    
    //save the initial state so we can return to it later
    smallX = _x;
    smallY = _y;
    smallWidth = _width;
    smallHeight = _height;
    
    //also save the full size based on a 3x3 grid of these controllers
    fullX = buffer;
    fullY = _screenHeight / 8 + buffer;
    fullWidth = _screenWidth - buffer*2;
    int upperBuffer = _screenHeight / 8;
    fullHeight = (_screenHeight - upperBuffer*2 - buffer*2);
    
    //Target the correct values (I'm thinking that you should always initialize and integrator with a target, I may add a "setAndTarget(&T, &T)" method, unsure, sometimes you definitely want tos et without targetting but when initializing you almost never do!)
    if(mode == modes::SETUP) {
        x.target(fullX);
        y.target(fullY);
        width.target(fullWidth);
        height.target(fullHeight);
    } else {
        x.target(smallX);
        y.target(smallY);
        width.target(smallWidth);
        height.target(smallHeight);
    }
    
    //Here is where we set up the a whole load of buttons. The first thing we'll do is set their positions and to do so we'll start with an initial CategoryX and Y, Width and Height. To find these we need to get the bounding box of our number font at the top.
    ofRectangle numberBoundingBox = numberFont->getStringBoundingBox("0" + ofToString(number), 0, 0);
    int CategoryX = 2*buffer;
    int CategoryY = fullY + buffer+ catFont->getStringBoundingBox(allPlayers->begin()->first, 0, 0).height + numberBoundingBox.height;
    int CategoryButtonWidth = ( fullWidth - buffer*2 ) / 2;
    int CategoryButtonHeight = ( fullHeight - numberBoundingBox.height - buffer*4 ) / 9;
    
    //Once we have these we can go through our buttons one at a time and set their positions while incrementing the Y value by the height of the button, we can also initialize the positions of the sound buttons at the same time AND set their indives
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        categoryButtons[i].bounds = categoryButtons[i].savedBounds = ofRectangle(CategoryX, CategoryY, CategoryButtonWidth, CategoryButtonHeight);
        soundButtons[i].bounds = soundButtons[i].savedBounds = ofRectangle(CategoryX + CategoryButtonWidth, CategoryY,  CategoryButtonWidth, CategoryButtonHeight);
        soundButtons[i].index = i;
        CategoryY += CategoryButtonHeight;
    }
    
    //Now go through our players and get the list of category names
    vector<string> catNames;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        catNames.push_back(it->first);
    }
    catNames.push_back("Recordings"); // add the last category "Recordings" to the end
    
    //Now set the category buttons to those names
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        categoryButtons[i].name = catNames[i];
    }
    
    //Now do the same above that we did for the category buttons but for the names of the sound buttons
    vector<string> soundNames;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        soundNames.push_back(it->first);
    }
    
    for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
        soundButtons[i].name = soundNames[i];
    }
    
    //Now we set the positions of the buttons
    float topButtonHeight = _screenHeight*0.1;
    
    //Edit button for entering and exitting setup mode
    edit.name = "Edit";
    edit.bounds = ofRectangle(smallX + smallWidth - _screenHeight*0.03 - buffer, smallY + buffer, _screenHeight*0.03, _screenHeight*0.03);
    edit.savedBounds = ofRectangle(fullX + fullWidth - _screenHeight*0.06 - buffer, fullY + buffer, _screenHeight*0.06, _screenHeight*0.06);
    
    //Mute button for muting that particular estimote
    mute.name = "Mute";
    mute.bounds = ofRectangle(smallX + smallWidth - _screenHeight*0.03 - buffer, smallY + smallHeight - _screenHeight*0.03 - buffer, _screenHeight*0.03, _screenHeight*0.03);
    
    //Record button for starting the recording
    record.name = "Record";
    record.bounds = ofRectangle( buffer*3 + _width*2, buffer, _width, topButtonHeight);
    
    //Change estimote button for changing the estimote (duh)
    changeEstimote.name = "changeEstimote";
    changeEstimote.bounds = ofRectangle(buffer, buffer, _width, topButtonHeight);
}

//Sets the player in a weird way, basically you give it a pointer to a player which becomes it's player but you also set the name and category by reverse-looking through your map. I think these must be a better way to do this but this was like the first method I wrote and it was late.
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

//Set the name of the recorder. Recorders have a bit more internal structure than the sound players so this method is much cleaner
void SoundController::setRecorder(soundRecording* _input) {
    recorder = _input;
    categoryName = "Recordings";
    soundName = recorder->getName();
    soundIndex = recorder->getIndex();
}

//Play the current sound player or recorder provided the pointer exist and are not NULL
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

//Stop the current recorder or player provided the pointer is not NULL
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

//Update called every frame
void SoundController::update() {
    //update the integrators
    x.update();
    y.update();
    width.update();
    height.update();
    //Check if we were playing but we've now stopped
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
    //Check if we were setting up but we've now stopped
    if(mode == modes::SETUP && width.val - 5 <= smallWidth) {
        if(!(categoryName == "Recordings")) {
            if(player->isPlaying()) {
                mode = modes::PLAYING;
            } else {
                mode = modes::IDLE;
            }
        } else {
            if(recorder->isPlaying()) {
                mode = modes::PLAYING;
            } else {
                mode = modes::IDLE;
            }
        }
    }
    //Check if our keyboard is showing and if so update the soundName with the text from the keyboard
    if(keyboard->isKeyboardShowing() && mode == modes::SETUP) {
        for(int i = 0; i < (*allRecorders).size(); i++) {
            if((*allRecorders)[i]->getIndex() == soundIndex) {
                (*allRecorders)[i]->setName(keyboard->getText());
                soundName = keyboard->getText();
                soundButtons[i].name = keyboard->getText();
            }
        }
    }
    //If the keybaord isn;t showing reset the text in the keyboad to an empty string
    if(!keyboard->isKeyboardShowing()) {
        keyboard->setText("");
    }
    //This is a bit of janky code which slides the controller up if we've got the keyboard open. I don't like it and would re-do it given the time but it does work.
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
    //save the last mode so we can tell if the mode has changed
    lastMode = mode;
}

//Draw the controller
void SoundController::draw() {
    ofPushStyle();
    ofFill();
    //If the mode is in setup and we've grown to our full setup size...
    if(mode == modes::SETUP && width.val + 5 >= fullWidth) {
        //Draw the changing estimote button if we can find nearby estimotes
        if(estimotes->getNearables()->size() && !changingEstimote) {
            ofSetColor(127);
            ofDrawRectRounded(changeEstimote.bounds, 20);
            ofSetColor(255);
            ofSetLineWidth(5);
            ofNoFill();
            ofDrawRectRounded(changeEstimote.bounds, 20);
            string title = "CHANGE BEACON";
            catFont->drawString(title, changeEstimote.bounds.x + changeEstimote.bounds.width/2 - catFont->getStringBoundingBox(title, 0, 0).width / 2, changeEstimote.bounds.y + changeEstimote.bounds.height/2 + catFont->getStringBoundingBox(title, 0, 0).height / 2);
        // if we're currently changing estimotes then draw draw the change back to sound methid
        } else if(estimotes->getNearables()->size()) {
            ofSetColor(127);
            ofDrawRectRounded(changeEstimote.bounds, 20);
            ofSetColor(255);
            ofSetLineWidth(5);
            ofNoFill();
            ofDrawRectRounded(changeEstimote.bounds, 20);
            string title = "CHANGE SOUND";
            catFont->drawString(title, changeEstimote.bounds.x + changeEstimote.bounds.width/2 - catFont->getStringBoundingBox(title, 0, 0).width / 2, changeEstimote.bounds.y + changeEstimote.bounds.height/2 + catFont->getStringBoundingBox(title, 0, 0).height / 2);
        }
        //If we've selected the recording category draw the recording button
        if(categoryName == "Recordings") {
            ofPushStyle();
            ofSetColor(255, 0, 0);
            if(currentlyRecording) {
                ofSetColor(0);
                ofFill();
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
    }
    //Here we're drawing the basic background
    //If we're inactive set the alpha to 50% and the color to the saved color
    if(mode == INACTIVE) {
        ofSetColor(col.r, col.g, col.b, 127);
    }
    //If not set the alpha to 100% and the colors to the saved color
    else {
       ofSetColor(col.r, col.g, col.b, 255);
    }
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
        ofPopStyle();
        smallEditImage->draw(edit.bounds);
        muteImage->draw(mute.bounds);
    }
    ofPopStyle();
    ofPushStyle();
    //Draw the rectangle that denoted playing
    if(mode == modes::PLAYING) {
        ofFill();
        if(categoryName != "Recordings") {
            ofDrawRectRounded(x.val + buffer, y.val + buffer + numberFont->getStringBoundingBox("0", 0, 0).height + buffer, ofMap(player->getPosition(), 0, 1.0, 0, width.val - buffer*2), 3, buffer);
        } else {
            ofDrawRectRounded(x.val + buffer, y.val + buffer + numberFont->getStringBoundingBox("0", 0, 0).height + buffer, ofMap(recorder->getPlayer()->getPosition(), 0, 1.0, 0, width.val - buffer*2), 3, buffer);
        }
    }
    ofPopStyle();
    //Draw lists and stuff if we're setting up, do this last so we don't get the ordering wrong (pretty annoying and inelegant)
    if(mode == modes::SETUP && width.val + 5 >= fullWidth) {
        catFont->drawString(categoryName,  x.val + 2*buffer + numberFont->getStringBoundingBox("22", 0, 0).width , y.val + catFont->getStringBoundingBox("d", 0, 0).height + buffer);
        ofPushStyle();
        ofSetRectMode(OF_RECTMODE_CENTER);
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
    //Draw the cross over the inactive controllers
    if(mode == INACTIVE) {
        ofPushStyle();
        ofSetColor(col.r, col.g, col.b, 190);
        inactiveImage->draw(x.val, y.val, width.val, height.val);
        ofPopStyle();
    }
}

//On Touch method which controls most of the apps
void SoundController::onTouch(ofTouchEventArgs & touch) {
    //Touch the sound controller to play the sound (only works if it wasn't inactive last frame)
    if((mode == modes::IDLE || mode == modes::PLAYING) && lastMode != INACTIVE) {
        if(isInside(touch.x, touch.y, x.val, y.val, width.val, height.val) && !edit.isInside(touch.x, touch.y) && !mute.isInside(touch.x, touch.y)) {
            stop();
            play();
        //Check if we've touched the edit button, if so go to setup mode and  stop the sound if it's playing
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
            toggleMute();
        }
    //If we're setting up then we have different controls
    } else if(mode == modes::SETUP) {
        //Check if the keyboard is showing, if the keyboard is showing we only want to interact with the keyboard
        if(!keyboard->isKeyboardShowing()) {
            if(!changingEstimote) {
                //Go through the category buttons and check if we've touched inside any of them, if we have we want to set the sound to the first sound and the category to that category that we touched
                //Also go through the sound buttons to check if we're in those, and if so just set the cound controller
                for(int i = 0; i < NUM_CATEGORY_BUTTONS; i++) {
                    if(categoryButtons[i].isInside(touch.x, touch.y)) {
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
                    } else if(soundButtons[i].isInside(touch.x, touch.y)) {
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
            //If we pressed on the edit button then save the current settings and return to idel mode
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
            //This controlls starting the recording.
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
        //
        if(!keyboard->isKeyboardShowing()) {
            //Open the "change estimote" screen and set initital values
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
            //Touch on the confirm circle to set the beacon
            if(changingEstimote && ofDist(touch.x, touch.y, circleX, circleY + maxRadius + buffer) < maxRadius) {
                if(numMoving == 1) {
                    beaconName = newBeacon;
                }
            }
        }
    //Toggle the mute controller
    } else if(mode == INACTIVE && !(*settingUp)) {
        if(mute.isInside(touch.x, touch.y)) {
            toggleMute();
        }
    }
}

//On touch up handles what we do when a touch is released, this has functionality for the recording button because we need to check the release of this button only
void SoundController::onTouchUp(ofTouchEventArgs & touch) {
    //If we're currently recording then stop recording and show the keyboard
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

//This does that same thing as onTouch for the sound and category buttons to allow the user to slide their finger along instead of having to tap
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

//Toggle the mute on and off
void SoundController::toggleMute() {
    if(mode == PLAYING || mode == IDLE) {
        if(!playingRecording) player->stop();
        else recorder->stop();
        mode = INACTIVE;
    } else if(mode == INACTIVE) {
        mode = IDLE;
    }
}

//Draw the buttons lists for both categories and sounds
void SoundController::drawLists() {
    ofPushStyle();
    ofNoFill();
    ofSetColor(0);
    //Go through all the players and draw the category buttons that correspond to each controller
    int i = 0;
    for(auto it = allPlayers->begin(); it != allPlayers->end(); it++) {
        //If the category is the one selected then draw the background and the arrow to denote that that is the one we have selected
        if(it->first == categoryName) {
            ofPushStyle();
            ofSetColor(255, 255, 255, 51);
            ofFill();
            ofDrawRectRounded(categoryButtons[i].bounds, 20);
            ofSetColor(255, 255, 255, 51);
            heirarchyArrowList->draw(categoryButtons[i].bounds.x + categoryButtons[i].bounds.width - 0.04*WIDTH - buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 - 0.02*HEIGHT*1.5/2, 0.04*WIDTH, 0.03*HEIGHT);
            ofPopStyle();
        }
        //otherwise just draw the text if it's not the one selected
        ofPushStyle();
        ofSetColor(255);
        catFont->drawString(it->first, categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 + catFont->getStringBoundingBox(it->first, 0, 0).height/2);
        ofPopStyle();
        i++;
    }
    //If the category name is recordings then draw recordings
    if(categoryName == "Recordings") {
        ofPushStyle();
        ofSetColor(255, 255, 255, 51);
        ofFill();
        ofDrawRectRounded(categoryButtons[i].bounds, 20);
        ofSetColor(255, 255, 255, 51);
        heirarchyArrowList->draw(categoryButtons[i].bounds.x + categoryButtons[i].bounds.width - 0.04*WIDTH - buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 - 0.02*HEIGHT*1.5/2, 0.04*WIDTH, 0.03*HEIGHT);
        ofPopStyle();
    }
    ofPushStyle();
    ofSetColor(255);
    catFont->drawString("Recordings", categoryButtons[i].bounds.x + buffer, categoryButtons[i].bounds.y + categoryButtons[i].bounds.height/2 + catFont->getStringBoundingBox("Recordings", 0, 0).height/2);
    ofPopStyle();
    //Otherwise use the lsit of players to fill the lists
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
            soundFont->drawString(it->first, soundButtons[i].bounds.x + buffer, soundButtons[i].bounds.y + soundButtons[i].bounds.height/2 + catFont->getStringBoundingBox(it->first, 0, 0).height/2);
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
    //If we're currently recording, demote which one is being recorded into by showing a "Recording" image
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

//Draw the estimote setup page
void SoundController::drawEstimoteSetup() {
    ofPushStyle();
    
    ofSetColor(255);
    int x, y;
    x = fullX + buffer;
    y = fullY + buffer*8 + numberFont->getStringBoundingBox("22", 0, 0).height;
    string message = "Connected Beacon Name: " + beaconName;
    
    ofPushStyle();
    ofSetColor(127, 127);
    ofFill();
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

//Set the values from the xml file, specifically what it's state was the last time you closed the app
void SoundController::setFromXml(ofxXmlSettings* settings) {
    categoryName = settings->getValue("CONTROLLER:CATEGORY", "Domestic", number-1);
    beaconName = settings->getValue("CONTROLLER:BEACON", "0", number-1);
    if(categoryName != "Recordings") {
        soundName = settings->getValue("CONTROLLER:SOUND", "Blender", number-1);
        ofSoundPlayer* newPlayer = (*allPlayers)[categoryName][soundName];
        setPlayer(newPlayer);
    } else {
        ofSoundPlayer* newPlayer = (*allPlayers)["Space"]["Blender"];
        setPlayer(newPlayer);
        categoryName = settings->getValue("CONTROLLER:CATEGORY", "Domestic", number-1);
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

//save the values to the xml file, specifically what it's last state was.
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