//
//  ViewController.m
//  category自动合成属性
//
//  Created by corder on 2019/2/26.
//  Copyright © 2019 corder. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+test.h"

#import <objc/runtime.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.t_point = CGPointMake(100, 100);
    NSLog(@"CGPoint:%@",NSStringFromCGPoint(self.t_point));
    
    BOOL a = self.t_bool;
    NSLog(@"bool:%d", self.t_bool);
    
    self.t_insets = UIEdgeInsetsMake(10, 10, 10, 10);
    NSLog(@"UIEdgeInsets:%@",NSStringFromUIEdgeInsets(self.t_insets));
    
    static NSObject *obj;
    obj = [NSObject new];
    
    self.t_weakObj = obj;
    NSLog(@"weakObj:%@",self.t_weakObj);
    
    obj = nil;
    //weak属性指向的对象释放，观察是否weak属性置为nil
    NSLog(@"weakObj:%@",self.t_weakObj);
    
    self.t_c_string = "corder";
    NSLog(@"c_string:%s",self.t_c_string);
    
    self.t_pointer = &a;
    NSLog(@"pointer:%p",self.t_pointer);
    
    struct my_struct my_s = {26,110,"corder"};
    self.my_s = my_s;
    NSLog(@"age:%d,weight:%f,name:%s",self.my_s.age,self.my_s.weight,self.my_s.name);
    
    NSLog(@"---------------------------");

}

@end
