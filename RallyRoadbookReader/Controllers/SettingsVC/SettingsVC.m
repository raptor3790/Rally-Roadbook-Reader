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

@interface SettingsVC ()
{
    BOOL isLightView;
    
    UIToolbar *toolbar;
    UIColor *themeBackGroundColor, *themeTextColor;
    
    NSMutableArray *arrEmails;
    
    UserConfig *objUserConfig;
    double totalDistance;
    double stepperValue;
}
@end

@implementation SettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    UIBarButtonItem *btnDismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDismissClicked:)];
    self.navigationItem.rightBarButtonItem = btnDismiss;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    _tblSettings.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    id object = [DefaultsValues getObjectValueFromUserDefaults_ForKey:kUserSharedEmails];
    
    arrEmails = [[NSMutableArray alloc] init];
    
    if (object)
    {
        [arrEmails addObjectsFromArray:object];
    }
    
    objUserConfig = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserConfiguration];
    
    if (objUserConfig == nil)
    {
        objUserConfig = [self getDefaultUserConfiguration];
    }
    
    totalDistance = AppContext.cal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    switch (objUserConfig.themePreference)
    {
        case ThemePreferenceDark:
        {
            isLightView = false;
        }
            break;
            
        case ThemePreferenceLight:
        {
            isLightView = true;
        }
            break;
            
        default:
            break;
    }
    
    
    if (!isLightView)
    {
        themeBackGroundColor = [UIColor blackColor];
        themeTextColor = [UIColor lightGrayColor];
    }
    else
    {
        themeBackGroundColor = [UIColor whiteColor];
        themeTextColor = [UIColor blackColor];
    }
    
    self.view.backgroundColor = themeBackGroundColor;
    [_tblSettings reloadData];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (isLightView) {
        return UIStatusBarStyleDefault;
    }
    else{
       return UIStatusBarStyleLightContent;
    }
    
}

#pragma mark - UIButton Click Events

- (IBAction)btnDismissClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if (_strRoadbookId)
    {
        if ([_delegate respondsToSelector:@selector(clickedLogout)])
        {
            [_delegate odoValueChanged:totalDistance];
            
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnSwitchClicked:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    switch (sender.tag)
    {
        case UserConfigTypeSpeed:
        {
            if (objUserConfig.isShowSpeed)
            {
                NSInteger count = objUserConfig.isShowSpeed + objUserConfig.isShowTime + objUserConfig.isShowCap;
                
                if (count == 1)
                {
                    [sender setOn:YES];
                    return;
                }
            }
            
            objUserConfig.isShowSpeed = !objUserConfig.isShowSpeed;
        }
            break;
            
        case UserConfigTypeTime:
        {
            if (objUserConfig.isShowTime)
            {
                NSInteger count = objUserConfig.isShowSpeed + objUserConfig.isShowTime + objUserConfig.isShowCap;
                
                if (count == 1)
                {
                    [sender setOn:YES];
                    return;
                }
            }

            objUserConfig.isShowTime = !objUserConfig.isShowTime;
        }
            break;
            
        case UserConfigTypeCAP:
        {
            if (objUserConfig.isShowCap)
            {
                NSInteger count = objUserConfig.isShowSpeed + objUserConfig.isShowTime + objUserConfig.isShowCap;
                
                if (count == 1)
                {
                    [sender setOn:YES];
                    return;
                }
            }

            objUserConfig.isShowCap = !objUserConfig.isShowCap;
        }
            break;
            
        case UserConfigTypeAlert:
        {
            objUserConfig.isShowAlert = !objUserConfig.isShowAlert;
        }
            break;
            
//        case UserConfigTypeTutorial:
//        {
//            objUserConfig.isShowTutorial = !objUserConfig.isShowTutorial;
//        }
//            break;
            
        default:
            break;
    }
    
    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (IBAction)btnChangeUnitClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    switch (sender.tag)
    {
        case DistanceUnitsTypeMiles:
        {
            if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles)
            {
                return;
            }
            
            objUserConfig.distanceUnit = DistanceUnitsTypeMiles;
            
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
            });
        }
            break;

        case DistanceUnitsTypeKilometers:
        {
            if (objUserConfig.distanceUnit == DistanceUnitsTypeKilometers)
            {
                return;
            }

            objUserConfig.distanceUnit = DistanceUnitsTypeKilometers;
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            });
        }
            break;

        default:
            break;
    }
    
    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (IBAction)btnChangeOdoUnitClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    switch (sender.tag)
    {
        case OdometerUnitHundredth:
        {
            if (objUserConfig.odometerUnit == OdometerUnitHundredth)
            {
                return;
            }
            
            objUserConfig.odometerUnit = OdometerUnitHundredth;
            
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
            });
            
            [self.tblSettings beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:UserConfigTypeCalibrate inSection:0];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [self.tblSettings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tblSettings endUpdates];
        }
            break;
            
        case OdometerUnitTenth:
        {
            if (objUserConfig.odometerUnit == OdometerUnitTenth)
            {
                return;
            }
            
            objUserConfig.odometerUnit = OdometerUnitTenth;
            
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            });
            
            [self.tblSettings beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:UserConfigTypeCalibrate inSection:0];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [self.tblSettings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tblSettings endUpdates];
        }
            break;
            
        default:
            break;
    }
    
    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (IBAction)btnChangePdfFormatClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    switch (sender.tag)
    {
        case PdfFormatCrossCountry:
        {
            if (objUserConfig.pdfFormat == PdfFormatCrossCountry)
            {
                return;
            }
            
            objUserConfig.pdfFormat = PdfFormatCrossCountry;
            
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
            });
        }
            break;
            
        case PdfFormatRoadRally:
        {
            if (objUserConfig.pdfFormat == PdfFormatRoadRally)
            {
                return;
            }
            
            objUserConfig.pdfFormat = PdfFormatRoadRally;
            
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            });
        }
            break;
            
        default:
            break;
    }
    
    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (IBAction)btnChangeHighlightPreferenceClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (sender.tag == 1)
    {
        if (objUserConfig.highlightPdf)
        {
            return;
        }
        
        objUserConfig.highlightPdf = !objUserConfig.highlightPdf;
        
        SettingsCell *cell =
        (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
        });
    }
    else
    {
        if (!objUserConfig.highlightPdf)
        {
            return;
        }
        
        objUserConfig.highlightPdf = !objUserConfig.highlightPdf;
        
        SettingsCell *cell =
        (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
        });
    }
    
    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
}

