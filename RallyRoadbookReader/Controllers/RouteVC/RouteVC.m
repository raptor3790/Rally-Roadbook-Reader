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
#import "HowToUseVC.h"
#import "JPSVolumeButtonHandler.h"
#import <FBSDKLoginKit.h>
#import <FBSDKCoreKit.h>
#import <WebKit/WebKit.h>

@import GoogleSignIn;
@import MediaPlayer;

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees) / 180.0)
#define RADIANS_TO_DEGREES(radians) ((radians * 180.0) / M_PI)

@interface RouteVC () <UITableViewDataSource, UITableViewDelegate, LocationManagerDelegate, SettingsVCDelegate, UIScrollViewDelegate, WKNavigationDelegate, AssetPlaybackManagerDelegate>
{
    CGFloat volume;

    double topSpeed;
    double totalDistance;
    double currentSpeed;
    double currentDegree;
    
    BOOL isTopSpeedDisplaying;
    
    NSString *strCurrentDateTime;
    NSMutableArray *arrAllLocations;
    
    CDRoute *obj_Route;
    RouteDetails *objRouteDetails;
    UserConfig *objUserConfig;
    
    NSTimer *ResetTimer;
    NSTimer *ScrollTimer;
    NSTimer *UpdateSpeed;
    int ResetCount;
    int ScrollCount;
    NSAttributedString *ResetLabel;
    
    JPSVolumeButtonHandler *volumeButtonHandler;
    
    NSPredicate *filterWaypointsPredicate;
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteCommandNextTrackNotification:) name:@"nextTrackNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteCommandPreviousTrackNotification:) name:@"previousTrackNotification" object:nil];

    volumeButtonHandler = [JPSVolumeButtonHandler volumeButtonHandlerWithUpBlock:^{
        [self btnDigitUpClicked:nil];
    } downBlock:^{
        [self btnDigitDownClicked:nil];
    }];
    [volumeButtonHandler startHandler:YES];
