//
//  Routes.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Routes.h"

NSString* const kRoutesId = @"id";
NSString* const kRoutesLength = @"length";
NSString* const kRoutesFolderId = @"folder_id";
NSString* const kRoutesEditable = @"editable";
NSString* const kRoutesUpdatedAt = @"updated_at";
NSString* const kRoutesName = @"name";
NSString* const kRoutesUnits = @"units";
NSString* const kRoutesWaypointCount = @"waypoint_count";
NSString* const kRoutesPdf = @"pdf";
NSString* const kRoutesRoadRallyPdf = @"road_rally_pdf";
NSString* const kRoutesCrossCountryHighlightPdf = @"cross_country_highlight_pdf";
NSString* const kRoutesHighlightRoadRally = @"highlight_road_rally";
NSString* const kRoutesType = @"current_style";

@interface Routes ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary*)dict;

@end

@implementation Routes

@synthesize routesIdentifier = _routesIdentifier;
@synthesize length = _length;
@synthesize editable = _editable;
@synthesize folderId = _folderId;
@synthesize updatedAt = _updatedAt;
@synthesize name = _name;
@synthesize units = _units;
@synthesize waypointCount = _waypointCount;
@synthesize pdf = _pdf;
@synthesize roadRallyPdf = _roadRallyPdf;
@synthesize crossCountryHighlightPdf = _crossCountryHighlightPdf;
@synthesize highlightRoadRally = _highlightRoadRally;

+ (Routes*)modelObjectWithDictionary:(NSDictionary*)dict
{
    Routes* instance = [[Routes alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];

    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.routesIdentifier = [[self objectOrNilForKey:kRoutesId fromDictionary:dict] doubleValue];
        self.length = [[self objectOrNilForKey:kRoutesLength fromDictionary:dict] doubleValue];
        self.folderId = [[self objectOrNilForKey:kRoutesFolderId fromDictionary:dict] doubleValue];
        self.editable = [[self objectOrNilForKey:kRoutesEditable fromDictionary:dict] boolValue];
        self.updatedAt = [self objectOrNilForKey:kRoutesUpdatedAt fromDictionary:dict];
        self.name = [self objectOrNilForKey:kRoutesName fromDictionary:dict];
        self.units = [self objectOrNilForKey:kRoutesUnits fromDictionary:dict];
        self.waypointCount = [[self objectOrNilForKey:kRoutesWaypointCount fromDictionary:dict] doubleValue];
        self.pdf = [self objectOrNilForKey:kRoutesPdf fromDictionary:dict];
        self.roadRallyPdf = [self objectOrNilForKey:kRoutesRoadRallyPdf fromDictionary:dict];
        self.crossCountryHighlightPdf = [self objectOrNilForKey:kRoutesCrossCountryHighlightPdf fromDictionary:dict];
        self.highlightRoadRally = [self objectOrNilForKey:kRoutesHighlightRoadRally fromDictionary:dict];
        self.type = [self objectOrNilForKey:kRoutesType fromDictionary:dict];
    }

    return self;
}

- (instancetype)initWithCDRoutes:(CDRoutes*)routes
{
    self = [super init];

    self.routesIdentifier = routes.routesIdentifierValue;
    self.length = routes.lengthValue;
    self.folderId = routes.folderIdValue;
    self.editable = [routes.editable boolValue];
    self.updatedAt = routes.updatedAt;
    self.name = routes.name;
    self.units = routes.units;
    self.waypointCount = routes.waypointCountValue;
    self.pdf = routes.pdf;
    self.roadRallyPdf = routes.roadRallyPdf;
    self.crossCountryHighlightPdf = routes.crossCountryHighlightPdf;
    self.highlightRoadRally = routes.highlightRoadRally;
    self.type = routes.type;

    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary* mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routesIdentifier] forKey:kRoutesId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.length] forKey:kRoutesLength];
    [mutableDict setValue:[NSNumber numberWithDouble:self.folderId] forKey:kRoutesFolderId];
    [mutableDict setValue:self.updatedAt forKey:kRoutesUpdatedAt];
    [mutableDict setValue:self.name forKey:kRoutesName];
    [mutableDict setValue:self.units forKey:kRoutesUnits];
    [mutableDict setValue:[NSNumber numberWithDouble:self.waypointCount] forKey:kRoutesWaypointCount];
    [mutableDict setValue:[NSNumber numberWithBool:self.editable] forKey:kRoutesEditable];
    [mutableDict setValue:self.pdf forKey:kRoutesPdf];
    [mutableDict setValue:self.roadRallyPdf forKey:kRoutesRoadRallyPdf];
    [mutableDict setValue:self.crossCountryHighlightPdf forKey:kRoutesCrossCountryHighlightPdf];
    [mutableDict setValue:self.highlightRoadRally forKey:kRoutesHighlightRoadRally];
    [mutableDict setValue:self.type forKey:kRoutesType];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary*)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];

    self.routesIdentifier = [aDecoder decodeDoubleForKey:kRoutesId];
    self.length = [aDecoder decodeDoubleForKey:kRoutesLength];
    self.folderId = [aDecoder decodeDoubleForKey:kRoutesFolderId];
    self.updatedAt = [aDecoder decodeObjectForKey:kRoutesUpdatedAt];
    self.name = [aDecoder decodeObjectForKey:kRoutesName];
    self.units = [aDecoder decodeObjectForKey:kRoutesUnits];
    self.waypointCount = [aDecoder decodeDoubleForKey:kRoutesWaypointCount];
    self.editable = [aDecoder decodeBoolForKey:kRoutesEditable];
    self.pdf = [aDecoder decodeObjectForKey:kRoutesPdf];
    self.roadRallyPdf = [aDecoder decodeObjectForKey:kRoutesRoadRallyPdf];
    self.crossCountryHighlightPdf = [aDecoder decodeObjectForKey:kRoutesCrossCountryHighlightPdf];
    self.highlightRoadRally = [aDecoder decodeObjectForKey:kRoutesHighlightRoadRally];
    self.type = [aDecoder decodeObjectForKey:kRoutesType];

    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{

    [aCoder encodeDouble:_routesIdentifier forKey:kRoutesId];
    [aCoder encodeDouble:_length forKey:kRoutesLength];
    [aCoder encodeDouble:_folderId forKey:kRoutesFolderId];
    [aCoder encodeObject:_updatedAt forKey:kRoutesUpdatedAt];
    [aCoder encodeObject:_name forKey:kRoutesName];
    [aCoder encodeObject:_units forKey:kRoutesUnits];
    [aCoder encodeDouble:_waypointCount forKey:kRoutesWaypointCount];
    [aCoder encodeBool:_editable forKey:kRoutesEditable];
    [aCoder encodeObject:_pdf forKey:kRoutesPdf];
    [aCoder encodeObject:_roadRallyPdf forKey:kRoutesRoadRallyPdf];
    [aCoder encodeObject:_crossCountryHighlightPdf forKey:kRoutesCrossCountryHighlightPdf];
    [aCoder encodeObject:_highlightRoadRally forKey:kRoutesHighlightRoadRally];
    [aCoder encodeObject:_type forKey:kRoutesType];
}

@end
