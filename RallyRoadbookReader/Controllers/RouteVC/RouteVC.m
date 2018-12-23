//
//  RouteVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "RouteVC.h"
#import "SettingsVC.h"
#import "RouteCell.h"
#import "RouteDetails.h"
#import "Waypoints.h"
#import "Backgroundimage.h"
#import "JPSVolumeButtonHandler.h"
#import <FBSDKLoginKit.h>
#import <FBSDKCoreKit.h>
#import <WebKit/WebKit.h>

@import GoogleSignIn;
@import MediaPlayer;

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees) / 180.0)
#define RADIANS_TO_DEGREES(radians) ((radians * 180.0) / M_PI)

@interface RouteVC () <UITableViewDataSource, UITableViewDelegate, LocationManagerDelegate, SettingsVCDelegate, AssetPlaybackManagerDelegate> {
    CGFloat volume;
    double topSpeed;
    double totalDistance;
    double currentSpeed;
    double currentDegree;
    
    BOOL isTopSpeedDisplaying;
    

    NSString* strCurrentDateTime;
    NSMutableArray* arrAllLocations;

    CDRoute* obj_Route;
    RouteDetails* objRouteDetails;
    UserConfig* objUserConfig;

    NSMutableArray* arrPageImages;
    NSMutableArray* arrPageHeights;

    NSTimer* ResetTimer;
    NSTimer* ScrollTimer;
    NSTimer* UpdateSpeed;
    int ResetCount;
    int ScrollCount;

    NSAttributedString* ResetLabel;

    JPSVolumeButtonHandler* volumeButtonHandler;

    NSPredicate* filterWaypointsPredicate;

    CGSize PDFSize;
}
@end

@implementation RouteVC

@synthesize remoteCommandDataSource;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _calibrate = AppContext.cal;

    self.title = _strRouteName;

    ResetCount = 0;

    AppContext.locationManager = [LocationManager sharedManager];
    AppContext.locationManager.delegate = self;

    AppContext.assetManager.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemoteCommandNextTrackNotification:)
                                                 name:@"nextTrackNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemoteCommandPreviousTrackNotification:)
                                                 name:@"previousTrackNotification"
                                               object:nil];

    volumeButtonHandler = [JPSVolumeButtonHandler
        volumeButtonHandlerWithUpBlock:^{
            [self btnDigitUpClicked:nil];
        }
        downBlock:^{
            [self btnDigitDownClicked:nil];
        }];
    [volumeButtonHandler startHandler:YES];
    //    volumeButtonHandler.sessionOptions =
    //    AVAudioSessionCategoryOptionAllowBluetooth/*|AVAudioSessionCategoryOptionMixWithOthers*/;

    filterWaypointsPredicate = [NSPredicate predicateWithBlock:^BOOL(Waypoints* objWayPoint, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objWayPoint.show;
    }];

    _pdfView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblRoadbook.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // Changes By Harjeet - hka
    UIBarButtonItem* btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"menu")
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(btnSettingsClicked:)];
    self.navigationItem.rightBarButtonItem = btnDrawer;

    UITapGestureRecognizer* tapUpGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnDigitUpClicked:)];
    UITapGestureRecognizer* tapDownGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnDigitDownClicked:)];
    UITapGestureRecognizer* tapSpeedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnSpeedClicked:)];
    UITapGestureRecognizer* tapTableGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnTableClicked:)];

    UILongPressGestureRecognizer* lPressDigitUpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                       action:@selector(btnDigitUpHoldClicked:)];
    UILongPressGestureRecognizer* lPressDigitDownGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                         action:@selector(btnDigitDownHoldClicked:)];
    UILongPressGestureRecognizer* lPressSpeedGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(btnResetTopSpeedClicked:)];
    UILongPressGestureRecognizer* lPressTableGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(btnTableClicked:)];

    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnResetDistanceClicked:)];
    UISwipeGestureRecognizer* swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnResetDistanceClicked:)];

    tapUpGesture.numberOfTapsRequired = 1;
    tapDownGesture.numberOfTapsRequired = 1;
    tapSpeedGesture.numberOfTapsRequired = 1;
    tapTableGesture.numberOfTapsRequired = 1;

    lPressSpeedGesture.minimumPressDuration = 1;
    lPressTableGesture.minimumPressDuration = 1;

    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionLeft;

    [_vwDigitUp addGestureRecognizer:tapUpGesture];
    [_vwDigitDown addGestureRecognizer:tapDownGesture];
    [_vwSpeed addGestureRecognizer:tapSpeedGesture];
    [_tblRoadbook addGestureRecognizer:tapTableGesture];

    [_tblRoadbook addGestureRecognizer:lPressTableGesture];
    [_vwDigitUp addGestureRecognizer:lPressDigitUpGesture];
    [_vwDigitDown addGestureRecognizer:lPressDigitDownGesture];
    [_vwSpeed addGestureRecognizer:lPressSpeedGesture];

    [_vwDigitUp addGestureRecognizer:swipeUpGesture];
    [_vwDigitDown addGestureRecognizer:swipeDownGesture];

    objUserConfig = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserConfiguration];

    if (objUserConfig == nil) {
        objUserConfig = [self getDefaultUserConfiguration];
    }

    _currentPdfFormat = objUserConfig.pdfFormat;
    _isHighlight = objUserConfig.highlightPdf;

    if (objUserConfig.isShowCap) {
        _lblCAPHeading.text = @"CAP HEADING";
        currentDegree = AppContext.locationManager.currentCourse;
        [self displayCAPHeading];
    }

    [self manageUI];

    User* objUser = GET_USER_OBJ;

    BOOL isUserRole = [objUser.role isEqualToString:@"user"];
    NSString* defaultRally = [NSString stringWithFormat:@"%@ - UPGRADED User View", kDefaultRallyName];
    NSString* defaultCross = [NSString stringWithFormat:@"%@ - UPGRADED User View", kDefaultCrossCountryName];

    if (!isUserRole || ([_objRoute.name isEqualToString:defaultRally]) || ([_objRoute.name isEqualToString:defaultCross])) {
        [self setupPdfView];
    } else {
        _tblRoadbook.hidden = NO;
        [self fetchRouteDetails];
        [self callWebServiceToGetRoute];
    }

    [self setupTutorial];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self
    //    selector:@selector(handleRouteChange:)
    //    name:AVAudioSessionRouteChangeNotification object:[AVAudioSession
    //    sharedInstance]];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //    selector:@selector(volumeDidChange:)
    //    name:@"AVSystemController_SystemVolumeDidChangeNotification"
    //    object:nil];

    objUserConfig = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserConfiguration];

    if (objUserConfig == nil) {
        objUserConfig = [self getDefaultUserConfiguration];
    }

    switch (objUserConfig.distanceUnit) {
    case DistanceUnitsTypeMiles:
        _lblOdoDistanceUnit.text = @"MILES";
        _lbldistancePerHour.text = @"MPH";
        break;

    case DistanceUnitsTypeKilometers:
        _lblOdoDistanceUnit.text = @"KILOMETERS";
        _lbldistancePerHour.text = @"KPH";
        break;

    default:
        break;
    }

    [self adjustHeader];
    [self displayAllUnits];
    [self getCurrentDateTime];

    if (_tblRoadbook.isHidden) {
        if (_currentPdfFormat != objUserConfig.pdfFormat || _isHighlight != objUserConfig.highlightPdf) {
            _currentPdfFormat = objUserConfig.pdfFormat;
            _isHighlight = objUserConfig.highlightPdf;

            arrPageImages = [[NSMutableArray alloc] init];
            arrPageHeights = [[NSMutableArray alloc] init];
            [_pdfView reloadData];

            [self loadPDF];
        }
    } else {
        [_tblRoadbook reloadData];
    }

    [self setNeedsStatusBarAppearanceUpdate];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];
