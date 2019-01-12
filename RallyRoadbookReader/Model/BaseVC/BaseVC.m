

//
//  BaseVC.m
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

+ (UserConfig*)getUserConfiguration
{
    UserConfig* objConfig = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserConfiguration];
    if (objConfig == NULL) {
        objConfig = [[UserConfig alloc] init];
        objConfig.isScreenRotateLock = YES;
        objConfig.isShowCap = YES;
        objConfig.isShowSpeed = YES;
        objConfig.isShowTime = YES;
        objConfig.isShowAlert = YES;
        objConfig.distanceUnit = DistanceUnitsTypeKilometers;
        objConfig.cal = 0.00f;
    }
    return objConfig;
}

- (id _Nonnull)registerCell:(nullable id)cell
                inTableView:(nullable UITableView*)tableView
               forClassName:(nonnull NSString*)className
                 identifier:(nonnull NSString*)identifier
{
    [tableView registerNib:[UINib nibWithNibName:className bundle:nil] forCellReuseIdentifier:identifier];
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    return [nib objectAtIndex:0];
}

- (NSArray* _Nullable)validateResponse:(nullable id)sender
                            forKeyName:(nonnull NSString*)keyName
                             forObject:(nullable id)object
                             showError:(BOOL)showError
{
    NSDictionary* dic = [sender responseDict];

    if ([dic valueForKey:keyName] && [[dic valueForKey:SUCCESS_STATUS] boolValue]) {
        if ([sender responseArray].count > 0) {
            return [sender responseArray];
        }
    }

    return @[];
}

- (void)showErrorInObject:(nullable id)object forDict:(NSDictionary* _Nullable)dicResponse
{
    if ([dicResponse objectForKey:SUCCESS_STATUS]) {
        if (![[dicResponse valueForKey:SUCCESS_STATUS] boolValue]) {
            if ([dicResponse objectForKey:ERROR_CODE]) {
                NSInteger errorCode = [[dicResponse valueForKey:ERROR_CODE] integerValue];
                [AlertManager alert:[RallyNavigatorConstants getErrorForErrorCode:errorCode] title:@"Error" imageName:@"ic_error" confirmed:NULL];
            }
        }
    }
}

- (UIInterfaceOrientationMask)getOrientation
{
    UserConfig* config = [BaseVC getUserConfiguration];
    if (iPadDevice && config.isScreenRotateLock) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

// GET CELL FROM THE BUTTON(SENDER)

- (UIView* _Nullable)getCellForClassName:(nonnull NSString*)classname withSender:(nullable id)sender
{
    UIView* superview = [sender superview];

    while (![superview isKindOfClass:NSClassFromString(classname)]) {
        superview = [superview superview];
    }

    return superview;
}

#pragma mark - Pull to Refresh and Load More Management

- (void)pullToRefreshHeaderSetUpForTableView:(nullable UITableView*)tableView
                                  withStatus:(nonnull NSString*)strPlaceholder
                         withRefreshingBlock:(nonnull RefreshBlock)block
{
    tableView.bounces = YES;
    //Header-Refresh
    MJRefreshNormalHeader* mainHeader = [[MJRefreshNormalHeader alloc] init];
    mainHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        block();
    }];
    mainHeader.lastUpdatedTimeLabel.hidden = YES;
    mainHeader.automaticallyChangeAlpha = YES;
    [mainHeader setTitle:strPlaceholder forState:MJRefreshStateIdle];
    [mainHeader setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
    [mainHeader setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
    tableView.mj_header = mainHeader;
}

- (void)loadMoreFooterSetUpForTableView:(nullable UITableView*)tableView withRefreshingBlock:(nonnull RefreshBlock)block
{
    tableView.bounces = YES;

    MJRefreshBackNormalFooter* footer = [[MJRefreshBackNormalFooter alloc] init];
    footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        block();
    }];
    footer.automaticallyChangeAlpha = YES;
    tableView.mj_footer = footer;
}

// Check Header Refreshing

- (BOOL)isHeaderRefreshingForTableView:(nullable UITableView*)tableView
{
    if (tableView.mj_header) {
        return [tableView.mj_header isRefreshing];
    }
    return NO;
}

- (BOOL)isFooterRefreshingForTableView:(nullable UITableView*)tableView
{
    if (tableView.mj_footer) {
        return [tableView.mj_footer isRefreshing];
    }
    return NO;
}

@end
