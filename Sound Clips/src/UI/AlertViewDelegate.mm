//
//  AlertViewDelegate.m
//  emptyExample
//
//  Created by lukasz karluk on 22/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlertViewDelegate.h"
#import "ofxiOSExternalDisplay.h"
#import "ofApp.h"

@implementation AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if(buttonIndex == 0){
        ((ofApp *)ofGetAppPtr())->popupDismissed();
    } else if(buttonIndex == 1){
        ((ofApp *)ofGetAppPtr())->popupAccepted();
    } else {
        vector<ofxiOSExternalDisplayMode> displayModes;
        displayModes = ofxiOSExternalDisplay::getExternalDisplayModes();
        
        if(displayModes.size()==0){
            return; // no display modes found.
        }
        
        int i = buttonIndex - 2;
        ofxiOSExternalDisplay::displayOnExternalScreen(displayModes[i]);
    }
    
}

@end