//}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    NSUInteger totalDisplayUnits = 1;

    totalDisplayUnits += (objUserConfig.isShowCap + objUserConfig.isShowTime + objUserConfig.isShowSpeed);

    _vwOdometer.layer.cornerRadius = 10.0f;
    _vwOdometer.clipsToBounds = YES;
    _vwOdometer.layer.borderWidth = 5.0f;
    _vwOdometer.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _vwSpeed.layer.cornerRadius = 10.0f;
    _vwSpeed.clipsToBounds = YES;
    _vwSpeed.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _vwTime.layer.cornerRadius = 10.0f;
    _vwTime.clipsToBounds = YES;
    _vwTime.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _vwCAP.layer.cornerRadius = 10.0f;
    _vwCAP.clipsToBounds = YES;
    _vwCAP.layer.borderWidth = 5.0f;
    _vwCAP.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _vWOdometerSuper.layer.cornerRadius = 10.0f;
    _vWOdometerSuper.clipsToBounds = YES;

    _vWSpeedSuper.layer.cornerRadius = 10.0f;
    _vWSpeedSuper.clipsToBounds = YES;

    _vWTimeSuper.layer.cornerRadius = 10.0f;
    _vWTimeSuper.clipsToBounds = YES;

    _vWCapSuper.layer.cornerRadius = 10.0f;
    _vWCapSuper.clipsToBounds = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if ([self isMovingFromParentViewController]) {
        //        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        //        [self resignFirstResponder];
        [super viewWillDisappear:animated];

        // assetManager = nil;

        [volumeButtonHandler setUpBlock:nil];
        [volumeButtonHandler setDownBlock:nil];
        [volumeButtonHandler stopHandler];

        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)handleRouteChange:(NSNotification*)notification
{
    NSDictionary* dicUserInfo = notification.userInfo;
    uint reason = [dicUserInfo[AVAudioSessionRouteChangeReasonKey] intValue];

    BOOL isHeadphonesConnected = NO;

    if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        AVAudioSession* session = [AVAudioSession sharedInstance];
        for (AVAudioSessionPortDescription* output in session.currentRoute.outputs) {
            if ([output.portType isEqualToString:AVAudioSessionPortHeadphones]) {
                isHeadphonesConnected = YES;
            }
        }
    } else if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription* previousRoute = dicUserInfo[AVAudioSessionRouteChangePreviousRouteKey];

        for (AVAudioSessionPortDescription* output in previousRoute.outputs) {
            if ([output.portType isEqualToString:AVAudioSessionPortHeadphones]) {
                isHeadphonesConnected = NO;
            }
        }
    }

    if (isHeadphonesConnected) {
        NSLog(@"Headphones connected");
    } else {
        NSLog(@"Headphones disconnected");
    }
}

- (IBAction)volumeDidChange:(NSNotification*)notification
{
    //    CGFloat newVolume = [[notification.userInfo valueForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    //
    //    if (volume == 0 || newVolume < volume) {
    //        [self btnDigitDownClicked:nil];
    //    } else {
    //        [self btnDigitUpClicked:nil];
    //    }
    //
    //    volume = newVolume;
}

- (void)handleRemoteCommandNextTrackNotification:(NSNotification*)notification
{
    NSLog(@"");
}

- (void)handleRemoteCommandPreviousTrackNotification:(NSNotification*)notification
{
    NSLog(@"");
}

- (void)nextCalled
{
    NSLog(@"Event Fired");

    User* objUser = GET_USER_OBJ;

    if ([objUser.role isEqualToString:@"user"]) {
    } else {
        [self handleTapPDFView:@"down"];
    }
}

- (void)prevCalled
{
    NSLog(@"Event Fired");

    User* objUser = GET_USER_OBJ;

    if ([objUser.role isEqualToString:@"user"]) {
    } else {
        [self handleTapPDFView:@"up"];
    }
}

- (MPRemoteCommandHandlerStatus)handleNextTrackCommandEvent:(MPRemoteCommandEvent*)event
{
    NSLog(@"Event Fired");

    User* objUser = GET_USER_OBJ;

    if ([objUser.role isEqualToString:@"user"]) {
    } else {
        [self handleTapPDFView:@"down"];
    }

    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePreviousTrackCommandEvent:(MPRemoteCommandEvent*)event
{
    NSLog(@"Event Fired");

    User* objUser = GET_USER_OBJ;

    if ([objUser.role isEqualToString:@"user"]) {
    } else {
        [self handleTapPDFView:@"up"];
    }

    return MPRemoteCommandHandlerStatusSuccess;
}

//- (MPRemoteCommandHandlerStatus)handleSkipBackwardCommandEvent:(MPRemoteCommandEvent*)event
//{
//    NSLog(@"Event Fired");
//
//    [self btnScrollDown:nil];
//    return MPRemoteCommandHandlerStatusSuccess;
//}
//
//- (MPRemoteCommandHandlerStatus)handleSkipForwardCommandEvent:(MPRemoteCommandEvent*)event
//{
//    NSLog(@"Event Fired");
//
//    [self btnScrollDown:nil];
//    return MPRemoteCommandHandlerStatusSuccess;
//}

#pragma mark - WS Call

- (void)callWebServiceToGetRoute
{
    NSString* strURL = [NSString stringWithFormat:@"%@/%ld", URLGetRouteDetails, (long)_objRoute.routesIdentifier];
    [[WebServiceConnector alloc] init:strURL
                       withParameters:nil
                           withObject:self
                         withSelector:@selector(handleRouteDetailsResponse:)
                       forServiceType:ServiceTypeGET
                       showDisplayMsg:@""
                           showLoader:NO];
}

- (IBAction)handleRouteDetailsResponse:(id)sender
{
    [self validateResponse:sender
                forKeyName:RouteKey
                 forObject:self
                 showError:YES];

    [self fetchRouteDetails];
}

- (void)fetchRouteDetails
{
    NSString* strRoadBookId = [NSString stringWithFormat:@"routeIdentifier = %ld", (long)_objRoute.routesIdentifier];
    NSArray* arrSyncedData = [[[CDRoute query] where:[NSPredicate predicateWithFormat:strRoadBookId]] all];

    if (arrSyncedData.count > 0) {
        obj_Route = arrSyncedData.firstObject;

        NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:obj_Route.data];
        objRouteDetails = [[RouteDetails alloc] initWithDictionary:jsonDict];
    }

    [_tblRoadbook reloadData];
}

#pragma mark - Custom Methods