//    volumeButtonHandler.sessionOptions = AVAudioSessionCategoryOptionAllowBluetooth/*|AVAudioSessionCategoryOptionMixWithOthers*/;

    filterWaypointsPredicate = [NSPredicate predicateWithBlock:^BOOL(Waypoints *objWayPoint, NSDictionary<NSString *,id> * _Nullable bindings) {
        return objWayPoint.show;
    }];
    
    _tblRoadbook.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Changes By Harjeet - hka
    UIBarButtonItem *btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"menu") style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingsClicked:)];
    self.navigationItem.rightBarButtonItem = btnDrawer;
    
    UITapGestureRecognizer *tapUpGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnDigitUpClicked:)];
    UITapGestureRecognizer *tapDownGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnDigitDownClicked:)];
    UITapGestureRecognizer *tapSpeedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnSpeedClicked:)];
    UITapGestureRecognizer *tapTableGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnTableClicked:)];
    
    UILongPressGestureRecognizer *lPressDigitUpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnDigitUpHoldClicked:)];
    UILongPressGestureRecognizer *lPressDigitDownGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnDigitDownHoldClicked:)];
    UILongPressGestureRecognizer *lPressSpeedGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnResetTopSpeedClicked:)];
    UILongPressGestureRecognizer *lPressTableGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnTableClicked:)];
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnResetDistanceClicked:)];
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnResetDistanceClicked:)];

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
    
    if (objUserConfig == nil)
    {
        objUserConfig = [self getDefaultUserConfiguration];
    }
    
    _currentPdfFormat = objUserConfig.pdfFormat;
    _isHighlight = objUserConfig.highlightPdf;
    
    if (objUserConfig.isShowCap)
    {
        _lblCAPHeading.text = @"CAP HEADING";
        currentDegree = AppContext.locationManager.currentCourse;
        [self displayCAPHeading];
    }
    
    [self manageUI];
    
    User *objUser = GET_USER_OBJ;

    BOOL isUserRole = [objUser.role isEqualToString:@"user"];
    NSString *defaultRally = [NSString stringWithFormat:@"%@ - UPGRADED User View", kDefaultRallyName];
    NSString *defaultCross = [NSString stringWithFormat:@"%@ - UPGRADED User View", kDefaultCrossCountryName];
    
    if ( !isUserRole ||
         ([_objRoute.name isEqualToString:defaultRally]) ||
         ([_objRoute.name isEqualToString:defaultCross]) )
    {
        [self setUpWebView];
    }
    else
    {
        _tblRoadbook.hidden = NO;
        [self fetchRouteDetails];
        [self callWebServiceToGetRoute];
    }
    
    [self SetUpTutorial];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];

    objUserConfig = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserConfiguration];
    
    if (objUserConfig == nil)
    {
        objUserConfig = [self getDefaultUserConfiguration];
    }
    
    switch (objUserConfig.distanceUnit)
    {
        case DistanceUnitsTypeMiles:
        {
            _lblOdoDistanceUnit.text = @"MILES";
            _lbldistancePerHour.text = @"MPH";
        }
            break;
            
        case DistanceUnitsTypeKilometers:
        {
            _lblOdoDistanceUnit.text = @"KILOMETERS";
            _lbldistancePerHour.text = @"KPH";
        }
            break;
            
        default:
            break;
    }
    
    [self adjustHeader];
    [self displayAllUnits];
    [self getCurrentDateTime];
    
    if (_wView)
    {
        if (_currentPdfFormat != objUserConfig.pdfFormat || _isHighlight != objUserConfig.highlightPdf)
        {
            _currentPdfFormat = objUserConfig.pdfFormat;
            _isHighlight = objUserConfig.highlightPdf;
            [_wView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
            
            NSString *strURL;
            
            if (objUserConfig.highlightPdf)
            {
                strURL = objUserConfig.pdfFormat == PdfFormatCrossCountry ? _objRoute.crossCountryHighlightPdf : _objRoute.highlightRoadRally;
            }
            else
            {
                strURL = objUserConfig.pdfFormat == PdfFormatRoadRally ?_objRoute.roadRallyPdf : _objRoute.pdf;
            }

            if (strURL.length == 0)
            {
                [SVProgressHUD showInfoWithStatus:@"PDF is unavailable for selected PDF format"];
            }
            else
            {
                [_activityIndicator startAnimating];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *strFileType;
                if (objUserConfig.highlightPdf)
                {
                    strFileType = objUserConfig.pdfFormat == PdfFormatCrossCountry ? @"_Highlighted_Cross_Country" : @"_Highlighted_Road_Rally";
                }
                else
                {
                    strFileType = objUserConfig.pdfFormat == PdfFormatRoadRally ? @"_Road_Rally" : @"_Cross_Country";
                }
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld%@.pdf", (long)_objRoute.routesIdentifier, strFileType]];
                
                NSURL *urlPdf = [NSURL fileURLWithPath:filePath];
                [_wView loadFileURL:urlPdf allowingReadAccessToURL:urlPdf];
                
                [_wView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]]];
                
                urlPdf = [NSURL URLWithString:strURL];
                NSURLSession *session = [NSURLSession sharedSession];
                [[session dataTaskWithURL:urlPdf completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    if(!error)
                    {
                        [data writeToFile:filePath atomically:YES];
                    }
                    
                }] resume];
            }
        }
    }
    else
    {
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
    
    totalDisplayUnits +=
    (objUserConfig.isShowCap + objUserConfig.isShowTime + objUserConfig.isShowSpeed);
    
    _vwOdometer.layer.cornerRadius = 10.0f;
    _vwOdometer.clipsToBounds = YES;
    _vwOdometer.layer.borderWidth = 5.0f;
    _vwOdometer.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
    _vwSpeed.layer.cornerRadius = 10.0f;
    _vwSpeed.clipsToBounds = YES;
    _vwSpeed.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
    _vwTime.layer.cornerRadius = 10.0f;
    _vwTime.clipsToBounds = YES;
    _vwTime.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
    _vwCAP.layer.cornerRadius = 10.0f;
    _vwCAP.clipsToBounds = YES;
    _vwCAP.layer.borderWidth = 5.0f;
    _vwCAP.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
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
    
    if ([self isMovingFromParentViewController])
    {
//        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//        [self resignFirstResponder];
        [super viewWillDisappear:animated];
        
            //assetManager = nil;

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

- (void)handleRouteChange:(NSNotification *)notification
{
    NSDictionary *dicUserInfo = notification.userInfo;
    uint reason  = [dicUserInfo[AVAudioSessionRouteChangeReasonKey] intValue];
    
    BOOL isHeadphonesConnected = NO;
    
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            for (AVAudioSessionPortDescription *output in session.currentRoute.outputs)
            {
                if ([output.portType isEqualToString:AVAudioSessionPortHeadphones])
                {
                    isHeadphonesConnected = YES;
                }
            }
        }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            AVAudioSessionRouteDescription *previousRoute = dicUserInfo[AVAudioSessionRouteChangePreviousRouteKey];
            
            for (AVAudioSessionPortDescription *output in previousRoute.outputs)
            {
                if ([output.portType isEqualToString:AVAudioSessionPortHeadphones])
                {
                    isHeadphonesConnected = NO;
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    if (isHeadphonesConnected)
    {
        NSLog(@"Headphones connected");
    }
    else
    {
        NSLog(@"Headphones disconnected");
    }
}

- (IBAction)volumeDidChange:(NSNotification *)notification
{
//    CGFloat newVolume = [[notification.userInfo valueForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
//
//    if (volume == 0 || newVolume < volume)
//    {
//        [self btnDigitDownClicked:nil];
//    }
//    else
//    {
//        [self btnDigitUpClicked:nil];
//    }
//
//    volume = newVolume;
}

- (void)handleRemoteCommandNextTrackNotification:(NSNotification *)notification
{
    NSLog(@"");
}

- (void)handleRemoteCommandPreviousTrackNotification:(NSNotification *)notification
{
    NSLog(@"");
}

- (void)nextCalled
{
    NSLog(@"Event Fired");
    
    User *objUser = GET_USER_OBJ;
    
    if ([objUser.role isEqualToString:@"user"])
    {
        
    }
    else
    {
        [self btnScrollDown:nil];
    }

}

- (void)prevCalled
{
    NSLog(@"Event Fired");
    
    User *objUser = GET_USER_OBJ;
    
    if ([objUser.role isEqualToString:@"user"])
    {
        
    }
    else
    {
        [self btnScrollUp:nil];
    }

}

- (MPRemoteCommandHandlerStatus)handleNextTrackCommandEvent:(MPRemoteCommandEvent *)event
{
    NSLog(@"Event Fired");
    
    User *objUser = GET_USER_OBJ;

    if ([objUser.role isEqualToString:@"user"])
    {
        
    }
    else
    {
        [self btnScrollDown:nil];
    }
    
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePreviousTrackCommandEvent:(MPRemoteCommandEvent *)event
{
    NSLog(@"Event Fired");
    
    User *objUser = GET_USER_OBJ;
    
    if ([objUser.role isEqualToString:@"user"])
    {
        
    }
    else
    {
        [self btnScrollUp:nil];
    }
    
    return MPRemoteCommandHandlerStatusSuccess;
}

//- (MPRemoteCommandHandlerStatus)handleSkipBackwardCommandEvent:(MPRemoteCommandEvent *)event
//{
//    NSLog(@"Event Fired");
//
//    [self btnScrollDown:nil];
//    return MPRemoteCommandHandlerStatusSuccess;
//}
//
//
//- (MPRemoteCommandHandlerStatus)handleSkipForwardCommandEvent:(MPRemoteCommandEvent *)event
//{
//    NSLog(@"Event Fired");
//
//    [self btnScrollDown:nil];
//    return MPRemoteCommandHandlerStatusSuccess;
//}

#pragma mark - WS Call

- (void)callWebServiceToGetRoute
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%ld", URLGetRouteDetails, (long)_objRoute.routesIdentifier];
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
    NSString *strRoadBookId = [NSString stringWithFormat:@"routeIdentifier = %ld", (long)_objRoute.routesIdentifier];
    NSArray *arrSyncedData = [[[CDRoute query] where:[NSPredicate predicateWithFormat:strRoadBookId]] all];
    
    if (arrSyncedData.count > 0)
    {
        obj_Route = arrSyncedData.firstObject;
        
        NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:obj_Route.data];
        objRouteDetails = [[RouteDetails alloc] initWithDictionary:jsonDict];
    }
    
    [_tblRoadbook reloadData];
}

#pragma mark - Custom Methods

- (void)adjustHeader
{
    NSUInteger totalDisplayUnits = 1;
    
    totalDisplayUnits +=
    (objUserConfig.isShowCap + objUserConfig.isShowTime + objUserConfig.isShowSpeed);
    
    if (totalDisplayUnits < 4)
    {
        if (totalDisplayUnits == 2) {
            _constraintWidthOdometer = [self changeMultiplier:_constraintWidthOdometer :0.5f];
            //_constraintWidthOdometer.multiplier = 0.5f
        }
        else{
            _constraintWidthOdometer = [self changeMultiplier:_constraintWidthOdometer :0.333f];
        }
    }
    else
    {
        // 4
        _constraintWidthOdometer = [self changeMultiplier:_constraintWidthOdometer :0.38f];
    }
    
    if (SCREEN_WIDTH >= 768) {
        _constraintAspectHeader = [self changeMultiplier:_constraintAspectHeader :320/60];
    }
    
    [self manageUI];
    
    if (objUserConfig.isShowCap)
    {
        _lblCAPHeading.text = @"CAP HEADING";
        [self displayCAPHeading];
        if (totalDisplayUnits < 4) {
            _vwTime.layer.borderWidth = 5.0f;
            _vwSpeed.layer.borderWidth = 5.0f;
        }
        else{
            _vwTime.layer.borderWidth = 2.5f;
            _vwSpeed.layer.borderWidth = 2.5f;
        }
    }
    else{
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
    
    _heightVwSpeed.constant = CGRectGetHeight(_vwMiddleContainer.frame)/2;
    _heightVwTime.constant = CGRectGetHeight(_vwMiddleContainer.frame)/2;
    
    if (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap)
    {
        _lblCAPHeading.text = @"Time of Day";
        _heightVwSpeed.constant = CGRectGetHeight(_vwMiddleContainer.frame);
        _heightVwTime.constant = 0.0f;
        
    }
    else if (objUserConfig.isShowSpeed && !objUserConfig.isShowTime)
    {
        _heightVwSpeed.constant = CGRectGetHeight(_vwMiddleContainer.frame);
        _heightVwTime.constant = 0.0f;
    }
    else if (!objUserConfig.isShowSpeed && objUserConfig.isShowTime)
    {
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
    if (![ResetTimer isValid])
    {
        double unit = totalDistance + (totalDistance * _calibrate / 100);
        
        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles)
        {
            unit = [self convertDistanceToMiles:unit];
        }
        
        if (objUserConfig.odometerUnit == OdometerUnitHundredth)
        {
            _lblDistance.text = [NSString stringWithFormat:unit >= 10 ? @"%.2f" : @"0%.2f", unit];
        }
        else
        {
            _lblDistance.text = [NSString stringWithFormat:unit < 10 ? @"00%.1f" : unit < 100 ? @"0%.1f" : @"%.1f", unit];
        }
        
        NSRange range = [_lblDistance.text rangeOfString:@"^0+(?!\\.)" options:NSRegularExpressionSearch];
        
        if(range.length > 0)
        {
             _lblDistance.text = [_lblDistance.text stringByReplacingCharactersInRange:range withString:@""];
        }
//
        
//        if([_lblDistance.text isEqualToString:@"0.0"]){
//            _lblDistance.text = @"00.0";
//        }
//        range = [_lblDistance.text rangeOfString:@"(?<!\\.)0+$" options:NSRegularExpressionSearch];
//        if(range.length > 0){
//            _lblDistance.text = [_lblDistance.text stringByReplacingCharactersInRange:range withString:@""];
//        }
        
        if (isTopSpeedDisplaying)
        {
            unit = topSpeed;
        }
        else
        {
            unit = currentSpeed;
        }
        
        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles)
        {
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
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    NSInteger hour = dateComponents.hour;
    
    NSString *strHourFormat = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange range = [strHourFormat rangeOfString:@"a"];
    BOOL hasAM = range.location != NSNotFound;
    
    if (hasAM)
    {
        if (hour > 12)
        {
            hour -= 12;
        }
        else if (hour == 0)
        {
            hour = 12;
        }
    }
    
    NSString *strAdditionalHour = @"";
    
    if (hour >= 0 && hour < 10)
    {
        strAdditionalHour = @"0";
    }
    
    NSString *strAdditionalMinute = @"";
    if (dateComponents.minute < 10)
    {
        strAdditionalMinute = @"0";
    }
    
    strCurrentDateTime = [NSString stringWithFormat:@"%@%ld:%@%d", strAdditionalHour, (long)hour, strAdditionalMinute, dateComponents.minute];
    if (objUserConfig.isShowSpeed && objUserConfig.isShowTime && !objUserConfig.isShowCap)
    {
        _lblDegree.text = strCurrentDateTime;
        _lblDegree.attributedText = [self StyleText:_lblDegree.text size:[self NormalizedFontSizeIsEdge:YES IsDate:YES]];
    }
    else
    {
        _lblTime.text = strCurrentDateTime;
        _lblTime.attributedText = [self StyleText:_lblTime.text size:[self NormalizedFontSizeIsEdge:NO IsDate:YES]];
    }
    
    [self performSelector:@selector(getCurrentDateTime) withObject:nil afterDelay:1];
}

- (NSArray *)convertToDegreeThroughLat:(double)latitude andLong:(double)longitude
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
    
    NSString *str1 = [NSString stringWithFormat:@"%d°%d.%d\'%s", abs(latDegrees) ,latMinutes, latSeconds, latDegrees >= 0 ? "N" : "S"];
    NSString *str2 = [NSString stringWithFormat:@"%d°%d.%d\'%s", abs(longDegrees) ,longMinutes, longSeconds, longDegrees >= 0 ? "E" : "W"];
    
    return @[str1, str2];
}

- (NSString *)calculateDistanceFor:(double)distance
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 2;
    formatter.roundingMode = NSNumberFormatterRoundHalfEven;
    
    NSString *numberString = [formatter stringFromNumber:@(distance / 1000)];
    
    return [numberString stringByReplacingOccurrencesOfString:@"," withString:@""];
}

-(void)InitateTimer{
    if (![ResetTimer isValid]){
        ResetTimer = [[NSTimer alloc] init];
        
        ResetLabel = [[NSAttributedString alloc]initWithString:_lblDistance.text];
        ResetTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(AnimateTheText) userInfo:nil repeats:YES];
    }
}

-(void)AnimateTheText{
    
    if (ResetCount >= ResetLabel.length * 2) {
        //_lblDistance.attributedText = ResetLabel;
        ResetCount = 0;
        _lblDistance.text = @"0.0";
        [self.view setUserInteractionEnabled:true];
        [ResetTimer invalidate];
        return;
    }
    else if ([_lblDistance.text characterAtIndex:ResetCount/2] != '.'){
        _lblDistance.attributedText = [self ChangeColorText];
        
    }
    else{
        ResetCount = ResetCount + 2;
        _lblDistance.attributedText = [self ChangeColorText];
    }
    ResetCount = ResetCount + 1;
}

-(NSAttributedString *)ChangeColorText{
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:_lblDistance.text];
    
    if (ResetCount % 2 == 0){
        [attributeText addAttribute:NSForegroundColorAttributeName
                              value:[UIColor clearColor]
                              range:NSMakeRange(ResetCount/2, 1)];
    }
    else{
        
        attributeText = [[NSMutableAttributedString alloc]initWithString:[self string:_lblDistance.text ByReplacingACharacterAtIndex:ResetCount/2 byCharacter:@"0"]];
        [attributeText addAttribute:NSForegroundColorAttributeName
                              value:[UIColor blackColor]
                              range:NSMakeRange(ResetCount/2, 1)];
        
    }
    
    return attributeText;
    
}

