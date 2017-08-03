//
//  LCArcView.h
//  HeJing
//
//  Created by liangrongchang on 16/10/20.
//  Copyright © 2016年 Rochang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCArcView : UIView

@property (nonatomic, assign) CGFloat outerRadius;
@property (nonatomic, assign) CGFloat arcWidth;
@property (nonatomic, strong) UIColor *arcColor;
@property (nonatomic, strong) UIColor *bgArcColor;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL showPercentLabel;
@property (nonatomic, assign) CGPoint centerP;
/** 背景圆环,两环间隙 */
@property (nonatomic, assign) CGFloat arcsMargin;

/** 设置percentLabel设置 */
@property (nonatomic, copy) void (^percentLabelBlock)(UILabel *label);
/** 单圆环 */
- (void)showArcViewWithStartAngle:(CGFloat)startA endAngle:(CGFloat)endA animaion:(BOOL)animaion;
/** 背景圆环 */
- (void)showArcViewWithBgStartAngle:(CGFloat)bgStartA endBgAngle:(CGFloat)bgEndA bgAnimation:(BOOL)bgAnimation StartAngle:(CGFloat)startA endAngle:(CGFloat)endA animaion:(BOOL)animaion;

@end