- (void)adjustHeader
{
    NSUInteger totalDisplayUnits = 1;

    totalDisplayUnits += (objUserConfig.isShowCap + objUserConfig.isShowTime + objUserConfig.isShowSpeed);

    if (totalDisplayUnits < 4) {
        if (totalDisplayUnits == 2) {
            _constraintWidthOdometer = [self changeMultiplier:_constraintWidthOdometer with:0.5f];
        } else {
            _constraintWidthOdometer = [self changeMultiplier:_constraintWidthOdometer with:0.333f];
        }
    } else {
        _constraintWidthOdometer = [self changeMultiplier:_constraintWidthOdometer with:0.38f];
    }

    if (SCREEN_WIDTH >= 768) {
        _constraintAspectHeader = [self changeMultiplier:_constraintAspectHeader with:320 / 60];
    }

    [self manageUI];

    if (objUserConfig.isShowCap) {
        _lblCAPHeading.text = @"CAP HEADING";
        [self displayCAPHeading];

        if (totalDisplayUnits < 4) {
            _vwTime.layer.borderWidth = 5.0f;
            _vwSpeed.layer.borderWidth = 5.0f;
        } else {
            _vwTime.layer.borderWidth = 2.5f;
            _vwSpeed.layer.borderWidth = 2.5f;
        }

    } else {
        _vwTime.layer.borderWidth = 5.0f;
        _vwSpeed.layer.borderWidth = 5.0f;
    }

    [self.view layoutIfNeeded];
    _vwMiddleContainer.hidden = NO;
    _vwSpeed.hidden = NO;
    _vwTime.hidden = NO;
    _vwCAP.hidden = NO;

    _vWTimeSuper.hidden = NO;
    _vWCapSuper.hidden = NO;
    _vWSpeedSuper.hidden = NO;
    _vWOdometerSuper.hidden = NO;

    _vwMiddleContainer.hidden = !(objUserConfig.isShowSpeed) && !(objUserConfig.isShowTime);
    _vwSpeed.hidden = !(objUserConfig.isShowSpeed);
    _vWSpeedSuper.hidden = !(objUserConfig.isShowSpeed);
    _vwTime.hidden = (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap) ? YES : !(objUserConfig.isShowTime);
    _vWTimeSuper.hidden = (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap) ? YES : !(objUserConfig.isShowTime);
    _vwCAP.hidden = (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap) ? NO : !(objUserConfig.isShowCap);
    _vWCapSuper.hidden = (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap) ? NO : !(objUserConfig.isShowCap);

    _heightVwSpeed.constant = CGRectGetHeight(_vwMiddleContainer.frame) / 2;
    _heightVwTime.constant = CGRectGetHeight(_vwMiddleContainer.frame) / 2;

    if (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap) {
        _lblCAPHeading.text = @"Time of Day";
        _heightVwSpeed.constant = CGRectGetHeight(_vwMiddleContainer.frame);
        _heightVwTime.constant = 0.0f;
    } else if (objUserConfig.isShowSpeed && !objUserConfig.isShowTime) {
        _heightVwSpeed.constant = CGRectGetHeight(_vwMiddleContainer.frame);
        _heightVwTime.constant = 0.0f;
    } else if (!objUserConfig.isShowSpeed && objUserConfig.isShowTime) {
        _heightVwSpeed.constant = 0.0f;
        _heightVwTime.constant = CGRectGetHeight(_vwMiddleContainer.frame);
    }

    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    [_vwMiddleContainer layoutIfNeeded];
}

- (double)convertDistanceToMiles:(double)unit
{
    return unit * 0.621371;
}

- (void)displayAllUnits
{
    if (![ResetTimer isValid]) {
        double unit = totalDistance + (totalDistance * _calibrate / 100);

        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles) {
            unit = [self convertDistanceToMiles:unit];
        }

        if (objUserConfig.odometerUnit == OdometerUnitHundredth) {
            _lblDistance.text = [NSString stringWithFormat:unit >= 10 ? @"%.2f" : @"0%.2f", unit];
        } else {
            _lblDistance.text = [NSString stringWithFormat:unit < 10 ? @"00%.1f" : unit < 100 ? @"0%.1f" : @"%.1f", unit];
        }

        NSRange range = [_lblDistance.text rangeOfString:@"^0+(?!\\.)" options:NSRegularExpressionSearch];

        if (range.length > 0) {
            _lblDistance.text = [_lblDistance.text stringByReplacingCharactersInRange:range withString:@""];
        }

        //        if ([_lblDistance.text isEqualToString:@"0.0"]) {
        //            _lblDistance.text = @"00.0";
        //        }
        //        range = [_lblDistance.text rangeOfString:@"(?<!\\.)0+$" options:NSRegularExpressionSearch];
        //        if (range.length > 0) {
        //            _lblDistance.text = [_lblDistance.text stringByReplacingCharactersInRange:range withString:@""];
        //        }

        if (isTopSpeedDisplaying) {
            unit = topSpeed;
        } else {
            unit = currentSpeed;
        }

        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles) {
            unit = [self convertDistanceToMiles:unit];
        }

        _lblSpeed.text = [NSString stringWithFormat:unit >= 10 ? @"%ld" : @"%ld", (long)unit];
    }
}

- (void)displayCAPHeading
{
    NSInteger degree = (NSInteger)currentDegree < 0 ? 0 : currentDegree;
    _lblDegree.text = [NSString stringWithFormat:degree < 10 ? @"00%ld°" : degree < 100 ? @"0%ld°" : @"%ld°", (long)degree];
    _lblDegree.attributedText = [self StyleText:_lblDegree.text size:[self NormalizedFontSizeIsEdge:YES IsDate:NO]];
}

- (void)getCurrentDateTime
{
    NSDate* date = [NSDate date];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* dateComponents = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
    NSInteger hour = dateComponents.hour;

    NSString* strHourFormat = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange range = [strHourFormat rangeOfString:@"a"];
    BOOL hasAM = range.location != NSNotFound;

    if (hasAM) {
        if (hour > 12) {
            hour -= 12;
        } else if (hour == 0) {
            hour = 12;
        }
    }

    NSString* strAdditionalHour = @"";

    if (hour >= 0 && hour < 10) {
        strAdditionalHour = @"0";
    }

    NSString* strAdditionalMinute = @"";
    if (dateComponents.minute < 10) {
        strAdditionalMinute = @"0";
    }

    strCurrentDateTime = [NSString stringWithFormat:@"%@%ld:%@%d", strAdditionalHour, (long)hour, strAdditionalMinute, (int)dateComponents.minute];
    if (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap) {
        _lblDegree.text = strCurrentDateTime;
        _lblDegree.attributedText = [self StyleText:_lblDegree.text size:[self NormalizedFontSizeIsEdge:YES IsDate:YES]];
    } else {
        _lblTime.text = strCurrentDateTime;
        _lblTime.attributedText = [self StyleText:_lblTime.text size:[self NormalizedFontSizeIsEdge:NO IsDate:YES]];
    }

    [self performSelector:@selector(getCurrentDateTime) withObject:nil afterDelay:1];
}

- (NSArray*)convertToDegreeThroughLat:(double)latitude andLong:(double)longitude
{
    int latSeconds = (int)floorf(latitude * 3600);
    int latDegrees = (int)floorf(latSeconds / 3600);
    latSeconds = abs(latSeconds % 3600);
    int latMinutes = (int)floorf(latSeconds / 60);
    latSeconds %= 60;
    int longSeconds = (int)floorf(longitude * 3600);
    int longDegrees = (int)floorf(longSeconds / 3600);

    longSeconds = abs(longSeconds % 3600);
    int longMinutes = (int)floorf(longSeconds / 60);
    longSeconds %= 60;

    NSString* str1 = [NSString stringWithFormat:@"%d°%d.%d\'%s", abs(latDegrees), latMinutes, latSeconds, latDegrees >= 0 ? "N" : "S"];
    NSString* str2 = [NSString stringWithFormat:@"%d°%d.%d\'%s", abs(longDegrees), longMinutes, longSeconds, longDegrees >= 0 ? "E" : "W"];

    return @[ str1, str2 ];
}

