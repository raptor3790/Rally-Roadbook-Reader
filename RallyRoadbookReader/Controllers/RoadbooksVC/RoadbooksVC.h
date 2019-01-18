//
//  RoadbooksVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 26/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

typedef enum {
    MyRoadbooksSectionFolders = 0,
    MyRoadbooksSectionRoadbooks
} MyRoadbooksSection;

@interface RoadbooksVC : BaseVC

@property (weak, nonatomic) IBOutlet UILabel* syncLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *syncLabelHeight;
@property (weak, nonatomic) IBOutlet UITableView* tblRoadbooks;

@property (strong, nonatomic) NSMutableArray* arrEmails;
@property (strong, nonatomic) NSMutableArray* arrFolders;
@property (strong, nonatomic) NSMutableArray* arrRoutes;

@property (nonatomic) BOOL isShareFolder;
@property (strong, nonatomic) NSString* strFolderId;
@property (strong, nonatomic) NSString* strRoadbookPageName;

@end
