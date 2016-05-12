//
//  ViewController.m
//  virtualAnimate
//
//  Created by 汤维炜 on 16/5/10.
//  Copyright © 2016年 Tommy. All rights reserved.
//

#import "AnimateViewController.h"
#import "WorkingCycleView.h"
#import "PressureSlider.h"

#define KSCREENWIDTH    self.view.frame.size.width
#define KSCREENHEIGHT   self.view.frame.size.height

typedef enum : NSInteger {
    appointStatus = 0,
    prepareStatus,
    grindStatus,
    extractStatus,
    flowingStatus,
    finishStatus,
} WorkStatus;

@interface AnimateViewController ()


@property (nonatomic, assign ) WorkStatus       workStatus;
@property (nonatomic, strong ) PressureSlider   *slider;
@property (nonatomic, strong ) WorkingCycleView *cycleView;
@property (nonatomic, strong ) NSArray          *stageArray;
@property (nonatomic, strong ) UIButton         *operateButton;
@property (nonatomic, strong ) UILabel          *status_lb;
@property (nonatomic, strong ) UILabel          *time_lb;
@property (nonatomic, strong ) UILabel          *flowValue_lb;
@property (nonatomic, strong ) UILabel          *timeValue_lb;

@property (nonatomic, assign ) int              mililliter;// 出浆量
@property (nonatomic, assign ) int              hour;
@property (nonatomic, assign ) int              mins;
@property (nonatomic, assign ) int              pointMake;

@property (nonatomic, strong ) NSTimer          *virtualTime;
@end

@implementation AnimateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationUI];
    [self initMainUI];
    [self defaultData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (self.cycleView) {
        [self.cycleView stopAnimate];
    }
    
    [self.virtualTime invalidate];
    self.virtualTime = nil;
}

- (void)defaultData {
    self.stageArray = @[@"预约",@"准备",@"加热",@"沸腾",@"完成"];
}

#pragma mark - UI

- (void)initNavigationUI {
    NSString *title = @"slider-animate";
    if (_uitype == 1) {
        title = @"cycle-animate";
    }
    self.navigationItem.title = title;
    
}

- (void)initMainUI {
    
    [self initMainView];
    [self initBottomView];
    self.view.backgroundColor = [UIColor whiteColor];
}



- (void)initMainView {
    switch (_uitype) {
        case sliderType:
            
            [self initMainTopViewWithWorkType:sliderType];
            break;
        case cycleType:
            
            [self initMainTopViewWithWorkType:cycleType];
            break;
    }
}

