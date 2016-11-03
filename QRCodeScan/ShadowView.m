//
//  ShadowView.m
//  QRCodeScan
//
//  Created by wenyou on 2016/10/12.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import "ShadowView.h"

@implementation ShadowView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexValue:0x000000 alpha:80];
        
        UIBezierPath *outPath = [UIBezierPath bezierPathWithRect:frame];
        CGSize size = frame.size;
        CGFloat width = size.width - 50 * 2;
        UIBezierPath *inPath = [[UIBezierPath bezierPathWithRect:CGRectMake(50, (size.height - width) / 2, width, width)] bezierPathByReversingPath];
        //[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y - 25) radius:50 startAngle:0 endAngle:2 * M_PI clockwise:NO];
        [outPath appendPath:inPath];
        outPath.usesEvenOddFillRule = YES;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = outPath.CGPath;
        self.layer.mask = shapeLayer;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    const CGFloat lineWidth = 4;
    const CGFloat lineLenght = 20;
    
    CGSize size = self.frame.size;
    CGFloat width = size.width - 50 * 2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [COLOR_BIANCHI setStroke];
    [path setLineWidth:4];
    
    [path moveToPoint:CGPointMake(50 - lineWidth / 2, (size.height - width) / 2 + lineLenght)];
    [path addLineToPoint:CGPointMake(50 - lineWidth / 2, (size.height - width) / 2 - lineWidth / 2)];
    [path addLineToPoint:CGPointMake(50 - lineWidth / 2 + lineLenght, (size.height - width) / 2 - lineWidth / 2)];
    
    [path moveToPoint:CGPointMake(size.width - 50 - lineLenght, (size.height - width) / 2 - lineWidth / 2)];
    [path addLineToPoint:CGPointMake(size.width - 50 + lineWidth / 2, (size.height - width) / 2 - lineWidth / 2)];
    [path addLineToPoint:CGPointMake(size.width - 50 + lineWidth / 2, (size.height - width) / 2 + lineLenght)];
    
    [path moveToPoint:CGPointMake(size.width - 50 + lineWidth / 2, (size.height + width) / 2 - lineLenght)];
    [path addLineToPoint:CGPointMake(size.width - 50 + lineWidth / 2, (size.height + width) / 2 + lineWidth / 2)];
    [path addLineToPoint:CGPointMake(size.width - 50 - lineLenght, (size.height + width) / 2 + lineWidth / 2)];
    
    [path moveToPoint:CGPointMake(50 - lineWidth / 2 + lineLenght, (size.height + width) / 2 + lineWidth / 2)];
    [path addLineToPoint:CGPointMake(50 - lineWidth / 2, (size.height + width) / 2 + lineWidth / 2)];
    [path addLineToPoint:CGPointMake(50 - lineWidth / 2, (size.height + width) / 2 - lineLenght)];
    
    [path stroke];
}
@end
