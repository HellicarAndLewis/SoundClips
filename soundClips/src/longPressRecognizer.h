//
//  longPressRecognizer.hpp
//  soundClips
//
//  Created by James Bentley on 1/22/16.
//
//

#ifndef longPressRecognizer_hpp
#define longPressRecognizer_hpp

#include "ofMain.h"

@interface longPressRecognizer : NSObject 

@property (nonatomic,strong) UILongPressGestureRecognizer *lpgr;

- (void) setup;

@end


#endif /* longPressRecognizer_hpp */