- (void)initBottomView {
    _operateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _operateButton.frame = CGRectMake(KSCREENWIDTH/5, KSCREENHEIGHT - 180, KSCREENWIDTH/5*3, 33);
    [_operateButton setTitle:@"取消制作" forState:UIControlStateNormal];
    [_operateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_operateButton setBackgroundImage:[UIImage imageNamed:@"btn"] forState:UIControlStateNormal];
    [_operateButton addTarget:self action:@selector(operateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_operateButton];
}


- (void)operateButtonClicked:(UIButton *)sender {
    
        // 预约状态
        sender.selected = !sender.selected;
        if (sender.selected) {
            [self.virtualTime invalidate];
            self.virtualTime = nil;
            [self.cycleView stopAnimate];
        }else {
            [self.virtualTime fire];
            [self.cycleView startAnimate];
        }

}


- (void)initMainTopViewWithWorkType:(int)worktype {
    
    switch (worktype) {
        case sliderType:
            [self initSliderView];
            break;
        case cycleType:
            [self initCycleView];
            break;
            
        default:
            break;
    }
}

/**
 *  工作阶段状态
 */
- (void)initSliderView {
    // 适配
    CGFloat SCREENWITH = self.view.frame.size.width;
    CGFloat SCGREENHEIGHT = self.view.frame.size.height;
    CGFloat BGVIEWHEIGHT = 300;
    CGFloat sliderWith = SCREENWITH -40;
    CGFloat sliderLeft = 20;
    CGFloat MARGINTOP = 20+64;
    CGFloat sliderH = 320;
    if (SCREENWITH == 375) {
        MARGINTOP = 50+64;
        BGVIEWHEIGHT = 330;
    }else if(SCREENWITH == 414) {
        MARGINTOP = 70+64;
        BGVIEWHEIGHT = 330;
    }else if (SCREENWITH == 320 && SCGREENHEIGHT ==568) {
        BGVIEWHEIGHT = 310;
        sliderWith = SCREENWITH - 20;
        sliderLeft = 10;
        sliderH = 300;
    }
    
    UIView *sliderBgview = [self drawBgviewWithMarginTop:MARGINTOP Width:self.view.frame.size.width Height:BGVIEWHEIGHT];
    sliderBgview.backgroundColor = [UIColor whiteColor];
    [self setTipsLabelOnView:sliderBgview WithType:@"slider"];
    
    UIView *centerView = [self drawCenterViewOnBgview:sliderBgview withWidth:self.view.frame.size.width/5*3];
    
    self.status_lb = [self setLabelCurrentStatusOnCenterView:centerView];

    
    self.time_lb = [self setLabelCurrentTimeOnCenterView:centerView];
    self.time_lb.font = [UIFont systemFontOfSize:12];
    self.time_lb.textColor = [UIColor grayColor];
    
    self.hour=11;
    self.mins=12;
    
    [self setSliderOnView:sliderBgview withWidth:sliderWith sliderLeft:sliderLeft sliderHeight:sliderH];
}

/**
 *  转圈工作状态
 */
- (void)initCycleView {
    // 适配
    CGFloat CYCLEWIDTH = 180;
    CGFloat BGVIEWHEIGHT = 300;
    CGFloat MARGINTOP = 20+64;
    if (KSCREENWIDTH == 414) {
        CYCLEWIDTH = 250;
        BGVIEWHEIGHT = 320;
        MARGINTOP = 40+64;
    }else if (KSCREENWIDTH == 375){
        MARGINTOP = 30+64;
        CYCLEWIDTH = 230;
        BGVIEWHEIGHT = 320;
    }else if (KSCREENWIDTH == 320) {
        MARGINTOP = 30+64;
        BGVIEWHEIGHT = 280;
    }
    
    UIView *bgview = [self drawBgviewWithMarginTop:MARGINTOP Width:self.view.frame.size.width Height:BGVIEWHEIGHT];
    
    UIView *cycleview = [self drawBgviewWithMarginTop:MARGINTOP Width:CYCLEWIDTH Height:CYCLEWIDTH];
    [bgview addSubview:cycleview];
    [self setTipsLabelOnView:bgview  WithType:@"clean"];
    
    UIView *centerView = [self drawCenterViewOnBgview:cycleview withWidth:140];
    self.cycleView = [[WorkingCycleView alloc]initWithFrame:CGRectMake(0, 0, CYCLEWIDTH, CYCLEWIDTH)];
    [self.cycleView startAnimate];
    [cycleview addSubview:self.cycleView];
    
    self.status_lb = [self setLabelCurrentStatusOnCenterView:centerView];
    NSString *statusStr = @" 清洗中...";
    self.status_lb.attributedText = [self statusStringPropertyChangeWithString:statusStr Type:0];
    
    self.time_lb = [self setLabelCurrentTimeOnCenterView:centerView];
    self.hour=11;
    self.mins=12;
    NSString *timeStr = [NSString stringWithFormat:@"预计%d分钟后完成",self.mins];
    self.time_lb.font = [UIFont systemFontOfSize:14];
    self.time_lb.textColor = [UIColor grayColor];
    self.time_lb.attributedText = [self statusStringPropertyChangeWithString:timeStr Type:1];
    
    self.virtualTime = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(reducingTime) userInfo:nil repeats:YES];
    [self.virtualTime fire];
}

- (void)reducingTime {
    self.mins -= 1;
    if (self.mins < 1) {
        [self.virtualTime invalidate];
        self.virtualTime = nil;
        return;
    }
    NSString *timeStr = [NSString stringWithFormat:@"预计%d分钟后完成",self.mins];
    self.time_lb.attributedText = [self statusStringPropertyChangeWithString:timeStr Type:1];
    
}

- (UIView *)drawCenterViewOnBgview:(UIView *)bgview withWidth:(CGFloat)width {
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, width, 70);
    view.center = CGPointMake(bgview.frame.size.width/2, bgview.frame.size.height/2);
    [bgview addSubview:view];
    
    return view;
}

- (UIView *)drawBgviewWithMarginTop:(CGFloat) margintop Width:(CGFloat)width Height:(CGFloat)height{
    
    UIView *bgview = [[UIView alloc]init];
    bgview.frame = CGRectMake(0, margintop, width, height);
    bgview.center = CGPointMake(self.view.frame.size.width/2, height/2+margintop);
    [self.view addSubview:bgview];
    
    return bgview;
}

- (void)setSliderOnView:(UIView *)bgview withWidth:(CGFloat)width sliderLeft:(CGFloat)left sliderHeight:(CGFloat)height{
   
    self.stageArray = @[@"预约",@"准备",@"加热",@"沸腾",@"完成"];
    self.slider = [[PressureSlider alloc] initWithFrame:CGRectMake(left, 0, width, height)];
    self.slider.unfilledColor = [UIColor lightGrayColor];
    self.slider.filledColor = [UIColor orangeColor];
    self.slider.hightLightPointCount = 1;
    self.slider.progress = 0;
    self.slider.normalPointColor = self.slider.unfilledColor;
    self.slider.hightLightPointColor = self.slider.filledColor;
    self.slider.backgroundColor = [UIColor whiteColor];
    [self.slider setInnerMarkingLabels:self.stageArray];
    
    self.slider.labelFont = [UIFont fontWithName:@"Hiragino Sans W3" size:11];
    self.slider.offsetAngle = 95 / 2;
    self.slider.startAngle = 90 + self.slider.offsetAngle;
    self.slider.endAngle = 360 + (90 - self.slider.offsetAngle);
    self.slider.lineWidth = 3;
    self.slider.labelColor = [UIColor grayColor];
    self.slider.handleColor = self.slider.filledColor;
    [bgview insertSubview:self.slider atIndex:0];
    self.pointMake = 0;

    self.virtualTime = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(virtualUsing) userInfo:nil repeats:YES];
    [self.virtualTime fire];
    
}

