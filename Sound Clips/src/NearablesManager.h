//
//  NearablesManager.h
//  EstimoteTest
//
//  Created by James Bentley on 1/12/16.
//
//

#ifndef NearablesManager_h
#define NearablesManager_h

#include "ofMain.h"
#import <Foundation/Foundation.h>
#import <EstimoteSDK/EstimoteSDK.h>

//This is a class that keeps a list of all nearby estimotes and whether or not they are moving. Basically functions by returning a map of beacon name strings and boolean values telling whether or not they are moving.

@interface nearablesManager : NSObject<ESTNearableManagerDelegate>

@property (nonatomic, strong) ESTNearableManager *manager; //Here is our nearable manager which will return information about the estimotes
@property map<string, bool> *beacons; //Here is the list of beacons that we'll keep

- (void) setup;

@end

//This is the C++ class that wraps the Objective-C class so we can interface with it in C++ for my own sanity
class movementManager {
public:
    nearablesManager *manager;
    map<string, bool> *beacons;
    movementManager();
    void setup();
    map<string, bool>* getNearables();
};


#endif /* NearablesManager_h */
