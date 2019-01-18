//
//  SettingsVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 14/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "SettingsVC.h"
#import "SettingsCell.h"
#import "UserConfig.h"
#import "HowToUseVC.h"

@interface SettingsVC () {
    BOOL isLightView;

    UIToolbar* toolbar;
    UIColor *themeBackGroundColor, *themeTextColor;

    NSMutableArray* arrEmails;

    UserConfig* objUserConfig;
    double totalDistance;
    double stepperValue;
}
@end

@implementation SettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Settings";

    UIBarButtonItem* btnDismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDismissClicked:)];
    self.navigationItem.rightBarButtonItem = btnDismiss;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = UIColor.blackColor;

    _tblSettings.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    id object = [DefaultsValues getObjectValueFromUserDefaults_ForKey:kUserSharedEmails];

    arrEmails = [[NSMutableArray alloc] init];

    if (object) {
        [arrEmails addObjectsFromArray:object];
    }

    objUserConfig = [BaseVC getUserConfiguration];

    totalDistance = AppContext.cal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    switch (objUserConfig.themePreference) {
    case ThemePreferenceDark: {
        isLightView = false;
        themeBackGroundColor = UIColor.blackColor;
        themeTextColor = UIColor.lightGrayColor;
    } break;

    case ThemePreferenceLight: {
        isLightView = true;
        themeBackGroundColor = UIColor.whiteColor;
        themeTextColor = UIColor.blackColor;
    } break;

    default:
        break;
    }

    self.view.backgroundColor = themeBackGroundColor;
    [_tblSettings reloadData];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (isLightView) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

#pragma mark - UIButton Click Events

