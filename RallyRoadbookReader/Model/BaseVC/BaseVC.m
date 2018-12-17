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

- (id _Nonnull)registerCell:(nullable id)cell
                inTableView:(nullable UITableView *)tableView
               forClassName:(nonnull NSString *)className
                 identifier:(nonnull NSString *)identifier
{
    [tableView registerNib:[UINib nibWithNibName:className bundle:nil] forCellReuseIdentifier:identifier];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    return [nib objectAtIndex:0];
}

- (NSArray * _Nullable)validateResponse:(nullable id)sender
                             forKeyName:(nonnull NSString *)keyName
                              forObject:(nullable id)object
                              showError:(BOOL)showError
{
    NSDictionary *dic = [sender responseDict];
    
    if ([dic valueForKey:keyName] && [[dic valueForKey:SUCCESS_STATUS] boolValue])
    {
        if ([sender responseArray].count > 0)
        {
            return [sender responseArray];
        }
    }
    
    return @[];
}

- (void)showErrorInObject:(nullable id)object forDict:(NSDictionary * _Nullable)dicResponse
{
    if ([dicResponse objectForKey:SUCCESS_STATUS])
    {
        if (![[dicResponse valueForKey:SUCCESS_STATUS] boolValue])
        {
            if ([dicResponse objectForKey:ERROR_CODE])
            {
                NSInteger errorCode = [[dicResponse valueForKey:ERROR_CODE] integerValue];
                [UIAlertController showAlertInViewController:object
                                                   withTitle:@"Error"
                                                     message:[RallyNavigatorConstants getErrorForErrorCode:errorCode]
                                           cancelButtonTitle:@"OK"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil
                                                    tapBlock:nil];
            }
        }
    }
}

- (void)presentConfirmationAlertWithTitle:(nonnull NSString *)strTitle
                              withMessage:(nonnull NSString *)strMessage
                    withCancelButtonTitle:(nonnull NSString *)strCancelTitle
                             withYesTitle:(nonnull NSString *)strYes
                       withExecutionBlock:(nonnull RefreshBlock)block
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:strTitle
                                                                             message:strMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:strCancelTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:strYes
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              block();
                                                          });
                                                      }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:yesAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (UserConfig *)getDefaultUserConfiguration
{
    UserConfig *objConfig = [[UserConfig alloc] init];
    objConfig.isShowCap = YES;
    objConfig.isShowSpeed = YES;
    objConfig.isShowTime = YES;
    objConfig.isShowAlert = YES;
    objConfig.isShowTutorial = YES;
    objConfig.distanceUnit = DistanceUnitsTypeKilometers;
    objConfig.cal = 0.00f;
    return objConfig;
}

// GET CELL FROM THE BUTTON(SENDER)

- (UIView * _Nullable)getCellForClassName:(nonnull NSString *)classname
                               withSender:(nullable id)sender
{
    UIView *superview = [sender superview];
    
    while (![superview isKindOfClass:NSClassFromString(classname)])
    {
        superview = [superview superview];
    }
    
    return superview;
}

#pragma mark - Pull to Refresh and Load More Management

- (void)pullToRefreshHeaderSetUpForTableView:(nullable UITableView *)tableView
                                  withStatus:(nonnull NSString *)strPlaceholder
                         withRefreshingBlock:(nonnull RefreshBlock)block
{
    tableView.bounces = YES;
    //Header-Refresh
    MJRefreshNormalHeader *mainHeader = [[MJRefreshNormalHeader alloc] init];
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

- (void)loadMoreFooterSetUpForTableView:(nullable UITableView *)tableView
                    withRefreshingBlock:(nonnull RefreshBlock)block
{
    tableView.bounces = YES;
    
    MJRefreshBackNormalFooter *footer = [[MJRefreshBackNormalFooter alloc] init];
    footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        block();
    }];
    footer.automaticallyChangeAlpha = YES;
    tableView.mj_footer = footer;
}

// Check Header Refreshing

- (BOOL)isHeaderRefreshingForTableView:(nullable UITableView *)tableView
{
    if (tableView.mj_header)
    {
        return [tableView.mj_header isRefreshing];
    }
    return NO;
}

- (BOOL)isFooterRefreshingForTableView:(nullable UITableView *)tableView
{
    if (tableView.mj_footer)
    {
        return [tableView.mj_footer isRefreshing];
    }
    return NO;
}

@end
