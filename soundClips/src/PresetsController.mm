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

MyViewController * viewController = nil;
AlertViewDelegate * alertViewDelegate = nil;

void PresetsController::draw() {
    ofPushStyle();
    ofSetColor(col.r, col.g, col.b);
    ofFill();
    ofDrawRectRounded(x.val, y.val, width.val, height.val, 10);
    if(mode == modes::IDLE) {
        ofSetColor(255);
        font->drawString("Presets", x.val + width.val/2 - font->getStringBoundingBox("Presets", 0, 0).width/2, y.val + height.val / 2 + font->getStringBoundingBox("Presets", 0, 0).height/2);
        ofPopStyle();
    }
    if(mode == modes::SETUP) {
        if(width.val + 5 >=fullWidth) {
            ofSetColor(255);
            titleFont->drawString("PRESETS", x.val + buffer, y.val + titleFont->getStringBoundingBox("PRESETS", 0, 0).height + 10);
            ofSetColor(255);
            ofDrawRectangle(x.val + buffer, y.val + 2* buffer + titleFont->getStringBoundingBox("0", 0, 0).getHeight(), width.val - buffer*2, 3);
            drawList();
            ofSetColor(255);
            acceptImg->draw(accept.bounds);
            ofSetColor(255, 0, 0);
            acceptImg->draw(cancel.bounds);
        }
    }
    ofPopStyle();
}

void PresetsController::update() {
    x.update();
    y.update();
    width.update();
    height.update();
    if(mode == modes::SETUP && width.val - 5 <= smallWidth) {
        mode = modes::IDLE;
    }
}

void PresetsController::setPosition(float _x, float _y, float _width, float _height) {
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
    
    ofRectangle titleBoundingBox = titleFont->getStringBoundingBox("Presets", 0, 0);
    int PresetX = 2*buffer;
    int PresetY = fullY + buffer + font->getStringBoundingBox((*presets)[0], 0, 0).height + titleBoundingBox.height;
    int PresetButtonWidth = ( fullWidth - buffer*2 ) / 2;
    int PresetButtonHeight = ( fullHeight - titleBoundingBox.height - buffer*4 ) / 9;
    
    for(int i = 0; i < NUM_PRESETS; i++) {
        presetButtons[i].name = (*presets)[i];
        presetButtons[i].bounds = presetButtons[i].savedBounds = ofRectangle(PresetX, PresetY, PresetButtonWidth, PresetButtonHeight);
        PresetY += PresetButtonHeight;
    }
    presetButtons[NUM_PRESETS-1].name = "Recordings";
    
    accept.name = "Accept";
    accept.bounds = ofRectangle(fullX + fullWidth - acceptImg->getWidth() - buffer, fullY + buffer, acceptImg->getWidth(), acceptImg->getHeight());
    
    cancel.name = "Cancel";
    cancel.bounds = accept.bounds;
    cancel.bounds.x -= buffer + accept.bounds.width;
}

void PresetsController::onTouch(ofTouchEventArgs & touch) {
    if(mode == modes::IDLE) {
        if(isInside(touch.x, touch.y, x.val, y.val, width.val, height.val)) {
            mode = modes::SETUP;
            x.target(fullX);
            y.target(fullY);
            width.target(fullWidth);
            height.target(fullHeight);
        }
    } else if( mode == modes::SETUP) {
        if(accept.isInside(touch.x, touch.y)) {
            alertViewDelegate = [[[AlertViewDelegate alloc] init] retain];
            UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Are you Sure you wish to Continue?"
                                                              message:@"Changing the preset will change all the sounds for all the sound controllers"
                                                             delegate:alertViewDelegate
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:nil] retain];
            [alert addButtonWithTitle:ofxStringToNSString("Continue")];
            
            [alert show];
            [alert release];
        } else if (cancel.isInside(touch.x, touch.y) ){
            //do cancel code here
            x.target(smallX);
            y.target(smallY);
            width.target(smallWidth);
            height.target(smallHeight);
        } else {
            for(int i = 0; i < NUM_PRESETS; i++) {
                if(presetButtons[i].isInside(touch.x, touch.y)) {
                    presetNum = i;
                }
            }
        }
    }
}

bool PresetsController::isInside(int _x, int _y, float boundsX, float boundsY, float width, float height) {
   return (_x > boundsX && _x < (boundsX + width)) && (_y > boundsY && _y < (boundsY + height));
}

void PresetsController::drawList() {
    ofPushStyle();
    for(int i = 0; i < NUM_PRESETS; i++) {
        ofPushStyle();
        ofFill();
        if(presetNum == i) {
            ofSetColor(255, 255, 255, 51);
            ofDrawRectRounded(presetButtons[i].bounds, 10);
        }
        ofPopStyle();
        ofPushStyle();
        ofSetColor(255);
        font->drawString(presetButtons[i].name, presetButtons[i].bounds.x + buffer, presetButtons[i].bounds.y + presetButtons[i].bounds.height - presetButtons[i].bounds.height/4);
        ofPopStyle();
    }
    ofPopStyle();
}

void PresetsController::onTouchMoved(ofTouchEventArgs & touch) {
    if( mode == modes::SETUP) {
        for(int i = 0; i < NUM_PRESETS; i++) {
            if(presetButtons[i].isInside(touch.x, touch.y)) {
                presetNum = i;
            }
        }
    }
}

void PresetsController::onAccept() {
    mode = modes::IDLE;
    x.target(smallX);
    y.target(smallY);
    width.target(smallWidth);
    height.target(smallHeight);
    if((*presets)[presetNum] == "Recordings") {
        string category = (*presets)[presetNum];
        vector<soundRecording*>*  recorders = controllers[0].getRecorders();
        for(int i = 0; i < 9; i++) {
            controllers[i].setRecorder((*recorders)[i]);
        }
    } else {
        string category = (*presets)[presetNum];
        map<string, ofSoundPlayer*> categoryPlayers = (*allPlayers)[category];
        auto it = categoryPlayers.begin();
        for(int i = 0; i < 9; i++) {
            ofSoundPlayer* player = it->second;
            controllers[i].setPlayer(player);
            it++;
        }
    }  
}