-(NSAttributedString *)StyleText:(NSString *)text size:(float )fontSize
{
    UIFont *digit = [UIFont fontWithName:@"DS-Digital-Italic" size:fontSize];
    UIFont *sep = [UIFont fontWithName:@"Digital-7Italic" size:(fontSize)];
    UIFont *degree = [UIFont fontWithName:@"Segment7Standard" size:(fontSize * 0.8)];
    
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeText addAttribute:NSFontAttributeName value:digit range:[text rangeOfString:text]];
    [attributeText setAttributes:@{NSFontAttributeName: sep} range:[text rangeOfString:@":"]];
    [attributeText setAttributes:@{NSFontAttributeName: degree} range:[text rangeOfString:@"°"]];
    
    return attributeText;
}

-(NSString *)string:(NSString*)string ByReplacingACharacterAtIndex:(int)i byCharacter:(NSString*)StringContainingAChar{
    
    return [string stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:StringContainingAChar];
}

-(NSLayoutConstraint *)changeMultiplier: (NSLayoutConstraint *)oldConstraint :(CGFloat)NewMultiplier{
    
    NSLayoutConstraint *NewConstraint = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
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

-(void)SetUpTutorial{
    
//    if(objUserConfig.isShowTutorial){
//        [self.viewOverlay setHidden:false];
//    }
//    else{
//        [self.viewOverlay setHidden:true];
//    }
    
    int borderWidth = 3.0f;
    _tViewScrollUp.clipsToBounds = YES;
    _tViewScrollUp.layer.borderWidth = borderWidth;
    _tViewScrollUp.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
    _tViewScrollDown.clipsToBounds = YES;
    _tViewScrollDown.layer.borderWidth = borderWidth;
    _tViewScrollDown.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
    _tViewSettings.clipsToBounds = YES;
    _tViewSettings.layer.borderWidth = borderWidth;
    _tViewSettings.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
    _tViewDistanceDecrease.clipsToBounds = YES;
    _tViewDistanceDecrease.layer.borderWidth = borderWidth;
    _tViewDistanceDecrease.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
    
    _tViewDistanceIncrease.clipsToBounds = YES;
    _tViewDistanceIncrease.layer.borderWidth = borderWidth;
    _tViewDistanceIncrease.layer.borderColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0f].CGColor;
}

-(void)hidePDFPageLabel{
    for (UIView* webSubView in [_wView subviews])
    {
//        NSLog(@"%@", webSubView);
        if ([webSubView isKindOfClass:[UIView class]]) {
            for(UIView* superSubView in [webSubView subviews]){
//                NSLog(@"%@", superSubView);
                if ([superSubView isKindOfClass:NSClassFromString(@"PDFPageLabelView")])
                {
                    //NSLog(@"Here");
                    [superSubView setHidden:true];
                }
                
                if ([superSubView isKindOfClass:NSClassFromString(@"WKPDFPageNumberIndicator")])
                {
                    [superSubView setHidden:true];
                }
            }
        }
    }
}

