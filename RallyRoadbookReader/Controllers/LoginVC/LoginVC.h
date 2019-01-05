//
//  LoginVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@interface LoginVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@property (assign, nonatomic) LoginType loginType;

@end

