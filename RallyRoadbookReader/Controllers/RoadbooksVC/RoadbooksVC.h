//
//  RoadbooksVC.h
//  RallyRoadbookReader
//
//  Created by C205 on 26/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

typedef enum
{
    MyRoadbooksSectionFolders = 0,
    MyRoadbooksSectionRoadbooks
}MyRoadbooksSection;

@interface RoadbooksVC : BaseVC

@property (strong, nonatomic) NSMutableArray *arrEmails;
@property (strong, nonatomic) NSMutableArray *arrFolders;
@property (strong, nonatomic) NSMutableArray *arrRoadBooks;

@property (strong, nonatomic) NSString *strFolderId;
@property (strong, nonatomic) NSString *strFolderType;
@property (strong, nonatomic) NSString *strRoadbookPageName;
@property (weak, nonatomic) IBOutlet UITableView *tblRoadbooks;

@end
