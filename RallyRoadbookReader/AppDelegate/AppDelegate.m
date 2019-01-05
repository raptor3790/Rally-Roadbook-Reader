//
//  AppDelegate.m
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import GoogleSignIn;
@import AVFoundation;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    if ([application applicationState] != UIApplicationStateBackground) {
        [NSThread sleepForTimeInterval:2.0];
    }

    _assetManager = [[AssetPlaybackManager alloc] init];
    _remoteCommandManager = [[RemoteCommandManager alloc] initWithAssetPlaybackManager:_assetManager];
    [_remoteCommandManager activatePlaybackCommands:YES];

    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [session setActive:YES withOptions:NO error:nil];

    //    [AppContext.assetManager initAsset];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                                      //        [AppContext.assetManager pause];
                                                                                  });

    [self progressView];

    [Fabric with:@[ [Crashlytics class] ]];

    [GIDSignIn sharedInstance].clientID = @"1047391793931-ke1vikkcqhhkatgf8o8rd09o14h68uip.apps.googleusercontent.com";

    return YES;
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id>*)options
{
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (void)applicationWillResignActive:(UIApplication*)application
{
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [AppContext.assetManager initAsset];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
}

- (void)progressView
{
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:0.4f];
    [SVProgressHUD setMaximumDismissTimeInterval:0.8f];
}

@end