- (NSString*)calculateDistanceFor:(double)distance
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 2;
    formatter.roundingMode = NSNumberFormatterRoundHalfEven;

    NSString* numberString = [formatter stringFromNumber:@(distance / 1000)];

    return [numberString stringByReplacingOccurrencesOfString:@"," withString:@""];
}

- (void)InitateTimer
{
    if (![ResetTimer isValid]) {
        ResetTimer = [[NSTimer alloc] init];

        ResetLabel = [[NSAttributedString alloc] initWithString:_lblDistance.text];
        ResetTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                      target:self
                                                    selector:@selector(AnimateTheText)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)AnimateTheText
{
    if (ResetCount >= ResetLabel.length * 2) {
        //        _lblDistance.attributedText = ResetLabel;
        ResetCount = 0;
        _lblDistance.text = @"0.0";
        [self.view setUserInteractionEnabled:true];
        [ResetTimer invalidate];
        return;
    } else if ([_lblDistance.text characterAtIndex:ResetCount / 2] != '.') {
        _lblDistance.attributedText = [self ChangeColorText];
    } else {
        ResetCount = ResetCount + 2;
        _lblDistance.attributedText = [self ChangeColorText];
    }
    ResetCount = ResetCount + 1;
}

- (NSAttributedString*)ChangeColorText
{
    NSMutableAttributedString* attributeText = [[NSMutableAttributedString alloc] initWithString:_lblDistance.text];

    if (ResetCount % 2 == 0) {
        [attributeText addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(ResetCount / 2, 1)];
    } else {
        attributeText = [[NSMutableAttributedString alloc]
            initWithString:[self string:_lblDistance.text ByReplacingACharacterAtIndex:ResetCount / 2 byCharacter:@"0"]];
        [attributeText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(ResetCount / 2, 1)];
    }

    return attributeText;
}

- (NSAttributedString*)StyleText:(NSString*)text size:(float)fontSize
{
    UIFont* digit = [UIFont fontWithName:@"DS-Digital-Italic" size:fontSize];
    UIFont* sep = [UIFont fontWithName:@"Digital-7Italic" size:(fontSize)];
    UIFont* degree = [UIFont fontWithName:@"Segment7Standard" size:(fontSize * 0.8)];

    NSMutableAttributedString* attributeText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeText addAttribute:NSFontAttributeName value:digit range:[text rangeOfString:text]];
    [attributeText setAttributes:@{ NSFontAttributeName : sep } range:[text rangeOfString:@":"]];
    [attributeText setAttributes:@{ NSFontAttributeName : degree } range:[text rangeOfString:@"°"]];

    return attributeText;
}

- (NSString*)string:(NSString*)string ByReplacingACharacterAtIndex:(int)i byCharacter:(NSString*)StringContainingAChar
{
    return [string stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:StringContainingAChar];
}

- (NSLayoutConstraint*)changeMultiplier:(NSLayoutConstraint*)oldConstraint with:(CGFloat)NewMultiplier
{
    NSLayoutConstraint* NewConstraint = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
                                                                     attribute:oldConstraint.firstAttribute
                                                                     relatedBy:oldConstraint.relation
                                                                        toItem:oldConstraint.secondItem
                                                                     attribute:oldConstraint.secondAttribute
                                                                    multiplier:NewMultiplier
                                                                      constant:oldConstraint.constant];

    [NSLayoutConstraint deactivateConstraints:([NSArray arrayWithObjects:oldConstraint, nil])];
    [NSLayoutConstraint activateConstraints:([NSArray arrayWithObjects:NewConstraint, nil])];

    return NewConstraint;
}

- (void)setupTutorial
{
    //    if (objUserConfig.isShowTutorial) {
    //        [self.viewOverlay setHidden:false];
    //    } else {
    //        [self.viewOverlay setHidden:true];
    //    }

    int borderWidth = 3.0f;
    _tViewScrollUp.clipsToBounds = YES;
    _tViewScrollUp.layer.borderWidth = borderWidth;
    _tViewScrollUp.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _tViewScrollDown.clipsToBounds = YES;
    _tViewScrollDown.layer.borderWidth = borderWidth;
    _tViewScrollDown.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _tViewSettings.clipsToBounds = YES;
    _tViewSettings.layer.borderWidth = borderWidth;
    _tViewSettings.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _tViewDistanceDecrease.clipsToBounds = YES;
    _tViewDistanceDecrease.layer.borderWidth = borderWidth;
    _tViewDistanceDecrease.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;

    _tViewDistanceIncrease.clipsToBounds = YES;
    _tViewDistanceIncrease.layer.borderWidth = borderWidth;
    _tViewDistanceIncrease.layer.borderColor = [UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0f].CGColor;
}

- (float)NormalizedFontSizeIsEdge:(BOOL)isEdge IsDate:(BOOL)isDate
{
    float width = UIScreen.mainScreen.bounds.size.width;
    int viewCount = (objUserConfig.isShowCap + objUserConfig.isShowSpeed + objUserConfig.isShowTime) + 1;

    if (viewCount == 4) {
        if (isEdge) {
            return MIN(width * 0.155, 140);
        } else {
            BOOL landscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);

            int screenWidth = SCREEN_WIDTH;
            switch (screenWidth) {
            case 320:
                return landscape ? 44 : 20;
            case 375:
                return landscape ? 56 : 26;
            case 414:
                return landscape ? 64 : 30;
            default:
                return landscape ? 76 : 54;
            }
        }
    }

    if (width == 812) {
        width = 768;
    }

    float ratio = viewCount == 2 ? 0.18 : (isDate ? 0.125 : 0.15);

    return MIN(width * ratio, 180);
}

