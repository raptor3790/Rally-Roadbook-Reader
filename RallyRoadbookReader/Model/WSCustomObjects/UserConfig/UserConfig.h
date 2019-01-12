//
//  UserConfig.h
//
//  Created by C205  on 20/09/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RallyNavigatorConstants.h"


@interface UserConfig : NSObject <NSCoding>

@property (nonatomic, assign) BOOL highlightPdf;
@property (nonatomic, assign) BOOL isShowTime;
@property (nonatomic, assign) BOOL isShowSpeed;
@property (nonatomic, assign) BOOL isShowCap;
@property (nonatomic, assign) BOOL isShowAlert;
@property (nonatomic, assign) BOOL isScreenRotateLock;
@property (nonatomic, assign) double cal;
@property (nonatomic, assign) ThemePreference themePreference;
@property (nonatomic, assign) PdfFormat pdfFormat;
@property (nonatomic, assign) DistanceUnitsType distanceUnit;
@property (nonatomic, assign) OdometerUnit odometerUnit;

+ (UserConfig *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
