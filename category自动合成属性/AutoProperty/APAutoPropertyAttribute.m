
//
//  APAutoPropertyAttribute.m
//  category自动合成属性
//
//  Created by corder on 2019/2/27.
//  Copyright © 2019 corder. All rights reserved.
//

#import "APAutoPropertyAttribute.h"

typedef NS_ENUM(NSUInteger, APAutoPropertyReferenceType) {
    APAutoPropertyReferenceTypeAssign,
    APAutoPropertyReferenceTypeStrong,
    APAutoPropertyReferenceTypeCopy,
    APAutoPropertyReferenceTypeWeak
};

@interface APAutoPropertyAttribute ()
@property (nonatomic, assign) BOOL isWeak;
@property (nonatomic, assign) BOOL isDynamic;
@property (nonatomic, assign) objc_AssociationPolicy policy;
@property (nonatomic, assign) char variableType;
@property (nonatomic, copy) NSString *completeVType;
@property (nonatomic, assign) objc_property_t property_t;
@end

@implementation APAutoPropertyAttribute

+ (instancetype)attributWithProperty:(objc_property_t)property {
    APAutoPropertyAttribute *attribute = [[APAutoPropertyAttribute alloc] init];
    
    
    NSString *attStr = @(property_getAttributes(property));
    NSArray<NSString *> *atts = [attStr componentsSeparatedByString:@","];
    
    APAutoPropertyReferenceType referenceType = APAutoPropertyReferenceTypeAssign;
    char variableType = '@';
    NSString *completeVType;
    BOOL isAtomic = YES;
    BOOL isWeak = NO;
    BOOL isDynamic = NO;
    
    
    for (NSString *str in atts) {
        if ([str hasPrefix:@"T"]) {
            //变量类型
            variableType = [str characterAtIndex:1];
            completeVType = [str substringFromIndex:1];
        } else if ([str isEqualToString:@"&"]) {
            referenceType = APAutoPropertyReferenceTypeStrong;
        } else if ([str isEqualToString:@"C"]) {
            referenceType = APAutoPropertyReferenceTypeCopy;
        } else if ([str isEqualToString:@"W"]) {
            isWeak = YES;
            referenceType = APAutoPropertyReferenceTypeWeak;
        } else if ([str isEqualToString:@"N"]) {
            isAtomic = NO;
        } else if([str isEqualToString:@"D"]) {
            isDynamic = YES;
        }
    }
    
    attribute.isWeak = isWeak;
    attribute.isDynamic = isDynamic;
    attribute.variableType = variableType;
    attribute.completeVType = completeVType;
    attribute.property_t = property;
    if (referenceType == APAutoPropertyReferenceTypeAssign) {
        //基本数据类型会以NSNumber或者NSValue关联属性
        attribute.policy = OBJC_ASSOCIATION_RETAIN;
    } else if ((referenceType == APAutoPropertyReferenceTypeStrong || referenceType == APAutoPropertyReferenceTypeWeak) && isAtomic) {
        attribute.policy = OBJC_ASSOCIATION_RETAIN;
    } else if ((referenceType == APAutoPropertyReferenceTypeStrong || referenceType == APAutoPropertyReferenceTypeWeak) && isAtomic == NO) {
        attribute.policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    } else if (referenceType == APAutoPropertyReferenceTypeCopy && isAtomic) {
        attribute.policy = OBJC_ASSOCIATION_COPY;
    } else if (referenceType == APAutoPropertyReferenceTypeCopy && isAtomic == NO) {
        attribute.policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
    }

    
    
    return attribute;
}

- (instancetype)init {
    if (self = [super init]) {
        self.isWeak = NO;
        self.policy = OBJC_ASSOCIATION_RETAIN;
    }
    return self;
}

@end
