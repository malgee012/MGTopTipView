```

//
//  MTSportResultController.m
//  Medically
//
//  Created by acmeway on 2017/7/12.
//  Copyright © 2017年 acmeway. All rights reserved.
//

#import "MTSportResultController.h"
#import <Masonry.h>
#import "UINavigationBar+MG.h"
#import "UIView+MTLayer.h"
#import "MTUnit.h"
#import "MTSportUnit.h"
typedef void(^SportFeelStatus)(NSInteger type, CGFloat heightValue, CGFloat lowValue);

@interface MTSportResultController ()<UINavigationControllerDelegate,
                                        UIPickerViewDelegate,
                                        UIPickerViewDataSource,
                                        UITextFieldDelegate,
                                        UIGestureRecognizerDelegate,
                                        MGTopTipViewDelegate>
{
    BOOL        _mark;
    
    BOOL        _isPlanVC;
    BOOL        _isExist;
    NSString    *_highValue;
    NSString    *_lowValue;
    NSInteger   _type;
    NSInteger   _sportTime;
    NSInteger   _overHeartTime;
    NSInteger   _rangeTime;
    NSInteger   _underHeartTime;
}
@property (nonatomic, copy) SportFeelStatus     feelStatus;

@property (nonatomic,retain) NSArray *titleArray;

@property (nonatomic,retain) NSArray *detailArray;

@property (retain, nonatomic) UIPickerView *pickerView;

@property (nonatomic, assign) NSInteger   rowA;

@property (nonatomic, weak) UILabel       *highTxt;

@property (nonatomic, strong) UITextField  *tempField;

@property (nonatomic, weak) UILabel       *lowTxt;

@property (nonatomic, assign) BOOL isCanSideBack;

@property (nonatomic, strong) NSMutableArray    *tempArray;

@end

@implementation MTSportResultController

- (instancetype)initWithExistPressure:(BOOL)isExist
                             isPlanVC:(BOOL)isPlanVC
                           feelStatus:(void(^)(NSInteger type, CGFloat heightValue, CGFloat lowValue))item;
{
    if (self = [super init]) {
        
        _isExist = isExist;
        
        _isPlanVC = isPlanVC;
        
        self.feelStatus = item;
        
    }
    return self;
}

- (instancetype)initWithExistPressure:(BOOL)isExist
                             isPlanVC:(BOOL)isPlanVC
                            sportTime:(NSInteger)sportTime
                        overHeartTime:(NSInteger)overHeartTime
                            rangeTime:(NSInteger)rangeTime
                       underHeartTime:(NSInteger)underHeartTime
                           feelStatus:(void(^)(NSInteger type, CGFloat heightValue, CGFloat lowValue))item
{
    if (self = [super init]) {
        
        _isExist = isExist;
        
        _isPlanVC = isPlanVC;
        
        self.feelStatus = item;
        
        _sportTime = sportTime;
        
        _overHeartTime = overHeartTime;
        
        _rangeTime = rangeTime;
        
        _underHeartTime = underHeartTime;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [MTNotification addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    
    [MTNotification addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    [self setupSubviews];
    
    [self setupNavigation];
    
}

- (void)setupSubviews
{
    UIView *bgview = [UIView setupViewWithColor:[UIColor colorWithHex:@"ffffff"]];
    [self.view addSubview:bgview];
    
    NSString *titleContent = @"";// 您今日运动计划已经完成\n请再接再厉！
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleContent];
    
    [attString addAttribute:NSForegroundColorAttributeName
                      value:[UIColor colorWithHex:@"2189F4"]
                      range:NSMakeRange(0, titleContent.length)];
    
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont systemFontOfSize:Font(17)]
                      range:NSMakeRange(0, titleContent.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    style.lineSpacing = viewY(10);
    
    [attString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, titleContent.length)];
    
    UILabel *title = [UILabel setLabelTitle:@"" fontSize:17 textColor:[UIColor colorWithHex:@"2189F4"]];
    
    title.attributedText = attString;
    
    title.textAlignment = NSTextAlignmentCenter;
    
    [bgview addSubview:title];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(bgview.mas_top).offset(viewY(40));
        make.centerX.equalTo(bgview.mas_centerX);
        
    }];
    
    NSString *desContent = @"选择本次的运动感受\n方便我们为您提供更符合自身的运动计划";
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:desContent];
    
    NSMutableParagraphStyle *style2 = [[NSMutableParagraphStyle alloc] init];
    
    style2.lineSpacing = viewY(6);
    
    [att addAttribute:NSParagraphStyleAttributeName value:style2 range:NSMakeRange(0, desContent.length)];
    
    UILabel *desTxt = [UILabel setLabelTitle:@"" fontSize:10 textColor:[UIColor colorWithHex:@"666666"]];
    
    desTxt.attributedText = att;
    
    desTxt.textAlignment = NSTextAlignmentCenter;
    
    [bgview addSubview:desTxt];
    
    [desTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(title.mas_bottom).offset(viewY(20));
        make.centerX.equalTo(self.view.mas_centerX);
        
    }];


    _titleArray = [[NSArray alloc]init];
    
    _titleArray = @[@"轻松",@"适中",@"有点吃力",@"吃力",@"十分辛苦"];
    
    _detailArray = [[NSArray alloc]init];
    
    _detailArray = @[@"呼吸轻松，可以说出完整句子",@"呼吸加快加深，但仍可以说出完整句子",@"呼吸变深，说话开始艰难",@"呼吸吃力，无法流畅的说话",@"无法呼吸"];
    
    _pickerView = [[UIPickerView alloc]init];
    
    _pickerView.delegate = self;
    
    _pickerView.dataSource = self;
    
    _pickerView.backgroundColor = [UIColor clearColor];
    
    _pickerView.width = viewX(201);
    
    _rowA = 1;
    _type = _rowA;
    [_pickerView selectRow:1 inComponent:0 animated:YES];
    
    [bgview addSubview:_pickerView];

    [_pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(desTxt.mas_bottom).offset(viewY(15));
        make.height.mas_equalTo(viewY(200));
        make.width.mas_equalTo(viewX(201));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIView *line = [UIView setupViewWithColor:[UIColor colorWithHex:@"E7EDF0"]];
    
    [bgview addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgview.mas_left).offset(viewX(17));
        make.right.equalTo(bgview.mas_right).offset(viewX(-17));
        make.height.mas_equalTo(viewY(1));
        make.top.equalTo(_pickerView.mas_bottom).offset(viewY(5));
    }];
 
    [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(line.mas_bottom);
    }];
    
    ////////////////////////////////////////////////////////////////////////////////////
    
    UILabel *desTxt2 = [UILabel setLabelTitle:@"请输入运动后血压值"
                                    fontSize:17
                                   textColor:[UIColor colorWithHex:@"2189F4"]];
    [self.view addSubview:desTxt2];
    
    [desTxt2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(line.mas_bottom).offset(viewY(30));
    }];
    
    UILabel *highTxt = [UILabel setLabelTitle:@"收缩压（高压 60-250）" fontSize:14 textColor:[UIColor colorWithHex:@"666666"]];
    self.highTxt = highTxt;
    [self.view addSubview:highTxt];
    
    [highTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(desTxt2.mas_bottom).offset(viewY(30));
    }];
    
    UITextField *highField = [[UITextField alloc] init];

    highField.borderStyle = UITextBorderStyleRoundedRect;
    highField.backgroundColor = [UIColor colorWithHex:@"ffffff"];
    highField.textAlignment = NSTextAlignmentCenter;
    highField.placeholder = @"mmHg";
    highField.delegate = self;
    highField.keyboardType = UIKeyboardTypeDecimalPad;
    highField.returnKeyType = UIReturnKeyDone;
    [highField setLayerBorderColor:[UIColor colorWithHex:@"3FAAF4"]];
    [highField setLayerBorderWidth:0.6];
    [highField setLayerCornerRadius:viewX(12.5)];
    [highField setValue:[UIColor colorWithHex:@"959595"] forKeyPath:@"_placeholderLabel.textColor"];
    [highField setValue:[UIFont boldSystemFontOfSize:Font(12)] forKeyPath:@"_placeholderLabel.font"];
    highField.tag = 111;
    highField.textColor = [UIColor colorWithHex:@"333333"];
    [highField setValue:@3 forKey:@"Ethan"];
    
//    highField.secureTextEntry = NO;
    [self.view addSubview:highField];
    [highField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [highField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(highTxt.mas_bottom).offset(viewY(10));
        make.width.mas_equalTo(viewX(241));
        make.height.mas_equalTo(viewY(26));
    }];
    
    UILabel *lowTxt = [UILabel setLabelTitle:@"舒张压（低压 40-150）" fontSize:14 textColor:[UIColor colorWithHex:@"666666"]];
    self.lowTxt = lowTxt;
    [self.view addSubview:lowTxt];
    
    [lowTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(highField.mas_bottom).offset(viewY(20));
    }];
    
    UITextField *lowField = [[UITextField alloc] init];
    lowField.borderStyle = UITextBorderStyleRoundedRect;
    lowField.backgroundColor = [UIColor colorWithHex:@"ffffff"];
    lowField.textAlignment = NSTextAlignmentCenter;
    lowField.placeholder = @"mmHg";
    lowField.delegate = self;
    lowField.keyboardType = UIKeyboardTypeDecimalPad;
    lowField.returnKeyType = UIReturnKeyDone;
    [lowField setLayerBorderColor:[UIColor colorWithHex:@"3FAAF4"]];
    [lowField setLayerBorderWidth:0.6];
    [lowField setLayerCornerRadius:viewX(12.5)];
    [lowField setValue:[UIColor colorWithHex:@"959595"] forKeyPath:@"_placeholderLabel.textColor"];
    [lowField setValue:[UIFont boldSystemFontOfSize:Font(12)] forKeyPath:@"_placeholderLabel.font"];
    lowField.tag = 222;
    lowField.textColor = [UIColor colorWithHex:@"333333"];
    [lowField setValue:@3 forKey:@"Ethan"];
//    lowField.secureTextEntry = YES;
    [self.view addSubview:lowField];
    [lowField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [lowField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(lowTxt.mas_bottom).offset(viewY(10));
        make.width.mas_equalTo(viewX(241));
        make.height.mas_equalTo(viewY(26));
    }];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *finishBtn = [[UIButton alloc] init];
    
    [finishBtn setBackgroundImage:[MTUnit imageWithColors:[UIColor colorWithHex:@"2189F4"]]
                         forState:UIControlStateNormal];
    
    [finishBtn setBackgroundImage:[MTUnit imageWithColors:[UIColor colorWithHex:@"2177FF"]]
                         forState:UIControlStateHighlighted];
    
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:Font(17)];
    
    [finishBtn setupLayerCornerRadius:viewY(20.5)];
    
    
    [finishBtn addTarget:self action:@selector(clickFinishBtn) forControlEvents:UIControlEventTouchUpInside];
    
    if (_isExist == YES)
    {
        [self.view addSubview:finishBtn];
        
        [finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(lowField.mas_bottom).offset(viewY(30));
            make.width.mas_equalTo(viewX(121));
            make.height.mas_equalTo(viewY(41));
        }];
    }
    else
    {
        desTxt2.hidden = YES;
        
        highTxt.hidden = YES;
        
        highField.hidden = YES;
        
        lowTxt.hidden = YES;
        
        lowField.hidden = YES;
        
        [bgview mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.view.mas_top).offset(viewY(100));
            
        }];
        
        line.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:finishBtn];
        
        [finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(bgview.mas_bottom).offset(viewY(50));
            make.width.mas_equalTo(viewX(121));
            make.height.mas_equalTo(viewY(41));
        }];

        
    }

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.tempField = textField;
    
    return YES;
}

- (void)textFieldDidChange:(id) sender
{
    UITextField *textfield = (UITextField *)sender;
    
    self.tempField = textfield;
    
    if (textfield.tag == 111)
    {
        _highValue = textfield.text;
    }
    else if (textfield.tag == 222)
    {
        _lowValue = textfield.text;
    }
    
}

- (void)clickFinishBtn
{
//    if (self.feelStatus)
//    {
//        self.feelStatus(_type, [_highValue floatValue], [_lowValue floatValue]);
//    }
//    else
//    {
//        self.feelStatus(1, 0.0f, 0.0f);
//    }
    
    if (_isPlanVC)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        
        NSString *content = [MTSportUnit sportTipSloganWithSportTime:_sportTime
                                                       overHeartTime:_overHeartTime
                                                           rangeTime:_rangeTime
                                                      underHeartTime:_underHeartTime
                                                          feelStatus:_type + 1];
        
        if (content)
        {
           [MGTopTipView showTopTipContent:content toView:nil].delegate = self;
        }
        else
        {
            if (self.feelStatus)
            {
                self.feelStatus(_type, [_highValue floatValue], [_lowValue floatValue]);
            }
            else
            {
                self.feelStatus(1, 0.0f, 0.0f);
            }
        }
        
    }
    
}

- (void)topTipViewDidAppear:(MGTopTipView *)topTipView
{
    if (self.feelStatus)
    {
        self.feelStatus(_type, [_highValue floatValue], [_lowValue floatValue]);
    }
    else
    {
        self.feelStatus(1, 0.0f, 0.0f);
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat height = keyboardFrame.origin.y;
    
    CGFloat textField_maxY = self.tempField.bottom;
    
    CGFloat space =  - height + textField_maxY;
    
    if (_mark == NO)
    {
        
        CGRect frame = self.view.frame;
        
        frame.origin.y = frame.origin.y - space ;
        
        self.view.frame = frame;
        
        _mark = YES;
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    _mark = NO;
    
    CGRect frame = self.view.frame;
    
    frame.origin.y = 0;
    
    self.view.frame = frame;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
     [self.view endEditing:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return viewY(50);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0)
    {
        
        return 100;
    }
    return 220;
}
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewX(201), viewY(50))];
    
    view3.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0,viewY(5), viewX(200), viewY(26))];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:Font(14)];
    
    [btn setTitle:[NSString stringWithFormat:@"%@",_titleArray[row]] forState:UIControlStateNormal];
    
    [btn setBackgroundColor:[UIColor clearColor]];
    
    [btn setTitleColor:[UIColor colorWithHex:@"2189F4"] forState:UIControlStateNormal];
    
    btn.layer.masksToBounds = YES;
    
    btn.layer.cornerRadius = viewY(13);
    
    btn.layer.borderWidth = 1;
    
    btn.layer.borderColor = [UIColor colorWithHex:@"2189F4"].CGColor;
    
    [view3 addSubview:btn];
    
    if (row == _rowA) {
        
        [btn setTitleColor:[UIColor colorWithHex:@"FFFFFF"] forState:UIControlStateNormal];
        
        [btn setBackgroundColor:[UIColor colorWithHex:@"2189F4"]];
    }
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(viewX(5), btn.bottom , viewX(191), viewY(15))];
    
    lab.font = [UIFont systemFontOfSize:Font(10)];
    
    lab.textAlignment = NSTextAlignmentCenter;
    
    lab.textColor = [UIColor colorWithHex:@"666666"];
    
    lab.text = [NSString stringWithFormat:@"%@",_detailArray[row]];
    
    [view3 addSubview:lab];
    
    ((UILabel *)[_pickerView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
    
    ((UILabel *)[_pickerView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
    
    return view3;
    
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated{
    
    NSLog(@"component = %ld",(long)component);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _rowA = row;
    
    _type = _rowA;
    
    [_pickerView reloadAllComponents];
}



- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

- (void)setupNavigation
{
    self.navigationController.delegate = self;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationController.navigationBar mg_setBackgroundColor:[UIColor clearColor]];
    
    [UINavigationBar appearance].barTintColor = [UIColor colorWithHex:@"FF8854"];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [UINavigationBar appearance].barTintColor = [UIColor clearColor];
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MTNSUserDefault removeObjectForKey:@"isShowNavigationBar"];
    
    [self.navigationController.navigationBar mg_reset];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationController.navigationBar mg_setBackgroundColor:[UIColor clearColor]];
    
    [UINavigationBar appearance].barTintColor = [UIColor colorWithHex:@"FF8854"];
    
    [self.view endEditing:YES];
}

#pragma mark - isCanSideBack
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
    return self.isCanSideBack;
}

- (void)resetSideBack
{
    self.isCanSideBack=YES;
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark - viewAppear

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isCanSideBack = NO;
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate=self;
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self resetSideBack];
    
}

- (NSMutableArray *)tempArray
{
    if (!_tempArray) {
        _tempArray = [[NSMutableArray alloc] init];
    }
    return _tempArray;
}

- (void)dealloc
{
    [MTNotification removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



```