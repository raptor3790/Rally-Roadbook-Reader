//
//  Routes.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Routes : NSObject <NSCoding>

@property (nonatomic, assign) double routesIdentifier;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) double folderId;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *units;
@property (nonatomic, assign) double waypointCount;
@property (nonatomic, strong) NSString *pdf;
@property (nonatomic, strong) NSString *roadRallyPdf;
@property (nonatomic, strong) NSString *crossCountryHighlightPdf;
@property (nonatomic, strong) NSString *highlightRoadRally;

+ (Routes *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
