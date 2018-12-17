//
//  RouteCell.m
//  RallyRoadbookReader
//
//  Created by C205 on 28/09/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "RouteCell.h"

@implementation RouteCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.vwLeft.layer.borderWidth = 2.0f;
    self.vwRight.layer.borderWidth = 2.0f;
    self.vwCenter.layer.borderWidth = 2.0f;
    
    self.vwLeft.layer.borderColor = [UIColor blackColor].CGColor;
    self.vwRight.layer.borderColor = [UIColor blackColor].CGColor;
    self.vwCenter.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.vwPerDistance.layer.borderWidth = 2.0f;
    self.vwAngle.layer.borderWidth = 2.0f;
    self.vwLocation.layer.borderWidth = 2.0f;
    
    self.vwPerDistance.layer.borderColor = [UIColor blackColor].CGColor;
    self.vwAngle.layer.borderColor = [UIColor blackColor].CGColor;
    self.vwLocation.layer.borderColor = [UIColor blackColor].CGColor;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)drawPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [_shapeLayer removeFromSuperlayer];
    
    _shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    //    CAShapeLayer *thinShapeLayer = [CAShapeLayer layer];
    //    UIBezierPath *thinPath = [UIBezierPath bezierPath];
    //    [thinPath moveToPoint:startPoint];
    //    [thinPath addLineToPoint:CGPointMake(endPoint.x + 15, endPoint.y - 30)];
    
    _shapeLayer.path = path.CGPath;
    //    thinShapeLayer.path = thinPath.CGPath;
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        //         thinShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        //         thinShapeLayer.strokeColor = [UIColor blackColor].CGColor;
    }
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.lineWidth = 4;
    //    thinShapeLayer.fillColor = [UIColor clearColor].CGColor;
    //    thinShapeLayer.lineWidth = 1;
    [view.layer addSublayer:_shapeLayer];
    //    [view.layer addSublayer:thinShapeLayer];
}

- (void)drawDirectionPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [_dirShapeLayer removeFromSuperlayer];
    
    _dirShapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    _dirShapeLayer.path = path.CGPath;
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _dirShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    }
    else
    {
        _dirShapeLayer.strokeColor = [UIColor blackColor].CGColor;
    }
    _dirShapeLayer.fillColor = [UIColor clearColor].CGColor;
    _dirShapeLayer.lineWidth = 4;
    [view.layer addSublayer:_dirShapeLayer];
}

- (void)drawTriPathIn:(UIView *)view startPoint:(CGPoint)startPoint leftPoint:(CGPoint)leftPoint rightPoint:(CGPoint)rightPoint
{
    [_triShapeLayer removeFromSuperlayer];
    
    _triShapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:leftPoint];
    [path addLineToPoint:rightPoint];
    [path closePath];
    _triShapeLayer.path = path.CGPath;
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _triShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _triShapeLayer.fillColor = [UIColor lightGrayColor].CGColor;
        
    }
    else
    {
        _triShapeLayer.strokeColor = [UIColor blackColor].CGColor;
        _triShapeLayer.fillColor = [UIColor blackColor].CGColor;
        
    }
    _triShapeLayer.lineWidth = 4;
    _triShapeLayer.zPosition = 2;
    [view.layer insertSublayer:_triShapeLayer atIndex:0];
}

@end
