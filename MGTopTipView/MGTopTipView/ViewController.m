//
//  ViewController.m
//  MGTopTipView
//
//  Created by acmeway on 2017/8/10.
//  Copyright © 2017年 acmeway. All rights reserved.
//

#import "ViewController.h"

#import "MGTopTipView.h"

@interface ViewController ()<MGTopTipViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)topTipViewDidAppear:(MGTopTipView *)topTipView
{
    NSLog(@"落幕消失了");
}
- (IBAction)clickButton:(UIButton *)sender {
    
    if (sender.tag == 1)
    {
        
        [MGTopTipView showTopTipContent:@"这是我的测试内容"
                                 toView:self.view.window].delegate = self;
    }
    else
    {
        [MGTopTipView showTopTipContent:@"这是我的测试我的测试内容这是我的测试内容我的测试内容这是我的测试内容我的测试内容这是我的测试内容我的测试内容这是我的测试内容我的测试内容这是我的测试内容我的测试内容这是我的测试内容我的测试内容这是我的测试内容内容这是我的测试内容试内容"
                                 toView:self.view.window].delegate = self;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
