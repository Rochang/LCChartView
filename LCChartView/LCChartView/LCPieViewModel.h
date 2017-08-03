//
//  LCPieViewModel.h
//  PieView
//
//  Created by liangrongchang on 2017/5/17.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LCPieViewModel : NSObject

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) NSString *text;

+ (instancetype)modelWithValue:(CGFloat)value color:(UIColor *)color text:(NSString *)text;

@end
