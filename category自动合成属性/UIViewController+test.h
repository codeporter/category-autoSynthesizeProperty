//
//  UIViewController+test.h
//  category自动合成属性
//
//  Created by corder on 2019/3/15.
//  Copyright © 2019 corder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/** 支持自动合成属性，通过@dynamic标记
 
 支持的属性类型：
 1、int，float等基本数据类型
 2、任何oc对象类型
 3、char *,void *指针类型
 4、oc中定义的结构体，CGRect，CGSize，CGPoint,CGVector,CGAffineTransform,CATransform3D,NSRange,UIOffset,UIEdgeInsets
 
 支持weak属性
 */

struct my_struct {
    int age;
    double weight;
    char *name;
};

@interface UIViewController (test)

@property (nonatomic, assign) BOOL t_bool;
@property (nonatomic, assign) CGPoint t_point;
@property (nonatomic, assign) UIEdgeInsets t_insets;
@property (nonatomic, assign) char *t_c_string;
@property (nonatomic, assign) void *t_pointer;
@property (nonatomic, weak) NSObject *t_weakObj;

/** 注意，自定义的结构体不支持自动合成 */
@property (nonatomic, assign) struct my_struct my_s;
@end

NS_ASSUME_NONNULL_END