- (IBAction)btnChangeThemeClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    switch (sender.tag)
    {
        case ThemePreferenceDark:
        {
            if (objUserConfig.themePreference == ThemePreferenceDark)
            {
                return;
            }
            
            objUserConfig.themePreference = ThemePreferenceDark;
            isLightView = false;
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
            });

        }
            break;
            
        case ThemePreferenceLight:
        {
            if (objUserConfig.themePreference == ThemePreferenceLight)
            {
                return;
            }
            
            objUserConfig.themePreference = ThemePreferenceLight;
            isLightView = true;
            
            SettingsCell *cell =
            (SettingsCell *)[self getCellForClassName:NSStringFromClass([SettingsCell class]) withSender:sender];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
            });
        }
            break;
            
        default:
            break;
    }
    
    if (!isLightView){
        themeBackGroundColor = [UIColor blackColor];
        themeTextColor = [UIColor lightGrayColor];
    }
    else{
        themeBackGroundColor = [UIColor whiteColor];
        themeTextColor = [UIColor blackColor];
    }
    [self.tblSettings reloadData];
    [DefaultsValues setCustomObjToUserDefaults:objUserConfig ForKey:kUserConfiguration];
    
    if (isLightView) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    else{
        [self.view setBackgroundColor:[UIColor blackColor]];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)btnLogoutClicked:(id)sender
{
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(clickedLogout)])
        {
            [self dismissViewControllerAnimated:YES completion:^{
                [_delegate clickedLogout];
                if (_strRoadbookId) {
                    if ([_delegate respondsToSelector:@selector(clickedLogout)])
                    {
                        [_delegate odoValueChanged:totalDistance];
                    }
                }
            }];
        }
    });
}


#pragma mark -

