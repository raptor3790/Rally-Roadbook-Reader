//
//  RoadbooksVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 26/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "RoadbooksVC.h"
#import "RouteVC.h"
#import "SettingsVC.h"
#import "RoadbooksCell.h"
#import "Roadbooks.h"
#import "Folders.h"
#import "Routes.h"
#import "Config.h"

@import GoogleSignIn;

@interface RoadbooksVC () <UITableViewDataSource, UITableViewDelegate, SettingsVCDelegate> {
    User* objUser;
    BOOL isLightView;
    UIToolbar* toolbar;
    id synchronizingObserver;
    id synchronizedObserver;
}
@end

@implementation RoadbooksVC
@synthesize arrFolders, arrEmails, arrRoadBooks;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"My Roadbooks";

    if (_strRoadbookPageName) {
        self.title = _strRoadbookPageName;
    }

    arrFolders = [[NSMutableArray alloc] init];
    arrRoadBooks = [[NSMutableArray alloc] init];

    id object = [DefaultsValues getObjectValueFromUserDefaults_ForKey:kUserSharedEmails];
    arrEmails = [[NSMutableArray alloc] init];
    if (object) {
        [arrEmails addObjectsFromArray:object];
    }

    _tblRoadbooks.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    UIBarButtonItem* btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"menu") style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingsClicked:)];
    self.navigationItem.rightBarButtonItem = btnDrawer;

    objUser = GET_USER_OBJ;

    [self fetchRoadbooks];
    [self getMyRoadBooksWithLoader:NO];

    [self pullToRefreshHeaderSetUpForTableView:_tblRoadbooks
                                    withStatus:@"Get new roadbooks"
                           withRefreshingBlock:^{
                               [self getMyRoadBooksWithLoader:NO];
                           }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UserConfig* objUserConfig = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserConfiguration];

    if (objUserConfig == nil) {
        objUserConfig = [self getDefaultUserConfiguration];
    }

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    switch (objUserConfig.themePreference) {
    case ThemePreferenceDark: {
        self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };

        UIBarButtonItem* button = [[UIBarButtonItem alloc] init];
        button = self.navigationItem.rightBarButtonItem;
        button.tintColor = [UIColor lightGrayColor];

        self.navigationItem.rightBarButtonItem = button;
        self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
        isLightView = false;
    } break;

    case ThemePreferenceLight: {
        isLightView = true;
        self.navigationController.navigationBar.titleTextAttributes
            = @{ NSForegroundColorAttributeName : [UIColor blackColor] };

        UIBarButtonItem* button = [[UIBarButtonItem alloc] init];
        button = self.navigationItem.rightBarButtonItem;
        button.tintColor = [UIColor blackColor];

        self.navigationItem.rightBarButtonItem = button;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    } break;

    default:
        break;
    }

    if (isLightView) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = NO;
    } else {
        [self.view setBackgroundColor:[UIColor blackColor]];
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.translucent = NO;
    }

    [self.tblRoadbooks reloadData];

    if (isLightView) {
        self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    } else {
        self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    }

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleSynchronizeEnd:) name:SyncManager.stateSynchronized object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleSynchronizing:) name:SyncManager.stateSynchronizing object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [NSNotificationCenter.defaultCenter removeObserver:self name:SyncManager.stateSynchronized object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:SyncManager.stateSynchronizing object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods

- (NSString*)convertDateFormatDate:(NSString*)strDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate* date = [formatter dateFromString:strDate];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];

    NSString* strConvertedDate = [formatter stringFromDate:date];

    return strConvertedDate;
}

#pragma mark - Sync Methods

- (void)handleSynchronizeBegin
{
    _syncLabel.text = @"Preparing to Download Roadbooks";
    self.syncLabelHeight.constant = 50.0f;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)handleSynchronizeEnd:(NSNotification*)notification
{
    _syncLabel.text = @"All Roadbooks Up to Date";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.syncLabelHeight.constant = 0.0f;
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    });
}

- (void)handleSynchronizing:(NSNotification*)notification
{
    if (_syncLabelHeight.constant == 0) {
        self.syncLabelHeight.constant = 50.0f;
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }

    NSDictionary* userInfo = notification.userInfo;

    double count = [[userInfo objectForKey:@"count"] doubleValue];
    double total = [[userInfo objectForKey:@"total"] doubleValue];
    double percentage = count / total;

    _syncLabel.text = [NSString stringWithFormat:@"Downloading Roadbooks - %d%%", (int)(percentage * 100)];
}

