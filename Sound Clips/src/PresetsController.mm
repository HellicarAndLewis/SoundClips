//
//  PresetsController.cpp
//  soundClips
//
//  Created by James Bentley on 1/21/16.
//
//

#include "PresetsController.h"
#import "MyViewController.h"
#import "AlertViewDelegate.h"

//Start delegate and view controller with nil values
MyViewController * viewController = nil;
AlertViewDelegate * alertViewDelegate = nil;

//Draw the controller
void PresetsController::draw() {
    
    //Draw the background
    ofPushStyle();
    ofSetColor(col.r, col.g, col.b);
    ofFill();
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 20);
    ofNoFill();
    ofSetLineWidth(5);
    ofSetColor(255);
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 20);
    ofPopStyle();
    
    ofPushStyle();
    //Check the mode
    if(mode == modes::IDLE || width.val - 5 <= smallWidth) {
        ofSetColor(255);
        //Draw the presets string if it's IDLE
        font->drawString("PRESETS", x.val + width.val/2 - font->getStringBoundingBox("PRESETS", 0, 0).width/2, y.val + height.val / 2 + font->getStringBoundingBox("PRESETS3", 0, 0).height/2);
    }
    if(mode == modes::SETUP) {
        //If we're setting up check if we're full sized
        if(width.val + 5 >=fullWidth) {
            //If we're full sized write the title header and draw the list of themes
            ofSetColor(255);
            titleFont->drawString("PRESETS", x.val + width.val/2 - titleFont->getStringBoundingBox("PRESETS", 0, 0).width/2, y.val + buffer + titleFont->getStringBoundingBox("PRESETS", 0, 0).height + 10);
            ofSetColor(255);
            ofDrawRectangle(x.val + buffer, y.val + 3 * buffer + titleFont->getStringBoundingBox("0", 0, 0).getHeight(), width.val - buffer*2, 3);
            //Draw the list of themes
            drawList();
            ofSetColor(255);
            //Draw the accept image
            acceptImg->draw(accept.bounds);
        }
    }
    ofPopStyle();
}

void PresetsController::update() {
    //Update the integrators
    x.update();
    y.update();
    width.update();
    height.update();
    //If we're setting up and we're getting smaller, then set the mode to IDLE
    if(mode == modes::SETUP && width.val - 5 <= smallWidth) {
        mode = modes::IDLE;
    }
}

//Set the initial position of the controller
void PresetsController::setPosition(float _x, float _y, float _width, float _height, float _screenWidth, float _screenHeight) {
    //Pass the x, y width and height values to the integrators
    x.set(_x);
    y.set(_y);
    width.set(_width);
    height.set(_height);
    
    //Set the attraction of the integrators to a magic number 0.1
    x.attraction = 0.1;
    y.attraction = 0.1;
    width.attraction = 0.1;
    height.attraction = 0.1;
    
    //Save the initial x, y, width and height so we can go back to them later
    smallX = _x;
    smallY = _y;
    smallWidth = _width;
    smallHeight = _height;
    
    //Initialize the size of the buffer
    buffer = _screenHeight*0.01;
    
    //initilaize the size of the buffer at the top of the whole screen
    int upperBuffer = _screenHeight / 8;
    
    //save the full expanded size of the presets controller which we use when it's in setup mode
    fullX = buffer;
    fullY = _screenHeight / 8 + buffer;
    fullWidth = _screenWidth - buffer*2;
    fullHeight = _screenHeight - upperBuffer*2;
    
    //Target the correct size and position based on the mode, mode check could be used for changing the orientation but we don't use it for that currently
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
    
    //Setup the list buttons
    ofRectangle titleBoundingBox = titleFont->getStringBoundingBox("Presets", 0, 0);
    int PresetX = 2*buffer;
    int PresetY = fullY + buffer*2 + listFont->getStringBoundingBox((*presets)[0], 0, 0).height + titleBoundingBox.height;
    int PresetButtonWidth = ( fullWidth - buffer*2 );
    int PresetButtonHeight = ( fullHeight - titleBoundingBox.height - buffer*8 ) / 9;
    
    for(int i = 0; i < NUM_PRESETS; i++) {
        presetButtons[i].name = (*presets)[i];
        presetButtons[i].bounds = presetButtons[i].savedBounds = ofRectangle(PresetX, PresetY, PresetButtonWidth, PresetButtonHeight);
        PresetY += PresetButtonHeight;
    }
    presetButtons[NUM_PRESETS-1].name = "Recordings";
    
    //Setup the "Accept" button
    accept.name = "Accept";
    accept.bounds = ofRectangle(fullX + fullWidth - _screenHeight*0.06 - buffer, fullY + buffer, _screenHeight*0.06, _screenHeight*0.06);
}

