//
//  LoginVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "LoginVC.h"
#import "RegisterVC.h"
#import "RoutesVC.h"
#import "RoadbooksVC.h"
#import <FBSDKLoginKit.h>
#import <FBSDKCoreKit.h>
#import <Crashlytics/Crashlytics.h>

@import GoogleSignIn;

static const int HEIGHT_DESCRIPTION_CELL = 104;
static const int HEIGHT_LOGIN_INFO_CELL = 126;
static const int HEIGHT_ACTIONS_CELL = 35;
static const int HEIGHT_FORGOT_PASSWORD_CELL = 46;
static const int HEIGHT_SOCIAL_LOGIN_CELL = 80;

@interface LoginVC () <GIDSignInDelegate, GIDSignInUIDelegate> {
    BOOL isSignUp;

    CGFloat heightLogoCell, height_Logo;
}
@end

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapRecognizer];

    AppContext.locationManager = [LocationManager sharedManager];
    [AppContext.locationManager startStandardUpdates];

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kLogIn]) {
        RoadbooksVC* vc = loadViewController(StoryBoard_Roadbooks, kIDRoadbooksVC);
        vc.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:vc animated:NO];
        //        [self setNeedsStatusBarAppearanceUpdate];

        [SyncManager.shared startSync];
    } else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (!isSignUp) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        isSignUp = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - KeyBoard Handling Methods

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    _bottomTblLogin.constant = kbSize.height;
    [self.view layoutIfNeeded];

    [_tblLogin scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:LoginCellTypeLoginInfo inSection:0]
                     atScrollPosition:UITableViewScrollPositionTop
                             animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    _bottomTblLogin.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - Validation

