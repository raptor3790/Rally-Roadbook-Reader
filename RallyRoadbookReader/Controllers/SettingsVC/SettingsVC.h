//
//  SettingsVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 14/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

typedef enum
{
    UserConfigSettings = 0,
    UserConfigNavigation,
    UserConfigTypeMobileUse,
    UserConfigTypeShareApplication,
    UserConfigTypeShareRoadbook,
    UserConfigTypePDFFormat,
    UserConfigTypeHighlightPreference,
    UserConfigTypeDistanceUnit,
    UserConfigTypeOdoDistance,
    UserConfigTypeTheme,
    UserConfigTypeCalibrate,
    UserConfigTypeSpeed,
    UserConfigTypeTime,
    UserConfigTypeCAP,
    UserConfigTypeAlert,
//    UserConfigTypeTutorial,
    UserConfigTypeLogout
}UserConfigType;

@protocol SettingsVCDelegate <NSObject>

@optional

- (void)clickedLogout;
- (void)clickedRoadbooks;
- (void)odoValueChanged: (double)distanceValue;

@end

@interface SettingsVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<SettingsVCDelegate> delegate;

@property (nonatomic, assign) double Ododistance;
@property (strong, nonatomic) NSString *strRoadbookId;
@property (weak, nonatomic) IBOutlet UITableView *tblSettings;

@end
