//
//  AudioPlayer.m
//  RallyRoadbookReader
//
//  Created by C205 on 25/10/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "AudioPlayer.h"
@import AVFoundation;

@implementation AudioPlayer

+ (id)sharedManager
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    
    return sharedMyModel;
}

- (void)createAudioPlayer:(NSString *)strSound :(NSString*)extension
{
    @autoreleasepool
    {
        NSString *strPath = [[NSBundle mainBundle] pathForResource:strSound ofType:extension];
        
        NSURL *strUrl = [NSURL URLWithString:strPath];
        NSError *error = nil;
        
        if (_player)
        {
            _player = nil;
        }
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:strUrl error:&error];
        
        _player.volume = 1.0;

        if (!error)
        {
            [_player play];
        }
    }
}

@end
