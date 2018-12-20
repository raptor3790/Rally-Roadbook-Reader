//
//  RoutesVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 24/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "RoutesVC.h"
#import "RouteVC.h"
#import "SettingsVC.h"
//#import "Routes.h"
#import "RoadbooksCell.h"
#import <FBSDKLoginKit.h>
#import <FBSDKCoreKit.h>
#import "HowToUseVC.h"
@import GoogleSignIn;

@interface RoutesVC () <UITableViewDataSource, UITableViewDelegate, SettingsVCDelegate>
{
    NSMutableArray *arrPDFs;
}
@end

@implementation RoutesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Roadbooks";
    
    _tblRoadbooks.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem *btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"menu") style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingsClicked:)];
    self.navigationItem.rightBarButtonItem = btnDrawer;
    
    [self getMyPDFWithLoader:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark - WS Call

- (void)getMyPDFWithLoader:(BOOL)showLoader
{
    [[WebServiceConnector alloc] init:URLGetMyPDF
                       withParameters:nil
                           withObject:self
                         withSelector:@selector(handleWSResponse:)
                       forServiceType:ServiceTypeGET
                       showDisplayMsg:@""
                           showLoader:showLoader];
}

- (IBAction)handleWSResponse:(id)sender
{
    arrPDFs = [[NSMutableArray alloc] init];
    
    NSArray *arrResponse = [self validateResponse:sender
                                       forKeyName:RoadBooksKey
                                        forObject:self
                                        showError:YES];
    arrPDFs = [arrResponse mutableCopy];
    [_tblRoadbooks reloadData];
}

- (IBAction)btnSettingsClicked:(id)sender
{
    SettingsVC *vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES animated:NO];
    [self presentViewController:nav animated:YES completion:nil];
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

- (void)clickedRoadbooks{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPDFs.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:kIDRouteVC];
    vc.objRoute = [arrPDFs objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Routes *objRoute = [arrPDFs objectAtIndex:indexPath.row];

    RoadbooksCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idRoadbookCell"];
    
    cell.lblTitle.text = objRoute.name;
    cell.lblDate.text = objRoute.updatedAt;
    
    return cell;
}

@end
