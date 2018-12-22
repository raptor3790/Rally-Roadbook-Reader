//
//  SVProgressHUD+Scale.m
//  RallyRoadbookReader
//
//  Created by Eliot Gravett on 2018/12/21.
//  Copyright © 2018 C205. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD+Scale.h"
#import "Constant.h"

@implementation SVProgressHUD (Scale)

+ (void) setScale:(BOOL)isScale
{
    if (isScale)
    {
        CGFloat width = 200;
        CGFloat fontSize = 16;
        if (SCREEN_WIDTH >= 375 && SCREEN_WIDTH < 500)
        {
            width = 240;
            fontSize = 20;
        }
        else if (SCREEN_WIDTH >= 500 && SCREEN_WIDTH < 1000)
        {
            width = 350;
            fontSize = 26;
        }
        else if (SCREEN_WIDTH >= 1000)
        {
            width = 850;
            fontSize = 36;
        }
        
        [SVProgressHUD setMinimumSize:CGSizeMake(width, width * 0.67)];
        [SVProgressHUD setFont:THEME_FONT_Medium(fontSize)];
    }
    else
    {
        [SVProgressHUD setMinimumSize:CGSizeZero];
        [SVProgressHUD setFont:THEME_FONT_Medium(16)];
    }
}

@end