- (void)setUpTextField:(UITextField *)textField
{
    textField.placeholder = @"Enter your email address here";
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.tintColor = RGB(85, 85, 85);
    [textField addTarget:self action:@selector(textFieldTextDidChanged:)
        forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
    
    if (!toolbar)
    {
        toolbar = [[UIToolbar alloc] init];
        toolbar.tintColor = [UIColor blackColor];
        [toolbar sizeToFit];
    }
    
    textField.inputAccessoryView = toolbar;
}

- (void)textFieldTextDidChanged:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    UIAlertAction *btnReset = alertController.actions.lastObject;
    if (alertController)
    {
        btnReset.enabled = [sender.text isValidEmail];
    }
    
    if (arrEmails)
    {
        if (arrEmails.count > 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", sender.text];
            NSArray *results = [arrEmails filteredArrayUsingPredicate:predicate];
            
            NSMutableArray<NSString *> *arrSuggestions = [[NSMutableArray alloc] initWithCapacity:2];
            [arrSuggestions addObjectsFromArray:results];
            
            NSMutableArray<UIBarButtonItem *> *arrItems = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < arrSuggestions.count; i++)
            {
                [arrItems addObject:[[UIBarButtonItem alloc] initWithTitle:arrSuggestions[i] style:UIBarButtonItemStylePlain target:self action:@selector(clickedOnToolBar:)]];
                if (arrItems.count == 2)
                    break;
            }
            
            toolbar.items = arrItems;
        }
    }
}

- (IBAction)clickedOnToolBar:(UIBarButtonItem *)sender
{
    NSString *strEmail = sender.title;
    
    if (self.presentedViewController)
    {
        id obj = self.presentedViewController;
        
        if ([obj isKindOfClass:[UIAlertController class]])
        {
            UIAlertController *alert = (UIAlertController *)obj;
            if (alert.textFields.count > 0)
            {
                alert.textFields.firstObject.text = strEmail;
                UIAlertAction *btnReset = alert.actions.lastObject;
                btnReset.enabled = [alert.textFields.firstObject.text isValidEmail];
            }
        }
    }
}

