//
//  SettingsCell.h
//  RallyRoadbookReader
//
//  Created by C205 on 14/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UISwitch *switchConfig;

@property (weak, nonatomic) IBOutlet UIButton *btnMiles;
@property (weak, nonatomic) IBOutlet UIButton *btnKilometers;

@property (weak, nonatomic) IBOutlet UIButton *btnLogout;

@property (weak, nonatomic) IBOutlet UILabel *lblNavigationTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnCloseWindow;

@property (weak, nonatomic) IBOutlet UILabel *redBordeer;

@property (weak, nonatomic) IBOutlet UILabel *lblCalibrate;

@property (weak, nonatomic) IBOutlet UIStepper *stepperView;

@property (weak, nonatomic) IBOutlet UILabel *lblOdoValue;




@end
