//
//  LCMethod.h
//  LCChartView
//
//  Created by liangrongchang on 2017/8/3.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LCMethod : NSObject

+ (CGSize)sizeWithText:(NSString *)text fontSize:(CGFloat)fontSize;

+ (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect;

+ (CAShapeLayer *)shapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor;

@end
