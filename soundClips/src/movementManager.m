//
//  moementManager.m
//  soundClips
//
//  Created by James Bentley on 1/19/16.
//
//

#import <Foundation/Foundation.h>
#import <EstimoteSDK/EstimoteSDK.h>

@interface nearablesManager : NSObject<ESTNearableManagerDelegate>

@property (nonatomic, strong) ESTNearableManager *manager;
//@property (nonatomic, strong) NSArray *nearables;
@property map<string, bool> *beacons;

- (void) start;

@end

@implementation nearablesManager

- (void) start {
    
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
        //[nearable ]
        self.beacons->operator[](name) = moving;
    }
}

@end