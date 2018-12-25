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
    BaseVC* vc = (BaseVC*)self.topViewController;
    return [vc getOrientation];
}

- (BOOL)shouldAutorotate
{
    BaseVC* vc = (BaseVC*)self.topViewController;
    return [vc getOrientation] == UIInterfaceOrientationMaskAll;
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
