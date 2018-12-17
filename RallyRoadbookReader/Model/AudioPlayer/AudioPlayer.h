//
//  AudioPlayer.h
//  RallyRoadbookReader
//
//  Created by C205 on 25/10/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface AudioPlayer : NSObject

@property (strong, nonatomic) AVAudioPlayer *player;

+ (id)sharedManager;
- (void)createAudioPlayer:(NSString *)strSound :(NSString*)extension;

@end