- (void)virtualUsing {
    self.pointMake += 1;
    NSString *timeStr;
    if (self.pointMake < self.stageArray.count) {
        self.status_lb.attributedText = [self statusStringPropertyChangeWithString:self.stageArray[self.pointMake] Type:0];
        self.slider.hightLightLabelIndex = self.pointMake;
        self.slider.hightLightPointCount = self.slider.hightLightLabelIndex + 1;
        self.slider.progress = (100 / ([self.stageArray count] - 1)) * self.slider.hightLightLabelIndex;
        timeStr = [self calculateAppointingTime];
        self.time_lb.attributedText = [self statusStringPropertyChangeWithString:timeStr Type:1];
        
    }else {
        [self.virtualTime invalidate];
        self.virtualTime = nil;
    }
    
}

- (void)setTipsLabelOnView:(UIView *)bgview  WithType:(NSString *)type {
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, KSCREENHEIGHT-250, KSCREENWIDTH, 30);
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"制作中，杯口有水气冒出，请勿靠太近!";
    
    label.textColor = [UIColor orangeColor];

    [self.view addSubview:label];
    
}

- (UILabel *)setLabelCurrentStatusOnCenterView:(UIView *)centerView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, centerView.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:label];

    return label;
}

- (UILabel *)setLabelCurrentTimeOnCenterView:(UIView *)centerView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, centerView.frame.size.height-25, centerView.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:label];

    return label;
}

- (UILabel *)setLabelShowWorkingStatusOnview:(UIView *)bgview WithMarginType:(int)marginType {
    UILabel *labels = [[UILabel alloc]init];
    [bgview addSubview:labels];
    if (marginType == 0) {
        labels.center = CGPointMake(bgview.center.x, bgview.frame.origin.y+9);
        
    }else {
        labels.center = CGPointMake(bgview.center.x, bgview.frame.origin.y+9);
    }
    return labels;
}


#pragma mark - Private Method

- (NSMutableAttributedString *)statusStringPropertyChangeWithString:(NSString *)string Type:(NSInteger)type{
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:string];
    int fontSize;
    
    if (0 == type) {
        fontSize = 22;
        NSRange normalrange = NSMakeRange(0, [string length]);
        NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor orangeColor]};
        [attStr addAttributes:dic range:normalrange];
    }else if(type == 1) {
        
        fontSize = 14;
        NSRange Range = NSMakeRange(0, [string length]);
        NSDictionary *graydic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor grayColor]};
        [attStr addAttributes:graydic range:Range];
    }else if (type == 3) {
        NSRange range = NSMakeRange([string length]-2, 2);
        NSDictionary *lightGrayDic = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]};
        [attStr addAttributes:lightGrayDic range:range];
    }else if (type == 4) {
        NSRange range = NSMakeRange([string length]-1, 1);
        NSDictionary *lightGrayDic = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]};
        [attStr addAttributes:lightGrayDic range:range];
    }
    
    return attStr;
}

- (NSString *)calculateAppointingTime {
    
    NSString *newTimeString;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *nowTime = [dateFormat stringFromDate:[NSDate date]];
    NSArray *timeArr = [nowTime componentsSeparatedByString:@":"];
    int hour_now = [timeArr[0] intValue];
    int min_now = [timeArr[1] intValue];
    
   NSString *timeStr = @"预计18:00完成";
    // 小时
    NSString *currentHour = [NSString stringWithFormat:@"%d",hour_now];
    if (hour_now < 10) {
        currentHour = [NSString stringWithFormat:@"0%d",hour_now];
    }
    
    
    // 分钟
    NSString *currentMin = [NSString stringWithFormat:@"%d",min_now];
    if (min_now < 10) {
        currentMin = [NSString stringWithFormat:@"0%d",min_now];
    }
    NSRange hourRange = NSMakeRange(2,2);
    NSRange minRange = NSMakeRange(5, 2);
    timeStr = [timeStr stringByReplacingCharactersInRange:hourRange withString:currentHour];
    newTimeString = [timeStr stringByReplacingCharactersInRange:minRange withString:currentMin];
    
    return newTimeString;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
