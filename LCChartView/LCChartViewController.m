//
//  LCChartViewController.m
//  LCChartView
//
//  Created by liangrongchang on 2017/1/13.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCChartViewController.h"
#import "LCChartView.h"
#import "LCPieView.h"
#import "LCArcView.h"
#import "UIView+LCLayout.h"

static BOOL isDouble = YES;
#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

@interface LCChartViewController ()

@property (nonatomic, strong) UIScrollView *contentView;
@property (strong, nonatomic) LCChartView *chartViewLine;
@property (strong, nonatomic) LCChartView *chartViewBar;
@property (strong, nonatomic) LCPieView *pieView;
@property (nonatomic, strong) LCArcView *arcView;

@end

@implementation LCChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"LCChartView";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNavBar];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.chartViewLine];
    [self.contentView addSubview:self.chartViewBar];
    [self.contentView addSubview:self.pieView];
    [self.contentView addSubview:self.arcView];
    [self resetData];
    self.contentView.contentSize = CGSizeMake(0, self.arcView.LC_bottom + 50);
}

#pragma mark - reponse
- (void)exchange {
    isDouble = isDouble == YES ? NO : YES;
    [self resetData];
}

- (void)resetData {
    if (isDouble) {
        LCChartViewModel *model = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"1组"];
        LCChartViewModel *model1 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"2组"];
        LCChartViewModel *model2 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"3组"];
        LCChartViewModel *model3 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"4组"];
        LCChartViewModel *model4 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"5组"];
        NSArray *dataSource = @[model, model1, model2, model3, model4];
        self.chartViewLine.title = @"折线图";
        [self.chartViewLine showChartViewWithYAxisMaxValue:1000 dataSource:@[model, model1]];
        
        self.chartViewBar.title = @"柱状图";
        [self.chartViewBar showChartViewWithYAxisMaxValue:1000 dataSource:dataSource];
        
    } else {
        LCChartViewModel *model = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"单组"];
        [self.chartViewLine showChartViewWithYAxisMaxValue:1000 dataSource:@[model]];
        
        [self.chartViewBar showChartViewWithYAxisMaxValue:1000 dataSource:@[model]];
    }
    
    LCPieViewModel *modelP0 = [LCPieViewModel modelWithValue:arc4random_uniform(100) color:[UIColor redColor] text:@"1组"];
    LCPieViewModel *modelP1 = [LCPieViewModel modelWithValue:arc4random_uniform(100) color:[UIColor grayColor] text:@"2组"];
    LCPieViewModel *modelP2 = [LCPieViewModel modelWithValue:arc4random_uniform(100) color:[UIColor blueColor] text:@"3组"];
    [self.pieView showPieViewWithDataSource:@[modelP0, modelP1, modelP2]];
    
    [self.arcView showArcViewWithBgStartAngle:0 endBgAngle:M_PI * 2 bgAnimation:NO StartAngle:0 endAngle:M_PI animaion:YES];
    
}

#pragma mark - private mothed
- (void)setupNavBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新数据" style:UIBarButtonItemStylePlain target:self action:@selector(exchange)];
}

- (NSArray *)randomArrayWithCount:(NSInteger)dataCounts {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataCounts; i++) {
        NSString *number = [NSString stringWithFormat:@"%d",arc4random_uniform(1000)];
        [array addObject:number];
    }
    return array.copy;
}


#pragma mark - getter
- (LCChartView *)chartViewLine {
    if (!_chartViewLine) {
        _chartViewLine = [LCChartView chartViewWithType:LCChartViewTypeLine];
        _chartViewLine.frame = CGRectMake(0, 64, self.view.LC_width, 250);
    }
    return _chartViewLine;
}

- (LCChartView *)chartViewBar {
    if (!_chartViewBar) {
        _chartViewBar = [[LCChartView alloc] initWithFrame:CGRectMake(0, 350, self.view.LC_width, 250) chartViewType:LCChartViewTypeBar];
    }
    return _chartViewBar;
}

- (LCPieView *)pieView {
    if (!_pieView) {
        _pieView = [LCPieView pieView];
        _pieView.frame = CGRectMake(0, 650, self.view.LC_width, 200);
    }
    return _pieView;
}

- (LCArcView *)arcView {
    if (!_arcView) {
        _arcView = [[LCArcView alloc] initWithFrame:CGRectMake(0, 900, self.view.LC_width, 150)];
    }
    return _arcView;
}

- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.LC_width, self.view.LC_height - 49)];
    }
    return _contentView;
}

@end
