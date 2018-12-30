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
@property (nonatomic, assign) PdfFormat currentPdfFormat;
@property (assign, nonatomic) BOOL isHighlight;
@property (strong, nonatomic) NSString *strRouteName;

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

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *containerViewUp;
@property (weak, nonatomic) IBOutlet UIView *containerViewDown;
@property (strong, nonatomic) WKWebView *pdfView;

@property (weak, nonatomic) IBOutlet UITableView *tblRoadbook;
@property (weak, nonatomic) IBOutlet UIImageView *footerView;

@property (weak, nonatomic) IBOutlet UIView *vwDigitUp;
@property (weak, nonatomic) IBOutlet UIView *vwDigitDown;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightVwSpeed;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightVwTime;

@property (weak, nonatomic) IBOutlet UIView *vWOdometerSuper;
@property (weak, nonatomic) IBOutlet UIView *vWSpeedSuper;
@property (weak, nonatomic) IBOutlet UIView *vWTimeSuper;
@property (weak, nonatomic) IBOutlet UIView *vWCapSuper;
@property (weak, nonatomic) IBOutlet UIView *vwMiddleContainer;

@property (weak, nonatomic) IBOutlet UILabel *labelTOD;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWidthOdometer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopDPH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopTOD;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightTOD;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightDPH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeaderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeaderRatio;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeaderCenter;

@property (strong, nonatomic) RemoteCommandDataSource *remoteCommandDataSource;


@end
