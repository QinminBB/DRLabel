//
//  ViewController.m
//  DRLabel
//
//  Created by fanren on 16/6/23.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import "DRLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DRLabel *label = [[DRLabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 40)];
    label.text = [[NSAttributedString alloc] initWithString:@"你好 世界是你的" attributes:@{
                            NSForegroundColorAttributeName : [UIColor whiteColor],
                            NSFontAttributeName : [UIFont systemFontOfSize:30]
                 }];
    label.backgroundColor = [UIColor blackColor];
    [self.view addSubview:label];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