-(float)NormalizedFontSizeIsEdge:(BOOL)isEdge IsDate:(BOOL)isDate
{
    float width = UIScreen.mainScreen.bounds.size.width;
    int viewCount = (objUserConfig.isShowCap + objUserConfig.isShowSpeed + objUserConfig.isShowTime) + 1;
    
    if (viewCount == 4)
    {
        if (isEdge)
        {
            return MIN(width * 0.155, 140);
        }
        else
        {
            BOOL landscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
            int screenWidth = SCREEN_WIDTH;
            switch (screenWidth)
            {
                case 320: return landscape ? 44 : 20;
                case 375: return landscape ? 56 : 26;
                case 414: return landscape ? 64 : 30;
                default: return landscape ? 76 : 54;
            }
        }
    }
    
    if (width == 812)
    {
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
    if (viewCount == 4)
    {
        if (screenWidth == 320)
        {
            _lblOdoDistanceUnit.font = [_lblOdoDistanceUnit.font fontWithSize:8];
            _lblCAPHeading.font = [_lblCAPHeading.font fontWithSize:8];
            _labelTOD.font = [_labelTOD.font fontWithSize:6];
            _lbldistancePerHour.font = [_lbldistancePerHour.font fontWithSize:6];
            _constraintTopDPH.constant = 2;
            _constraintTopTOD.constant = 2;
            _constraintHeightDPH.constant = 6;
            _constraintHeightTOD.constant = 6;
        }
        else if (screenWidth == 375)
        {
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
    
    if (viewCount < 4 || (viewCount == 4 && screenWidth > 375))
    {
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
    if (UIScreen.mainScreen.bounds.size.width > 600)
    {
        _settingImage.image = [UIImage imageNamed:@"menu_h"];
    }
    else
    {
        _settingImage.image = [UIImage imageNamed:@"menu"];
    }
}

-(float)ReturnFontSize:(BOOL)Bigger
{
    int Width = SCREEN_WIDTH;
    BOOL landscape = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    
    if (!Bigger)
    {
        switch (Width) {
            case 320: return landscape ? 50 : 15;
            case 375: return landscape ? 60 : 25;
            case 414: return landscape ? 65 : 30;
            default: return 65;
        }
    }
    else
    {
        switch (Width) {
            case 320: return landscape ? 60 : 30;
            case 375: return landscape ? 75 : 40;
            case 414: return landscape ? 80 : 45;
            default: return landscape ? 120 : 90;
        }
    }
}

#pragma mark - Orientation Delegate Methods

- (IBAction)orientationChanged:(id)sender
{
    
    [self SetUpScrollViews];
    [self adjustHeader];
    @autoreleasepool {
        NSArray *arrVisibleRows = [_tblRoadbook visibleCells];
        
        for (RouteCell *cell in arrVisibleRows)
        {
            NSIndexPath *indexPath = [_tblRoadbook indexPathForCell:cell];
            [self manageDegreeForCell:cell withIndexPath:indexPath];
        }
    }
}

#pragma mark - Web View Set Up

- (void)setUpWebView
{
    _wView = [[WKWebView alloc] init];
    _wView.backgroundColor = UIColor.clearColor;
    _wView.layer.cornerRadius = 10.0f;
    _wView.clipsToBounds = YES;
    _wView.navigationDelegate = self;
    _wView.scrollView.delegate = self;
    [self.view addSubview:_wView];
    
    
    [self.view bringSubviewToFront:_activityIndicator];
    [self.view bringSubviewToFront:self.viewOverlay];
    
    _wView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Trailing
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_wView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0f
                                                                 constant: -3.0f];
    
    // Leading
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_wView
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f
                                                                constant:3.0f];
    
    // Bottom
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_wView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_bottomFooter
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0f
                                                               constant:0.0f];
    
    // Top
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_wView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_vwSeparator
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0f
                                                            constant:-10.0f];
    
    [self.view addConstraint:trailing];
    [self.view addConstraint:bottom];
    [self.view addConstraint:leading];
    [self.view addConstraint:top];
    
    [self SetUpScrollViews];
    
    //    NSString *strPDFPath = [[NSBundle mainBundle] pathForResource:@"roadbooktest" ofType:@"pdf"];
    //    [wView loadFileURL:[NSURL fileURLWithPath:strPDFPath] allowingReadAccessToURL:[NSURL fileURLWithPath:strPDFPath]];
    
    NSString *strURL;
    
    if (objUserConfig.highlightPdf)
    {
        strURL = objUserConfig.pdfFormat == PdfFormatCrossCountry ? _objRoute.crossCountryHighlightPdf : _objRoute.highlightRoadRally;
    }
    else
    {
        strURL = objUserConfig.pdfFormat == PdfFormatRoadRally ?_objRoute.roadRallyPdf : _objRoute.pdf;
    }

    if (strURL.length == 0)
    {
        [SVProgressHUD showInfoWithStatus:@"PDF is unavailable for selected PDF format"];
    }
    else
    {
        [_activityIndicator startAnimating];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *strFileType;
        if (objUserConfig.highlightPdf)
        {
            strFileType = objUserConfig.pdfFormat == PdfFormatCrossCountry ? @"_Highlighted_Cross_Country" : @"_Highlighted_Road_Rally";
        }
        else
        {
            strFileType = objUserConfig.pdfFormat == PdfFormatRoadRally ? @"_Road_Rally" : @"_Cross_Country";
        }
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld%@.pdf", (long)_objRoute.routesIdentifier, strFileType]];
        
        NSURL *urlPdf = [NSURL fileURLWithPath:filePath];
        [_wView loadFileURL:urlPdf allowingReadAccessToURL:urlPdf];
        
        if ([[WebServiceConnector alloc] checkNetConnection])
        {
            urlPdf = [NSURL URLWithString:strURL];
            [_wView loadRequest:[NSURLRequest requestWithURL:urlPdf]];

            NSURLSession *session = [NSURLSession sharedSession];
            [[session dataTaskWithURL:urlPdf completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                if(!error)
                {
                    [data writeToFile:filePath atomically:YES];
                }

            }] resume];
        }
    }
}

-(void)SetUpScrollViews{
    //ScrollUpView
    
    [_vWScrollUp removeFromSuperview];
    [_vWScrollDown removeFromSuperview];
    
    _vWScrollUp = [[UIView alloc] init];
    _vWScrollUp.backgroundColor = UIColor.clearColor;
    
    //    _vWScrollUp.frame = CGRectMake(0, 100, SCREEN_WIDTH, 150);
    
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    [self.view addSubview:_vWScrollUp];
    
    _vWScrollUp.translatesAutoresizingMaskIntoConstraints = NO;
    // Trailing
    NSLayoutConstraint *trailingUp = [NSLayoutConstraint constraintWithItem:_vWScrollUp
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0f
                                                                   constant:0.0f];
    
    // Leading
    NSLayoutConstraint *leadingUp = [NSLayoutConstraint constraintWithItem:_vWScrollUp
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0f
                                                                  constant:0.0f];
    
    // Bottom
    NSLayoutConstraint *heightUp = [NSLayoutConstraint constraintWithItem:_vWScrollUp
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:0.0f
                                                                 constant:self.wView.frame.size.height/2];
    
    // Top
    NSLayoutConstraint *topUp = [NSLayoutConstraint constraintWithItem:_vWScrollUp
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_vwSeparator
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0f
                                                              constant:-10.0f];
    
    
    _vWScrollDown = [[UIView alloc] init];
    _vWScrollDown.backgroundColor = UIColor.clearColor;
    
    [self.view addSubview:_vWScrollDown];
    
    _vWScrollDown.translatesAutoresizingMaskIntoConstraints = NO;
    // Trailing
    NSLayoutConstraint *trailingDown = [NSLayoutConstraint constraintWithItem:_vWScrollDown
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1.0f
                                                                     constant:0.0f];
    
    // Leading
    NSLayoutConstraint *leadingDown = [NSLayoutConstraint constraintWithItem:_vWScrollDown
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0f
                                                                    constant:0.0f];
    
    // Bottom
    NSLayoutConstraint *heightDown = [NSLayoutConstraint constraintWithItem:_vWScrollDown
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:0.0f
                                                                   constant:self.wView.frame.size.height/2];
    
    // Top
    NSLayoutConstraint *bottomDown = [NSLayoutConstraint constraintWithItem:_vWScrollDown
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:-60.0f];
    
    [self.view addConstraint:trailingUp];
    [self.vWScrollUp addConstraint:heightUp];
    [self.view addConstraint:leadingUp];
    [self.view addConstraint:topUp];
    [self.view addConstraint:trailingDown];
    [self.vWScrollDown addConstraint:heightDown];
    [self.view addConstraint:leadingDown];
    [self.view addConstraint:bottomDown];
    
    [self updateViewConstraints];
    
    [self SetUpGeusture];
    [self.view bringSubviewToFront:self.viewOverlay];
}

