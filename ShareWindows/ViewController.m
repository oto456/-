//
//  ViewController.m
//  ShareWindows
//
//  Created by kakapo on 15/7/29.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import "ViewController.h"
#import "G9shareBaseActivity.h"
#import "G9SharePopupWindow.h"
#import "TestA.h"

@interface ViewController ()
@property (nonatomic, strong) G9SharePopupWindow *window;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    TestA *a = [[TestA alloc] init];
    TestA *b = [[TestA alloc] init];
    TestA *c = [[TestA alloc] init];
    TestA *d = [[TestA alloc] init];
    TestA *q = [[TestA alloc] init];
    TestA *w = [[TestA alloc] init];
    //
    TestA *e = [[TestA alloc] init];
    TestA *f = [[TestA alloc] init];
    TestA *g = [[TestA alloc] init];
    TestA *h = [[TestA alloc] init];
    
    NSArray *array2 = @[e, f, g, h, q, w];
    
    NSArray *array = @[a, b, c, d];
    
    
    _window = [[G9SharePopupWindow alloc] initWithASharedActivity:array actionActivities:array2];
}

- (IBAction)buttonClick:(id)sender {
    [_window show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
