//
//  APAutoPropertyAttribute.h
//  category自动合成属性
//
//  Created by corder on 2019/2/27.
//  Copyright © 2019 corder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>



NS_ASSUME_NONNULL_BEGIN

@interface APAutoPropertyAttribute : NSObject

@property (nonatomic, assign, readonly) BOOL isWeak;
@property (nonatomic, assign, readonly) BOOL isDynamic;

@property (nonatomic, assign, readonly) objc_AssociationPolicy policy;

/** 变量类型，int，float，id 等等*/
@property (nonatomic, assign, readonly) char variableType;
/** 完整的typeEncoding，例如属性是UIEdgeInsets时，为"{UIEdgeInsets=dddd}"*/
@property (nonatomic, copy, readonly) NSString *completeVType;

@property (nonatomic, assign, readonly) objc_property_t property_t;

+ (instancetype)attributWithProperty:(objc_property_t)property;
@end

NS_ASSUME_NONNULL_END
