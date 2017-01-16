//
//  UIView+LayoutMethods.h
//  HeJing
//
//  Created by liangrongchang on 16/10/19.
//  Copyright © 2016年 Rochang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LayoutMethods)

- (CGFloat)LC_height;
- (CGFloat)LC_width;
- (CGFloat)LC_x;
- (CGFloat)LC_y;

- (CGFloat)LC_centerX;
- (CGFloat)LC_centerY;

- (CGFloat)LC_left;
- (CGFloat)LC_top;
- (CGFloat)LC_bottom;
- (CGFloat)LC_right;
- (CGSize)LC_size;

- (void)setLC_height:(CGFloat)height;
- (void)setLC_width:(CGFloat)width;
- (void)setLC_x:(CGFloat)x;
- (void)setLC_y:(CGFloat)y;

- (void)setLC_centerX:(CGFloat)centerX;
- (void)setLC_centerY:(CGFloat)centerY;

- (void)setLC_top:(CGFloat)top;
- (void)setLC_left:(CGFloat)left;
- (void)setLC_right:(CGFloat)right;
- (void)setLC_bottom:(CGFloat)bottom;
- (void)setLC_size:(CGSize)LC_size;

@end