void PresetsController::onTouch(ofTouchEventArgs & touch) {
    //Check if the touch is even inside the controller
    if(isInside(touch.x, touch.y, x.val, y.val, width.val, height.val)) {
        //If the mode is idle change the mode to setup and target the full position and size
        if(mode == modes::IDLE) {
            mode = modes::SETUP;
            x.target(fullX);
            y.target(fullY);
            width.target(fullWidth);
            height.target(fullHeight);
        // if the mode is setup then check other stuff
        } else if( mode == modes::SETUP) {
            //Check if we're pressing the accept button
            if(accept.isInside(touch.x, touch.y)) {
                //Pop up a warning window, cancel to return to idle mode accept to return to idle mode but also change all of the controllers to the preset selection that you chose.
                alertViewDelegate = [[[AlertViewDelegate alloc] init] retain];
                UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure you wish to Continue?"
                                                                  message:@"Changing the preset will change all the sounds for all the sound controllers.\nCancel to return to the main menu without changes."
                                                                 delegate:alertViewDelegate
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:nil] retain];
                [alert addButtonWithTitle:ofxStringToNSString("Continue")];
                [alert show];
                [alert release];
            }else {
                //Iterate over the preset buttons and check if we're touching it. If so set the preset number to the one we're touching
                for(int i = 0; i < NUM_PRESETS; i++) {
                    if(presetButtons[i].isInside(touch.x, touch.y)) {
                        presetNum = i;
                    }
                }
            }
        }
    }
}

//isInside method to check if something is inside something else (amazing)
bool PresetsController::isInside(int _x, int _y, float boundsX, float boundsY, float width, float height) {
   return (_x > boundsX && _x < (boundsX + width)) && (_y > boundsY && _y < (boundsY + height));
}

//Draw the list text
void PresetsController::drawList() {
    ofPushStyle();
    //Loop through the preset buttons to get positions. Draw text alwasy and draw greyed out rectangle if it's selected
    for(int i = 0; i < NUM_PRESETS; i++) {
        ofPushStyle();
        ofFill();
        //If selected draw rectangle
        if(presetNum == i) {
            ofSetColor(255, 255, 255, 51);
            ofDrawRectRounded(presetButtons[i].bounds, 20);
        }
        ofPopStyle();
        ofPushStyle();
        ofSetColor(255);
        listFont->drawString(presetButtons[i].name, presetButtons[i].bounds.x + presetButtons[i].bounds.width/2 - listFont->getStringBoundingBox(presetButtons[i].name, 0, 0).width/2 + buffer, presetButtons[i].bounds.y + presetButtons[i].bounds.height/2 + listFont->getStringBoundingBox(presetButtons[i].name, 0, 0).height/2);
        ofPopStyle();
    }
    ofPopStyle();
}

//This just allows the user to scroll the cursor by sliding his/her finger instead of taping every time
void PresetsController::onTouchMoved(ofTouchEventArgs & touch) {
    if( mode == modes::SETUP) {
        for(int i = 0; i < NUM_PRESETS; i++) {
            if(presetButtons[i].isInside(touch.x, touch.y)) {
                presetNum = i;
            }
        }
    }
}

//This handles setting all the sound controllers to the chosen preset theme (only called after accepting the popup)
void PresetsController::onAccept() {
    //First we target our small size to return to the main page
    x.target(smallX);
    y.target(smallY);
    width.target(smallWidth);
    height.target(smallHeight);
    //Check if we selected the recording category, if so we'll need to set recorders instead of players
    if((*presets)[presetNum] == "Recordings") {
        string category = (*presets)[presetNum];
        vector<soundRecording*>*  recorders = controllers[0].getRecorders(); //We can get the recorder list through the pointer saved in controllers[0] because all controllers have the same pointer to recorders and players
        //Loop throuh the sound controllers and set the recording of each one and set it to "playing recording"
        for(int i = 0; i < 9; i++) {
            controllers[i].setRecorder((*recorders)[i]);
            controllers[i].setIsPlayingRecording(true);
        }
    } else {
        //If it's not recordings we'll do the same with the players
        string category = (*presets)[presetNum];
        map<string, ofSoundPlayer*> categoryPlayers = (*allPlayers)[category];
        auto it = categoryPlayers.begin();
        for(int i = 0; i < 9; i++) {
            ofSoundPlayer* player = it->second;
            controllers[i].setPlayer(player);
            controllers[i].setIsPlayingRecording(false);
            it++;
        }
    }  
}

//This handles what we do if we cancel the popup window
void PresetsController::onCancel() {
    //Go back to Idle mode and main page without changing nahy of the sounds attached to the controllers
    x.target(smallX);
    y.target(smallY);
    width.target(smallWidth);
    height.target(smallHeight);
}