-(void)SetupWebviewBorder{
    
    [_upperPDFBorder removeFromSuperview];
    _upperPDFBorder = [[UIView alloc] init];
    _upperPDFBorder.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    
   
    //    _vWScrollUp.frame = CGRectMake(0, 100, SCREEN_WIDTH, 150)
    [self.view addSubview:_upperPDFBorder];
    
    [self.view bringSubviewToFront:_upperPDFBorder];
    
    
    _upperPDFBorder.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *heightUpperBorder = [NSLayoutConstraint constraintWithItem:_upperPDFBorder
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:0.0f
                                                                   constant:8.5f];
    
    // Leading
    NSLayoutConstraint *leadingUpperBorder = [NSLayoutConstraint constraintWithItem:_upperPDFBorder
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f
                                                                constant:3.0f];
    
    // Bottom
    NSLayoutConstraint *trailingUpperBorder = [NSLayoutConstraint constraintWithItem:_upperPDFBorder
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0f
                                                               constant:-3.0f];
    
    // Top
    NSLayoutConstraint *topUpperBorder = [NSLayoutConstraint constraintWithItem:_upperPDFBorder
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_vwSeparator
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0f
                                                            constant:-10.0f];
    
    [self.view addConstraint:leadingUpperBorder];
    [_upperPDFBorder addConstraint:heightUpperBorder];
    [self.view addConstraint:trailingUpperBorder];
    [self.view addConstraint:topUpperBorder];
    
    [self updateViewConstraints];
    
    _upperPDFBorder.layer.cornerRadius = 10;
    
    
    //Lower Border
    [_lowerPDFBorder removeFromSuperview];
    _lowerPDFBorder = [[UIView alloc] init];
    _lowerPDFBorder.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];

    [self.view addSubview:_lowerPDFBorder];
    
    [self.view bringSubviewToFront:_lowerPDFBorder];
    
    
    _lowerPDFBorder.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *heightLowerBorder = [NSLayoutConstraint constraintWithItem:_lowerPDFBorder
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:0.0f
                                                                   constant:8.5f];
    
    // Leading
    NSLayoutConstraint *leadingLowerBorder = [NSLayoutConstraint constraintWithItem:_lowerPDFBorder
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f
                                                                constant:3.0f];
    
    // Bottom
    NSLayoutConstraint *trailingLowerBorder = [NSLayoutConstraint constraintWithItem:_lowerPDFBorder
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0f
                                                                 constant:-3.0f];
    
    // Top
    NSLayoutConstraint *bottomLowerBorder = [NSLayoutConstraint constraintWithItem:_lowerPDFBorder
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomFooter
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0f
                                                            constant:0.0f];
    
    [self.view addConstraint:leadingLowerBorder];
    [_lowerPDFBorder addConstraint:heightLowerBorder];
    [self.view addConstraint:trailingLowerBorder];
    [self.view addConstraint:bottomLowerBorder];
    
    [self updateViewConstraints];
    
    _lowerPDFBorder.layer.cornerRadius = 10;
    [self.view bringSubviewToFront:self.viewOverlay];
    
}

-(void)SetUpGeusture{
    UITapGestureRecognizer *tapUpGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnScrollUp:)];
    UITapGestureRecognizer *tapDownGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnScrollDown:)];
    
    UILongPressGestureRecognizer *lPressDigitUpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnScrollAllUp:)];
    UILongPressGestureRecognizer *lPressDigitDownGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnScrollAllDown:)];
    
    tapUpGesture.numberOfTapsRequired = 1;
    tapDownGesture.numberOfTapsRequired = 1;
    
    lPressDigitUpGesture.minimumPressDuration = 1.0;
    lPressDigitDownGesture.minimumPressDuration = 1.0;
    
    [_vWScrollDown addGestureRecognizer:tapUpGesture];
    [_vWScrollUp addGestureRecognizer:tapDownGesture];
    
    [_vWScrollDown addGestureRecognizer:lPressDigitUpGesture];
    [_vWScrollUp addGestureRecognizer:lPressDigitDownGesture];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self SetupWebviewBorder];

    [self hidePDFPageLabel];
    [_activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [_activityIndicator stopAnimating];
    [SVProgressHUD showInfoWithStatus:@"Failed to Load PDF file"];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0');document.getElementsByTagName('head')[0].appendChild(meta);";
    
    [webView evaluateJavaScript:javascript completionHandler:nil];
}



//Changes by Harjeet - hka
#pragma mark - Scroll View Method

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    [[scrollView pinchGestureRecognizer] setEnabled:false];
}

#pragma mark - Setting Delegate Methods

- (void)clickedLogout
{
    [self presentConfirmationAlertWithTitle:@"Confirm Logout"
                                withMessage:@"Are you sure you want to log out?"
                      withCancelButtonTitle:@"Cancel"
                               withYesTitle:@"Yes"
                         withExecutionBlock:^{
                             
                             FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
                             [login logOut];
                             
                             [[GIDSignIn sharedInstance] signOut];
                             [DefaultsValues setBooleanValueToUserDefaults:NO ForKey:kLogIn];
                             [self.navigationController popToRootViewControllerAnimated:YES];
                         }];
}

//Change by Harjeet - hka
- (void)clickedRoadbooks
{
    [self presentConfirmationAlertWithTitle:@"Load New Roadbook?"
                                withMessage:@"Are you sure you want to load new roadbook and reset odometer?"
                      withCancelButtonTitle:@"Cancel"
                               withYesTitle:@"Yes"
                         withExecutionBlock:^{
                             [self.navigationController popViewControllerAnimated:YES];
                         }];
}

- (void)clickedWebView{
    HowToUseVC *vc = loadViewController(StoryBoard_Settings, kIDHowToUseVC);
    [self.navigationController pushViewController:vc animated:YES];
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
    
    [[AudioPlayer sharedManager] createAudioPlayer:@"Tink" :@"mp3"];
    
    if (objUserConfig.odometerUnit == OdometerUnitTenth)
    {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f/0.621371 : 0.10f);
    }
    else
    {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f/0.621371 : 0.01f);
    }
    
    [self displayAllUnits];
}

- (IBAction)btnDigitDownClicked:(id)sender
{
    [[AudioPlayer sharedManager] createAudioPlayer:@"Tock" :@"mp3"];
    
    if (objUserConfig.odometerUnit == OdometerUnitTenth)
    {
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f/0.621371 : 0.10f);
    }else{
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f/0.621371 : 0.01f);
    }
    
    if (totalDistance < 0)
    {
        totalDistance = 0.0f;
    }
    
    [self displayAllUnits];
}

- (IBAction)btnDigitDownHoldClicked:(id)sender{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        UILongPressGestureRecognizer *r = sender;
        if (r.state == UIGestureRecognizerStateBegan){
            [[AudioPlayer sharedManager] createAudioPlayer:@"Tock" :@"mp3"];
            if(!UpdateSpeed.isValid){
                UpdateSpeed = [[NSTimer alloc]init];
                UpdateSpeed = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(UpdateSpeedContinuosDown) userInfo:nil repeats:YES];
            }
        }
        else if (r.state == UIGestureRecognizerStateEnded){
            [UpdateSpeed invalidate];
        }
    }
}

-(void)UpdateSpeedContinuosDown{
    if (objUserConfig.odometerUnit == OdometerUnitTenth)
    {
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f/0.621371 : 0.10f);
    }else{
        totalDistance -= (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f/0.621371 : 0.01f);
    }
    
    if (totalDistance < 0){
        totalDistance = 0.0f;
    }
    
    [self displayAllUnits];
}

- (IBAction)btnDigitUpHoldClicked:(id)sender{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        UILongPressGestureRecognizer *r = sender;
        if (r.state == UIGestureRecognizerStateBegan){
            [[AudioPlayer sharedManager] createAudioPlayer:@"Tink" :@"mp3"];
            if(!UpdateSpeed.isValid){
                UpdateSpeed = [[NSTimer alloc]init];
                UpdateSpeed = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(UpdateSpeedContinuosUp) userInfo:nil repeats:YES];
            }
        }
        else if (r.state == UIGestureRecognizerStateEnded){
            [UpdateSpeed invalidate];
        }
    }
}

-(void)UpdateSpeedContinuosUp{
    if (objUserConfig.odometerUnit == OdometerUnitTenth)
    {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f/0.621371 : 0.10f);
    }
    else
    {
        totalDistance += (objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f/0.621371 : 0.01f);
    }
    
    [self displayAllUnits];
}