- (void)shareRoadbookForEmailID:(NSString *)strEmail
{
    if (!arrEmails)
    {
        arrEmails = [[NSMutableArray alloc] init];
    }

    if ([arrEmails containsObject:strEmail])
    {
        if (arrEmails.firstObject != strEmail)
        {
            NSInteger index = [arrEmails indexOfObject:strEmail];
            [arrEmails exchangeObjectAtIndex:index withObjectAtIndex:0];
        }
    }
    else
    {
        if (arrEmails.count > 4)
        {
            [arrEmails removeLastObject];
        }
        
        [arrEmails insertObject:strEmail atIndex:0];
    }
    
    [DefaultsValues setObjectValueToUserDefaults:arrEmails ForKey:kUserSharedEmails];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:_strRoadbookId forKey:@"route_id"];
    [dicParam setValue:@[strEmail] forKey:@"emails"];
    
    NSMutableDictionary *dicShare = [[NSMutableDictionary alloc] init];
    [dicShare setObject:dicParam forKey:@"share"];
    
    [[WebServiceConnector alloc] init:@"https://rallynavigator-staging.herokuapp.com/api/v1/folders/share_reader_roadbook"
                       withParameters:dicShare
                           withObject:self
                         withSelector:@selector(handleShareResponse:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (IBAction)handleShareResponse:(id)sender
{
    NSDictionary *dic = [sender responseDict];
    
    if ([[dic valueForKey:SUCCESS_STATUS] boolValue])
    {
        [SVProgressHUD showSuccessWithStatus:@"Roadbook has been shared successfully"];
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:@"Sharing has been failed"];
    }
}

- (IBAction)stepperChanged:(UIStepper *)sender {

    //printf("Stepper value :::::::: %f",sender.value);

    if(sender.value > stepperValue)
    {
//        if (objUserConfig.odometerUnit == OdometerUnitTenth)
//        {
            totalDistance += 0.10f;//(objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f/0.621371 : 0.10f);
//        }
//        else
//        {
//            totalDistance += 0.01f;//(objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f/0.621371 : 0.01f);
//        }
    }
    else{
//        if (objUserConfig.odometerUnit == OdometerUnitTenth)
//        {
            totalDistance -= 0.10f;//(objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.10f/0.621371 : 0.10f);
//        }
//        else
//        {
//            totalDistance -= 0.01f;//(objUserConfig.distanceUnit == DistanceUnitsTypeMiles ? 0.01f/0.621371 : 0.01f);
//        }
    }
    
//    if (totalDistance <= 0)
//    {
//        totalDistance = 0.0f;
//    }
    
    stepperValue = sender.value;
    AppContext.cal = totalDistance;
    
    NSLog(@"%f", AppContext.cal);
    
    id superView = [sender superview];
    
    superView = [superView superview];
    
    if ([superView isKindOfClass:[SettingsCell class]])
    {
        SettingsCell *cell = (SettingsCell *)superView;
        
        double unit = totalDistance;
        if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles)
        {
            unit = [self convertDistanceToMiles:unit];
        }
        NSString *strValue = [NSString stringWithFormat:unit < 10 ? @"%.1f%%" : unit < 100 ? @"%.1f%%" : @"%.1f%%", unit];
        cell.lblOdoValue.text = unit > 0 ? [@"+" stringByAppendingString:strValue]: strValue;
        NSRange range = [cell.lblOdoValue.text rangeOfString:@"^0+(?!\\.)" options:NSRegularExpressionSearch];
        
        if(range.length > 0)
        {
            cell.lblOdoValue.text = [cell.lblOdoValue.text stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    

//    [self.tblSettings beginUpdates];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:UserConfigTypeCalibrate inSection:0];
//    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
//    [self.tblSettings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//    [self.tblSettings endUpdates];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == UserConfigTypeShareRoadbook && !_strRoadbookId)
    {
        return 0.00f;
    }
    
    /*if (indexPath.row == UserConfigTypeCalibrate && !_strRoadbookId)
    {
        return 0.00f;
    }*/
    
    return UITableViewAutomaticDimension;
    
    /*switch (indexPath.row)
    {
        case UserConfigTypeShareRoadbook:
        case UserConfigTypeHighlightPreference:
        case UserConfigTypeTheme:
        case UserConfigTypePDFFormat:
        case UserConfigTypeDistanceUnit:
        case UserConfigTypeOdoDistance:
        case UserConfigTypeLogout:
        {
            return UITableViewAutomaticDimension;
            if (SCREEN_WIDTH >= 768){
                return 70.0f;
            }
            return 65.0f;
        }
            break;
            
        case UserConfigNavigation:
        case UserConfigSettings:
        case UserConfigTypeMobileUse:
        {
            return UITableViewAutomaticDimension;
        }
            break;
            
        default:
            break;
    }
    
    return 55.0f;*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case UserConfigNavigation:
        {
            [self.view endEditing:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(clickedRoadbooks)])
                {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [_delegate clickedRoadbooks];
                    }];
                    if (_strRoadbookId) {
                        if ([_delegate respondsToSelector:@selector(clickedLogout)])
                        {
                            [_delegate odoValueChanged:totalDistance];
                            
                        }
                    }
                }
            });
        }
            break;
            
        case UserConfigTypeShareRoadbook:
        {
            [self.view endEditing:YES];
            
            if (_strRoadbookId)
            {
                /*UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Pick Sharing Method"
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
                
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                }]];
                
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Share Through Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {*/
                    
                    NSString *strAlertMsg = @"Please enter your email address";
                    
                    UIAlertController *alertController =
                    [UIAlertController alertControllerWithTitle:@"Email Address"
                                                        message:strAlertMsg
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                        [self setUpTextField:textField];
                    }];
                    
                    UIAlertAction *btnReset =
                    [UIAlertAction actionWithTitle:@"Send"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               [self.view endEditing:YES];
                                               NSString *strEmail = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                                               [self shareRoadbookForEmailID:strEmail];
                                           }];
                    
                    UIAlertAction *btnCancel =
                    [UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleDefault
                                           handler:nil];
                    
                    btnReset.enabled = NO;
                    
                    [alertController addAction:btnCancel];
                    [alertController addAction:btnReset];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alertController animated:YES completion:nil];
                    });
                
                /*}]];
                
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Share Through Peer to Peer" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [SVProgressHUD showInfoWithStatus:@"Currently work is under progress"];
                }]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:actionSheet animated:YES completion:nil];
                });*/
            }
        }
            break;
            
        case UserConfigTypeMobileUse:
        {
            [self.view endEditing:YES];
            
            HowToUseVC *vc = loadViewController(StoryBoard_Settings, kIDHowToUseVC);
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;

        case UserConfigTypeShareApplication:
        {
            [self.view endEditing:YES];
            
            NSString *strDetails = @"Join the Rally Revolution.\n\nRally Navigator - Rally Roadbook Reader\n\nLearn more at https://www.rallynavigator.com\n\nDownload Application: https://itunes.apple.com\n\niOS Mobile app Offers Complete Roadbook Rally Navigation Dash for iPad or iPhone: Roadbook, Adjustable Odometer and Compass Heading Display. Load a Roadbook and GO!\n\nRally Navigator Desktop Software Streamlines the Process of Creating Rally Navigation Roadbooks.\n\nDesign your Route, add Waypoint Details and Print FIM & FIA Specification Rally Roadbooks for Cross Country and Road Rally events.\n\nCreate. Share. Rally";

            NSArray *dataToShare = @[strDetails];
            UIActivityViewController *activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
            activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
            [activityViewController setValue:@"Rally Navigator - Rally Roadbook Reader for iOS" forKey:@"subject"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                activityViewController.popoverPresentationController.sourceView = self.view;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:activityViewController animated:YES completion:nil];
            });
        }
            break;

        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell;
    switch (indexPath.row)
    {
            
        case UserConfigSettings:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsNavigationCell"];
            cell.lblNavigationTitle.text = @"SETTINGS";
            cell.lblNavigationTitle.textColor = [UIColor redColor];
            if (SCREEN_WIDTH >= 768){
                [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:32.0f]];
            }
            [cell.btnCloseWindow setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [cell.btnCloseWindow setHidden:false];
            cell.redBordeer.backgroundColor = [UIColor redColor];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.f, CGFLOAT_MAX);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
            
        case UserConfigNavigation:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsNavigationCell"];
            cell.lblNavigationTitle.text = @"My Roadbooks";
            cell.lblNavigationTitle.textColor = themeTextColor;
            if (SCREEN_WIDTH >= 768){
                [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:32.0f]];
            }
            [cell.btnCloseWindow setHidden:true];
            cell.redBordeer.backgroundColor = [UIColor clearColor];
