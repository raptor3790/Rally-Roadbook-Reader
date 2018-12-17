//
//  LoginVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 11/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

typedef enum
{
    LoginCellTypeLogo = 0,
    LoginCellTypeDescription,
    LoginCellDescription,
    LoginCellTypeLoginInfo,
    LoginCellTypeActions,
    LoginCellTypeForgotPassword,
    LoginCellTypeSocialLogin
}LoginCellType;

@interface LoginVC : BaseVC <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (assign, nonatomic) LoginType loginType;

@property (weak, nonatomic) IBOutlet UITableView *tblLogin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTblLogin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightLogo;

@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strPassword;

@end