- (BOOL)validateUserInput
{
    if (_strEmail.length == 0) {
        [AlertManager alert:@"Please Enter Email Address" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if (![_strEmail isValidEmail]) {
        [AlertManager alert:@"Please Enter Valid Email Address" title:NULL imageName:@"ic_error"];
        return NO;
    }

    if (_strPassword.length == 0) {
        [AlertManager alert:@"Please Enter Password" title:NULL imageName:@"ic_error"];
        return NO;
    }

    return YES;
}

#pragma mark -

- (int)SetSmallFont
{
    int originalSmallFontSize = 14;

    if (SCREEN_WIDTH == 320) {
        // iPhone SE / 5s
        return originalSmallFontSize;
    } else if (SCREEN_WIDTH == 375) {
        // iPhone 6 / 8 / X
        return originalSmallFontSize + 3;
    } else if (SCREEN_WIDTH == 414) {
        // iPhone 8 Plus
        return originalSmallFontSize + 5;
    } else if (SCREEN_WIDTH == 768 || SCREEN_WIDTH == 834 || SCREEN_WIDTH == 1024) {
        return originalSmallFontSize + 7;
    }

    return originalSmallFontSize;
}

- (int)SetBigFont
{
    int originalBigFontSize = 20;

    if (SCREEN_WIDTH == 320) {
        // iPhone SE / 5s
        return originalBigFontSize;
    } else if (SCREEN_WIDTH == 375) {
        // iPhone 6 / 8 / X
        return originalBigFontSize + 3;
    } else if (SCREEN_WIDTH == 414) {
        // iPhone 8 Plus
        return originalBigFontSize + 5;
    } else if (SCREEN_WIDTH == 768 || SCREEN_WIDTH == 834 || SCREEN_WIDTH == 1024) {
        return originalBigFontSize + 7;
    }

    return originalBigFontSize;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField.tag == 3001) {
        UITableViewCell* cell = [_tblLogin cellForRowAtIndexPath:[NSIndexPath indexPathForRow:LoginCellTypeLoginInfo inSection:0]];
        [[cell.contentView viewWithTag:3002] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}

- (void)updateLabelUsingContentsOfTextField:(id)sender
{
    UITextField* txtInfo = (UITextField*)sender;

    switch (txtInfo.tag) {
    case 3001: {
        _strEmail = txtInfo.text;
    } break;

    case 3002: {
        _strPassword = txtInfo.text;
    } break;

    default:
        break;
    }
}

- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - Google Delegate Method

- (void)signIn:(GIDSignIn*)signIn didSignInForUser:(GIDGoogleUser*)user withError:(NSError*)error
{
    NSString* strUserId = user.userID;
    NSString* strEmail = user.profile.email;
    NSString* strFullName = user.profile.name;
    NSString* strTokenId = user.authentication.accessToken;

    if (!error) {
        NSMutableDictionary* dicAuth = [[NSMutableDictionary alloc] init];

        NSMutableDictionary* dicInfo = [[NSMutableDictionary alloc] init];
        [dicInfo setValue:strEmail forKey:@"email"];
        [dicInfo setValue:strFullName forKey:@"name"];

        [dicAuth setValue:dicInfo forKey:@"info"];
        [dicAuth setValue:strUserId forKey:@"uid"];

        NSMutableDictionary* dicCredentials = [[NSMutableDictionary alloc] init];
        [dicCredentials setValue:strTokenId forKey:@"token"];

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

#pragma mark - Button Click Events

- (IBAction)btnLogInClicked:(id)sender
{
    [self.view endEditing:YES];

    if ([self validateUserInput]) {
        if ([[WebServiceConnector alloc] checkNetConnection]) {
            NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];

            [dicParam setValue:_strEmail forKey:@"email"];
            [dicParam setValue:_strPassword forKey:@"password"];
            [dicParam setValue:@YES forKey:@"send_email"];

            _loginType = LoginTypeNormal;

            [[WebServiceConnector alloc] init:URLLogin
                               withParameters:dicParam
                                   withObject:self
                                 withSelector:@selector(handleLoginResponse:)
                               forServiceType:ServiceTypePOST
                               showDisplayMsg:@""
                                   showLoader:YES];
        } else {
            if ([DefaultsValues isKeyAvailbaleInDefault:kUserObject]) {
                User* objUser = GET_USER_OBJ;
                if ([objUser.email isEqualToString:_strEmail]) {
                    if ([[DefaultsValues getStringValueFromUserDefaults_ForKey:kUserPassword] isEqualToString:_strPassword]) {
                        [DefaultsValues setBooleanValueToUserDefaults:YES ForKey:kLogIn];
                        RoutesVC* vc = [self.storyboard instantiateViewControllerWithIdentifier:kIDRoutesVC];
                        vc.navigationItem.hidesBackButton = YES;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
            }
        }
    }
}

- (IBAction)btnLogInFacebookClicked:(id)sender
{
    [self.view endEditing:YES];

    FBSDKLoginManager* login = [[FBSDKLoginManager alloc] init];

    login.loginBehavior = FBSDKLoginBehaviorNative;

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"id, name, link, first_name, last_name, picture.type(large), email, birthday, location, friends, hometown, gender, friendlists", @"fields", nil];

    [login logInWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult* result, NSError* error) {
                                if (error) {
                                } else if (result.isCancelled) {
                                } else {
                                    if ([result.grantedPermissions containsObject:@"public_profile"]) {
                                        if ([FBSDKAccessToken currentAccessToken]) {
                                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                               parameters:params]
                                                startWithCompletionHandler:^(FBSDKGraphRequestConnection* connection, id result, NSError* error) {

                                                    if (!error) {
                                                        NSMutableDictionary* dicAuth = [[NSMutableDictionary alloc] init];

                                                        NSMutableDictionary* dicInfo = [[NSMutableDictionary alloc] init];
                                                        [dicInfo setValue:[result valueForKey:@"email"] forKey:@"email"];
                                                        [dicInfo setValue:[result valueForKey:@"name"] forKey:@"name"];

                                                        [dicAuth setValue:dicInfo forKey:@"info"];
                                                        [dicAuth setValue:[NSString stringWithFormat:@"%@", [result valueForKey:@"id"]] forKey:@"uid"];

                                                        NSMutableDictionary* dicCredentials = [[NSMutableDictionary alloc] init];
                                                        [dicCredentials setValue:[[FBSDKAccessToken currentAccessToken] tokenString] forKey:@"token"];

                                                        [dicAuth setValue:dicCredentials forKey:@"credentials"];

                                                        [dicAuth setValue:@"facebook" forKey:@"provider"];

                                                        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
                                                        [dicParam setValue:dicAuth forKey:@"auth"];
                                                        [dicParam setValue:@YES forKey:@"send_email"];

                                                        self->_loginType = LoginTypeFacebook;

                                                        [[WebServiceConnector alloc] init:URLSocialLogin
                                                                           withParameters:dicParam
                                                                               withObject:self
                                                                             withSelector:@selector(handleLoginResponse:)
                                                                           forServiceType:ServiceTypeJSON
                                                                           showDisplayMsg:@""
                                                                               showLoader:YES];
                                                    }
                                                }];
                                        }
                                    }
                                }
                            }];
}

- (IBAction)btnSignInGoogleClicked:(id)sender
{
    [self.view endEditing:YES];

    GIDSignIn* signInGoogle = [GIDSignIn sharedInstance];
    [signInGoogle setScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/plus.login"]];
    signInGoogle.delegate = self;
    signInGoogle.uiDelegate = self;
    [signInGoogle signIn];
}

- (IBAction)handleLoginResponse:(id)sender
{
    NSString* strLoginType = @"";

    switch (_loginType) {
    case LoginTypeNormal: {
        strLoginType = @"Normal";
    } break;

    case LoginTypeGoogle: {
        strLoginType = @"Google";
    } break;

    case LoginTypeFacebook: {
        strLoginType = @"Facebook";
    } break;

    default:
        break;
    }

    NSArray* arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];

    [Answers logLoginWithMethod:strLoginType
                        success:@(arrResponse.count > 0)
               customAttributes:@{}];

    if (arrResponse.count > 0) {
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDFolders class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoutes class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoute class])];

        User* objUser = [arrResponse firstObject];

        if (objUser.config == nil) {
            objUser.config = @"{\"action\":\"{\\\"autoPhoto\\\":false,\\\"voiceToText\\\":true,\\\"takePicture\\\":true,\\\"voiceRecorder\\\":true,\\\"waypointOnly\\\":true,\\\"text\\\":true}\",\"unit\":\"Kilometers\",\"rotation\":{\"value\":\"1\"},\"sync\":\"2\",\"odo\":\"00.00\",\"autoCamera\":true,\"accuracy\":{\"minDistanceTrackpoint\":50,\"angle\":1,\"accuracy\":50,\"distance\":3}}";
        }

        UserConfig* objConfig = [self getDefaultUserConfiguration];
        [DefaultsValues setCustomObjToUserDefaults:objConfig ForKey:kUserConfiguration];

        [DefaultsValues setCustomObjToUserDefaults:objUser ForKey:kUserObject];
        [DefaultsValues setBooleanValueToUserDefaults:YES ForKey:kLogIn];
        [DefaultsValues setStringValueToUserDefaults:_strPassword ForKey:kUserPassword];

        RoadbooksVC* vc = loadViewController(StoryBoard_Roadbooks, kIDRoadbooksVC);
        vc.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:vc animated:YES];

        [SyncManager.shared startSync];
    } else {
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

- (IBAction)btnForgotPasswordClicked:(id)sender
{
    [self.view endEditing:YES];

    [AlertManager input:@"Please enter your email address to reset your password"
                  title:@"Forgot password?"
            placeHolder:NULL
                  image:@"ic_email_w"
               negative:NULL
               positive:NULL
              confirmed:^(NSString* _Nullable email) {
                  if (email.isValid) {
                      [AlertManager dismiss];
                      [self.view endEditing:YES];
                      [self resetPasswordForEmailID:email];
                  } else {
                      [AlertManager toast:@"Please Enter Valid Email Address" title:NULL image:@"ic_error"];
                  }
              }];
}

- (void)resetPasswordForEmailID:(NSString*)strEmail
{
    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:strEmail forKey:@"email"];

    [[WebServiceConnector alloc] init:URLForgotPassword
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleResetResponse:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (IBAction)handleResetResponse:(id)sender
{
    NSDictionary* dic = [sender responseDict];

    if ([[dic valueForKey:SUCCESS_STATUS] boolValue]) {
        [AlertManager alert:@"Check your email for the link to reset your password" title:@"Password Request Sent" imageName:@"ic_success"];
    } else {
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

- (IBAction)btnSignUpClicked:(id)sender
{
    [self.view endEditing:YES];

    isSignUp = YES;

    RegisterVC* vc = loadViewController(StoryBoard_Main, kIDRegisterVC);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case LoginCellTypeLogo: {
        double val = (SCREEN_HEIGHT / 2) - (HEIGHT_LOGIN_INFO_CELL / 2) - HEIGHT_DESCRIPTION_CELL;

        heightLogoCell = val < 100 ? 100 : val;

        if (_heightLogo) {
            val = val < 100 ? 100 : val > 250 ? 250 : val;
            height_Logo = (val > heightLogoCell) ? heightLogoCell : val;
            _heightLogo.constant = height_Logo;
        }

        return heightLogoCell;
    } break;

    case LoginCellTypeDescription: {
        return UITableViewAutomaticDimension;
    } break;
    case LoginCellDescription: {
        return UITableViewAutomaticDimension;
    } break;

    case LoginCellTypeLoginInfo: {
        return HEIGHT_LOGIN_INFO_CELL;
    } break;

    case LoginCellTypeActions: {
        return HEIGHT_ACTIONS_CELL;
    } break;

    case LoginCellTypeForgotPassword: {
        return HEIGHT_FORGOT_PASSWORD_CELL;
    } break;

    case LoginCellTypeSocialLogin: {
        return HEIGHT_SOCIAL_LOGIN_CELL;
    } break;

    default:
        break;
    }

    return 0.0f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;

    switch (indexPath.row) {
    case LoginCellTypeLogo: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginLogoCell"];

        NSLayoutConstraint* heightConstraint;
        for (NSLayoutConstraint* constraint in [cell.contentView viewWithTag:2001].constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                break;
            }
        }

        if (_heightLogo) {
            _heightLogo.constant = height_Logo;
            [cell.contentView layoutIfNeeded];
        } else {
            _heightLogo = heightConstraint;
        }
    } break;

    case LoginCellTypeDescription: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginDescriptionCell"];

        [((UILabel*)[cell.contentView viewWithTag:4004]) setFont:[((UILabel*)[cell.contentView viewWithTag:4004]).font fontWithSize:[self SetBigFont]]];
        [((UILabel*)[cell.contentView viewWithTag:4005]) setFont:[((UILabel*)[cell.contentView viewWithTag:4005]).font fontWithSize:[self SetSmallFont]]];
        [((UILabel*)[cell.contentView viewWithTag:4006]) setFont:[((UILabel*)[cell.contentView viewWithTag:4006]).font fontWithSize:[self SetBigFont]]];
        [((UILabel*)[cell.contentView viewWithTag:4007]) setFont:[((UILabel*)[cell.contentView viewWithTag:4007]).font fontWithSize:[self SetSmallFont]]];
    } break;
    case LoginCellDescription: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idDescritpion"];

        [((UILabel*)[cell.contentView viewWithTag:4002]) setFont:[((UILabel*)[cell.contentView viewWithTag:4002]).font fontWithSize:[self SetBigFont]]];

        [((UILabel*)[cell.contentView viewWithTag:4003]) setFont:[((UILabel*)[cell.contentView viewWithTag:4003]).font fontWithSize:[self SetBigFont]]];
    } break;

    case LoginCellTypeLoginInfo: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginDataCell"];

        ((UITextField*)[cell.contentView viewWithTag:3001]).delegate = self;
        ((UITextField*)[cell.contentView viewWithTag:3002]).delegate = self;

        NSAttributedString* strEmail = [[NSAttributedString alloc] initWithString:@"Enter Email Address" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
        ((UITextField*)[cell.contentView viewWithTag:3001]).attributedPlaceholder = strEmail;

        NSAttributedString* strPassword = [[NSAttributedString alloc] initWithString:@"Enter Password" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
        ((UITextField*)[cell.contentView viewWithTag:3002]).attributedPlaceholder = strPassword;
        [[cell.contentView viewWithTag:3001] addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
        [[cell.contentView viewWithTag:3002] addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
    } break;

    case LoginCellTypeActions: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginActionCell"];
    } break;

    case LoginCellTypeForgotPassword: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginForgotPasswordCell"];
    } break;

    case LoginCellTypeSocialLogin: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginSocialCell"];
    } break;

    default:
        break;
    }

    return cell;
}

@end