- (void)manageUI
{
    int viewCount = (objUserConfig.isShowCap + objUserConfig.isShowSpeed + objUserConfig.isShowTime) + 1;

    _lblDistance.font = [_lblDistance.font fontWithSize:[self NormalizedFontSizeIsEdge:YES IsDate:NO]];
    _lblSpeed.font = [_lblSpeed.font fontWithSize:[self NormalizedFontSizeIsEdge:NO IsDate:NO]];
    _lblTime.attributedText = [self StyleText:_lblTime.text size:[self NormalizedFontSizeIsEdge:NO IsDate:YES]];

    BOOL degreeAsDate = !objUserConfig.isShowCap && objUserConfig.isShowTime && objUserConfig.isShowSpeed;
    _lblDegree.attributedText = [self StyleText:_lblDegree.text size:[self NormalizedFontSizeIsEdge:YES IsDate:degreeAsDate]];

    float screenWidth = UIScreen.mainScreen.bounds.size.width;
    if (viewCount == 4) {
        if (screenWidth == 320) {
            _lblOdoDistanceUnit.font = [_lblOdoDistanceUnit.font fontWithSize:8];
            _lblCAPHeading.font = [_lblCAPHeading.font fontWithSize:8];
            _labelTOD.font = [_labelTOD.font fontWithSize:6];
            _lbldistancePerHour.font = [_lbldistancePerHour.font fontWithSize:6];
            _constraintTopDPH.constant = 2;
            _constraintTopTOD.constant = 2;
            _constraintHeightDPH.constant = 6;
            _constraintHeightTOD.constant = 6;
        } else if (screenWidth == 375) {
            _lblOdoDistanceUnit.font = [_lblOdoDistanceUnit.font fontWithSize:12];
            _lblCAPHeading.font = [_lblCAPHeading.font fontWithSize:12];
            _labelTOD.font = [_labelTOD.font fontWithSize:8];
            _lbldistancePerHour.font = [_lbldistancePerHour.font fontWithSize:8];
            _constraintTopDPH.constant = 5;
            _constraintTopTOD.constant = 5;
            _constraintHeightDPH.constant = 8;
            _constraintHeightTOD.constant = 8;
        }
    }

    if (viewCount < 4 || (viewCount == 4 && screenWidth > 375)) {
        _constraintTopDPH.constant = viewCount == 4 ? 2 : 5;
        _constraintTopTOD.constant = viewCount == 4 ? 2 : 5;
        _constraintHeightDPH.constant = 12;
        _constraintHeightTOD.constant = 12;

        float fontSize = screenWidth == 320 ? 8 : ((screenWidth == 375 && viewCount == 3 && objUserConfig.isShowCap) ? 10 : 12);

        _lblOdoDistanceUnit.font = [_lblOdoDistanceUnit.font fontWithSize:fontSize];
        _lblCAPHeading.font = [_lblCAPHeading.font fontWithSize:fontSize];
        _labelTOD.font = [_labelTOD.font fontWithSize:fontSize];
        _lbldistancePerHour.font = [_lbldistancePerHour.font fontWithSize:fontSize];
    }

    // Setting button image
    if (UIScreen.mainScreen.bounds.size.width > 600) {
        _settingImage.image = [UIImage imageNamed:@"menu_h"];
    } else {
        _settingImage.image = [UIImage imageNamed:@"menu"];
    }
}

- (float)ReturnFontSize:(BOOL)Bigger
{
    int Width = SCREEN_WIDTH;
    BOOL landscape = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);

    if (!Bigger) {
        switch (Width) {
        case 320:
            return landscape ? 50 : 15;
        case 375:
            return landscape ? 60 : 25;
        case 414:
            return landscape ? 65 : 30;
        default:
            return 65;
        }
    } else {
        switch (Width) {
        case 320:
            return landscape ? 60 : 30;
        case 375:
            return landscape ? 75 : 40;
        case 414:
            return landscape ? 80 : 45;
        default:
            return landscape ? 120 : 90;
        }
    }
}

#pragma mark - Orientation Delegate Methods

- (IBAction)orientationChanged:(id)sender
{
    [self adjustHeader];
    @autoreleasepool {
        NSArray* arrVisibleRows = [_tblRoadbook visibleCells];

        for (RouteCell* cell in arrVisibleRows) {
            NSIndexPath* indexPath = [_tblRoadbook indexPathForCell:cell];
            [self manageDegreeForCell:cell withIndexPath:indexPath];
        }
    }
}

#pragma mark - PDF View Setup

- (void)setupPdfView
{
    _pdfContainer.layer.cornerRadius = 10.0f;
    _pdfContainer.clipsToBounds = YES;

    [self.view bringSubviewToFront:_pdfContainer];
    [self.view bringSubviewToFront:_activityIndicator];
    [self.view bringSubviewToFront:self.viewOverlay];

    [self loadPDF];
}

- (void)loadPDF
{
    NSString* remoteUrl;

    if (objUserConfig.highlightPdf) {
        remoteUrl = objUserConfig.pdfFormat == PdfFormatCrossCountry ? _objRoute.crossCountryHighlightPdf : _objRoute.highlightRoadRally;
    } else {
        remoteUrl = objUserConfig.pdfFormat == PdfFormatRoadRally ? _objRoute.roadRallyPdf : _objRoute.pdf;
    }

    if (remoteUrl.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"PDF is unavailable for selected PDF format"];
    } else {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* strFileType;

        if (objUserConfig.highlightPdf) {
            strFileType = objUserConfig.pdfFormat == PdfFormatCrossCountry ? @"_Highlighted_Cross_Country" : @"_Highlighted_Road_Rally";
        } else {
            strFileType = objUserConfig.pdfFormat == PdfFormatRoadRally ? @"_Road_Rally" : @"_Cross_Country";
        }
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:
                                                     [NSString stringWithFormat:@"%ld%@.pdf", (long)_objRoute.routesIdentifier, strFileType]];
        NSURL* localUrl = [NSURL fileURLWithPath:filePath];

        [_activityIndicator startAnimating];
        NSLog(@">>>>> Load pdf: remote = %@, local = %@", remoteUrl, localUrl);

        if ([[WebServiceConnector alloc] checkNetConnection]) {
            NSURLSession* session = [NSURLSession sharedSession];
            [[session dataTaskWithURL:[NSURL URLWithString:remoteUrl]
                    completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self.activityIndicator stopAnimating];
                            });
                            [SVProgressHUD showInfoWithStatus:@"Failed to Load PDF file"];
                        } else {
                            [data writeToFile:filePath atomically:YES];
                            [self setupPDFPages:localUrl];
                        }
                    }] resume];
        } else {
            [self setupPDFPages:localUrl];
        }
    }
}

- (void)setupPDFPages:(NSURL*)url
{
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    CGSize documentSize = CGPDFPageGetBoxRect(page, kCGPDFCropBox).size;
    
    arrPageImages = [[NSMutableArray alloc] init];
    arrPageHeights = [[NSMutableArray alloc] init];

    CGFloat reminder = documentSize.height;
    while (reminder > 0) {
        if (reminder > MAX_PDF_PAGE_HEIGHT) {
            [arrPageHeights addObject:[NSNumber numberWithFloat:MAX_PDF_PAGE_HEIGHT]];
            reminder -= MAX_PDF_PAGE_HEIGHT;
        } else {
            [arrPageHeights addObject:[NSNumber numberWithFloat:reminder]];
            break;
        }
    }
    
    int pageCount = (int)arrPageHeights.count;
    CGFloat scale = 1;
    PDFSize = CGSizeMake(documentSize.width, documentSize.height);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat offset = 0;
        for (int i = 0; i < pageCount; i++) {
            CGFloat height = (CGFloat)[[self->arrPageHeights objectAtIndex:i] floatValue];
            
            UIGraphicsBeginImageContext(CGSizeMake(self->PDFSize.width, height));
            
//            CGContextRef context = CGPDFContextCreateWithURL((CFURLRef)url, NULL, NULL);
//            CGPDFContextBeginPage(context, NULL);
//            UIGraphicsPushContext(context);

            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
            
            // Flip coordinates
            CGContextScaleCTM(context, scale, -scale);
            CGContextTranslateCTM(context, 0, -documentSize.height + offset);
            
            CGContextDrawPDFPage(UIGraphicsGetCurrentContext(), page);
            
            [self->arrPageImages addObject:UIGraphicsGetImageFromCurrentImageContext()];
            
//            UIGraphicsPopContext();
            
//            CGPDFContextEndPage(context);
//            CGPDFContextClose(context);
            
            CGContextRestoreGState(context);
            UIGraphicsEndImageContext();
            
            offset += height;
        }
        
        CGPDFDocumentRelease(pdf);

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.activityIndicator stopAnimating];
            [self.pdfView reloadData];
        });
    });
}