#pragma mark -  WS Call

- (void)getMyRoadBooksWithLoader:(BOOL)showLoader
{
    NSString* strAppendURL = URLGetMyFolders;

    if (_strFolderId) {
        strAppendURL = [strAppendURL stringByAppendingString:[NSString stringWithFormat:@"?from=reader&folder_id=%@", _strFolderId]];
    } else {
        strAppendURL = [strAppendURL stringByAppendingString:@"?from=reader"];
    }

    [[WebServiceConnector alloc] init:strAppendURL
                       withParameters:nil
                           withObject:self
                         withSelector:@selector(handleMyRoadBooksResponse:)
                       forServiceType:ServiceTypeGET
                       showDisplayMsg:@""
                           showLoader:showLoader];
}

- (IBAction)handleMyRoadBooksResponse:(id)sender
{
    if ([self isHeaderRefreshingForTableView:_tblRoadbooks]) {
        [_tblRoadbooks.mj_header endRefreshing];
        if (!SyncManager.shared.isSyncing) {
            [self handleSynchronizeBegin];
            [SyncManager.shared startSyncWithResponse:sender scanChild:NO];
        }
    }

    if (_strFolderId == NULL && !SyncManager.shared.isSyncing) {
        [self handleSynchronizeBegin];
        [SyncManager.shared startSyncWithResponse:sender scanChild:YES];
    }

    [self validateResponse:sender forKeyName:RoadbooksKey forObject:self showError:YES];
    [self fetchRoadbooks];
}

- (void)fetchRoadbooks
{
    NSString* predicateFolder;

    if (_strFolderId) {
        predicateFolder = [NSString stringWithFormat:@"parentId = %@", _strFolderId];
    } else {
        predicateFolder = @"parentId = 0";
        _isShareFolder = NO;
    }

    NSMutableArray* arrSyncFolders =
        [[NSMutableArray alloc] initWithArray:[CoreDataAdaptor fetchDataFromLocalDB:predicateFolder
                                                                     sortDescriptor:nil
                                                                          forEntity:NSStringFromClass([CDFolders class])]];

    NSString* parentId;

    if (_strFolderId) {
        parentId = _strFolderId;
    } else {
        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(CDFolders* objFolder, NSDictionary<NSString*, id>* _Nullable bindings) {
            return [objFolder.folderType isEqualToString:@"default"];
        }];

        NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
        arrWayPoints = [[arrSyncFolders filteredArrayUsingPredicate:predicate] mutableCopy];

        if (arrWayPoints.count > 0) {
            CDFolders* objFolder = arrWayPoints[0];
            parentId = [NSString stringWithFormat:@"%ld", (long)[objFolder.foldersIdentifier doubleValue]];
        } else {
            return;
        }
    }

    NSMutableArray* arrSyncData =
        [[NSMutableArray alloc] initWithArray:[CoreDataAdaptor fetchDataFromLocalDB:parentId ? [NSString stringWithFormat:@"folderId = %@", parentId] : parentId
                                                                     sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]
                                                                          forEntity:NSStringFromClass([CDRoutes class])]];

    BOOL userRole = [objUser.role isEqualToString:@"user"];

    arrRoadBooks = [[NSMutableArray alloc] init];
    for (CDRoutes* route in arrSyncData) {

        Routes* item = [[Routes alloc] initWithCDRoutes:route];
        BOOL isDefault = [route.name isEqualToString:kDefaultRallyName] || [route.name isEqualToString:kDefaultCrossCountryName];

        if (userRole && isDefault) {
            item.name = [NSString stringWithFormat:@"%@ - FREE User View", route.name];
            [arrRoadBooks addObject:item];

            Routes* itemPdf = [[Routes alloc] initWithCDRoutes:route];
            itemPdf.name = [NSString stringWithFormat:@"%@ - UPGRADED User View", route.name];
            [arrRoadBooks addObject:itemPdf];
        } else {
            [arrRoadBooks addObject:item];
        }
    }

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(CDFolders* objFolder, NSDictionary<NSString*, id>* _Nullable bindings) {
        return ![objFolder.folderType isEqualToString:@"default"];
    }];

    NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
    arrWayPoints = [[arrSyncFolders filteredArrayUsingPredicate:predicate] mutableCopy];

    if (arrWayPoints.count == 0) {
        arrWayPoints = [arrSyncFolders mutableCopy];
    }

    arrFolders = [[NSMutableArray alloc] init];
    for (CDFolders* folder in arrWayPoints) {
        Folders* item = [[Folders alloc] initWithCDFolders:folder];
        [arrFolders addObject:item];
    }

    [_tblRoadbooks reloadData];
}

