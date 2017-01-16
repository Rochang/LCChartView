//
//  LCChartViewController.m
//  LCChartView
//
//  Created by liangrongchang on 2017/1/13.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCChartViewController.h"
#import "UIView+LayoutMethods.h"
#import "LCChartView.h"

#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]
#define LCBrown119                      RGB(119, 107, 95)

static BOOL isDouble = YES;
static CGFloat navHeight = 64;
static CGFloat chartViewMargin = 40;
static CGFloat margin = 10;

@interface LCChartViewController ()

@property (strong, nonatomic) LCChartView *axisViewLine;
@property (strong, nonatomic) LCChartView *axisViewLineAndBar;
@property (strong, nonatomic) UIButton *resetDataButton;

@end

@implementation LCChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"🌍_LCChartView";
    self.view.backgroundColor = LCBrown119;
    [self setupNavBar];
    [self.view addSubview:self.resetDataButton];
    [self.view addSubview:self.axisViewLine];
    [self.view addSubview:self.axisViewLineAndBar];
    [self setupSubviews];
    [self resetData];
}

- (void)setupSubviews {
    self.axisViewLine.frame = CGRectMake(0, navHeight + margin, self.view.LC_width, (self.view.LC_height - navHeight - chartViewMargin - 4 * margin) / 2);
    self.resetDataButton.frame = CGRectMake(0, self.axisViewLine.LC_bottom + margin, self.axisViewLine.LC_width, chartViewMargin);
    self.axisViewLineAndBar.frame = CGRectMake(0, self.resetDataButton.LC_bottom + margin, self.axisViewLine.LC_width, self.axisViewLine.LC_height);
}

#pragma mark - reponse
- (void)exchange {
    isDouble = isDouble == YES ? NO : YES;
    [self resetData];
}

- (void)resetData {
    if (isDouble) {
        LCChartViewDataModel *model = [LCChartViewDataModel getModelWithLineColor:RandomColor BarColor:RandomColor plots:[self randomArrayWithCount:18]];
        LCChartViewDataModel *model1 = [LCChartViewDataModel getModelWithLineColor:RandomColor BarColor:RandomColor plots:[self randomArrayWithCount:18]];
        self.axisViewLine.dataSource = @[model, model1];
        [self.axisViewLine drawChartView];
        self.axisViewLineAndBar.dataSource = @[model, model1];
        self.axisViewLineAndBar.showPlotsLabel = NO;
        [self.axisViewLineAndBar drawChartView];
    } else {
        LCChartViewDataModel *model = [LCChartViewDataModel getModelWithLineColor:RandomColor BarColor:RandomColor plots:[self randomArrayWithCount:18]];
        self.axisViewLine.dataSource = @[model];
        [self.axisViewLine drawChartView];
        self.axisViewLineAndBar.dataSource = @[model];
        self.axisViewLineAndBar.showPlotsLabel = NO;
        [self.axisViewLineAndBar drawChartView];
    }
}

#pragma mark - private mothed
- (void)setupNavBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换单双" style:UIBarButtonItemStylePlain target:self action:@selector(exchange)];
}

- (NSArray *)randomArrayWithCount:(NSInteger)dataCounts {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataCounts; i++) {
        NSNumber *number = [NSNumber numberWithInt:arc4random_uniform(1000)];
        [array addObject:number];
    }
    return array.copy;
}


#pragma mark - getter
- (LCChartView *)axisViewLine {
    if (!_axisViewLine) {
        _axisViewLine = [LCChartView getAxisViewLineWithYAxisMaxValue:1000];
    }
    return _axisViewLine;
}

- (LCChartView *)axisViewLineAndBar {
    if (!_axisViewLineAndBar) {
        _axisViewLineAndBar = [LCChartView getAxisViewLineAndBarWithYAxisMaxValue:1000];
    }
    return _axisViewLineAndBar;
}

- (UIButton *)resetDataButton {
    if (!_resetDataButton) {
        _resetDataButton = [[UIButton alloc] init];
        _resetDataButton.backgroundColor = [UIColor redColor];
        [_resetDataButton setTitle:@"随机数据,颜色" forState:UIControlStateNormal];
        _resetDataButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_resetDataButton addTarget:self action:@selector(resetData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetDataButton;
}

@end