- (IBAction)btnDismissClicked:(id)sender
{
    [self.view endEditing:YES];

    if (_strRoadbookId) {
        if ([_delegate respondsToSelector:@selector(clickedLogout)]) {
            [_delegate odoValueChanged:totalDistance];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnSwitchClicked:(UISwitch*)sender
{
    [self.view endEditing:YES];

    switch (sender.tag) {
    case UserConfigTypeRotateLock: {
        objUserConfig.isScreenRotateLock = !objUserConfig.isScreenRotateLock;
    } break;

    case UserConfigTypeSpeed: {
        if (objUserConfig.isShowSpeed) {
            NSInteger count = objUserConfig.isShowSpeed + objUserConfig.isShowTime + objUserConfig.isShowCap;
            if (count == 1) {
                [sender setOn:YES];
                return;
            }
        }

        objUserConfig.isShowSpeed = !objUserConfig.isShowSpeed;
    } break;

    case UserConfigTypeTime: {
        if (objUserConfig.isShowTime) {
            NSInteger count = objUserConfig.isShowSpeed + objUserConfig.isShowTime + objUserConfig.isShowCap;
            if (count == 1) {
                [sender setOn:YES];
                return;
            }
        }

        objUserConfig.isShowTime = !objUserConfig.isShowTime;
    } break;

    case UserConfigTypeCAP: {
        if (objUserConfig.isShowCap) {
            NSInteger count = objUserConfig.isShowSpeed + objUserConfig.isShowTime + objUserConfig.isShowCap;
            if (count == 1) {
                [sender setOn:YES];
                return;
            }
        }

        objUserConfig.isShowCap = !objUserConfig.isShowCap;
    } break;

    case UserConfigTypeAlert: {
        objUserConfig.isShowAlert = !objUserConfig.isShowAlert;
    } break;

    default:
        break;
    }

    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (void)btnChangeUnitClicked:(UIButton*)sender
{
    [self.view endEditing:YES];

    switch (sender.tag) {
    case DistanceUnitsTypeMiles: {
        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles) {
            return;
        }

        objUserConfig.distanceUnit = DistanceUnitsTypeMiles;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });
    } break;

    case DistanceUnitsTypeKilometers: {
        if (objUserConfig.distanceUnit == DistanceUnitsTypeKilometers) {
            return;
        }

        objUserConfig.distanceUnit = DistanceUnitsTypeKilometers;
        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnMiles setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });
    } break;

    default:
        break;
    }

    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (void)btnChangeOdoUnitClicked:(UIButton*)sender
{
    [self.view endEditing:YES];

    switch (sender.tag) {
    case OdometerUnitHundredth: {
        if (objUserConfig.odometerUnit == OdometerUnitHundredth) {
            return;
        }

        objUserConfig.odometerUnit = OdometerUnitHundredth;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });

        [self.tblSettings beginUpdates];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:UserConfigTypeCalibrate inSection:0];
        NSArray* indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tblSettings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tblSettings endUpdates];
    } break;

    case OdometerUnitTenth: {
        if (objUserConfig.odometerUnit == OdometerUnitTenth) {
            return;
        }

        objUserConfig.odometerUnit = OdometerUnitTenth;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnMiles setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });

        [self.tblSettings beginUpdates];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:UserConfigTypeCalibrate inSection:0];
        NSArray* indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tblSettings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tblSettings endUpdates];
    } break;

    default:
        break;
    }

    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (void)btnChangePdfFormatClicked:(UIButton*)sender
{
    [self.view endEditing:YES];

    switch (sender.tag) {
    case PdfFormatCrossCountry: {
        if (objUserConfig.pdfFormat == PdfFormatCrossCountry) {
            return;
        }

        objUserConfig.pdfFormat = PdfFormatCrossCountry;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });
    } break;

    case PdfFormatRoadRally: {
        if (objUserConfig.pdfFormat == PdfFormatRoadRally) {
            return;
        }

        objUserConfig.pdfFormat = PdfFormatRoadRally;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnMiles setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });
    } break;

    default:
        break;
    }

    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (void)btnChangeHighlightPreferenceClicked:(UIButton*)sender
{
    [self.view endEditing:YES];

    if (sender.tag == 1) {
        if (objUserConfig.highlightPdf) {
            return;
        }

        objUserConfig.highlightPdf = !objUserConfig.highlightPdf;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });
    } else {
        if (!objUserConfig.highlightPdf) {
            return;
        }

        objUserConfig.highlightPdf = !objUserConfig.highlightPdf;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnMiles setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });
    }

    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (void)btnChangeThemeClicked:(UIButton*)sender
{
    [self.view endEditing:YES];

    switch (sender.tag) {
    case ThemePreferenceDark: {
        if (objUserConfig.themePreference == ThemePreferenceDark) {
            return;
        }

        objUserConfig.themePreference = ThemePreferenceDark;
        isLightView = false;
        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });

    } break;

    case ThemePreferenceLight: {
        if (objUserConfig.themePreference == ThemePreferenceLight) {
            return;
        }

        objUserConfig.themePreference = ThemePreferenceLight;
        isLightView = true;

        SettingsCell* cell = (SettingsCell*)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnMiles setTitleColor:self->themeTextColor forState:UIControlStateNormal];
        });
    } break;

    default:
        break;
    }

    if (!isLightView) {
        themeBackGroundColor = UIColor.blackColor;
        themeTextColor = UIColor.lightGrayColor;
    } else {
        themeBackGroundColor = UIColor.whiteColor;
        themeTextColor = UIColor.blackColor;
    }
    [self.tblSettings reloadData];
    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];

    if (isLightView) {
        [self.view setBackgroundColor:UIColor.whiteColor];
    } else {
        [self.view setBackgroundColor:UIColor.blackColor];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)btnLogoutClicked:(id)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if ([self->_delegate respondsToSelector:@selector(clickedLogout)]) {
                                     [self->_delegate clickedLogout];
                                 }
                                 if (self->_strRoadbookId && [self->_delegate respondsToSelector:@selector(odoValueChanged:)]) {
                                     [self->_delegate odoValueChanged:self->totalDistance];
                                 }
                             }];
}