- (IBAction)btnResetDistanceClicked:(id)sender
{
    if (objUserConfig.isShowAlert)
    {
        [self presentConfirmationAlertWithTitle:@"Reset ODO Distance"
                                    withMessage:@"Are you sure you want to reset distance?"
                          withCancelButtonTitle:@"Cancel"
                                   withYesTitle:@"Yes"
                             withExecutionBlock:^{
                                 self->totalDistance = 0.0f;
                                 [[AudioPlayer sharedManager] createAudioPlayer:@"Reset" :@"wav"];
                                 //_lblDistance.text = [NSString stringWithFormat:totalDistance >= 10 ? @"%.2f" : @"0%.2f", totalDistance];
                                 [self InitateTimer];
                             }];
    }
    else
    {
        totalDistance = 0.0f;
        [[AudioPlayer sharedManager] createAudioPlayer:@"Reset" :@"wav"];
        [self.view setUserInteractionEnabled:false];
        [self InitateTimer];
        //_lblDistance.text = [NSString stringWithFormat:totalDistance >= 10 ? @"%.2f" : @"0%.2f", totalDistance];
    }
}

- (IBAction)btnSpeedClicked:(id)sender
{
    if (!isTopSpeedDisplaying)
    {
        isTopSpeedDisplaying = YES;
        
        _lbldistancePerHour.text = @"Top Speed";
        [self displayAllUnits];
        
        [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
            
            self->isTopSpeedDisplaying = NO;
            
            switch (self->objUserConfig.distanceUnit)
            {
                case DistanceUnitsTypeMiles:
                {
                    self->_lbldistancePerHour.text = @"MPH";
                }
                    break;
                    
                case DistanceUnitsTypeKilometers:
                {
                    self->_lbldistancePerHour.text = @"KPH";
                }
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
    if (isTopSpeedDisplaying)
    {
        topSpeed = 0.0f;
        [self displayAllUnits];
    }
}

- (IBAction)btnTableClicked:(id)sender
{
    CGPoint touchPoint = [sender locationInView: _vwBackground];
    
    CGRect upRect = CGRectMake(0, 0, CGRectGetWidth(_tblRoadbook.frame), CGRectGetHeight(_tblRoadbook.frame) / 2);
    BOOL isUp = !CGRectContainsPoint(upRect, touchPoint);
    
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        // Long press
        UILongPressGestureRecognizer *r = sender;
        [self handleLongPressBoardForUp:isUp touchState:r.state];
    }
    else
    {
        // Tap
        [self handleTapBoardForUp:isUp];
    }
}

- (IBAction)btnSettingsClicked:(id)sender
{
    SettingsVC *vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.delegate = self;
    vc.strRoadbookId = [NSString stringWithFormat:@"%ld", (long)[obj_Route.routeIdentifier doubleValue]];
    vc.Ododistance = _calibrate;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES animated:NO];
    [self presentViewController:nav animated:YES completion:nil];
}

-(IBAction)btnScrollUp:(id)sender{
//    NSLog(@"Up");
    [self hidePDFPageLabel];
//    [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];
    int scrollDistance = 100;
    if (SCREEN_WIDTH >= 768) {
        scrollDistance = 200;
    }
    if (_wView.scrollView.contentOffset.y > 0){
        if ((_wView.scrollView.contentOffset.y - scrollDistance) < 0){
            CGPoint Down = CGPointMake(0,0);
            [UIView animateWithDuration:1.0 animations:^{
                [self->_wView.scrollView setContentOffset:Down];
            }];
//            [_wView.scrollView setContentOffset:Down];
        }else{
            CGPoint Down = CGPointMake(0, _wView.scrollView.contentOffset.y - scrollDistance);
            [UIView animateWithDuration:1.0 animations:^{
                [self->_wView.scrollView setContentOffset:Down];
            }];
//            [_wView.scrollView setContentOffset:Down];
        }
    }
   
}

-(IBAction)btnScrollDown:(id)sender{
//    NSLog(@"Down");
    [self hidePDFPageLabel];
//    [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];
//    int currentPosition = (int)(_wView.scrollView.contentSize.height - _wView.frame.size.height);
//    printf("%d", currentPosition);
    int scrollDistance = 100;
    if (SCREEN_WIDTH >= 768) {
        scrollDistance = 200;
    }
    if (_wView.scrollView.contentOffset.y < (int)(_wView.scrollView.contentSize.height - _wView.frame.size.height)) {
        if (((_wView.scrollView.contentOffset.y + _wView.frame.size.height) + scrollDistance) > _wView.scrollView.contentSize.height){
            CGPoint Down = CGPointMake(0, _wView.scrollView.contentSize.height - _wView.frame.size.height);
            
            
            [UIView animateWithDuration:1.0 animations:^{
                [self->_wView.scrollView setContentOffset:Down];
            }];
        }
        else{
            CGPoint Down = CGPointMake(0, _wView.scrollView.contentOffset.y + scrollDistance);
            [UIView animateWithDuration:1.0 animations:^{
                [self->_wView.scrollView setContentOffset:Down];
            }];
           // [_wView.scrollView setContentOffset:Down];
        }
        
    }
}

-(IBAction)btnScrollAllDown:(id)sender{
//    NSLog(@"AllDown");
    [self hidePDFPageLabel];
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        UILongPressGestureRecognizer *r = sender;
        if (r.state == UIGestureRecognizerStateBegan){
//            [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];
            if(!ScrollTimer.isValid){
                ScrollCount = 0;
                ScrollTimer = [[NSTimer alloc]init];
                ScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(ScrollPDFDown) userInfo:nil repeats:YES];
            }
        }
        else if (r.state == UIGestureRecognizerStateEnded){
            ScrollCount = 0;
            [ScrollTimer invalidate];
        }
    }
    //CGPoint Down = CGPointMake(0, _wView.scrollView.contentSize.height - _wView.frame.size.height);
    //[_wView.scrollView setContentOffset:Down];
}

-(void)ScrollPDFDown{
//    NSLog(@"SCROLLING DOWN ::::::::::");
    ScrollCount++;
    
    if (ScrollCount > 20) {
//        int currentPosition = (int)(_wView.scrollView.contentSize.height - _wView.frame.size.height);
//        printf("%d", currentPosition);
        if (_wView.scrollView.contentOffset.y < (int)(_wView.scrollView.contentSize.height - _wView.frame.size.height)) {
            if (((_wView.scrollView.contentOffset.y + _wView.frame.size.height) + 25) > _wView.scrollView.contentSize.height){
                CGPoint Down = CGPointMake(0, _wView.scrollView.contentSize.height - _wView.frame.size.height);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
                //[_wView.scrollView setContentOffset:Down];
            }
            else{
                CGPoint Down = CGPointMake(0, _wView.scrollView.contentOffset.y + 25);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
                //[_wView.scrollView setContentOffset:Down];
            }
            
        }
    }
    else{
//        int currentPosition = (int)(_wView.scrollView.contentSize.height - _wView.frame.size.height);
//        printf("%d", currentPosition);
        if (_wView.scrollView.contentOffset.y < (int)(_wView.scrollView.contentSize.height - _wView.frame.size.height)) {
            if (((_wView.scrollView.contentOffset.y + _wView.frame.size.height) + 5) > _wView.scrollView.contentSize.height){
                CGPoint Down = CGPointMake(0, _wView.scrollView.contentSize.height - _wView.frame.size.height);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
               // [_wView.scrollView setContentOffset:Down];
            }
            else{
                CGPoint Down = CGPointMake(0, _wView.scrollView.contentOffset.y + 5);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
                //[_wView.scrollView setContentOffset:Down];
            }
            
        }
    }
    
}