//            [cell.btnCloseWindow setTitleColor:themeTextColor forState:UIControlStateNormal];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
            
        case UserConfigTypeShareRoadbook:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
            cell.lblNavigationTitle.text = @"Share Active Roadbook";
            if (SCREEN_WIDTH >= 768){
                [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:26.0f]];
            }
            cell.lblNavigationTitle.textColor = themeTextColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
            
        case UserConfigTypeSpeed:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            
            cell.lblTitle.text = @"Display Speed";
            cell.switchConfig.on = objUserConfig.isShowSpeed;
            cell.lblTitle.textColor = themeTextColor;
            if (SCREEN_WIDTH >= 768){
                [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
            }
            if (isLightView) {
                cell.switchConfig.thumbTintColor = [UIColor blackColor];
            }
            else{
                cell.switchConfig.thumbTintColor = [UIColor lightGrayColor];
            }
        }
            break;
            
        case UserConfigTypeTime:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            
            cell.lblTitle.text = @"Display Time";
            cell.switchConfig.on = objUserConfig.isShowTime;
            if (SCREEN_WIDTH >= 768){
                [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
            }
            cell.lblTitle.textColor = themeTextColor;
            if (isLightView) {
                cell.switchConfig.thumbTintColor = [UIColor blackColor];
            }
            else{
                cell.switchConfig.thumbTintColor = [UIColor lightGrayColor];
            }
        }
            break;
            
        case UserConfigTypeCAP:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            
            cell.lblTitle.text = @"Display CAP Heading";
            cell.switchConfig.on = objUserConfig.isShowCap;
            if (SCREEN_WIDTH >= 768){
                [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
            }
            cell.lblTitle.textColor = themeTextColor;
            if (isLightView) {
                cell.switchConfig.thumbTintColor = [UIColor blackColor];
            }
            else{
                cell.switchConfig.thumbTintColor = [UIColor lightGrayColor];
            }
        }
            break;
            
        case UserConfigTypeAlert:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            
            cell.lblTitle.text = @"ODO Reset Alert";
            cell.switchConfig.on = objUserConfig.isShowAlert;
            if (SCREEN_WIDTH >= 768){
                [cell.lblTitle setFont:[cell.lblTitle.font fontWithSize:26.0f]];
            }
            cell.lblTitle.textColor = themeTextColor;
            if (isLightView) {
                cell.switchConfig.thumbTintColor = [UIColor blackColor];
            }
            else{
                cell.switchConfig.thumbTintColor = [UIColor lightGrayColor];
            }
        }
            break;
            
