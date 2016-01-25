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


@interface nearablesManager : NSObject<ESTNearableManagerDelegate>

@property (nonatomic, strong) ESTNearableManager *manager;
@property map<string, bool> *beacons;

- (void) setup;

@end

class movementManager {
public:
    nearablesManager *manager;
    map<string, bool> *beacons;
    movementManager();
    void setup();
    map<string, bool>* getNearables();
};


#endif /* NearablesManager_h */
