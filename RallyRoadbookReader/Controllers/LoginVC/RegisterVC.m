//
//  RegisterVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 17/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "RegisterVC.h"
#import "RoadbooksVC.h"
#import <Crashlytics/Crashlytics.h>

@import GoogleSignIn;

@interface RegisterVC () <GIDSignInDelegate, GIDSignInUIDelegate, UITextFieldDelegate> {
}
@end

@implementation RegisterVC

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapRecognizer];
    self.view.backgroundColor = UIColor.blackColor;

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)getOrientation
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Handling Method

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == _emailText) {
        [_userNameText becomeFirstResponder];
    } else if (textField == _userNameText) {
        [_passwordText becomeFirstResponder];
    } else if (textField == _passwordText) {
        [_confirmPasswordText becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}

#pragma mark - Google Delegate Method

- (void)signIn:(GIDSignIn*)signIn didSignInForUser:(GIDGoogleUser*)user withError:(NSError*)error
{
    NSString* strUserId = user.userID;
    NSString* strAuthToken = user.authentication.accessToken;
    NSString* strFullName = user.profile.name;
    NSString* strEmail = user.profile.email;

    if (!error) {
        NSMutableDictionary* dicAuth = [[NSMutableDictionary alloc] init];

        NSMutableDictionary* dicInfo = [[NSMutableDictionary alloc] init];
        [dicInfo setValue:strEmail forKey:@"email"];
        [dicInfo setValue:strFullName forKey:@"name"];

        [dicAuth setValue:dicInfo forKey:@"info"];
        [dicAuth setValue:strUserId forKey:@"uid"];

        NSMutableDictionary* dicCredentials = [[NSMutableDictionary alloc] init];
        [dicCredentials setValue:strAuthToken forKey:@"token"];

        [dicAuth setValue:dicCredentials forKey:@"credentials"];

        [dicAuth setValue:@"google_oauth2" forKey:@"provider"];

        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setValue:dicAuth forKey:@"auth"];
        [dicParam setValue:@YES forKey:@"send_email"];

        _loginType = LoginTypeGoogle;

        [[WebServiceConnector alloc] init:URLSocialLogin
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleLoginResponse:)
                           forServiceType:ServiceTypeJSON
                           showDisplayMsg:@""
                               showLoader:YES];
    }
}

#pragma mark - Validation

- (BOOL)validateInput
{
    if ([_emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [AlertManager alert:@"Please Enter Email Address" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if (![[_emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isValidEmail]) {
        [AlertManager alert:@"Please Enter Valid Email Address" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if ([_userNameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [AlertManager alert:@"Please Enter User Name" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if (![[_userNameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isValidName]) {
        [AlertManager alert:@"Please Enter Valid User Name" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if ([_passwordText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [AlertManager alert:@"Please Enter Password" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if (![_passwordText.text isValidPassword]) {
        [AlertManager alert:@"Password Must Be Between 6-32 Characters" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if ([_confirmPasswordText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [AlertManager alert:@"Please Enter Confirm Password" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if (![_passwordText.text isEqualToString:_confirmPasswordText.text]) {
        [AlertManager alert:@"Password and Confirm Password must be same" title:NULL imageName:@"ic_error"];
        return NO;
    }

    return YES;
}

#pragma mark - Button Click Events

- (IBAction)btnSignInGoogleClicked:(id)sender
{
    [self.view endEditing:YES];

    GIDSignIn* signInGoogle = [GIDSignIn sharedInstance];
    [signInGoogle setScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/plus.login"]];
    signInGoogle.delegate = self;
    signInGoogle.uiDelegate = self;
    [signInGoogle signIn];
}

- (void)handleLoginResponse:(id)sender
{
    NSString* strLoginType = _loginType == LoginTypeGoogle ? @"Google" : @"Normal";
    NSDictionary* dic = [sender responseDict];
    NSArray* arrResponse = [dic valueForKey:LoginKey] && [[dic valueForKey:SUCCESS_STATUS] boolValue] ? [sender responseArray] : @[];
    [Answers logSignUpWithMethod:strLoginType success:@(arrResponse.count > 0) customAttributes:@{}];

    if (arrResponse.count > 0) {
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDFolders class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoutes class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoute class])];

        User* objUser = [arrResponse firstObject];

        if (objUser.config == nil) {
            objUser.config = @"{\"action\":\"{\\\"autoPhoto\\\":false,\\\"voiceToText\\\":true,\\\"takePicture\\\":true,\\\"voiceRecorder\\\":true,\\\"waypointOnly\\\":true,\\\"text\\\":true}\",\"unit\":\"Kilometers\",\"rotation\":{\"value\":\"1\"},\"sync\":\"2\",\"odo\":\"00.00\",\"autoCamera\":true,\"accuracy\":{\"minDistanceTrackpoint\":50,\"angle\":1,\"accuracy\":50,\"distance\":3}}";
        }

        UserConfig* objConfig = [[UserConfig alloc] init];
        objConfig.isShowCap = YES;
        objConfig.isShowSpeed = YES;
        objConfig.isShowTime = YES;
        objConfig.isShowAlert = YES;
        objConfig.isShowTutorial = YES;
        objConfig.distanceUnit = DistanceUnitsTypeKilometers;
        objConfig.cal = 0.00f;
        [DefaultsValues setCustomObjToUserDefaults:objConfig ForKey:kUserConfiguration];

        [DefaultsValues setCustomObjToUserDefaults:objUser ForKey:kUserObject];
        [DefaultsValues setBooleanValueToUserDefaults:YES ForKey:kLogIn];
        [DefaultsValues setStringValueToUserDefaults:_passwordText.text ForKey:kUserPassword];

        RoadbooksVC* vc = loadViewController(StoryBoard_Roadbooks, kIDRoadbooksVC);
        vc.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:vc animated:NO];

    } else {
        NSDictionary* dicResponse = [sender responseDict];
        BOOL isStatusFalse = [dicResponse objectForKey:SUCCESS_STATUS] && ![[dicResponse valueForKey:SUCCESS_STATUS] boolValue];
        if (isStatusFalse && [dicResponse objectForKey:ERROR_CODE]) {
            NSInteger errorCode = [[dicResponse valueForKey:ERROR_CODE] integerValue];
            [AlertManager alert:[RallyNavigatorConstants getErrorForErrorCode:errorCode] title:@"Error" imageName:@"ic_error"];
        }
    }
}

- (IBAction)btnAlreadyAccountClicked:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSignUpClick:(id)sender
{
    [self.view endEditing:YES];

    if ([self validateInput]) {
        NSMutableDictionary* dicUser = [[NSMutableDictionary alloc] init];
        [dicUser setValue:_emailText.text forKey:@"email"];
        [dicUser setValue:_userNameText.text forKey:@"username"];
        [dicUser setValue:_passwordText.text forKey:@"password"];
        [dicUser setValue:_confirmPasswordText.text forKey:@"password_confirmation"];

        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setValue:dicUser forKey:@"user"];

        _loginType = LoginTypeNormal;

        [[WebServiceConnector alloc] init:URLSignUp
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleLoginResponse:)
                           forServiceType:ServiceTypeJSON
                           showDisplayMsg:@""
                               showLoader:YES];
    }
}

- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - UITableView Delegate Methods

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        if (UIScreen.mainScreen.bounds.size.width == 320 && UIScreen.mainScreen.bounds.size.width < UIScreen.mainScreen.bounds.size.height) {
            return 140;
        } else {
            return UIScreen.mainScreen.bounds.size.height * 0.33;
        }
    }

    return UITableViewAutomaticDimension;
}

@end