//        case UserConfigTypeTutorial:
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
//
//            cell.lblTitle.text = @"Show Tutorial";
//            cell.switchConfig.on = objUserConfig.isShowTutorial;
//
//            cell.lblTitle.textColor = themeTextColor;
//            if (isLightView) {
//                cell.switchConfig.thumbTintColor = [UIColor blackColor];
//            }
//            else{
//                cell.switchConfig.thumbTintColor = [UIColor lightGrayColor];
//            }
//        }
//            break;
            
        case UserConfigTypeMobileUse:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
            cell.lblNavigationTitle.text = @"Mobile App – How it Works";
            if (SCREEN_WIDTH >= 768){
                [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:26.0f]];
            }
            cell.lblNavigationTitle.textColor = themeTextColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
            
        case UserConfigTypeHighlightPreference:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];
            
            [cell.btnMiles setTitle:@"Auto Highlight" forState:UIControlStateNormal];
            [cell.btnKilometers setTitle:@"No Highlight" forState:UIControlStateNormal];
            
            if (SCREEN_WIDTH >= 768){
                [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
                [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
            }
            if (objUserConfig.highlightPdf)
            {
                [cell.btnMiles setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
                [cell.btnKilometers setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
            
            cell.btnMiles.tag = 1;
            cell.btnKilometers.tag = 0;
            
            [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnMiles addTarget:self action:@selector(btnChangeHighlightPreferenceClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers addTarget:self action:@selector(btnChangeHighlightPreferenceClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case UserConfigTypeTheme:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];
            
            [cell.btnMiles setTitle:@"Dark View" forState:UIControlStateNormal];
            [cell.btnKilometers setTitle:@"Light View" forState:UIControlStateNormal];
            
            if (SCREEN_WIDTH >= 768){
                [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
                [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
            }
            switch (objUserConfig.themePreference)
            {
                case ThemePreferenceDark:
                {
                    [cell.btnMiles setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
                }
                    break;
                    
                case ThemePreferenceLight:
                {
                    [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.btnMiles.tag = ThemePreferenceDark;
            cell.btnKilometers.tag = ThemePreferenceLight;
            
            [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnMiles addTarget:self action:@selector(btnChangeThemeClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers addTarget:self action:@selector(btnChangeThemeClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case UserConfigTypePDFFormat:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];
            
            [cell.btnMiles setTitle:@"Cross Country" forState:UIControlStateNormal];
            [cell.btnKilometers setTitle:@"Road Rally" forState:UIControlStateNormal];
            
            if (SCREEN_WIDTH >= 768){
                [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
                [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
            }
            switch (objUserConfig.pdfFormat)
            {
                case PdfFormatCrossCountry:
                {
                    [cell.btnMiles setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
                }
                    break;
                    
                case PdfFormatRoadRally:
                {
                    [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.btnMiles.tag = PdfFormatCrossCountry;
            cell.btnKilometers.tag = PdfFormatRoadRally;
            
            [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnMiles addTarget:self action:@selector(btnChangePdfFormatClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers addTarget:self action:@selector(btnChangePdfFormatClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case UserConfigTypeDistanceUnit:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];
            
            [cell.btnMiles setTitle:@"Miles" forState:UIControlStateNormal];
            [cell.btnKilometers setTitle:@"Kilometers" forState:UIControlStateNormal];
            
            if (SCREEN_WIDTH >= 768)
            {
                [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
                [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
            }
            
            switch (objUserConfig.distanceUnit)
            {
                case DistanceUnitsTypeKilometers:
                {
                    [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                    break;
                    
                case DistanceUnitsTypeMiles:
                {
                    [cell.btnMiles setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.btnMiles.tag = DistanceUnitsTypeMiles;
            cell.btnKilometers.tag = DistanceUnitsTypeKilometers;
            
            [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnMiles addTarget:self action:@selector(btnChangeUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers addTarget:self action:@selector(btnChangeUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case UserConfigTypeOdoDistance:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];
            
            [cell.btnMiles setTitle:@"00.00" forState:UIControlStateNormal];
            [cell.btnKilometers setTitle:@"000.0" forState:UIControlStateNormal];
            
            if (SCREEN_WIDTH >= 768){
                [cell.btnMiles.titleLabel setFont:[cell.btnMiles.titleLabel.font fontWithSize:26.0f]];
                [cell.btnKilometers.titleLabel setFont:[cell.btnKilometers.titleLabel.font fontWithSize:26.0f]];
            }
            switch (objUserConfig.odometerUnit)
            {
                case OdometerUnitHundredth:
                {
                    [cell.btnMiles setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:themeTextColor forState:UIControlStateNormal];
                }
                    break;
                    
                case OdometerUnitTenth:
                {
                    [cell.btnMiles setTitleColor:themeTextColor forState:UIControlStateNormal];
                    [cell.btnKilometers setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.btnMiles.tag = OdometerUnitHundredth;
            cell.btnKilometers.tag = OdometerUnitTenth;
            
            [cell.btnMiles removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [cell.btnMiles addTarget:self action:@selector(btnChangeOdoUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnKilometers addTarget:self action:@selector(btnChangeOdoUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case UserConfigTypeShareApplication:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
            cell.lblNavigationTitle.text = @"Share Rally Roadbook Reader App";
            cell.lblNavigationTitle.textColor = themeTextColor;
            if (SCREEN_WIDTH >= 768){
                [cell.lblNavigationTitle setFont:[cell.lblNavigationTitle.font fontWithSize:26.0f]];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
            
        case UserConfigTypeLogout:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsLogoutCell"];
            
            [cell.btnLogout addTarget:self action:@selector(btnLogoutClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (SCREEN_WIDTH >= 768){
                [cell.btnLogout.titleLabel setFont:[cell.btnLogout.titleLabel.font fontWithSize:26.0f]];
            }
        }
            break;
        case UserConfigTypeCalibrate:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCalibrationCell"];
            
            cell.lblCalibrate.text = @"ODO Calibration";
            
            if (SCREEN_WIDTH >= 768)
            {
                [cell.lblCalibrate setFont:[cell.lblCalibrate.font fontWithSize:26.0f]];
                [cell.lblOdoValue setFont:[cell.lblOdoValue.font fontWithSize:23.0f]];
            }
            cell.backgroundColor = themeBackGroundColor;
            cell.lblCalibrate.textColor = themeTextColor;
            cell.lblOdoValue.textColor = themeTextColor;
            
            cell.stepperView.value = totalDistance;
            
            stepperValue = totalDistance;
            
            if (objUserConfig.odometerUnit == OdometerUnitTenth)
            {
                cell.stepperView.stepValue = 0.1f;
                cell.stepperView.minimumValue = -9999.999f;
            }
            else
            {
                cell.stepperView.stepValue = 0.01f;
                cell.stepperView.minimumValue = -9999.999f;
            }
            
            cell.stepperView.maximumValue = 9999.999f;
            
            [cell.stepperView addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
            
            double unit = totalDistance;
            if (objUserConfig.distanceUnit == DistanceUnitsTypeMiles)
            {
                unit = [self convertDistanceToMiles:unit];
            }
            
//            if (objUserConfig.odometerUnit == OdometerUnitHundredth)
//            {
//                NSString *strValue = [NSString stringWithFormat:unit >= 10 ? @"%.2f%%" : @"%.2f%%", unit];
//                cell.lblOdoValue.text = unit > 0 ? [@"+" stringByAppendingString:strValue]: strValue;
//            }
//            else
//            {
                NSString *strValue = [NSString stringWithFormat:unit < 10 ? @"%.1f%%" : unit < 100 ? @"%.1f%%" : @"%.1f%%", unit];
                cell.lblOdoValue.text = unit > 0 ? [@"+" stringByAppendingString:strValue]: strValue;
//            }
            
            NSRange range = [cell.lblOdoValue.text rangeOfString:@"^0+(?!\\.)" options:NSRegularExpressionSearch];
            
            if(range.length > 0)
            {
                cell.lblOdoValue.text = [cell.lblOdoValue.text stringByReplacingCharactersInRange:range withString:@""];
            }
            //
            
//            if ([cell.lblOdoValue.text isEqualToString:@"0.0"])
//            {
//                cell.lblOdoValue.text = @"0.0";
//            }
            
        }
            break;
            
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
