//
//  RouteCell.h
//  RallyRoadbookReader
//
//  Created by C205 on 28/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vwLeft;
@property (weak, nonatomic) IBOutlet UIView *vwCenter;
@property (weak, nonatomic) IBOutlet UIView *vwRight;

@property (weak, nonatomic) IBOutlet UIView *vwPerDistance;
@property (weak, nonatomic) IBOutlet UIView *vwAngle;
@property (weak, nonatomic) IBOutlet UIView *vwLocation;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITextView *txtView;

@property (weak, nonatomic) IBOutlet UILabel *lblRow;
@property (weak, nonatomic) IBOutlet UILabel *lblAngle;

@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblPerDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblLatitude;
@property (weak, nonatomic) IBOutlet UILabel *lblLongitude;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightCAPHeading;


@property CAShapeLayer *shapeLayer;
@property CAShapeLayer *dirShapeLayer;
@property CAShapeLayer *triShapeLayer;

- (void)drawPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (void)drawDirectionPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (void)drawTriPathIn:(UIView *)view startPoint:(CGPoint)startPoint leftPoint:(CGPoint)leftPoint rightPoint:(CGPoint)rightPoint;

@end
