//
//  ViewController.m
//  PSSCycleView
//
//  Created by 山不在高 on 17/7/9.
//  Copyright © 2017年 山不在高. All rights reserved.
//

#import "ViewController.h"
#import "PSSCycleView.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenSize   [UIScreen mainScreen].bounds.size
#define kWindows [[UIApplication sharedApplication].delegate window]

@interface ViewController () <PSSCycleViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    PSSCycleView *view = [[PSSCycleView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 200)];
    view.backgroundColor = [UIColor redColor];
    view.delegate = self;
    [self.view addSubview:view];
    view.duration = 4;
    [view refreshCycle];
}
// 只有在创建View的时候, 才会调用这个方法, 总共只调用`numberOfItemsInCycleView:`次
- (UIView *)cycleView:(PSSCycleView *)cycleView  cell:(UICollectionViewCell *)cell forItemAtIndex:(NSInteger)index {
    
    UILabel *view = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    view.backgroundColor = [UIColor purpleColor];
    view.text = [NSString stringWithFormat:@"%ld", index];
    view.textAlignment = NSTextAlignmentCenter;
    return view;
}
- (NSInteger)numberOfItemsInCycleView:(PSSCycleView *)cycleView
{
    return 5;
}
- (void)cycleView:(PSSCycleView *)cycleView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"%ld", index);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