-(void)ScrollTableDown{
//    NSLog(@"SCROLLING DOWN ::::::::::");
    ScrollCount++;
    if (ScrollCount > 20) {
//        int currentPosition = (int)(_tblRoadbook.contentSize.height - _tblRoadbook.frame.size.height);
//        printf("%d", currentPosition);
        if (_tblRoadbook.contentOffset.y < (int)(_tblRoadbook.contentSize.height - _tblRoadbook.frame.size.height)) {
            if (((_tblRoadbook.contentOffset.y + _tblRoadbook.frame.size.height) + 25) > _tblRoadbook.contentSize.height){
                CGPoint Down = CGPointMake(0, _tblRoadbook.contentSize.height - _tblRoadbook.frame.size.height);
                [_tblRoadbook setContentOffset:Down];
            }
            else{
                CGPoint Down = CGPointMake(0, _tblRoadbook.contentOffset.y + 25);
                [_tblRoadbook setContentOffset:Down];
            }
            
        }
    }
    else{
//        int currentPosition = (int)(_tblRoadbook.contentSize.height - _tblRoadbook.frame.size.height);
//        printf("%d", currentPosition);
        if (_tblRoadbook.contentOffset.y < (int)(_tblRoadbook.contentSize.height - _tblRoadbook.frame.size.height)) {
            if (((_tblRoadbook.contentOffset.y + _tblRoadbook.frame.size.height) + 5) > _tblRoadbook.contentSize.height){
                CGPoint Down = CGPointMake(0, _tblRoadbook.contentSize.height - _tblRoadbook.frame.size.height);
                [_tblRoadbook setContentOffset:Down];
            }
            else{
                CGPoint Down = CGPointMake(0, _tblRoadbook.contentOffset.y + 5);
                [_tblRoadbook setContentOffset:Down];
            }
            
        }
    }
    
}


-(IBAction)btnScrollAllUp:(id)sender{
//    NSLog(@"AllUp");
    
    //CGPoint Down = CGPointMake(0, 0);
    //[_wView.scrollView setContentOffset:Down];
    [self hidePDFPageLabel];
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        UILongPressGestureRecognizer *r = sender;
        if (r.state == UIGestureRecognizerStateBegan){
//            [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];
            if(!ScrollTimer.isValid){
                ScrollCount = 0;
                ScrollTimer = [[NSTimer alloc]init];
                ScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(ScrollPDFUp) userInfo:nil repeats:YES];
            }
        }
        else if (r.state == UIGestureRecognizerStateEnded){
            ScrollCount = 0;
            [ScrollTimer invalidate];
        }
    }
    
}

-(void)ScrollTableUp{
//    NSLog(@"SCROLLING Up ::::::::::");
    ScrollCount++;
    if (ScrollCount > 20){
        if (_tblRoadbook.contentOffset.y > 0){
            if ((_tblRoadbook.contentOffset.y - 25) < 0){
                CGPoint Down = CGPointMake(0,0);
                [_tblRoadbook setContentOffset:Down];
            }else{
                CGPoint Down = CGPointMake(0, _tblRoadbook.contentOffset.y - 25);
                [_tblRoadbook setContentOffset:Down];
            }
        }
    }
    else{
        if (_tblRoadbook.contentOffset.y > 0){
            if ((_tblRoadbook.contentOffset.y - 5) < 0){
                CGPoint Down = CGPointMake(0,0);
                [_tblRoadbook setContentOffset:Down];
            }else{
                CGPoint Down = CGPointMake(0, _tblRoadbook.contentOffset.y - 5);
                [_tblRoadbook setContentOffset:Down];
            }
        }
    }
}

-(void)ScrollPDFUp{
//    NSLog(@"SCROLLING Up ::::::::::");
    ScrollCount++;
    if (ScrollCount > 20){
        if (_wView.scrollView.contentOffset.y > 0){
            if ((_wView.scrollView.contentOffset.y - 25) < 0){
                CGPoint Down = CGPointMake(0,0);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
                //[_wView.scrollView setContentOffset:Down];
            }else{
                CGPoint Down = CGPointMake(0, _wView.scrollView.contentOffset.y - 25);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
                //[_wView.scrollView setContentOffset:Down];
            }
        }
    }
    else{
        if (_wView.scrollView.contentOffset.y > 0){
            if ((_wView.scrollView.contentOffset.y - 5) < 0){
                CGPoint Down = CGPointMake(0,0);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
                //[_wView.scrollView setContentOffset:Down];
                
            }else{
                CGPoint Down = CGPointMake(0, _wView.scrollView.contentOffset.y - 5);
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_wView.scrollView setContentOffset:Down];
                }];
                //[_wView.scrollView setContentOffset:Down];
            }
        }
    }
    
}

- (IBAction)buttonActSkipTutorial:(id)sender {
    [self.viewOverlay setHidden:true];
}

- (void)handleLongPressBoardForUp:(BOOL)isUp touchState:(UIGestureRecognizerState)state
{
    [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];
    if (state == UIGestureRecognizerStateBegan)
    {
        [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];
        if (!ScrollTimer.isValid)
        {
            ScrollCount = 0;
            ScrollTimer = [[NSTimer alloc]init];
            ScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                           target:self
                                                         selector:isUp ? @selector(ScrollTableUp) : @selector(ScrollPDFDown)
                                                         userInfo:nil repeats:YES];
        }
    }
    else if (state == UIGestureRecognizerStateEnded)
    {
        ScrollCount = 0;
        [ScrollTimer invalidate];
    }
}

- (void)handleTapBoardForUp:(BOOL)isUp
{
    [[AudioPlayer sharedManager] createAudioPlayer:@"ScrollChange" :@"mp3"];
    
    // DataSource
    NSMutableArray *arrSearchResults = [[objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate] mutableCopy];
    if (arrSearchResults.count == 0) { return; }
    
    NSArray *arrCells = [_tblRoadbook visibleCells];
    if (arrCells.count == 0) { return; }
    
    // Get indexPath
    RouteCell *cell = isUp ? arrCells.firstObject : arrCells.lastObject;
    NSIndexPath *indexPath = [_tblRoadbook indexPathForCell:cell];
    
    if (isUp && indexPath.row > 0)
    {
        [_tblRoadbook scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]
                            atScrollPosition:UITableViewScrollPositionTop
                                    animated:YES];
    }
    else if (!isUp && indexPath.row < arrSearchResults.count - 1)
    {
        [_tblRoadbook scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]
                            atScrollPosition:UITableViewScrollPositionBottom
                                    animated:YES];
    }
}


#pragma mark - Location Manager Services

- (void)didUpdateToLocation:(NSArray<CLLocation *> *)arrLocations
{
    if (arrLocations.count > 0)
    {
        CLLocation *location = arrLocations.firstObject;
        
        if (!arrAllLocations)
        {
            arrAllLocations = [[NSMutableArray alloc] init];
        }
        
        if (arrAllLocations.count > 0)
        {
            CLLocation *preLocation = arrAllLocations.lastObject;
            
            double distance = [location distanceFromLocation:preLocation];
            
            distance = distance / 1000.0f;
            
            totalDistance += distance;
        }
        
        double speed = ((location.speed * 3600) / 1000);
        currentSpeed = speed > 0 ? speed : 0;
        
        if (currentSpeed > topSpeed)
        {
            topSpeed = currentSpeed;
        }
        
        [self displayAllUnits];
        
        
        if (([self convertDistanceToMiles:currentSpeed] >= 3.0f) && (objUserConfig.isShowCap))
        {
            currentDegree = location.course;
            _lblCAPHeading.text = @"CAP HEADING";
            [self displayCAPHeading];
        }
        
        
        [arrAllLocations addObject:location];
    }
}

