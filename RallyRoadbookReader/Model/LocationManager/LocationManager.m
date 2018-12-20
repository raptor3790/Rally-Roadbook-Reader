//
//  LocationManager.m
//  RallyRoadbookReader
//
//  Created by C205 on 13/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

#pragma mark - Shared Instance

+ (id)sharedManager
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    
    return sharedMyModel;
}

#pragma mark - Location Manager Set Up

- (void)startStandardUpdates
{
    if (_locationManager == nil)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    _locationManager.delegate = self;
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    
    if ([_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
    {
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count > 0)
    {
        _currentCourse = locations.firstObject.course;
        
        if ([_delegate respondsToSelector:@selector(didUpdateToLocation:)])
        {
            [_delegate didUpdateToLocation:locations];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if ([_delegate respondsToSelector:@selector(didUpdateToHeading:)])
    {
        [_delegate didUpdateToHeading:(CLHeading *)newHeading];
    }
}

@end
