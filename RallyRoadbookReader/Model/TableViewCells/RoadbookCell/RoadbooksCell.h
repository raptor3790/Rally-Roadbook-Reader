//
//  RoadbooksCell.h
//  RallyRoadbookReader
//
//  Created by C205 on 27/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoadbooksCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;

@property (weak, nonatomic) IBOutlet UIButton *btnShare;


@end
