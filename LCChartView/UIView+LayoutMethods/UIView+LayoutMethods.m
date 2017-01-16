//
//  UIView+LayoutMethods.m
//  HeJing
//
//  Created by liangrongchang on 16/10/19.
//  Copyright © 2016年 Rochang. All rights reserved.
//

#import "UIView+LayoutMethods.h"

@implementation UIView (LayoutMethods)

- (CGFloat)LC_height {
    return self.frame.size.height;
}

- (CGFloat)LC_width {
    return self.frame.size.width;
}

- (CGFloat)LC_x {
    return self.frame.origin.x;
}

- (CGFloat)LC_y {
    return self.frame.origin.y;
}


- (CGFloat)LC_centerX {
    return self.center.x;
}

- (CGFloat)LC_centerY {
    return self.center.y;
}

- (CGFloat)LC_top {
    return self.LC_y;
}

- (CGFloat)LC_bottom {
    return self.LC_height + self.LC_y;
}

- (CGFloat)LC_left {
    return self.LC_x;
}

- (CGFloat)LC_right {
    return self.LC_width + self.LC_x;
}

- (void)setLC_x:(CGFloat)x {
    self.frame = CGRectMake(x, self.LC_y, self.LC_width, self.LC_height);
}

- (void)setLC_y:(CGFloat)y {
    self.frame = CGRectMake(self.LC_x, y, self.LC_width, self.LC_height);
}

- (void)setLC_height:(CGFloat)height {
    CGRect newFrame = CGRectMake(self.LC_x, self.LC_y, self.LC_width, height);
    self.frame = newFrame;
}

- (void)setLC_width:(CGFloat)width {
    CGRect newFrame = CGRectMake(self.LC_x, self.LC_y, width, self.LC_height);
    self.frame = newFrame;
}

- (void)setLC_left:(CGFloat)left {
    self.LC_x = left;
}

- (void)setLC_right:(CGFloat)right {
    self.LC_x = right - self.LC_width;
}

- (void)setLC_top:(CGFloat)top {
    self.LC_y = top;
}

- (void)setLC_bottom:(CGFloat)bottom {
    self.LC_y = bottom - self.LC_height;
}

- (void)setLC_centerX:(CGFloat)centerX {
    CGPoint center = CGPointMake(self.LC_centerX, self.LC_centerY);
    center.x = centerX;
    self.center = center;
}

- (void)setLC_centerY:(CGFloat)centerY {
    CGPoint center = CGPointMake(self.LC_centerX, self.LC_centerY);
    center.y = centerY;
    self.center = center;
}

- (void)setLC_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)LC_size{
    return self.frame.size;
}

@end
