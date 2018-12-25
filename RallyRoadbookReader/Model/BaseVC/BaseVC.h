//
//  BaseVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserConfig.h"

@interface BaseVC : UIViewController

typedef void (^RefreshBlock) (void);

- (id _Nonnull)registerCell:(nullable id)cell
                inTableView:(nullable UITableView *)tableView
               forClassName:(nonnull NSString *)className
                 identifier:(nonnull NSString *)identifier;

- (NSArray * _Nullable)validateResponse:(nullable id)sender
                             forKeyName:(nonnull NSString *)keyName
                              forObject:(nullable id)object
                              showError:(BOOL)showError;

- (void)showErrorInObject:(nullable id)object forDict:(NSDictionary * _Nullable)dicResponse;

- (UserConfig * _Nullable)getDefaultUserConfiguration;

- (UIView * _Nullable)getCellForClassName:(nonnull NSString *)classname
                               withSender:(nullable id)sender;

- (BOOL)isHeaderRefreshingForTableView:(nullable UITableView *)tableView;
- (BOOL)isFooterRefreshingForTableView:(nullable UITableView *)tableView;

- (void)pullToRefreshHeaderSetUpForTableView:(nullable UITableView *)tableView withStatus:(nonnull NSString *)strPlaceholder withRefreshingBlock:(nonnull RefreshBlock)block;

- (void)loadMoreFooterSetUpForTableView:(nullable UITableView *)tableView withRefreshingBlock:(nonnull RefreshBlock)block;

- (UIInterfaceOrientationMask)getOrientation;

@end
