//
//  WebHelper.m
//  SQLExample
//
//  Created by iMac on 17/03/14.
//  Copyright (c) 2014 Narola. All rights reserved.
//

#import "WebServiceDataAdaptor.h"
#import "Roadbooks.h"
#import "Folders.h"
#import "Routes.h"
#import "Route.h"
#import <objc/runtime.h>

@implementation WebServiceDataAdaptor

@synthesize arrParsedData;

- (NSArray*)autoParse:(NSDictionary*)allValues forServiceName:(NSString*)requestURL
{
    arrParsedData = [NSArray new];

    if (isService(URLLogin) || isService(URLSocialLogin) || isService(URLSignUp) || isService(URLGetConfig) || isService(URLSetConfig)) {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue]) {
            arrParsedData = [self processJSONData:allValues
                                         forClass:LoginClass
                                        forEntity:LoginEntity
                                      withJSONKey:LoginKey];
        }
    } else if ((isService(URLGetMyFolders) || ([requestURL containsString:URLGetMyFolders])) && ![requestURL containsString:@"share_reader_folder"]) {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue]) {
            arrParsedData = [self processJSONData:allValues
                                         forClass:RoadbooksClass
                                        forEntity:RoadbooksEntity
                                      withJSONKey:RoadbooksKey];
        }
    } else if (isService(URLGetMyPDF)) {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue]) {
            arrParsedData = [self processJSONData:allValues
                                         forClass:RoutesClass
                                        forEntity:RoutesEntity
                                      withJSONKey:RoutesKey];
        }
    } else if ([requestURL containsString:URLGetRouteDetails]) {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue]) {
            arrParsedData = [self processJSONData:allValues
                                         forClass:RouteClass
                                        forEntity:RouteEntity
                                      withJSONKey:RouteKey];
        }
    }

    return arrParsedData;
}

#pragma mark - Helper Method

