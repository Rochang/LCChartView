//
//  LCChartViewModel.m
//  LCProject
//
//  Created by liangrongchang on 2017/5/17.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCChartViewModel.h"

@implementation LCChartViewModel

- (instancetype)init {
    if (self = [super init]) {
        _plotButtons = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)modelWithColor:(UIColor *)color plots:(NSArray<NSString *> *)plots project:(NSString *)project {
    LCChartViewModel *model = [[self alloc] init];
    model.color = color;
    model.project = project;
    model.plots = plots;
    return model;
}

@end
