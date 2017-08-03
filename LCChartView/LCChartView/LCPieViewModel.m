//
//  LCPieViewModel.m
//  PieView
//
//  Created by liangrongchang on 2017/5/17.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCPieViewModel.h"

@implementation LCPieViewModel

+ (instancetype)modelWithValue:(CGFloat)value color:(UIColor *)color text:(NSString *)text{
    LCPieViewModel *model = [[LCPieViewModel alloc] init];
    model.value = value;
    model.color  = color;
    model.text = text;
    return model;
}


@end