- (NSArray*)processJSONData:(NSDictionary*)dict
                   forClass:(NSString*)classname
                  forEntity:(NSString*)entityname
                withJSONKey:(NSString*)json_Key
{
    NSMutableArray* arrProcessedData = [NSMutableArray array];

    if ([[dict objectForKey:json_Key] isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < [[dict objectForKey:json_Key] count]; i++) {
            NSDictionary* allvalues = [[dict objectForKey:json_Key] objectAtIndex:i];
            id objClass = [[[NSClassFromString(classname) alloc] init] initWithDictionary:allvalues];
            [arrProcessedData addObject:objClass];
        }
    } else {
        @try {
            id objClass = [[[NSClassFromString(classname) alloc] init] initWithDictionary:[dict objectForKey:json_Key]];
            [arrProcessedData addObject:objClass];

            if ([entityname isEqualToString:RoadbooksEntity]) {
                Roadbooks* objRoadbooks = objClass;

                [CoreDataAdaptor deleteDataInCoreDB:NSStringFromClass([CDFolders class])
                                      withCondition:[NSString stringWithFormat:@"parentId='%f'", objRoadbooks.parentId]];

                for (Folders* objFolder in objRoadbooks.folders) {
                    if ([objFolder.folderType isEqualToString:@"default"]) {
                        objRoadbooks.parentId = objFolder.foldersIdentifier;
                    }

                    NSArray* arrFiltered = [[[CDFolders query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"foldersIdentifier='%f'", objFolder.foldersIdentifier]]] all];

                    if ([arrFiltered count] > 0) {
                        CDFolders* objCDFolder = [arrFiltered firstObject];
                        objCDFolder.folderName = objFolder.folderName;
                        objCDFolder.folderType = objFolder.folderType;
                        objCDFolder.parentId = [NSNumber numberWithDouble:objFolder.parentId];
                        objCDFolder.subfoldersCount = [NSNumber numberWithDouble:objFolder.subfoldersCount];
                        objCDFolder.routesCounts = [NSNumber numberWithDouble:objFolder.routesCounts];
                        [CoreDataHelper save];
                    } else {
                        [CoreDataAdaptor SaveDataInCoreDB:[self processObjectForCoreData:objFolder] forEntity:@"CDFolders"];
                    }
                }

                [CoreDataAdaptor deleteDataInCoreDB:NSStringFromClass([CDRoutes class])
                                      withCondition:[NSString stringWithFormat:@"folderId='%f'", objRoadbooks.parentId]];

                for (Routes* objRoute in objRoadbooks.routes) {
                    NSArray* arrFiltered = [[[CDRoutes query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"routesIdentifier='%f'", objRoute.routesIdentifier]]] all];

                    if ([arrFiltered count] > 0) {
                        CDRoutes* objCDRoutes = [arrFiltered firstObject];
                        objCDRoutes.name = [NSString stringWithFormat:@"%@", objRoute.name];
                        objCDRoutes.length = [NSNumber numberWithDouble:objRoute.length];
                        objCDRoutes.updatedAt = [NSString stringWithFormat:@"%@", objRoute.updatedAt];
                        objCDRoutes.units = [NSString stringWithFormat:@"%@", objRoute.units];
                        objCDRoutes.waypointCount = [NSNumber numberWithDouble:objRoute.waypointCount];
                        objCDRoutes.folderId = [NSNumber numberWithDouble:objRoute.folderId];
                        objCDRoutes.editable = [NSNumber numberWithBool:objRoute.editable];
                        objCDRoutes.pdf = [NSString stringWithFormat:@"%@", objRoute.pdf];
                        objCDRoutes.roadRallyPdf = [NSString stringWithFormat:@"%@", objRoute.roadRallyPdf];
                        objCDRoutes.crossCountryHighlightPdf = [NSString stringWithFormat:@"%@", objRoute.crossCountryHighlightPdf];
                        objCDRoutes.highlightRoadRally = [NSString stringWithFormat:@"%@", objRoute.highlightRoadRally];
                        objCDRoutes.type = [NSString stringWithFormat:@"%@", objRoute.type];
                        [CoreDataHelper save];
                    } else {
                        [CoreDataAdaptor SaveDataInCoreDB:[self processObjectForCoreData:objRoute] forEntity:RoutesEntity];
                    }
                }
            } else if ([entityname isEqualToString:RouteEntity]) {
                Route* objRoute = objClass;

                NSArray* arrRoutes = [[[CDRoute query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"routeIdentifier='%f'", objRoute.routeIdentifier]]] all];

                if ([arrRoutes count] > 0) {
                    CDRoute* objCDRoute = [arrRoutes firstObject];
                    objCDRoute.routeIdentifier = [NSNumber numberWithDouble:objRoute.routeIdentifier];
                    objCDRoute.updatedAt = [NSString stringWithFormat:@"%@", objRoute.updatedAt];
                    objCDRoute.name = [NSString stringWithFormat:@"%@", objRoute.name];
                    objCDRoute.length = [NSNumber numberWithDouble:objRoute.length];
                    objCDRoute.units = [NSString stringWithFormat:@"%@", objRoute.units];
                    objCDRoute.waypointCount = [NSNumber numberWithDouble:objRoute.waypointCount];
                    objCDRoute.userId = [NSNumber numberWithDouble:objRoute.userId];
                    objCDRoute.startLatitude = [NSNumber numberWithDouble:objRoute.startLatitude];
                    objCDRoute.startLongitude = [NSNumber numberWithDouble:objRoute.startLongitude];
                    objCDRoute.startAddress = [NSString stringWithFormat:@"%@", objRoute.startAddress];
                    objCDRoute.endLatitude = [NSNumber numberWithDouble:objRoute.endLatitude];
                    objCDRoute.endLongitude = [NSNumber numberWithDouble:objRoute.endLongitude];
                    objCDRoute.endAddress = [NSString stringWithFormat:@"%@", objRoute.endAddress];
                    objCDRoute.sharingLevel = [NSNumber numberWithDouble:objRoute.sharingLevel];
                    objCDRoute.fuelRange = [NSNumber numberWithDouble:objRoute.fuelRange];
                    objCDRoute.routeDescription = [NSString stringWithFormat:@"%@", objRoute.routeDescription];
                    objCDRoute.folderId = [NSNumber numberWithDouble:objRoute.folderId];
                    objCDRoute.deletedAt = [NSString stringWithFormat:@"%@", objRoute.deletedAt];
                    objCDRoute.currentStyle = [NSString stringWithFormat:@"%@", objRoute.currentStyle];
                    objCDRoute.token = [NSString stringWithFormat:@"%@", objRoute.token];
                    objCDRoute.data = [NSString stringWithFormat:@"%@", objRoute.data];
                    objCDRoute.lock = [NSString stringWithFormat:@"%@", objRoute.lock];

                    [CoreDataHelper save];
                } else {
                    [CoreDataAdaptor SaveDataInCoreDB:[self processObjectForCoreData:objRoute] forEntity:RouteEntity];
                }
            }
        } @catch (NSException* exception) {
        } @finally {
        }
    }

    return arrProcessedData;
}

- (NSDictionary*)processObjectForCoreData:(id)obj
{
    NSArray* aVoidArray = @[ @"NSDate" ];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    unsigned count;
    objc_property_t* properties = class_copyPropertyList([obj class], &count);
    for (int i = 0; i < count; i++) {
        NSString* key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (![aVoidArray containsObject:key]) {
            if ([obj valueForKey:key] != nil) {
                [dict setObject:[obj valueForKey:key] forKey:key];
            }
        }
    }
    return dict;
}

@end
