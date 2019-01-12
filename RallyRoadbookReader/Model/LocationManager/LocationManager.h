//
//  LocationManager.h
//  RallyRoadbookReader
//
//  Created by C205 on 13/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol LocationManagerDelegate <NSObject>

@optional
- (void)didUpdateToLocation:(NSArray<CLLocation *> *)arrLocations;
- (void)didUpdateToHeading:(CLHeading *)heading;

@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<LocationManagerDelegate> delegate;
@property (assign, nonatomic) double currentCourse;
@property (strong, nonatomic) CLLocationManager *locationManager;

+ (id)sharedManager;
- (void)startStandardUpdates;

@end
