//
//  RegisterVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 17/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "RegisterVC.h"
#import "RoutesVC.h"
#import "RegisterCell.h"
#import <FBSDKCoreKit.h>
#import <FBSDKLoginKit.h>
#import <Crashlytics/Crashlytics.h>
@import GoogleSignIn;

typedef enum
{
    RegisterCellTypeHeader = 0,
    RegisterCellTypeEmail,
    RegisterCellTypeUserName,
    RegisterCellTypePassword,
    RegisterCellTypeConfirmPassword,
    RegisterCellTypeSignUp,
    RegisterCellTypeSignInGoogle,
    RegisterCellTypeSignInFacebook
}RegisterCellType;


@interface RegisterVC () <GIDSignInDelegate, GIDSignInUIDelegate>
{
    BOOL isSignIn;
    
    CGFloat heightLogoCell, height_Logo;
}
@end

@implementation RegisterVC

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [_tblRegister addGestureRecognizer:tapRecognizer];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!isSignIn)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else
    {
        isSignIn = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - KeyBoard Handling Methods

- (void)registerForKeyboardNotifications
{
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_bottomTblRegister.constant = kbSize.height;
        [self.view layoutIfNeeded];
        
        switch (self->_currentTextFieldTag)
        {
            case RegisterCellTypeEmail:
            {
                [self->_tblRegister scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypeEmail inSection:0]
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
            }
                break;
                
            case RegisterCellTypeUserName:
            {
                [self->_tblRegister scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypeUserName inSection:0]
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
            }
                break;
                
            case RegisterCellTypePassword:
            {
                [self->_tblRegister scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypePassword inSection:0]
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
            }
                break;
                
            case RegisterCellTypeConfirmPassword:
            {
                [self->_tblRegister scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypeConfirmPassword inSection:0]
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
            }
                break;
                
            default:
                break;
        }
    });
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    _bottomTblRegister.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - UITextField Handling Method

