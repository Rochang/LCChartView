//
//  LCPieView.h
//  LCPieView
//
//  Created by liangrongchang on 2017/5/16.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCPieViewModel.h"

@interface LCPieView : UIView

@property (nonatomic, assign) CGFloat arcWidth;
@property (nonatomic, assign) CGFloat outerArcRadius;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL showText;
@property (nonatomic, assign) BOOL animtion;
@property (nonatomic, assign) BOOL showPercent;
@property (nonatomic, assign) BOOL isCanClick;

/** 注释文字属性 */
@property (nonatomic, copy) void (^noteTextBlock)(UILabel *label);
/** 点击pieView的回调 */
@property (nonatomic, copy) void (^clickPieViewBlock)(LCPieViewModel *model, NSInteger index);

+ (instancetype)pieView;

- (void)showPieViewWithDataSource:(NSArray <LCPieViewModel *>*)dataSource;

@end