- (void)shareRoadbookForEmailID:(NSString*)strEmail
{
    if (!arrEmails) {
        arrEmails = [[NSMutableArray alloc] init];
    }

    if ([arrEmails containsObject:strEmail]) {
        if (arrEmails.firstObject != strEmail) {
            NSInteger index = [arrEmails indexOfObject:strEmail];
            [arrEmails exchangeObjectAtIndex:index withObjectAtIndex:0];
        }
    } else {
        if (arrEmails.count > 4) {
            [arrEmails removeLastObject];
        }

        [arrEmails insertObject:strEmail atIndex:0];
    }

    [DefaultsValues setObjectValueToUserDefaults:arrEmails ForKey:kUserSharedEmails];

    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:_strRoadbookId forKey:@"route_id"];
    [dicParam setValue:@[ strEmail ] forKey:@"emails"];

    NSMutableDictionary* dicShare = [[NSMutableDictionary alloc] init];
    [dicShare setObject:dicParam forKey:@"share"];

    NSString* url = [URLGetMyFolders stringByAppendingString:@"/share_reader_roadbook"];
    [[WebServiceConnector alloc] init:url
                       withParameters:dicShare
                           withObject:self
                         withSelector:@selector(handleShareResponse:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (void)handleShareResponse:(id)sender
{
    NSDictionary* dic = [sender responseDict];

    if ([[dic valueForKey:SUCCESS_STATUS] boolValue]) {
        [AlertManager alert:@"" title:@"Roadbook has been shared with user" imageName:@"ic_success" confirmed:NULL];
    } else {
        [AlertManager alert:@"" title:@"Sharing has failed\nYou must be online to share a Roadbook" imageName:@"ic_error" confirmed:NULL];
    }
}

- (void)stepperChanged:(UIStepper*)sender
{
    if (sender.value > stepperValue) {
        totalDistance += 0.10f;
    } else {
        totalDistance -= 0.10f;
    }

    stepperValue = sender.value;
    AppContext.cal = totalDistance;

    NSLog(@"%f", AppContext.cal);

    id superView = [sender superview];

    superView = [superView superview];

    if ([superView isKindOfClass:[SettingsCell class]]) {
        SettingsCell* cell = (SettingsCell*)superView;

        double unit = totalDistance;
        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles) {
            unit = [self convertDistanceToMiles:unit];
        }
        NSString* strValue = [NSString stringWithFormat:unit < 10 ? @"%.1f%%" : unit < 100 ? @"%.1f%%" : @"%.1f%%", unit];
        cell.lblOdoValue.text = unit > 0 ? [@"+" stringByAppendingString:strValue] : strValue;
        NSRange range = [cell.lblOdoValue.text rangeOfString:@"^0+(?!\\.)" options:NSRegularExpressionSearch];

        if (range.length > 0) {
            cell.lblOdoValue.text = [cell.lblOdoValue.text stringByReplacingCharactersInRange:range withString:@""];
        }
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 17;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case UserConfigTypeShareRoadbook: {
        if (_strRoadbookId == NULL) {
            return 0;
        }
    } break;

    case UserConfigTypePDFFormat: {
        return 0;
    } break;

    case UserConfigTypeDistanceUnit: {
        if ([self.delegate respondsToSelector:@selector(showDistanceUnit)]) {
            if (![self.delegate showDistanceUnit]) {
                return 0;
            }
        } else {
            return 0;
        }
    } break;

    case UserConfigTypeRotateLock: {
        if (iPhoneDevice) {
            return 0;
        }
    } break;

    default:
        break;
    }

    return iPadDevice ? 60 : 50;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.view endEditing:YES];

    switch (indexPath.row) {
    case UserConfigNavigation: {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     if ([self->_delegate respondsToSelector:@selector(clickedRoadbooks)]) {
                                         [self->_delegate clickedRoadbooks];
                                     }
                                     if (self->_strRoadbookId && [self->_delegate respondsToSelector:@selector(odoValueChanged:)]) {
                                         [self->_delegate odoValueChanged:self->totalDistance];
                                     }
                                 }];

    } break;

    case UserConfigTypeShareRoadbook: {
        if (_strRoadbookId) {
            [AlertManager input:@"User will receive invitation email to download Rally Roadbook Reader mobile app"
                          title:@"Share Roadbook"
                          extra:@"Roadbook will be in users \"Shared With Me\" folder on App"
                    suggestions:arrEmails
                    placeHolder:NULL
                          image:@"ic_email_w"
                       negative:NULL
                       positive:@"Send"
                      confirmed:^(NSString* _Nullable email) {
                          [AlertManager dismiss];
                          [self.view endEditing:YES];
                          [self shareRoadbookForEmailID:email];
                      }];
        }
    } break;

    case UserConfigTypeMobileUse: {
        HowToUseVC* vc = loadViewController(StoryBoard_Settings, kIDHowToUseVC);
        [self.navigationController pushViewController:vc animated:YES];
    } break;

    case UserConfigTypeShareApplication: {
        NSString* strDetails = @"Join the Rally Revolution.\n\nRally Navigator - Rally Roadbook Reader\n\nLearn more at https://www.rallynavigator.com\n\nDownload Application: https://itunes.apple.com\n\niOS Mobile app Offers Complete Roadbook Rally Navigation Dash for iPad or iPhone: Roadbook, Adjustable Odometer and Compass Heading Display. Load a Roadbook and GO!\n\nRally Navigator Desktop Software Streamlines the Process of Creating Rally Navigation Roadbooks.\n\nDesign your Route, add Waypoint Details and Print FIM & FIA Specification Rally Roadbooks for Cross Country and Road Rally events.\n\nCreate. Share. Rally";

        NSArray* dataToShare = @[ strDetails ];
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[ UIActivityTypeAirDrop ];
        [activityViewController setValue:@"Rally Navigator - Rally Roadbook Reader for iOS" forKey:@"subject"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            activityViewController.popoverPresentationController.sourceView = self.view;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityViewController animated:YES completion:nil];
        });
    } break;

    default:
        break;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SettingsCell* cell;
    switch (indexPath.row) {

    case UserConfigSettings: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsNavigationCell"];
        cell.lblNavigationTitle.text = @"SETTINGS";
        cell.lblNavigationTitle.textColor = UIColor.redColor;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:32.0f]];
            [cell.btnCloseWindow setImage:[UIImage imageNamed:@"cross_x"] forState:UIControlStateNormal];
            cell.btnCloseWindow.contentEdgeInsets = UIEdgeInsetsZero;
        }
        [cell.btnCloseWindow setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [cell.btnCloseWindow setHidden:false];
        cell.redBordeer.backgroundColor = UIColor.redColor;
        cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.f, CGFLOAT_MAX);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } break;

    case UserConfigNavigation: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsNavigationCell"];
        cell.lblNavigationTitle.text = @"My Roadbooks";
        cell.lblNavigationTitle.textColor = themeTextColor;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:32.0f]];
            [cell.btnCloseWindow setImage:[UIImage imageNamed:@"cross_x"] forState:UIControlStateNormal];
            cell.btnCloseWindow.contentEdgeInsets = UIEdgeInsetsZero;
        }
        [cell.btnCloseWindow setTitleColor:themeTextColor forState:UIControlStateNormal];
        [cell.btnCloseWindow setHidden:true];
        cell.redBordeer.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } break;

    case UserConfigTypeMobileUse: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.lblNavigationTitle.text = @"Mobile App – How it Works";
        if (SCREEN_WIDTH >= 768) {
            [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:26.0f]];
        }
        cell.lblNavigationTitle.textColor = themeTextColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } break;

    case UserConfigTypeShareApplication: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.lblNavigationTitle.text = @"Share Rally Roadbook Reader App";
        cell.lblNavigationTitle.textColor = themeTextColor;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:26.0f]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } break;

    case UserConfigTypeShareRoadbook: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.lblNavigationTitle.text = @"Share Active Roadbook";
        if (SCREEN_WIDTH >= 768) {
            [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:26.0f]];
        }
        cell.lblNavigationTitle.textColor = themeTextColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } break;

    case UserConfigTypePDFFormat: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];

        [cell.btnMiles setTitle:@"Cross Country" forState:UIControlStateNormal];
        [cell.btnKilometers setTitle:@"Road Rally" forState:UIControlStateNormal];

        if (SCREEN_WIDTH >= 768) {
            [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
            [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
        }
        switch (objUserConfig.pdfFormat) {
        case PdfFormatCrossCountry: {
            [cell.btnMiles setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
        } break;

        case PdfFormatRoadRally: {
            [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        } break;

        default:
            break;
        }

        cell.btnMiles.tag = PdfFormatCrossCountry;
        cell.btnKilometers.tag = PdfFormatRoadRally;

        [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMiles addTarget:self action:@selector(btnChangePdfFormatClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers addTarget:self action:@selector(btnChangePdfFormatClicked:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    case UserConfigTypeHighlightPreference: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];

        [cell.btnMiles setTitle:@"Auto Highlight" forState:UIControlStateNormal];
        [cell.btnKilometers setTitle:@"No Highlight" forState:UIControlStateNormal];

        if (SCREEN_WIDTH >= 768) {
            [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
            [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
        }
        if (objUserConfig.highlightPdf) {
            [cell.btnMiles setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
        } else {
            [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        }

        cell.btnMiles.tag = 1;
        cell.btnKilometers.tag = 0;

        [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMiles addTarget:self action:@selector(btnChangeHighlightPreferenceClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers addTarget:self action:@selector(btnChangeHighlightPreferenceClicked:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    case UserConfigTypeDistanceUnit: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];

        [cell.btnMiles setTitle:@"Miles" forState:UIControlStateNormal];
        [cell.btnKilometers setTitle:@"Kilometers" forState:UIControlStateNormal];

        if (SCREEN_WIDTH >= 768) {
            [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
            [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
        }

        if (objUserConfig.distanceUnit == DistanceUnitsTypeKilometers) {
            [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        } else {
            [cell.btnMiles setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
        }

        cell.btnMiles.tag = DistanceUnitsTypeMiles;
        [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMiles addTarget:self action:@selector(btnChangeUnitClicked:) forControlEvents:UIControlEventTouchUpInside];

        cell.btnKilometers.tag = DistanceUnitsTypeKilometers;
        [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers addTarget:self action:@selector(btnChangeUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    case UserConfigTypeOdoDistance: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];

        [cell.btnMiles setTitle:@"0.00" forState:UIControlStateNormal];
        [cell.btnKilometers setTitle:@"00.0" forState:UIControlStateNormal];

        if (SCREEN_WIDTH >= 768) {
            [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
            [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
        }
        switch (objUserConfig.odometerUnit) {
        case OdometerUnitHundredth: {
            [cell.btnMiles setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
        } break;

        case OdometerUnitTenth: {
            [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        } break;

        default:
            break;
        }

        cell.btnMiles.tag = OdometerUnitHundredth;
        cell.btnKilometers.tag = OdometerUnitTenth;

        [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMiles addTarget:self action:@selector(btnChangeOdoUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers addTarget:self action:@selector(btnChangeOdoUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    case UserConfigTypeTheme: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];

        [cell.btnMiles setTitle:@"Dark View" forState:UIControlStateNormal];
        [cell.btnKilometers setTitle:@"Light View" forState:UIControlStateNormal];

        if (SCREEN_WIDTH >= 768) {
            [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
            [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
        }
        switch (objUserConfig.themePreference) {
        case ThemePreferenceDark: {
            [cell.btnMiles setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
        } break;

        case ThemePreferenceLight: {
            [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        } break;

        default:
            break;
        }

        cell.btnMiles.tag = ThemePreferenceDark;
        cell.btnKilometers.tag = ThemePreferenceLight;

        [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMiles addTarget:self action:@selector(btnChangeThemeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnKilometers addTarget:self action:@selector(btnChangeThemeClicked:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    case UserConfigTypeCalibrate: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCalibrationCell"];

        cell.lblCalibrate.text = @"ODO Calibration";

        if (SCREEN_WIDTH >= 768) {
            [cell.lblCalibrate setFont:[cell.lblCalibrate.font fontWithSize:26.0f]];
            [cell.lblOdoValue setFont:[cell.lblOdoValue.font fontWithSize:23.0f]];
        }
        cell.backgroundColor = themeBackGroundColor;
        cell.lblCalibrate.textColor = themeTextColor;
        cell.lblOdoValue.textColor = themeTextColor;

        cell.stepperView.value = totalDistance;

        stepperValue = totalDistance;

        if (objUserConfig.odometerUnit == OdometerUnitTenth) {
            cell.stepperView.stepValue = 0.1f;
            cell.stepperView.minimumValue = -9999.999f;
        } else {
            cell.stepperView.stepValue = 0.01f;
            cell.stepperView.minimumValue = -9999.999f;
        }

        cell.stepperView.maximumValue = 9999.999f;

        [cell.stepperView addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];

        double unit = totalDistance;
        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles) {
            unit = [self convertDistanceToMiles:unit];
        }

        NSString* strValue = [NSString stringWithFormat:unit < 10 ? @"%.1f%%" : unit < 100 ? @"%.1f%%" : @"%.1f%%", unit];
        cell.lblOdoValue.text = unit > 0 ? [@"+" stringByAppendingString:strValue] : strValue;

        NSRange range = [cell.lblOdoValue.text rangeOfString:@"^0+(?!\\.)" options:NSRegularExpressionSearch];

        if (range.length > 0) {
            cell.lblOdoValue.text = [cell.lblOdoValue.text stringByReplacingCharactersInRange:range withString:@""];
        }
    } break;

    case UserConfigTypeRotateLock: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];

        cell.lblTitle.text = @"Screen Rotate Lock";
        cell.switchConfig.on = objUserConfig.isScreenRotateLock;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
        }
        cell.lblTitle.textColor = themeTextColor;
        if (isLightView) {
            cell.switchConfig.thumbTintColor = UIColor.blackColor;
        } else {
            cell.switchConfig.thumbTintColor = UIColor.lightGrayColor;
        }
    } break;

    case UserConfigTypeSpeed: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];

        cell.lblTitle.text = @"Display Speed";
        cell.switchConfig.on = objUserConfig.isShowSpeed;
        cell.lblTitle.textColor = themeTextColor;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
        }
        if (isLightView) {
            cell.switchConfig.thumbTintColor = UIColor.blackColor;
        } else {
            cell.switchConfig.thumbTintColor = UIColor.lightGrayColor;
        }
    } break;

    case UserConfigTypeTime: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];

        cell.lblTitle.text = @"Display Time";
        cell.switchConfig.on = objUserConfig.isShowTime;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
        }
        cell.lblTitle.textColor = themeTextColor;
        if (isLightView) {
            cell.switchConfig.thumbTintColor = UIColor.blackColor;
        } else {
            cell.switchConfig.thumbTintColor = UIColor.lightGrayColor;
        }
    } break;

    case UserConfigTypeCAP: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];

        cell.lblTitle.text = @"Display CAP Heading";
        cell.switchConfig.on = objUserConfig.isShowCap;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
        }
        cell.lblTitle.textColor = themeTextColor;
        if (isLightView) {
            cell.switchConfig.thumbTintColor = UIColor.blackColor;
        } else {
            cell.switchConfig.thumbTintColor = UIColor.lightGrayColor;
        }
    } break;

    case UserConfigTypeAlert: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];

        cell.lblTitle.text = @"ODO Reset Alert";
        cell.switchConfig.on = objUserConfig.isShowAlert;
        if (SCREEN_WIDTH >= 768) {
            [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
        }
        cell.lblTitle.textColor = themeTextColor;
        if (isLightView) {
            cell.switchConfig.thumbTintColor = UIColor.blackColor;
        } else {
            cell.switchConfig.thumbTintColor = UIColor.lightGrayColor;
        }
    } break;

    case UserConfigTypeLogout: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsLogoutCell"];

        [cell.btnLogout addTarget:self action:@selector(btnLogoutClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (SCREEN_WIDTH >= 768) {
            [cell.btnLogout.titleLabel setFont:[cell.btnLogout.titleLabel.font fontWithSize:26.0f]];
        }
    } break;

    default:
        break;
    }

    cell.switchConfig.tag = indexPath.row;
    [cell.switchConfig addTarget:self action:@selector(btnSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (double)convertDistanceToMiles:(double)unit
{
    return unit * 0.621371;
}

@end
