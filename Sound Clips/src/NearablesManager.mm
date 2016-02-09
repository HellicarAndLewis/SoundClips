//
//  NearableManager.m
//  EstimoteTest
//
//  Created by James Bentley on 1/12/16.
//
//

#include "NearablesManager.h"

//Constructor which just initializes the nearables manager
movementManager::movementManager() {
    manager = [[nearablesManager alloc] init];
}

//Setup the nearables manager and assign the pointer to the estimotes to the nearbles manager beacon list
void movementManager::setup() {
    [manager setup];
    beacons = [manager beacons];
}

//Return the pointer to the list of beacons
map<string, bool>* movementManager::getNearables() {
    return beacons;
}

@implementation nearablesManager

- (void) setup {
    //Initialize the super class
    [super init];
    
    //Setup the manager and give it itself as a delegate
    self.manager = [[ESTNearableManager alloc] init];
    self.manager.delegate = self;
    
    //Start ranging the beacons
    [self.manager startRangingForType:ESTNearableTypeAll];
    
    //Initialize the list of beacons pointer
    _beacons = new map<string, bool>();
}

//This is the callback function when the nearble manager ranges the beacons and fills the list of beacons with whether or not they are moving.
- (void)nearableManager:(ESTNearableManager *)manager didRangeNearables:(NSArray *)nearables withType:(ESTNearableType)type {
    for(id nearable in nearables) {
        string name = string([[nearable identifier] UTF8String]);
        bool moving = [nearable isMoving];
        self.beacons->operator[](name) = moving;
    }
}

@end