#pragma mark - Setting Delegate Methods

- (void)clickedLogout
{
    [self presentConfirmationAlertWithTitle:@"Confirm Logout"
                                withMessage:@"Are you sure you want to log out?"
                      withCancelButtonTitle:@"Cancel"
                               withYesTitle:@"Yes"
                         withExecutionBlock:^{
                             FBSDKLoginManager* login = [[FBSDKLoginManager alloc] init];
                             [login logOut];

                             [[GIDSignIn sharedInstance] signOut];
                             [DefaultsValues setBooleanValueToUserDefaults:NO ForKey:kLogIn];
                             [self.navigationController popToRootViewControllerAnimated:YES];
                         }];
}

// Change by Harjeet - hka
- (void)clickedRoadbooks
{
    [self presentConfirmationAlertWithTitle:@"Load New Roadbook?"
                                withMessage:@"Are you sure you want to load new "
                                            @"roadbook and reset odometer?"
                      withCancelButtonTitle:@"Cancel"
                               withYesTitle:@"Yes"
                         withExecutionBlock:^{
                             [self.navigationController popViewControllerAnimated:YES];
                         }];
}

- (void)odoValueChanged:(double)distanceValue
{
    AppContext.cal = distanceValue;
    _calibrate = distanceValue;
    [self displayAllUnits];
}

#pragma mark - Button Click Events

- (IBAction)btnDigitUpClicked:(id)sender
{
    [[AudioPlayer sharedManager] createAudioPlayer:@"Tink":@"mp3"];

    if (objUserConfig.odometerUnit == OdometerUnitTenth) {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f / 0.621371 : 0.10f);
    } else {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f / 0.621371 : 0.01f);
    }

    [self displayAllUnits];
}

- (IBAction)btnDigitDownClicked:(id)sender
{
    [[AudioPlayer sharedManager] createAudioPlayer:@"Tock":@"mp3"];

    if (objUserConfig.odometerUnit == OdometerUnitTenth) {
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f / 0.621371 : 0.10f);
    } else {
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f / 0.621371 : 0.01f);
    }

    if (totalDistance < 0) {
        totalDistance = 0.0f;
    }

    [self displayAllUnits];
}

- (IBAction)btnDigitDownHoldClicked:(id)sender
{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer* r = sender;
        if (r.state == UIGestureRecognizerStateBegan) {
            [[AudioPlayer sharedManager] createAudioPlayer:@"Tock":@"mp3"];

            if (!UpdateSpeed.isValid) {
                UpdateSpeed = [[NSTimer alloc] init];
                UpdateSpeed = [NSTimer
                    scheduledTimerWithTimeInterval:0.05
                                            target:self
                                          selector:@selector(UpdateSpeedContinuosDown)
                                          userInfo:nil
                                           repeats:YES];
            }
        } else if (r.state == UIGestureRecognizerStateEnded) {
            [UpdateSpeed invalidate];
        }
    }
}

- (void)UpdateSpeedContinuosDown
{
    if (objUserConfig.odometerUnit == OdometerUnitTenth) {
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f / 0.621371 : 0.10f);
    } else {
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f / 0.621371 : 0.01f);
    }

    if (totalDistance < 0) {
        totalDistance = 0.0f;
    }

    [self displayAllUnits];
}

- (IBAction)btnDigitUpHoldClicked:(id)sender
{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer* r = sender;
        if (r.state == UIGestureRecognizerStateBegan) {
            [[AudioPlayer sharedManager] createAudioPlayer:@"Tink":@"mp3"];

            if (!UpdateSpeed.isValid) {
                UpdateSpeed = [[NSTimer alloc] init];
                UpdateSpeed = [NSTimer
                    scheduledTimerWithTimeInterval:0.05
                                            target:self
                                          selector:@selector(UpdateSpeedContinuosUp)
                                          userInfo:nil
                                           repeats:YES];
            }
        } else if (r.state == UIGestureRecognizerStateEnded) {
            [UpdateSpeed invalidate];
        }
    }
}

- (void)UpdateSpeedContinuosUp
{
    if (objUserConfig.odometerUnit == OdometerUnitTenth) {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f / 0.621371 : 0.10f);
    } else {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f / 0.621371 : 0.01f);
    }

    [self displayAllUnits];
}

- (IBAction)btnResetDistanceClicked:(id)sender
{
    if (objUserConfig.isShowAlert) {
        [self presentConfirmationAlertWithTitle:@"Reset ODO Distance"
                                    withMessage:
                                        @"Are you sure you want to reset distance?"
                          withCancelButtonTitle:@"Cancel"
                                   withYesTitle:@"Yes"
                             withExecutionBlock:^{
                                 self->totalDistance = 0.0f;
                                 [[AudioPlayer sharedManager] createAudioPlayer:@"Reset":@"wav"];
                                 [self InitateTimer];
                             }];
    } else {
        totalDistance = 0.0f;
        [[AudioPlayer sharedManager] createAudioPlayer:@"Reset":@"wav"];
        [self.view setUserInteractionEnabled:false];
        [self InitateTimer];
    }
}

- (IBAction)btnSpeedClicked:(id)sender
{
    if (!isTopSpeedDisplaying) {
        isTopSpeedDisplaying = YES;

        _lbldistancePerHour.text = @"Top Speed";
        [self displayAllUnits];

        [NSTimer scheduledTimerWithTimeInterval:2
                                        repeats:NO
                                          block:^(NSTimer* _Nonnull timer) {
                                              self->isTopSpeedDisplaying = NO;

                                              switch (self->objUserConfig.distanceUnit) {
                                              case DistanceUnitsTypeMiles:
                                                  self->_lbldistancePerHour.text = @"MPH";
                                                  break;

                                              case DistanceUnitsTypeKilometers:
                                                  self->_lbldistancePerHour.text = @"KPH";
                                                  break;

                                              default:
                                                  break;
                                              }

                                              [self displayAllUnits];
                                          }];
    }
}

- (IBAction)btnResetTopSpeedClicked:(id)sender
{
    if (isTopSpeedDisplaying) {
        topSpeed = 0.0f;
        [self displayAllUnits];
    }
}

- (IBAction)btnTableClicked:(id)sender
{
    CGPoint touchPoint = [sender locationInView:_vwBackground];

    CGRect upRect = CGRectMake(0, 0, CGRectGetWidth(_tblRoadbook.frame), CGRectGetHeight(_tblRoadbook.frame) / 2);
    BOOL isUp = CGRectContainsPoint(upRect, touchPoint);

    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        // Long press
        UILongPressGestureRecognizer* r = sender;
        [self handleLongPressTableForUp:isUp touchState:r.state];
    } else {
        // Tap
        [self handleTapTableForUp:isUp];
    }
}

- (IBAction)btnSettingsClicked:(id)sender
{
    SettingsVC* vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.delegate = self;
    vc.strRoadbookId = [NSString stringWithFormat:@"%ld", (long)[obj_Route.routeIdentifier doubleValue]];
    vc.Ododistance = _calibrate;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES animated:NO];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Scroll custom

