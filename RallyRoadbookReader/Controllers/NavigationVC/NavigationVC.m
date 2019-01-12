//
//  NavigationVC.m
//  RallyRoadbookReader
//
//  Created by Eliot Gravett on 2018/12/23.
//  Copyright © 2018 C205. All rights reserved.
//

#import "NavigationVC.h"

@interface NavigationVC ()

@end

@implementation NavigationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    id vc = self.topViewController;
    if ([vc isKindOfClass:BaseVC.class]) {
        BaseVC* baseVC = (BaseVC*)self.topViewController;
        return [baseVC getOrientation];
    } else {
        return [BaseVC getUserConfiguration].isEnableRotate ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate
{
    id vc = self.topViewController;
    if ([vc isKindOfClass:BaseVC.class]) {
        BaseVC* baseVC = (BaseVC*)self.topViewController;
        return [baseVC getOrientation] == UIInterfaceOrientationMaskAll;
    } else {
        return [BaseVC getUserConfiguration].isEnableRotate;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
