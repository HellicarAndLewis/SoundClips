//
//  NearableManager.m
//  EstimoteTest
//
//  Created by James Bentley on 1/12/16.
//
//

#include "NearablesManager.h"

movementManager::movementManager() {
    manager = [[nearablesManager alloc] init];
}

void movementManager::setup() {
    [manager setup];
    beacons = [manager beacons];
}

map<string, bool>* movementManager::getNearables() {
    return beacons;
}

@implementation nearablesManager

- (void) setup {
    
    [super init];
    
    self.manager = [[ESTNearableManager alloc] init];
    self.manager.delegate = self;
    
    [self.manager startRangingForType:ESTNearableTypeAll];
    
    _beacons = new map<string, bool>();
}

- (void)nearableManager:(ESTNearableManager *)manager didRangeNearables:(NSArray *)nearables withType:(ESTNearableType)type {
    //self.nearables = nearables;
    //self.nearables->clear();
    for(id nearable in nearables) {
        string name = string([[nearable identifier] UTF8String]);
        bool moving = [nearable isMoving];
        self.beacons->operator[](name) = moving;
    }
}

@end