- (void)handleLongPressTableForUp:(BOOL)isUp touchState:(UIGestureRecognizerState)state
{
    if (state == UIGestureRecognizerStateBegan) {
        //        [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange":@"mp3"];
        if (!ScrollTimer.isValid) {
            ScrollCount = 0;
            ScrollTimer = [[NSTimer alloc] init];
            ScrollTimer = [NSTimer
                scheduledTimerWithTimeInterval:0.05
                                        target:self
                                      selector:isUp ? @selector(ScrollTableDown) : @selector(ScrollTableUp)
                                      userInfo:nil
                                       repeats:YES];
        }
    } else if (state == UIGestureRecognizerStateEnded) {
        ScrollCount = 0;
        [ScrollTimer invalidate];
    }
}

- (void)handleTapTableForUp:(BOOL)isUp
{
    //    [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange":@"mp3"];

    // DataSource
    NSMutableArray* arrSearchResults = [[objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate] mutableCopy];
    if (arrSearchResults.count == 0) {
        return;
    }

    NSArray* arrCells = [_tblRoadbook visibleCells];
    if (arrCells.count == 0) {
        return;
    }

    // Get indexPath
    RouteCell* cell = isUp ? arrCells.lastObject : arrCells.firstObject;
    NSIndexPath* indexPath = [_tblRoadbook indexPathForCell:cell];

    if (!isUp && indexPath.row > 0) {
        [_tblRoadbook scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]
                            atScrollPosition:UITableViewScrollPositionTop
                                    animated:YES];
    } else if (isUp && indexPath.row < arrSearchResults.count - 1) {
        [_tblRoadbook scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]
                            atScrollPosition:UITableViewScrollPositionBottom
                                    animated:YES];
    }
}

- (IBAction)handleLongPressPDFView:(id)sender
{
    if (![sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return;
    }

    UILongPressGestureRecognizer* r = sender;
    BOOL isUp = r.view == _pdfViewUp;

    switch (r.state) {
    case UIGestureRecognizerStateBegan:
        //        [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange":@"mp3"];
        if (!ScrollTimer.isValid) {
            ScrollCount = 0;
            ScrollTimer = [[NSTimer alloc] init];
            ScrollTimer = [NSTimer
                scheduledTimerWithTimeInterval:0.05
                                        target:self
                                      selector:isUp ? @selector(ScrollPDFDown) : @selector(ScrollPDFUp)
                                      userInfo:nil
                                       repeats:YES];
        }
        break;

    case UIGestureRecognizerStateEnded:
        ScrollCount = 0;
        [ScrollTimer invalidate];
        break;

    default:
        break;
    }
}

- (IBAction)handleTapPDFView:(id)sender
{
    //    [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];

    int step = SCREEN_WIDTH >= 768 ? 200 : 100;
    BOOL isUp = FALSE;

    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer* r = sender;
        isUp = r.view == _pdfViewUp;
    } else if ([sender isEqualToString:@"up"]) {
        isUp = YES;
    }

    [self ScrollPDF2Up:!isUp step:step];
}

- (void)ScrollTableUp
{
    ScrollCount++;

    CGFloat offset = _tblRoadbook.contentOffset.y;

    if (offset <= 0) {
        return;
    }

    CGFloat step = ScrollCount > 20 ? 25 : 5;
    CGPoint point = CGPointMake(0, MAX(0, offset - step));
    [_tblRoadbook setContentOffset:point];
}

- (void)ScrollTableDown
{
    ScrollCount++;

    CGFloat offset = _tblRoadbook.contentOffset.y;
    CGFloat maxY = _tblRoadbook.contentSize.height - _tblRoadbook.frame.size.height;

    if (offset >= maxY) {
        return;
    }

    CGFloat step = ScrollCount > 20 ? 25 : 5;
    CGPoint point = CGPointMake(0, MIN(maxY, offset + step));
    [_tblRoadbook setContentOffset:point];
}

- (void)ScrollPDFUp
{
    ScrollCount++;

    CGFloat step = ScrollCount > 20 ? 25 : 5;
    [self ScrollPDF2Up:YES step:step];
}

- (void)ScrollPDFDown
{
    ScrollCount++;

    CGFloat step = ScrollCount > 20 ? 25 : 5;
    [self ScrollPDF2Up:NO step:step];
}

- (void)ScrollPDF2Up:(BOOL)isUp step:(CGFloat)step
{
    CGFloat offset = _pdfView.contentOffset.y;
    CGFloat maxY = _pdfView.contentSize.height - _pdfView.frame.size.height;

    if ((isUp && offset <= 0) || (!isUp && offset >= maxY)) {
        return;
    }

    CGPoint point = isUp ? CGPointMake(0, MAX(0, offset - step))
                         : CGPointMake(0, MIN(maxY, offset + step));
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.pdfView setContentOffset:point];
                     }];
}

#pragma mark - Location Manager Services

- (void)didUpdateToLocation:(NSArray<CLLocation*>*)arrLocations
{
    if (arrLocations.count > 0) {
        CLLocation* location = arrLocations.firstObject;

        if (!arrAllLocations) {
            arrAllLocations = [[NSMutableArray alloc] init];
        }

        if (arrAllLocations.count > 0) {
            CLLocation* preLocation = arrAllLocations.lastObject;

            double distance = [location distanceFromLocation:preLocation];

            distance = distance / 1000.0f;

            totalDistance += distance;
        }

        double speed = ((location.speed * 3600) / 1000);
        currentSpeed = speed > 0 ? speed : 0;

        if (currentSpeed > topSpeed) {
            topSpeed = currentSpeed;
        }

        [self displayAllUnits];

        if (([self convertDistanceToMiles:currentSpeed] >= 3.0f) && (objUserConfig.isShowCap)) {
            currentDegree = location.course;
            _lblCAPHeading.text = @"CAP HEADING";
            [self displayCAPHeading];
        }

        [arrAllLocations addObject:location];
    }
}

