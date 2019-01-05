//
//  RegisterVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 17/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@interface RegisterVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordText;

@property (assign, nonatomic) LoginType loginType;

@end
