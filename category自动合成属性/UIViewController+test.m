
//
//  UIViewController+test.m
//  category自动合成属性
//
//  Created by corder on 2019/3/15.
//  Copyright © 2019 corder. All rights reserved.
//

#import "UIViewController+test.h"
#import <objc/runtime.h>

@implementation UIViewController (test)

@dynamic t_bool, t_point, t_insets, t_c_string, t_pointer, t_weakObj;

//因为不支持自动合成结构体,需要自己手动实现setter和getter
- (struct my_struct)my_s {
    NSValue *value = objc_getAssociatedObject(self, @selector(my_s));
    struct my_struct my_s = {0,0,NULL};
    if (value) {
        [value getValue:&my_s];
    }
    return my_s;
}
- (void)setMy_s:(struct my_struct)my_s {
    NSValue *value = [NSValue value:&my_s withObjCType:@encode(struct my_struct)];
    objc_setAssociatedObject(self, @selector(my_s), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
