//
//  UserConfig.m
//
//  Created by C205  on 20/09/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "UserConfig.h"


NSString *const kUserConfigIsShowTime = @"isShowTime";
NSString *const kUserConfigIsShowSpeed = @"isShowSpeed";
NSString *const kUserConfigIsShowCap = @"isShowCap";
NSString *const kUserConfigIsShowAlert = @"isShowAlert";
NSString *const kUserConfigIsShowTutorial = @"isShowTutorial";
NSString *const kUserConfigHighlightPdf = @"highlightPdf";
NSString *const kUserConfigCal = @"cal";
NSString *const kUserConfigThemePreference = @"themePreference";
NSString *const kUserConfigPdfFormat = @"pdfFormat";
NSString *const kUserConfigDistanceUnit = @"distanceUnit";
NSString *const kUserConfigOdometerUnit = @"odometerUnit";


@interface UserConfig ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation UserConfig

@synthesize isShowTime = _isShowTime;
@synthesize isShowSpeed = _isShowSpeed;
@synthesize isShowCap = _isShowCap;
@synthesize isShowAlert = _isShowAlert;
@synthesize highlightPdf = _highlightPdf;
@synthesize cal = _cal;
@synthesize themePreference = _themePreference;
@synthesize pdfFormat = _pdfFormat;
@synthesize distanceUnit = _distanceUnit;
@synthesize odometerUnit = _odometerUnit;
@synthesize isShowTutorial = _isShowTutorial;


+ (UserConfig *)modelObjectWithDictionary:(NSDictionary *)dict
{
    UserConfig *instance = [[UserConfig alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.isShowTime = [[self objectOrNilForKey:kUserConfigIsShowTime fromDictionary:dict] boolValue];
            self.isShowSpeed = [[self objectOrNilForKey:kUserConfigIsShowSpeed fromDictionary:dict] boolValue];
            self.isShowCap = [[self objectOrNilForKey:kUserConfigIsShowCap fromDictionary:dict] boolValue];
        self.isShowAlert = [[self objectOrNilForKey:kUserConfigIsShowAlert fromDictionary:dict] boolValue];
        self.isShowTutorial = [[self objectOrNilForKey:kUserConfigIsShowTutorial fromDictionary:dict] boolValue];
        self.highlightPdf = [[self objectOrNilForKey:kUserConfigHighlightPdf fromDictionary:dict] boolValue];
        self.cal = [[self objectOrNilForKey:kUserConfigCal fromDictionary:dict] doubleValue];
        self.themePreference = (ThemePreference)[[self objectOrNilForKey:kUserConfigThemePreference fromDictionary:dict] integerValue];
        self.pdfFormat = (PdfFormat)[[self objectOrNilForKey:kUserConfigPdfFormat fromDictionary:dict] integerValue];
        self.distanceUnit = (DistanceUnitsType)[[self objectOrNilForKey:kUserConfigDistanceUnit fromDictionary:dict] integerValue];
        self.odometerUnit = (OdometerUnit)[[self objectOrNilForKey:kUserConfigOdometerUnit fromDictionary:dict] integerValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.isShowTime] forKey:kUserConfigIsShowTime];
    [mutableDict setValue:[NSNumber numberWithBool:self.isShowSpeed] forKey:kUserConfigIsShowSpeed];
    [mutableDict setValue:[NSNumber numberWithBool:self.isShowCap] forKey:kUserConfigIsShowCap];
    [mutableDict setValue:[NSNumber numberWithBool:self.isShowAlert] forKey:kUserConfigIsShowAlert];
    [mutableDict setValue:[NSNumber numberWithBool:self.isShowTutorial] forKey:kUserConfigIsShowTutorial];
    [mutableDict setValue:[NSNumber numberWithBool:self.highlightPdf] forKey:kUserConfigHighlightPdf];
    [mutableDict setValue:[NSNumber numberWithDouble:self.cal] forKey:kUserConfigCal];
    [mutableDict setValue:[NSNumber numberWithBool:self.themePreference] forKey:kUserConfigThemePreference];
    [mutableDict setValue:[NSNumber numberWithBool:self.pdfFormat] forKey:kUserConfigPdfFormat];
    [mutableDict setValue:[NSNumber numberWithBool:self.distanceUnit] forKey:kUserConfigDistanceUnit];
    [mutableDict setValue:[NSNumber numberWithBool:self.odometerUnit] forKey:kUserConfigOdometerUnit];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.isShowTime = [aDecoder decodeBoolForKey:kUserConfigIsShowTime];
    self.isShowSpeed = [aDecoder decodeBoolForKey:kUserConfigIsShowSpeed];
    self.isShowCap = [aDecoder decodeBoolForKey:kUserConfigIsShowCap];
    self.isShowAlert = [aDecoder decodeBoolForKey:kUserConfigIsShowAlert];
    self.isShowTutorial = [aDecoder decodeBoolForKey:kUserConfigIsShowTutorial];
    self.highlightPdf = [aDecoder decodeBoolForKey:kUserConfigHighlightPdf];
    self.cal = [aDecoder decodeDoubleForKey:kUserConfigCal];
    self.themePreference = [aDecoder decodeBoolForKey:kUserConfigThemePreference];
    self.pdfFormat = [aDecoder decodeBoolForKey:kUserConfigPdfFormat];
    self.distanceUnit = [aDecoder decodeBoolForKey:kUserConfigDistanceUnit];
    self.odometerUnit = [aDecoder decodeBoolForKey:kUserConfigOdometerUnit];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_isShowTime forKey:kUserConfigIsShowTime];
    [aCoder encodeBool:_isShowSpeed forKey:kUserConfigIsShowSpeed];
    [aCoder encodeBool:_isShowCap forKey:kUserConfigIsShowCap];
    [aCoder encodeBool:_isShowAlert forKey:kUserConfigIsShowAlert];
    [aCoder encodeBool:_isShowTutorial forKey:kUserConfigIsShowTutorial];
    [aCoder encodeBool:_highlightPdf forKey:kUserConfigHighlightPdf];
    [aCoder encodeDouble:_cal forKey:kUserConfigCal];
    [aCoder encodeBool:_themePreference forKey:kUserConfigThemePreference];
    [aCoder encodeBool:_pdfFormat forKey:kUserConfigPdfFormat];
    [aCoder encodeBool:_distanceUnit forKey:kUserConfigDistanceUnit];
    [aCoder encodeBool:_odometerUnit forKey:kUserConfigOdometerUnit];
}


@end
