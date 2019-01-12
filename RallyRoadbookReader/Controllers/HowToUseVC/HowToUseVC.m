//
//  HowToUseVC.m
//  RallyRoadbookReader
//
//  Created by NC2-25 on 02/10/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "HowToUseVC.h"

@interface HowToUseVC ()<UIWebViewDelegate>{
    UserConfig *objUserConfig;
    BOOL isLightView;
}

@end

@implementation HowToUseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"How Rally Navigator Works";

    _webView.backgroundColor = [UIColor whiteColor];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSString *strLink = @"https://www.rallynavigator.com/rally-navigator-mobile-application";
//    NSString *strLink = @"https://rallynavigator-staging.herokuapp.com/rally-navigator-mobile-application";
    NSURL *urlLink = [NSURL URLWithString:strLink];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:urlLink]];
    
    objUserConfig = [BaseVC getUserConfiguration];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    switch (objUserConfig.themePreference)
    {
        case ThemePreferenceDark:
        {
            self.view.backgroundColor = [UIColor blackColor];
            _activityIndicator.color = [UIColor whiteColor];
            isLightView = false;
            
            self.navigationController.navigationBar.titleTextAttributes
            = @{NSForegroundColorAttributeName : [UIColor lightGrayColor]};
            
            self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
            self.view.backgroundColor = [UIColor blackColor];
            self.webView.backgroundColor = [UIColor blackColor];
        }
            break;
            
        case ThemePreferenceLight:
        {
            self.view.backgroundColor = [UIColor whiteColor];
            _activityIndicator.color = [UIColor blackColor];
            isLightView = true;
            
            self.navigationController.navigationBar.titleTextAttributes
            = @{NSForegroundColorAttributeName : [UIColor blackColor]};
            
            self.navigationController.navigationBar.tintColor = [UIColor blackColor];
            self.view.backgroundColor = [UIColor whiteColor];
            self.webView.backgroundColor = [UIColor whiteColor];
        }
            break;
            
        default:
            break;
    }
    
    if (isLightView) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    }
    else{
        [self.view setBackgroundColor:[UIColor blackColor]];
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (isLightView) {
        return UIStatusBarStyleDefault;
    }
    else{
        return UIStatusBarStyleLightContent;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_webView stopLoading];
    _webView = nil;
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _activityIndicator.hidden = YES;
}

@end
