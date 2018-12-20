//
//  AppDelegate.h
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rally_Navigator_Mobile-Swift.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) double cal;
@property (strong, nonatomic) LocationManager *locationManager;

@property (strong, nonatomic) RemoteCommandManager *remoteCommandManager;
@property (strong, nonatomic) AssetPlaybackManager *assetManager;

@end