- (void)didUpdateToHeading:(CLHeading*)heading
{
    if (([self convertDistanceToMiles:currentSpeed] < 3.0f) && (objUserConfig.isShowCap)) {
        currentDegree = heading.magneticHeading;
        _lblCAPHeading.text = @"CAP HEADING";
        [self displayCAPHeading];
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _pdfView) {
        return arrPageImages.count;
    } else {
        return [objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate].count;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (tableView == _pdfView) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"idPDFCell" forIndexPath:indexPath];

        UIImageView* imageView = [cell viewWithTag:123];
        imageView.image = (UIImage*)[arrPageImages objectAtIndex:indexPath.row];

        return cell;
    }

    RouteCell* cell = [tableView dequeueReusableCellWithIdentifier:@"idRouteCell"];

    if (!cell) {
        cell = [self registerCell:cell inTableView:tableView forClassName:NSStringFromClass([RouteCell class]) identifier:@"idRouteCell"];
    }

    NSMutableArray* arrSearchResults = [[objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate] mutableCopy];
    Waypoints* objWayPoint = [arrSearchResults objectAtIndex:indexPath.row];

    cell.lblRow.text = [NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)];

    NSArray* arrResults = [self convertToDegreeThroughLat:objWayPoint.lat andLong:objWayPoint.lon];

    if (arrResults.count == 2) {
        cell.lblLatitude.text = arrResults[0];
        cell.lblLongitude.text = arrResults[1];
    }

    if (objWayPoint.backgroundimage.url.length > 0) {
        [cell.imgView
            sd_setImageWithURL:[NSURL URLWithString:objWayPoint.backgroundimage.url]
              placeholderImage:nil
                     completed:^(UIImage* _Nullable image, NSError* _Nullable error, SDImageCacheType cacheType, NSURL* _Nullable imageURL) {
                         if (error == nil) {
                             cell.imgView.image = image;
                         }
                     }];
    } else {
        cell.imgView.image = nil;
    }

    cell.txtView.layer.shadowColor = WHITE_COLOR.CGColor;

    cell.txtView.text = objWayPoint.wayPointDescription;

    cell.txtView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    cell.txtView.layer.shadowOpacity = 1.0f;
    cell.txtView.layer.shadowRadius = 3.0f;
    cell.txtView.layer.shouldRasterize = YES;
    cell.txtView.editable = NO;
    cell.txtView.userInteractionEnabled = YES;

    if (UIScreen.mainScreen.bounds.size.width > 500) {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:48];
    } else {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:36];
    }

    if (indexPath.row == 0) {
        cell.lblDistance.text = @"0.00";
        cell.lblPerDistance.text = @"0.00";
    } else {
        double distance = 0.0;
        double tempDistance = 0.0;

        for (NSInteger i = 0; i < objRouteDetails.waypoints.count - 1; i++) {
            Waypoints* objLocation1 = objRouteDetails.waypoints[i];
            Waypoints* objLocation2 = objRouteDetails.waypoints[i + 1];

            CLLocation* objLoc1 = [[CLLocation alloc] initWithLatitude:objLocation1.lat longitude:objLocation1.lon];
            CLLocation* objLoc2 = [[CLLocation alloc] initWithLatitude:objLocation2.lat longitude:objLocation2.lon];

            distance += [objLoc1 distanceFromLocation:objLoc2];
            tempDistance += [objLoc1 distanceFromLocation:objLoc2];

            if ([objLocation2 isEqual:objWayPoint]) {
                break;
            } else if (objLocation2.show) {
                tempDistance = 0.0;
            }
        }

        double val = 0;

        if (objUserConfig.distanceUnit == DistanceUnitsTypeKilometers) {
            val = 1.0f;
        } else {
            val = 0.62f;
        }

        cell.lblPerDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:tempDistance * val] doubleValue]];
        cell.lblDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:distance * val] doubleValue]];
    }

    if (objUserConfig.distanceUnit == DistanceUnitsTypeKilometers) {
        cell.lblDistanceUnit.text = @"KM";
    } else {
        cell.lblDistanceUnit.text = @"MILE";
    }

    User* objUser = GET_USER_OBJ;
    if ([objUser.role isEqualToString:@"user"]) {
        cell.heightCAPHeading.constant = 0;
    } else {
        cell.heightCAPHeading.constant = 35;
    }

    [cell updateConstraints];
    [cell layoutIfNeeded];

    [self manageDegreeForCell:cell withIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (tableView == _pdfView) {
        CGFloat height = (CGFloat)[[arrPageHeights objectAtIndex:indexPath.row] floatValue];
        return height * tableView.frame.size.width / PDFSize.width;
    }

    return UITableViewAutomaticDimension;
}

- (double)angleFromCoordinate:(double)lat1 lon1:(double)lon1 lat2:(double)lat2 lon2:(double)lon2
{
    lat1 = DEGREES_TO_RADIANS(lat1);
    lon1 = DEGREES_TO_RADIANS(lon1);

    lat2 = DEGREES_TO_RADIANS(lat2);
    lon2 = DEGREES_TO_RADIANS(lon2);

    double dLon = lon2 - lon1;

    double dPhi = log(tan(lat2 / 2.0 + M_PI / 4.0) / tan(lat1 / 2.0 + M_PI / 4.0));

    if (fabs(dLon) > M_PI) {
        if (dLon > 0.0) {
            dLon = -(2.0 * M_PI - dLon);
        } else {
            dLon = (2.0 * M_PI + dLon);
        }
    }

    return fmodf(RADIANS_TO_DEGREES(atan2(dLon, dPhi)) + 360.0, 360.0);
}

- (NSAttributedString*)moveDegreeSymbolUp:(NSString*)str
{
    CGFloat fontSize = iPadDevice ? 16.0f : 13.0f;

    UIFont* fnt = [UIFont systemFontOfSize:fontSize];
    NSString* strAngel = [NSString stringWithFormat:@" %@", str];
    NSCharacterSet* characterset = [NSCharacterSet characterSetWithCharactersInString:@"°"];
    NSRange range = [strAngel rangeOfCharacterFromSet:characterset];
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", str]
                                                                                         attributes:@{ NSFontAttributeName : [fnt fontWithSize:fontSize] }];

    NSDictionary* attr = @{
        NSFontAttributeName : [fnt fontWithSize:fontSize],
        NSBaselineOffsetAttributeName : @5
    };
    [attributedString setAttributes:attr range:NSMakeRange(range.location, 1)];

    return attributedString;
}

- (void)manageDegreeForCell:(RouteCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    CGPoint centerPoint = CGPointMake((_tblRoadbook.frame.size.width / 2), /*55*/ 62.5);

    [cell drawPathIn:cell.contentView startPoint:centerPoint endPoint:CGPointMake(centerPoint.x, centerPoint.y + /*35*/ 45)];

    NSMutableArray* arrWayPoints = [[objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate] mutableCopy];
    Waypoints* objWayPoints = arrWayPoints[indexPath.row];

    double curAngle = 0.0;
    double preAngle = 0.0;

    NSInteger curIndex = [objRouteDetails.waypoints indexOfObject:objWayPoints];

    if (curIndex != objRouteDetails.waypoints.count - 1) {
        Waypoints* objLocation2 = objRouteDetails.waypoints[curIndex + 1];

        curAngle = [self angleFromCoordinate:objWayPoints.lat lon1:objWayPoints.lon lat2:objLocation2.lat lon2:objLocation2.lon];

        Waypoints* objLocation1;

        if (curIndex == 0) {
            preAngle = curAngle;
        } else {
            objLocation1 = objRouteDetails.waypoints[curIndex - 1];

            preAngle = [self angleFromCoordinate:objLocation1.lat lon1:objLocation1.lon lat2:objWayPoints.lat lon2:objWayPoints.lon];
        }

        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %d° ", ROUND_TO_NEAREST(curAngle)]];

        if (preAngle > curAngle) {
            // left // minus
            float A = 360 - (ROUND_TO_NEAREST(preAngle) - ROUND_TO_NEAREST(curAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

            [cell drawDirectionPathIn:cell.contentView startPoint:centerPoint endPoint:CGPointMake(x, y)];

            float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

            float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        } else {
            // right // positive
            float A = (ROUND_TO_NEAREST(curAngle) - ROUND_TO_NEAREST(preAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

            [cell drawDirectionPathIn:cell.contentView startPoint:centerPoint endPoint:CGPointMake(x, y)];

            float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

            float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        }

    } else {
        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:@" ---° "];

        float A = (ROUND_TO_NEAREST(0) - ROUND_TO_NEAREST(0)) - 90;
        float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
        float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

        [cell drawDirectionPathIn:cell.contentView startPoint:centerPoint endPoint:CGPointMake(x, y)];

        float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
        float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

        float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
        float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

        [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
    }

    // Update font size
    if (UIScreen.mainScreen.bounds.size.width > 500) {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:48];
    } else {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:36];
    }
}

@end
