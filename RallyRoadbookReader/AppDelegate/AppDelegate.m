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
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import GoogleSignIn;
@import AVFoundation;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([application applicationState] != UIApplicationStateBackground)
    {
        [NSThread sleepForTimeInterval:2.0];
    }
    
    _assetManager = [[AssetPlaybackManager alloc] init];
    _remoteCommandManager = [[RemoteCommandManager alloc] initWithAssetPlaybackManager:_assetManager];
    [_remoteCommandManager activatePlaybackCommands:YES];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [session setActive:YES withOptions:NO error:nil];

//    [AppContext.assetManager initAsset];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [AppContext.assetManager pause];
    });

    [self progressView];
    
    [Fabric with:@[[Crashlytics class]]];
    
    [GIDSignIn sharedInstance].clientID = @"1047391793931-ke1vikkcqhhkatgf8o8rd09o14h68uip.apps.googleusercontent.com";

    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    BOOL handled2 = [[GIDSignIn sharedInstance] handleURL:url
                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    return handled || handled2;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation];
    
    BOOL handled2 = [[GIDSignIn sharedInstance] handleURL:url
                                        sourceApplication:sourceApplication
                                               annotation:annotation];

    return handled || handled2;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [AppContext.assetManager initAsset];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (void)progressView
{
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:0.4f];
    [SVProgressHUD setMaximumDismissTimeInterval:0.8f];
    [SVProgressHUD setFont:THEME_FONT_Medium(16)];
}

@end
