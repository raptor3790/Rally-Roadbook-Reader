//
//  RouteVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"
#import "Routes.h"

@import UIKit;
@import WebKit;

@interface RouteVC : BaseVC

@property (assign, nonatomic) double calibrate;
@property (weak, nonatomic) Routes *objRoute;
@property (assign, nonatomic) BOOL isHighlight;

@property (weak, nonatomic) IBOutlet UIImageView *settingImage;

@property (weak, nonatomic) IBOutlet UIView *vwOdometer;
@property (weak, nonatomic) IBOutlet UIView *vwSpeed;
@property (weak, nonatomic) IBOutlet UIView *vwCAP;
@property (weak, nonatomic) IBOutlet UIView *vwTime;

@property (weak, nonatomic) IBOutlet UILabel *lblOdoDistanceUnit;
@property (weak, nonatomic) IBOutlet UILabel *lbldistancePerHour;
@property (weak, nonatomic) IBOutlet UILabel *lblCAPHeading;

@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDegree;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (weak, nonatomic) IBOutlet UIStackView *headerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UIView *containerViewUp;
@property (weak, nonatomic) IBOutlet UIView *containerViewDown;
@property (strong, nonatomic) WKWebView *pdfView;

@property (weak, nonatomic) IBOutlet UITableView *tblRoadbook;
@property (weak, nonatomic) IBOutlet UIImageView *footerView;

@property (weak, nonatomic) IBOutlet UIView *vwDigitUp;
@property (weak, nonatomic) IBOutlet UIView *vwDigitDown;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIView *vWOdometerSuper;
@property (weak, nonatomic) IBOutlet UIView *vwSpeedSuper;
@property (weak, nonatomic) IBOutlet UIView *vwTimeSuper;
@property (weak, nonatomic) IBOutlet UIView *vwCapSuper;
@property (weak, nonatomic) IBOutlet UIStackView *vwMiddleContainer;

@property (weak, nonatomic) IBOutlet UILabel *labelTOD;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dphTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *todTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *todHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dphHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleViewWidth;

@property (strong, nonatomic) RemoteCommandDataSource *remoteCommandDataSource;


@end