- (void)updateLabelUsingContentsOfTextField:(id)sender
{
    UITextField *txtInfo = (UITextField *)sender;
    
    switch (txtInfo.tag)
    {
        case RegisterCellTypeEmail:
        {
            _strEmail = txtInfo.text;
        }
            break;
            
        case RegisterCellTypeUserName:
        {
            _strUsername = txtInfo.text;
        }
            break;
            
        case RegisterCellTypePassword:
        {
            _strPassword = txtInfo.text;
        }
            break;
            
        case RegisterCellTypeConfirmPassword:
        {
            _strConfirmPassword = txtInfo.text;
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextFieldTag = textField.tag;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag)
    {
        case RegisterCellTypeEmail:
        {
            [_tblRegister scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypeUserName inSection:0]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:NO];
            RegisterCell *cell = [_tblRegister cellForRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypeUserName inSection:0]];
            [cell.txtInput becomeFirstResponder];
        }
            break;
            
        case RegisterCellTypeUserName:
        {
            [_tblRegister scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypePassword inSection:0]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:NO];
            RegisterCell *cell = [_tblRegister cellForRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypePassword inSection:0]];
            [cell.txtInput becomeFirstResponder];
        }
            break;
            
        case RegisterCellTypePassword:
        {
            [_tblRegister scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypeConfirmPassword inSection:0]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:NO];
            RegisterCell *cell = [_tblRegister cellForRowAtIndexPath:[NSIndexPath indexPathForRow:RegisterCellTypeConfirmPassword inSection:0]];
            [cell.txtInput becomeFirstResponder];
        }
            break;
            
        case RegisterCellTypeConfirmPassword:
        {
            [textField resignFirstResponder];
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

#pragma mark - Google Delegate Method

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    NSString *strUserId = user.userID;
    NSString *strAuthToken = user.authentication.accessToken;
    NSString *strFullName = user.profile.name;
    NSString *strEmail = user.profile.email;
    
    if (!error)
    {
        NSMutableDictionary *dicAuth = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] init];
        [dicInfo setValue:strEmail forKey:@"email"];
        [dicInfo setValue:strFullName forKey:@"name"];
        
        [dicAuth setValue:dicInfo forKey:@"info"];
        [dicAuth setValue:strUserId forKey:@"uid"];
        
        NSMutableDictionary *dicCredentials = [[NSMutableDictionary alloc] init];
        [dicCredentials setValue:strAuthToken forKey:@"token"];
        
        [dicAuth setValue:dicCredentials forKey:@"credentials"];
        
        [dicAuth setValue:@"google_oauth2" forKey:@"provider"];
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
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
    if ([_strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        [AlertManager alert:@"Please Enter Email Address" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    if (![[_strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isValidEmail])
    {
        [AlertManager alert:@"Please Enter Valid Email Address" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    if ([_strUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        [AlertManager alert:@"Please Enter User Name" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    if (![[_strUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isValidName])
    {
        [AlertManager alert:@"Please Enter Valid User Name" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    if ([_strPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        [AlertManager alert:@"Please Enter Password" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    if (![_strPassword isValidPassword])
    {
        [AlertManager alert:@"Password Must Be Between 6-32 Characters" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    if ([_strConfirmPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        [AlertManager alert:@"Please Enter Confirm Password" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    if (![_strPassword isEqualToString:_strConfirmPassword])
    {
        [AlertManager alert:@"Password and Confirm Password must be same" title:NULL imageName:@"ic_error"];
        return NO;
    }
    
    return YES;
}

#pragma mark - Button Click Events

- (IBAction)handleSocialLoginClicked:(id)sender
{
    switch ([((UIButton *)sender) tag])
    {
        case RegisterCellTypeSignInGoogle:
        {
            [self btnSignInGoogleClicked:sender];
        }
            break;
            
        case RegisterCellTypeSignInFacebook:
        {
            [self btnLogInFacebookClicked:sender];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)btnSignInGoogleClicked:(id)sender
{
    [self.view endEditing:YES];
    
    GIDSignIn *signInGoogle = [GIDSignIn sharedInstance];
    [signInGoogle setScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/plus.login"]];
    signInGoogle.delegate = self;
    signInGoogle.uiDelegate = self;
    [signInGoogle signIn];
}

- (IBAction)btnLogInFacebookClicked:(id)sender
{
    [self.view endEditing:YES];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    login.loginBehavior = FBSDKLoginBehaviorNative;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"id, name, link, first_name, last_name, picture.type(large), email, birthday, location, friends, hometown, gender, friendlists", @"fields", nil];
    
    [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) { }
                                else if (result.isCancelled) { }
                                else
                                {
                                    if ([result.grantedPermissions containsObject:@"public_profile"])
                                    {
                                        if ([FBSDKAccessToken currentAccessToken])
                                        {
                                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                               parameters:params]
                                             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                 if (!error)
                                                 {
                                                     NSMutableDictionary *dicAuth = [[NSMutableDictionary alloc] init];
                                                     
                                                     NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] init];
                                                     [dicInfo setValue:[result valueForKey:@"email"] forKey:@"email"];
                                                     [dicInfo setValue:[result valueForKey:@"name"] forKey:@"name"];
                                                     
                                                     [dicAuth setValue:dicInfo forKey:@"info"];
                                                     [dicAuth setValue:[NSString stringWithFormat:@"%@", [result valueForKey:@"id"]] forKey:@"uid"];
                                                     
                                                     NSMutableDictionary *dicCredentials = [[NSMutableDictionary alloc] init];
                                                     [dicCredentials setValue:[[FBSDKAccessToken currentAccessToken] tokenString] forKey:@"token"];
                                                     
                                                     [dicAuth setValue:dicCredentials forKey:@"credentials"];
                                                     
                                                     [dicAuth setValue:@"facebook" forKey:@"provider"];
                                                     
                                                     NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
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

- (IBAction)handleLoginResponse:(id)sender
{
    NSString *strLoginType = @"";
    
    switch (_loginType)
    {
        case LoginTypeNormal:
        {
            strLoginType = @"Normal";
        }
            break;
            
        case LoginTypeGoogle:
        {
            strLoginType = @"Google";
        }
            break;
            
        case LoginTypeFacebook:
        {
            strLoginType = @"Facebook";
        }
            break;
            
        default:
            break;
    }
    
    NSArray *arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    
    [Answers logSignUpWithMethod:strLoginType
                         success:@(arrResponse.count > 0)
                customAttributes:@{}];
    
    if (arrResponse.count > 0)
    {
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDFolders class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoutes class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoute class])];

        User *objUser = [arrResponse firstObject];
        
        if (objUser.config == nil)
        {
            objUser.config = @"{\"action\":\"{\\\"autoPhoto\\\":false,\\\"voiceToText\\\":true,\\\"takePicture\\\":true,\\\"voiceRecorder\\\":true,\\\"waypointOnly\\\":true,\\\"text\\\":true}\",\"unit\":\"Kilometers\",\"rotation\":{\"value\":\"1\"},\"sync\":\"2\",\"odo\":\"00.00\",\"autoCamera\":true,\"accuracy\":{\"minDistanceTrackpoint\":50,\"angle\":1,\"accuracy\":50,\"distance\":3}}";
        }
        
        UserConfig *objConfig = [self getDefaultUserConfiguration];
        [DefaultsValues setCustomObjToUserDefaults:objConfig ForKey:kUserConfiguration];
        
        [DefaultsValues setCustomObjToUserDefaults:objUser ForKey:kUserObject];
        [DefaultsValues setBooleanValueToUserDefaults:YES ForKey:kLogIn];
        [DefaultsValues setStringValueToUserDefaults:_strPassword ForKey:kUserPassword];

        RoutesVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:kIDRoutesVC];
        vc.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:vc animated:NO];
        
        [SyncManager.shared startSync];
    }
    else
    {
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

- (IBAction)btnLoginClicked:(id)sender
{
    [self.view endEditing:YES];
    
    isSignIn = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSignUpClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if ([self validateInput])
    {
        NSMutableDictionary *dicUser = [[NSMutableDictionary alloc] init];
        [dicUser setValue:_strEmail forKey:@"email"];
        [dicUser setValue:_strUsername forKey:@"username"];
        [dicUser setValue:_strPassword forKey:@"password"];
        [dicUser setValue:_strConfirmPassword forKey:@"password_confirmation"];
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case RegisterCellTypeHeader:
        {
            double val = (SCREEN_HEIGHT / 2) - 160.0f;
            
            heightLogoCell = val < 100 ? 100 : val;
            
            if (_heightLogo)
            {
                val = val < 100 ? 100 : val > 250 ? 250 : val;
                height_Logo = (val > heightLogoCell) ? heightLogoCell : val;
                _heightLogo.constant = height_Logo;
            }
            
            return heightLogoCell;
            
            //            return (SCREEN_HEIGHT/2) - 130.0f;
        }
            break;
            
        case RegisterCellTypeEmail:
        case RegisterCellTypeUserName:
        case RegisterCellTypePassword:
        case RegisterCellTypeConfirmPassword:
        {
            return 65.0f;
        }
            break;
            
        case RegisterCellTypeSignUp:
        {
            return 60.0f;
        }
            break;
            
        case RegisterCellTypeSignInGoogle:
        case RegisterCellTypeSignInFacebook:
        {
            return 45.0f;
        }
            break;
            
        default:
            break;
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegisterCell *cell;
    
    switch (indexPath.row)
    {
        case RegisterCellTypeHeader:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterHeaderCell"];
            
            NSLayoutConstraint *heightConstraint;
            for (NSLayoutConstraint *constraint in [cell.contentView viewWithTag:2001].constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                    heightConstraint = constraint;
                    break;
                }
            }
            
            if (_heightLogo)
            {
                _heightLogo.constant = height_Logo;
                [cell.contentView layoutIfNeeded];
            }
            else
            {
                _heightLogo = heightConstraint;
            }
        }
            break;
            
        case RegisterCellTypeEmail:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterInputCell"];
            
            cell.txtInputPlaceHolder.text = @"Email";
            cell.txtInput.placeholder = @"Enter Email Address";
            NSAttributedString *strEmail = [[NSAttributedString alloc] initWithString:@"Enter Email Address" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
            cell.txtInput.attributedPlaceholder = strEmail;
            cell.txtInput.tag = RegisterCellTypeEmail;
            cell.txtInput.text = _strEmail;
            cell.txtInput.secureTextEntry = NO;
            cell.txtInput.keyboardType = UIKeyboardTypeEmailAddress;
            cell.txtInput.returnKeyType = UIReturnKeyNext;
            [cell.txtInput addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
        }
            break;
            
        case RegisterCellTypeUserName:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterInputCell"];
            
            cell.txtInputPlaceHolder.text = @"Username";
            cell.txtInput.placeholder = @"Enter Username";
            NSAttributedString *strEmail = [[NSAttributedString alloc] initWithString:@"Enter Username" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
            cell.txtInput.attributedPlaceholder = strEmail;
            cell.txtInput.tag = RegisterCellTypeUserName;
            cell.txtInput.text = _strUsername;
            cell.txtInput.secureTextEntry = NO;
            cell.txtInput.keyboardType = UIKeyboardTypeDefault;
            cell.txtInput.returnKeyType = UIReturnKeyNext;
            [cell.txtInput addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
        }
            break;
            
        case RegisterCellTypePassword:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterInputCell"];
            
            cell.txtInputPlaceHolder.text = @"Password";
            cell.txtInput.placeholder = @"Enter Password";
            NSAttributedString *strEmail = [[NSAttributedString alloc] initWithString:@"Enter Password" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
            cell.txtInput.attributedPlaceholder = strEmail;
            cell.txtInput.tag = RegisterCellTypePassword;
            cell.txtInput.text = _strPassword;
            cell.txtInput.secureTextEntry = YES;
            cell.txtInput.keyboardType = UIKeyboardTypeDefault;
            cell.txtInput.returnKeyType = UIReturnKeyNext;
            [cell.txtInput addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
        }
            break;
            
        case RegisterCellTypeConfirmPassword:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterInputCell"];
            
            cell.txtInputPlaceHolder.text = @"Confirm Password";
            cell.txtInput.placeholder = @"Enter Confirm Password";
            NSAttributedString *strEmail = [[NSAttributedString alloc] initWithString:@"Enter Confirm Password" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
            cell.txtInput.attributedPlaceholder = strEmail;
            cell.txtInput.tag = RegisterCellTypeConfirmPassword;
            cell.txtInput.text = _strConfirmPassword;
            cell.txtInput.secureTextEntry = YES;
            cell.txtInput.keyboardType = UIKeyboardTypeDefault;
            cell.txtInput.returnKeyType = UIReturnKeyDone;
            [cell.txtInput addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
        }
            break;
            
        case RegisterCellTypeSignUp:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterSignUpCell"];
            
            [cell.btnLogin addTarget:self action:@selector(btnLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnSignUp addTarget:self action:@selector(btnSignUpClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case RegisterCellTypeSignInGoogle:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterScoialCell"];
            
            cell.btnSocialLogin.tag = RegisterCellTypeSignInGoogle;
            [cell.btnSocialLogin setBackgroundImage:[UIImage imageNamed:@"SignInWithGoogle"] forState:UIControlStateNormal];
            [cell.btnSocialLogin addTarget:self action:@selector(handleSocialLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case RegisterCellTypeSignInFacebook:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idRegisterScoialCell"];
            
            cell.btnSocialLogin.tag = RegisterCellTypeSignInFacebook;
            [cell.btnSocialLogin setBackgroundImage:[UIImage imageNamed:@"LoginWithFb"] forState:UIControlStateNormal];
            [cell.btnSocialLogin addTarget:self action:@selector(handleSocialLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end