#pragma mark - Setting Delegate Methods

- (void)clickedLogout
{
    [AlertManager confirm:@"Are you sure you want to log out?"
                    title:@"Confirm Logout"
                 negative:@"Cancel"
                 positive:@"Yes"
                confirmed:^{
                    [[GIDSignIn sharedInstance] signOut];
                    [DefaultsValues setBooleanValueToUserDefaults:NO ForKey:kLogIn];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
}

#pragma mark - Button Click Events

- (IBAction)btnSettingsClicked:(id)sender
{
    SettingsVC* vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.delegate = self;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES animated:NO];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnShareClicked:(id)sender
{
    [self.view endEditing:YES];

    RoadbooksCell* cell = (RoadbooksCell*)[self getCellForClassName:NSStringFromClass([RoadbooksCell class]) withSender:sender];
    NSIndexPath* idPath = [_tblRoadbooks indexPathForCell:cell];

    NSString* strId;

    if (idPath.section == MyRoadbooksSectionRoadbooks) {
        Routes* objRoadbook = [arrRoadBooks objectAtIndex:idPath.row];

        if (objRoadbook.editable) {
            strId = [NSString stringWithFormat:@"%ld", (long)objRoadbook.routesIdentifier];
        } else {
            [AlertManager alert:@"This route can not be shared" title:NULL imageName:@"ic_error"];
            return;
        }
    } else {
        Folders* objFolder = [arrFolders objectAtIndex:idPath.row];
        strId = [NSString stringWithFormat:@"%d", (int)objFolder.foldersIdentifier];
    }

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
                  [self share:strId for:(MyRoadbooksSection)idPath.section withEmailID:email];
              }];
}