- (void)didUpdateToHeading:(CLHeading *)heading
{
    if (([self convertDistanceToMiles:currentSpeed] < 3.0f) && (objUserConfig.isShowCap))
    {
        currentDegree = heading.magneticHeading;
        _lblCAPHeading.text = @"CAP HEADING";
        [self displayCAPHeading];
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idRouteCell"];
    
    if (!cell)
    {
        cell = [self registerCell:cell inTableView:tableView forClassName:NSStringFromClass([RouteCell class]) identifier:@"idRouteCell"];
    }
    
    NSMutableArray *arrSearchResults = [[objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate] mutableCopy];
    Waypoints *objWayPoint = [arrSearchResults objectAtIndex:indexPath.row];
    
    cell.lblRow.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    
    NSArray *arrResults = [self convertToDegreeThroughLat:objWayPoint.lat andLong:objWayPoint.lon];
    
    if (arrResults.count == 2)
    {
        cell.lblLatitude.text = arrResults[0];
        cell.lblLongitude.text = arrResults[1];
    }
    
    if (objWayPoint.backgroundimage.url.length > 0)
    {
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:objWayPoint.backgroundimage.url]
                        placeholderImage:nil
                               completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                   if (error == nil)
                                   {
                                       cell.imgView.image = image;
                                   }
                               }];
    }
    else
    {
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
    
    if (UIScreen.mainScreen.bounds.size.width > 500)
    {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:48];
    }
    else
    {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:36];
    }
    
    if (indexPath.row == 0)
    {
        cell.lblDistance.text = @"0.00";
        cell.lblPerDistance.text = @"0.00";
    }
    else
    {
        double distance = 0.0;
        double tempDistance = 0.0;
        
        for (NSInteger i = 0; i < objRouteDetails.waypoints.count - 1; i++)
        {
            Waypoints *objLocation1 = objRouteDetails.waypoints[i];
            Waypoints *objLocation2 = objRouteDetails.waypoints[i+1];
            
            CLLocation *objLoc1 = [[CLLocation alloc] initWithLatitude:objLocation1.lat longitude:objLocation1.lon];
            CLLocation *objLoc2 = [[CLLocation alloc] initWithLatitude:objLocation2.lat longitude:objLocation2.lon];
            
            distance += [objLoc1 distanceFromLocation:objLoc2];
            tempDistance += [objLoc1 distanceFromLocation:objLoc2];
            
            if ([objLocation2 isEqual:objWayPoint])
            {
                break;
            }
            else if (objLocation2.show)
            {
                tempDistance = 0.0;
            }
        }
        
        double val = 0;
        
        if (objUserConfig.distanceUnit == DistanceUnitsTypeKilometers)
        {
            val = 1.0f;
        }
        else
        {
            val = 0.62f;
        }
        
        cell.lblPerDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:tempDistance * val] doubleValue]];
        cell.lblDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:distance * val] doubleValue]];
    }
    
    if (objUserConfig.distanceUnit == DistanceUnitsTypeKilometers)
    {
        cell.lblDistanceUnit.text = @"KM";
    }
    else
    {
        cell.lblDistanceUnit.text = @"MILE";
    }
    
    User *objUser = GET_USER_OBJ;
    if ([objUser.role isEqualToString:@"user"])
    {
        cell.heightCAPHeading.constant = 0;
    }
    else
    {
        cell.heightCAPHeading.constant = 35;
    }
    
    [cell updateConstraints];
    [cell layoutIfNeeded];
    
    [self manageDegreeForCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (double)angleFromCoordinate:(double)lat1 lon1:(double)lon1 lat2:(double)lat2 lon2:(double)lon2
{
    lat1 = DEGREES_TO_RADIANS(lat1);
    lon1 = DEGREES_TO_RADIANS(lon1);
    
    lat2 = DEGREES_TO_RADIANS(lat2);
    lon2 = DEGREES_TO_RADIANS(lon2);
    
    double dLon = lon2 - lon1;
    
    double dPhi = log(tan(lat2 / 2.0 + M_PI / 4.0) / tan(lat1 / 2.0 + M_PI / 4.0));
    
    if (fabs(dLon) > M_PI)
    {
        if (dLon > 0.0)
        {
            dLon = -(2.0 * M_PI - dLon);
        }
        else
        {
            dLon = (2.0 * M_PI + dLon);
        }
    }
    
    return fmodf(RADIANS_TO_DEGREES(atan2(dLon, dPhi)) + 360.0, 360.0);
}

- (NSAttributedString *)moveDegreeSymbolUp:(NSString *)str
{
    CGFloat fontSize = iPadDevice ? 16.0f : 13.0f;
    
    UIFont *fnt = [UIFont systemFontOfSize:fontSize];
    NSString *strAngel = [NSString stringWithFormat:@" %@", str];
    NSCharacterSet *characterset = [NSCharacterSet characterSetWithCharactersInString:@"°"];
    NSRange range = [strAngel rangeOfCharacterFromSet:characterset];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", str]
                                                                                         attributes:@{NSFontAttributeName: [fnt fontWithSize:fontSize]}];
    [attributedString setAttributes:@{NSFontAttributeName : [fnt fontWithSize:fontSize]
                                      , NSBaselineOffsetAttributeName : @5} range:NSMakeRange(range.location, 1)];
    
    return attributedString;
}

- (void)manageDegreeForCell:(RouteCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    CGPoint centerPoint = CGPointMake((_tblRoadbook.frame.size.width / 2), /*55*/62.5);
    
    [cell drawPathIn:cell.contentView
          startPoint:centerPoint
            endPoint:CGPointMake(centerPoint.x, centerPoint.y + /*35*/45)];
    
    NSMutableArray *arrWayPoints = [[objRouteDetails.waypoints filteredArrayUsingPredicate:filterWaypointsPredicate] mutableCopy];
    Waypoints *objWayPoints = arrWayPoints[indexPath.row];
    
    double curAngle = 0.0;
    double preAngle = 0.0;
    
    NSInteger curIndex = [objRouteDetails.waypoints indexOfObject:objWayPoints];
    
    if (curIndex != objRouteDetails.waypoints.count - 1)
    {
        Waypoints *objLocation2 = objRouteDetails.waypoints[curIndex+1];
        
        curAngle = [self angleFromCoordinate:objWayPoints.lat
                                        lon1:objWayPoints.lon
                                        lat2:objLocation2.lat
                                        lon2:objLocation2.lon];
        
        Waypoints *objLocation1;
        
        if (curIndex == 0)
        {
            preAngle = curAngle;
        }
        else
        {
            objLocation1 = objRouteDetails.waypoints[curIndex-1];
            
            preAngle = [self angleFromCoordinate:objLocation1.lat
                                            lon1:objLocation1.lon
                                            lat2:objWayPoints.lat
                                            lon2:objWayPoints.lon];
        }
        
        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %d° ", ROUND_TO_NEAREST(curAngle)]];
        
        if (preAngle > curAngle)
        {
            // left // minus
            float A = 360 - (ROUND_TO_NEAREST(preAngle) - ROUND_TO_NEAREST(curAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;
            
            [cell drawDirectionPathIn:cell.contentView
                           startPoint:centerPoint
                             endPoint:CGPointMake(x, y)];
            
            float sX = 15 * cos(DEGREES_TO_RADIANS((A+155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A+155))) + y;
            
            float eX = 15 * cos(DEGREES_TO_RADIANS((A-155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A-155))) + y;
            
            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        }
        else
        {
            // right // positive
            float A = (ROUND_TO_NEAREST(curAngle) - ROUND_TO_NEAREST(preAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;
            
            [cell drawDirectionPathIn:cell.contentView
                           startPoint:centerPoint
                             endPoint:CGPointMake(x, y)];
            
            float sX = 15 * cos(DEGREES_TO_RADIANS((A+155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A+155))) + y;
            
            float eX = 15 * cos(DEGREES_TO_RADIANS((A-155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A-155))) + y;
            
            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        }
        
    }
    else
    {
        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:@" ---° "];
        
        float A = (ROUND_TO_NEAREST(0) - ROUND_TO_NEAREST(0)) - 90;
        float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
        float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;
        
        [cell drawDirectionPathIn:cell.contentView
                       startPoint:centerPoint
                         endPoint:CGPointMake(x, y)];
        
        float sX = 15 * cos(DEGREES_TO_RADIANS((A+155))) + x;
        float sY = 15 * sin(DEGREES_TO_RADIANS((A+155))) + y;
        
        float eX = 15 * cos(DEGREES_TO_RADIANS((A-155))) + x;
        float eY = 15 * sin(DEGREES_TO_RADIANS((A-155))) + y;
        
        [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
    }
    
    // Update font size
    if (UIScreen.mainScreen.bounds.size.width > 500)
    {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:48];
    }
    else
    {
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:36];
    }
}

@end
