//
//  RouteVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"
#import "Routes.h"

@import WebKit;
@import UIKit;

@interface RouteVC : BaseVC

@property (assign, nonatomic) double calibrate;
@property (weak, nonatomic) CDRoutes *objRoute;
@property (nonatomic, assign) PdfFormat currentPdfFormat;
@property (assign, nonatomic) BOOL isHighlight;
@property (strong, nonatomic) NSString *strRouteName;

@property (weak, nonatomic) IBOutlet UIView *vwHeader;

@property (weak, nonatomic) IBOutlet UIView *vwOdometer;
@property (weak, nonatomic) IBOutlet UIView *vwSpeed;
@property (weak, nonatomic) IBOutlet UIView *vwCAP;
@property (weak, nonatomic) IBOutlet UIView *vwTime;
@property (weak, nonatomic) IBOutlet UIView *vwMiddleContainer;

@property (weak, nonatomic) IBOutlet UILabel *lblOdoDistanceUnit;
@property (weak, nonatomic) IBOutlet UILabel *lbldistancePerHour;
@property (weak, nonatomic) IBOutlet UILabel *lblCAPHeading;

@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDegree;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (weak, nonatomic) IBOutlet UIView *vwSeparator;
@property (strong, nonatomic) IBOutlet WKWebView *wView;
@property (strong, nonatomic) IBOutlet UIView *vWScrollUp;
@property (strong, nonatomic) IBOutlet UIView *vWScrollDown;

@property (weak, nonatomic) IBOutlet UIView *vwBackground;
@property (weak, nonatomic) IBOutlet UITableView *tblRoadbook;
@property (weak, nonatomic) IBOutlet UIImageView *bottomFooter;

@property (weak, nonatomic) IBOutlet UIView *vwDigitUp;
@property (weak, nonatomic) IBOutlet UIView *vwDigitDown;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightVwSpeed;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightVwTime;

@property (weak, nonatomic) IBOutlet UIView *vWOdometerSuper;
@property (weak, nonatomic) IBOutlet UIView *vWSpeedSuper;
@property (weak, nonatomic) IBOutlet UIView *vWTimeSuper;
@property (weak, nonatomic) IBOutlet UIView *vWCapSuper;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWidthOdometer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop_Time;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop_Speed;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWidthSetting;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightSetting;

@property (weak, nonatomic) IBOutlet UILabel *labelTOD;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopDPH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopTOD;

@property (weak, nonatomic) IBOutlet UIView *viewOverlay;

@property (strong, nonatomic) IBOutlet UIView *upperPDFBorder;
@property (strong, nonatomic) IBOutlet UIView *lowerPDFBorder;

@property (weak, nonatomic) IBOutlet UIView *tViewDistanceIncrease;
@property (weak, nonatomic) IBOutlet UIView *tViewDistanceDecrease;
@property (weak, nonatomic) IBOutlet UIView *tViewSettings;
@property (weak, nonatomic) IBOutlet UIView *tViewScrollUp;
@property (weak, nonatomic) IBOutlet UIView *tViewScrollDown;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightTOD;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightDPH;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAspectHeader;

@property (strong, nonatomic) RemoteCommandDataSource *remoteCommandDataSource;


@end