- (void)share:(NSString *)strR_Id for:(MyRoadbooksSection)section withEmailID:(NSString *)strEmail
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
    if (section == MyRoadbooksSectionRoadbooks) {
        [dicParam setValue:strR_Id forKey:@"route_id"];
    }
    [dicParam setValue:@[ strEmail ] forKey:@"emails"];

    NSMutableDictionary* dicShare = [[NSMutableDictionary alloc] init];
    [dicShare setObject:dicParam forKey:section == MyRoadbooksSectionRoadbooks ? @"share" : @"share_folder"];

    NSString* strUrl;

    if (section == MyRoadbooksSectionFolders) {
        strUrl = [URLGetMyFolders stringByAppendingString:[NSString stringWithFormat:@"/%@/share_reader_folder", strR_Id]];
    } else {
        strUrl = [URLGetMyFolders stringByAppendingString:@"/share_reader_roadbook"];
    }

    [[WebServiceConnector alloc] init:strUrl
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
        [AlertManager alert:@"" title:@"Roadbook has been shared with user" imageName:@"ic_success"];
    } else {
        [AlertManager alert:@"" title:@"Sharing has failed\nYou must be online to share a Roadbook" imageName:@"ic_error"];
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
    case MyRoadbooksSectionFolders: {
        return arrFolders.count;
    } break;

    case MyRoadbooksSectionRoadbooks: {
        return arrRoadBooks.count;
    } break;

    default:
        break;
    }

    return 0;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
    case MyRoadbooksSectionFolders: {
        RoadbooksVC* vc = loadViewController(StoryBoard_Roadbooks, kIDRoadbooksVC);
        Folders* objFolder = arrFolders[indexPath.row];
        vc.strFolderId = [NSString stringWithFormat:@"%d", (int)objFolder.foldersIdentifier];
        vc.strRoadbookPageName = objFolder.folderName;
        if (_isShareFolder) {
            vc.isShareFolder = _isShareFolder;
        } else {
            vc.isShareFolder = [objFolder.folderType isEqualToString:@"shared_with_me"];
        }
        [self.navigationController pushViewController:vc animated:YES];
    } break;

    case MyRoadbooksSectionRoadbooks: {
        RouteVC* vc = loadViewController(StoryBoard_Roadbooks, kIDRouteVC);
        Routes* objRoadbook = arrRoadBooks[indexPath.row];
        vc.objRoute = objRoadbook;
        vc.strRouteName = objRoadbook.name;
        vc.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } break;

    default:
        break;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    RoadbooksCell* cell = [tableView dequeueReusableCellWithIdentifier:@"idRoadbooksCell"];

    if (!cell) {
        cell = [self registerCell:cell inTableView:tableView forClassName:NSStringFromClass([RoadbooksCell class]) identifier:@"idRoadBooksCell"];
    }

    switch (indexPath.section) {
    case MyRoadbooksSectionFolders: {
        Folders* objFolder = [arrFolders objectAtIndex:indexPath.row];

        cell.lblTitle.text = objFolder.folderName;
        cell.lblDetails.text = objFolder.routesCounts == 1 ? @"1 route" : [NSString stringWithFormat:@"%d routes", (int)objFolder.routesCounts];
        cell.lblDate.text = objFolder.subfoldersCount == 1 ? @"1 sub-folder" : [NSString stringWithFormat:@"%d sub-folders", (int)objFolder.subfoldersCount];
        cell.imgIcon.image = Set_Local_Image(@"folder_icon");

        if (isLightView) {
            cell.lblDate.textColor = UIColor.blackColor;
            cell.lblDetails.textColor = UIColor.blackColor;
            cell.lblTitle.textColor = UIColor.blackColor;

        } else {
            cell.lblDate.textColor = UIColor.lightGrayColor;
            cell.lblDetails.textColor = UIColor.lightGrayColor;
            cell.lblTitle.textColor = UIColor.lightGrayColor;
        }

        BOOL isSharedPage = [objFolder.folderType isEqualToString:@"shared_with_me"];
        [cell.btnShare setHidden:(_isShareFolder || isSharedPage)];
    } break;

    case MyRoadbooksSectionRoadbooks: {
        Routes* objRoadbook = [arrRoadBooks objectAtIndex:indexPath.row];
        cell.lblTitle.text = objRoadbook.name;

        NSInteger distance = 0;
        NSString* strUnit = @"";

        Config* objConfig;

        if (objUser.config == nil) {
            objConfig.unit = @"Kilometers";
        } else {
            NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
            objConfig = [[Config alloc] initWithDictionary:jsonDict];
        }

        if ([objConfig.unit isEqualToString:@"Kilometers"]) {
            strUnit = @"km";

            if ([objRoadbook.units isEqualToString:@"kilometers"]) {
                distance = (NSInteger)ceilf(objRoadbook.length);
            } else {
                distance = (NSInteger)ceilf(objRoadbook.length / 0.62f);
            }
        } else {
            strUnit = @"mi";

            if ([objRoadbook.units isEqualToString:@"kilometers"]) {
                distance = (NSInteger)ceilf(objRoadbook.length * 0.62f);
            } else {
                distance = (NSInteger)ceilf(objRoadbook.length);
            }
        }

        cell.lblDetails.text = [NSString stringWithFormat:@"%d Way Points | %d %@", (int)floorf(objRoadbook.waypointCount), (int)distance, strUnit];

        NSString* strDate = [self convertDateFormatDate:objRoadbook.updatedAt];
        cell.lblDate.text = strDate;

        cell.imgIcon.image = Set_Local_Image(@"roadbook_icon");
        if (isLightView) {
            cell.lblDate.textColor = UIColor.blackColor;
            cell.lblDetails.textColor = UIColor.blackColor;
            cell.lblTitle.textColor = UIColor.blackColor;

        } else {
            cell.lblDate.textColor = UIColor.lightGrayColor;
            cell.lblDetails.textColor = UIColor.lightGrayColor;
            cell.lblTitle.textColor = UIColor.lightGrayColor;
        }

        [cell.btnShare setHidden:(_isShareFolder)];
    } break;

    default:
        break;
    }

    [cell.btnShare setTintColor:[UIColor redColor]];
    [cell.btnShare addTarget:self action:@selector(btnShareClicked:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

@end
