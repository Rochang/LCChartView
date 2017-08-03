//
//  LCMethod.m
//  LCChartView
//
//  Created by liangrongchang on 2017/8/3.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCMethod.h"

@implementation LCMethod

+ (CGSize)sizeWithText:(NSString *)text fontSize:(CGFloat)fontSize {
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]};
    return [text sizeWithAttributes:attr];
}

+ (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (CAShapeLayer *)shapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = fillColor.CGColor;
    shapeLayer.strokeColor = strokeColor.CGColor;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.lineJoin = kCALineJoinBevel;
    shapeLayer.path = path.CGPath;
    return shapeLayer;
}

@end
