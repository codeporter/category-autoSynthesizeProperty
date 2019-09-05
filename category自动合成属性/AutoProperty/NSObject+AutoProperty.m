//
//  NSObject+AutoProperty.m
//  category自动合成属性
//
//  Created by corder on 2019/2/27.
//  Copyright © 2019 corder. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NSObject+AutoProperty.h"
#import "APAutoPropertyAttribute.h"
#import <objc/runtime.h>

@implementation NSObject (AutoProperty)
+ (void)load {
    SEL originalSelector = @selector(resolveInstanceMethod:);
    SEL overrideSelector = @selector(AP_resolveInstanceMethod:);
    Method originalMethod = class_getClassMethod([NSObject class], originalSelector);
    Method overrideMethod = class_getClassMethod([NSObject class], overrideSelector);
    method_exchangeImplementations(originalMethod, overrideMethod);
}

+ (BOOL)AP_resolveInstanceMethod:(SEL)sel {
    if ([self AP_resolveInstanceMethod:sel]) {
        return YES;
    }

    NSString *methodName = NSStringFromSelector(sel);
    NSString *propertyName = AP_propertyNameOfSelector(sel);

    objc_property_t property = class_getProperty(self, [propertyName UTF8String]);
    if (property == nil && [methodName hasPrefix:@"is"]) {
        //如果属性重写了getter = isXXX
        NSString *prefix = [[methodName substringWithRange:NSMakeRange(2, 1)] lowercaseString];
        NSString *tail = [methodName substringFromIndex:3];
        propertyName = [NSString stringWithFormat:@"%@%@",prefix,tail];

        property = class_getProperty(self, [propertyName UTF8String]);
    }


    if (property) {
        APAutoPropertyAttribute *attribute = [self AP_propertyAttributeWithProperty:property];
        if (attribute.isDynamic) {
            return [self AP_dynamicAddPropertyForSelector:sel attribute:attribute];
        }
    }

    return NO;
}

+ (BOOL)AP_dynamicAddPropertyForSelector:(SEL)sel attribute:(APAutoPropertyAttribute *)attribute {
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName hasPrefix:@"set"]) {
        //添加setter方法
        return [self AP_dynamicAddSetterMethod:sel attribute:attribute];
    } else {
        //添加getter方法
        return [self AP_dynamicAddGetterMethod:sel attribute:attribute];
    }
}
+ (BOOL)AP_dynamicAddSetterMethod:(SEL)sel attribute:(APAutoPropertyAttribute *)attribute {
    switch (attribute.variableType) {
            
        case 'B': { //BOOL
            return class_addMethod(self, sel, (IMP)AP_dynamicBOOLSetter, "v@:B");
            break;
        };
        case 'c': { //char
            return class_addMethod(self, sel, (IMP)AP_dynamicCharSetter, "v@:c");
            break;
        };
        case 'C': { //unsigned char
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedCharSetter, "v@:C");
            break;
        };
        case 's': { //short
            return class_addMethod(self, sel, (IMP)AP_dynamicShortSetter, "v@:s");
            break;
        };
        case 'S': { //unsigned short
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedShortSetter, "v@:S");
            break;
        };
        case 'i': { //int
            return class_addMethod(self, sel, (IMP)AP_dynamicIntSetter, "v@:i");
            break;
        };
        case 'I': { //unsigned int
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedIntSetter, "v@:I");
            break;
        };
        case 'l': { //long
            return class_addMethod(self, sel, (IMP)AP_dynamicLongSetter, "v@:l");
            break;
        };
        case 'L': { //unsigned long
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedLongSetter, "v@:L");
            break;
        };
        case 'q': { //long long
            return class_addMethod(self, sel, (IMP)AP_dynamicLongLongSetter, "v@:q");
            break;
        };
        case 'Q': { //unsigned long long
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedLongLongSetter, "v@:Q");
            break;
        };
        case 'f': { //float
            return class_addMethod(self, sel, (IMP)AP_dynamicFloatSetter, "v@:f");
            break;
        };
        case 'd': { //double
            return class_addMethod(self, sel, (IMP)AP_dynamicDoubleSetter, "v@:d");
            break;
        };
        case 'D': { //long double
            return class_addMethod(self, sel, (IMP)AP_dynamicLongDoubleSetter, "v@:D");
            break;
        }
        case '@': { //id
            if (attribute.isWeak) {
                return class_addMethod(self, sel, (IMP)AP_dynamicWeakIdSetter, "v@:@");
            } else {
                return class_addMethod(self, sel, (IMP)AP_dynamicIdSetter, "v@:@");
            }
            break;
        };
        case '#': { //Class
            return class_addMethod(self, sel, (IMP)AP_dynamicClassSetter, "v@:#");
            break;
        };
        case '*': { // char *
            return class_addMethod(self, sel, (IMP)AP_dynamicCharacterStringSetter, "v@:*");
            break;
        }
        case '^':{ //pointer
            return class_addMethod(self, sel, (IMP)AP_dynamicPointerSetter, "v@:^");
            break;
        }
        case '{': { //结构体
            const char *type = [attribute.completeVType UTF8String];
            const char *typeEncoding = [[NSString stringWithFormat:@"v@:%@",attribute.completeVType] UTF8String];
            if (strcmp(type, @encode(CGPoint)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGPointSetter, typeEncoding);
            } else if (strcmp(type, @encode(CGSize)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGSizeSetter, typeEncoding);
            } else if (strcmp(type, @encode(CGRect)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGRectSetter, typeEncoding);
            } else if (strcmp(type, @encode(CGVector)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGVectorSetter, typeEncoding);
            } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGAffineTransformSetter, typeEncoding);
            } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCATransform3DSetter, typeEncoding);
            } else if (strcmp(type, @encode(NSRange)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicNSRangeSetter, typeEncoding);
            } else if (strcmp(type, @encode(UIOffset)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicUIOffsetSetter, typeEncoding);
            } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicUIEdgeInsetsSetter, typeEncoding);
            } else {
                return NO;
            }
            break;
        };
        case '(': { //联合体
            return NO;
            break;
        };
        case '[': {// c数组
            return NO;
            break;
        }
        default: { // unknown
            return NO;
            break;
        };
    }
    return NO;
}
+ (BOOL)AP_dynamicAddGetterMethod:(SEL)sel attribute:(APAutoPropertyAttribute *)attribute {
    switch (attribute.variableType) {
        case 'B': { //BOOL
            return class_addMethod(self, sel, (IMP)AP_dynamicBOOLGetter, "B@:");
            break;
        };
        case 'c': { //char
            return class_addMethod(self, sel, (IMP)AP_dynamicCharGetter, "c@:");
            break;
        };
        case 'C': { //unsigned char
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedCharGetter, "C@:");
            break;
        };
        case 's': { //short
            return class_addMethod(self, sel, (IMP)AP_dynamicShortGetter, "s@:");
            break;
        };
        case 'S': { //unsigned short
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedShortGetter, "S@:");
            break;
        };
        case 'i': { //int
            return class_addMethod(self, sel, (IMP)AP_dynamicIntGetter, "i@:");
            break;
        };
        case 'I': { //unsigned int
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedIntGetter, "I@:");
            break;
        };
        case 'l': { //long
            return class_addMethod(self, sel, (IMP)AP_dynamicLongGetter, "l@:");
            break;
        };
        case 'L': { //unsigned long
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedLongGetter, "L@:");
            break;
        };
        case 'q': { //long long
            return class_addMethod(self, sel, (IMP)AP_dynamicLongLongGetter, "q@:");
            break;
        };
        case 'Q': { //unsigned long long
            return class_addMethod(self, sel, (IMP)AP_dynamicUnsignedLongLongGetter, "Q@:");
            break;
        };
        case 'f': { //float
            return class_addMethod(self, sel, (IMP)AP_dynamicFloatGetter, "f@:");
            break;
        };
        case 'd': { //double
            return class_addMethod(self, sel, (IMP)AP_dynamicDoubleGetter, "d@:");
            break;
        };
        case 'D': { //long double
            return class_addMethod(self, sel, (IMP)AP_dynamicLongDoubleGetter, "D@:");
            break;
        }
        case '@': { //id
            if (attribute.isWeak) {
                return class_addMethod(self, sel, (IMP)AP_dynamicWeakIdGetter, "@@:");
            } else {
                return class_addMethod(self, sel, (IMP)AP_dynamicIdGetter, "@@:");
            }
            break;
        };
        case '#': { //Class
            return class_addMethod(self, sel, (IMP)AP_dynamicClassGetter, "#@:");
            break;
        };
        case '*': { // char *
            return class_addMethod(self, sel, (IMP)AP_dynamicCharacterStringGetter, "*@:");
            break;
        }
        case '^': { //pointer
            return class_addMethod(self, sel, (IMP)AP_dynamicPointerGetter, "^@:");
            break;
        }
        case '{': { //结构体
            const char *type = [attribute.completeVType UTF8String];
            const char *typeEncoding = [[NSString stringWithFormat:@"%@@:",attribute.completeVType] UTF8String];
            if (strcmp(type, @encode(CGPoint)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGPointGetter, typeEncoding);
            } else if (strcmp(type, @encode(CGSize)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGSizeGetter, typeEncoding);
            } else if (strcmp(type, @encode(CGRect)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGRectGetter, typeEncoding);
            } else if (strcmp(type, @encode(CGVector)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGVectorGetter, typeEncoding);
            } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCGAffineTransformGetter, typeEncoding);
            } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicCATransform3DGetter, typeEncoding);
            } else if (strcmp(type, @encode(NSRange)) == 0) {
                return class_addMethod(self, sel, (IMP)AP_dynamicNSRangeGetter, typeEncoding);
            } else if (strcmp(type, @encode(UIOffset)) == 0) {
               return class_addMethod(self, sel, (IMP)AP_dynamicUIOffsetGetter, typeEncoding);
            } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
               return class_addMethod(self, sel, (IMP)AP_dynamicUIEdgeInsetsGetter, typeEncoding);
            } else {
                return NO;
            }
            break;
        }
        case '(': { //联合体
            return NO;
            break;
        };
        case '[': {// c数组
            return NO;
            break;
        }
        default: { // unknown
            return NO;
            break;
        };
    }
    return NO;
}
+ (NSMutableDictionary *)AP_propertyAttributes {
    NSMutableDictionary *dic = objc_getAssociatedObject([self class], _cmd);
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject([self class], _cmd, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}
+ (APAutoPropertyAttribute *)AP_propertyAttributeWithProperty:(objc_property_t)property {
    NSString *propertyName = @(property_getName(property));
    APAutoPropertyAttribute *attribute = self.AP_propertyAttributes[propertyName];
    if (attribute == nil) {
        attribute = [APAutoPropertyAttribute attributWithProperty:property];
        self.AP_propertyAttributes[propertyName] = attribute;
    }
    return attribute;
}

APAutoPropertyAttribute *AP_propertyAttribute(id obj, SEL sel) {
    NSString *propetyName = AP_propertyNameOfSelector(sel);
    return [[obj class] AP_propertyAttributes][propetyName];
}
NSString *AP_propertyNameOfSelector(SEL sel) {
    NSString *name = NSStringFromSelector(sel);
    if ([name hasPrefix:@"set"]) {
        NSString *prefix = [[name substringWithRange:NSMakeRange(3, 1)] lowercaseString];
        NSString *tail = [[name substringFromIndex:4] stringByReplacingOccurrencesOfString:@":" withString:@""];
        name = [NSString stringWithFormat:@"%@%@",prefix,tail];
        return name;
    } else {
        return name;
    }
}


#pragma mark - setter & getter
void AP_dynamicBOOLSetter(id self, SEL _cmd, BOOL value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
BOOL AP_dynamicBOOLGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.boolValue;
}
void AP_dynamicCharSetter(id self, SEL _cmd, char value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
char AP_dynamicCharGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.charValue;
}
void AP_dynamicUnsignedCharSetter(id self, SEL _cmd, unsigned char value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
unsigned char AP_dynamicUnsignedCharGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.unsignedCharValue;
}
void AP_dynamicShortSetter(id self, SEL _cmd, short value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
short AP_dynamicShortGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.shortValue;
}
void AP_dynamicUnsignedShortSetter(id self, SEL _cmd, unsigned short value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
unsigned short AP_dynamicUnsignedShortGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.unsignedShortValue;
}
void AP_dynamicIntSetter(id self, SEL _cmd, int value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
int AP_dynamicIntGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.intValue;
}
void AP_dynamicUnsignedIntSetter(id self, SEL _cmd, unsigned int value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
unsigned int AP_dynamicUnsignedIntGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.unsignedIntValue;
}
void AP_dynamicLongSetter(id self, SEL _cmd, long value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
long AP_dynamicLongGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.longValue;
}
void AP_dynamicUnsignedLongSetter(id self, SEL _cmd, unsigned long value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
unsigned long AP_dynamicUnsignedLongGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.unsignedLongValue;
}
void AP_dynamicLongLongSetter(id self, SEL _cmd, long long value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
long long AP_dynamicLongLongGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.longLongValue;
}
void AP_dynamicUnsignedLongLongSetter(id self, SEL _cmd, unsigned long long value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
unsigned long long AP_dynamicUnsignedLongLongGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.unsignedLongLongValue;
}
void AP_dynamicFloatSetter(id self, SEL _cmd, float value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
float AP_dynamicFloatGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.floatValue;
}
void AP_dynamicDoubleSetter(id self, SEL _cmd, double value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = @(value);
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
double AP_dynamicDoubleGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSNumber *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.doubleValue;
}
void AP_dynamicLongDoubleSetter(id self, SEL _cmd, long double value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    //NSNumber没有longDoubleValue方法，故用NSValue封装数据
    NSValue *boxValue = [NSValue value:&value withObjCType:@encode(long double)];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
long double AP_dynamicLongDoubleGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    long double res;
    [boxValue getValue:&res];
    return res;
}
void AP_dynamicIdSetter(id self, SEL _cmd, id value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    objc_setAssociatedObject(self, attribute.property_t, value, attribute.policy);
}
id AP_dynamicIdGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    return objc_getAssociatedObject(self, attribute.property_t);
}
void AP_dynamicWeakIdSetter(id self, SEL _cmd, id value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    __weak typeof(value) weakValue = value;
    id(^block)(void) = ^(void) {
        return weakValue;
    };
    objc_setAssociatedObject(self, attribute.property_t, block, attribute.policy);
}
id AP_dynamicWeakIdGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    id(^block)(void) = objc_getAssociatedObject(self, attribute.property_t);
    if (block) {
        return block();
    }
    return nil;
}
void AP_dynamicClassSetter(id self, SEL _cmd, Class value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    objc_setAssociatedObject(self, attribute.property_t, value, attribute.policy);
}
Class AP_dynamicClassGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    return objc_getAssociatedObject(self, attribute.property_t);
}
void AP_dynamicCharacterStringSetter(id self, SEL _cmd, char *value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSString *ocString = [NSString stringWithUTF8String:value];
    objc_setAssociatedObject(self, attribute.property_t, ocString, attribute.policy);
}
char *AP_dynamicCharacterStringGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSString *ocString = objc_getAssociatedObject(self, attribute.property_t);
    return (char *)[ocString UTF8String];
}
void AP_dynamicPointerSetter(id self, SEL _cmd, void *value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithPointer:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
void * AP_dynamicPointerGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.pointerValue;
}
void AP_dynamicCGPointSetter(id self, SEL _cmd, CGPoint value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithCGPoint:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
CGPoint AP_dynamicCGPointGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.CGPointValue;
}
void AP_dynamicCGSizeSetter(id self, SEL _cmd, CGSize value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithCGSize:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
CGSize AP_dynamicCGSizeGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.CGSizeValue;
}
void AP_dynamicCGRectSetter(id self, SEL _cmd, CGRect value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithCGRect:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
CGRect AP_dynamicCGRectGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.CGRectValue;
}
void AP_dynamicCGVectorSetter(id self, SEL _cmd, CGVector value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithCGVector:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
CGVector AP_dynamicCGVectorGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.CGVectorValue;
}
void AP_dynamicCGAffineTransformSetter(id self, SEL _cmd, CGAffineTransform value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithCGAffineTransform:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
CGAffineTransform AP_dynamicCGAffineTransformGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.CGAffineTransformValue;
}
void AP_dynamicCATransform3DSetter(id self, SEL _cmd, CATransform3D value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithCATransform3D:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
CATransform3D AP_dynamicCATransform3DGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.CATransform3DValue;
}
void AP_dynamicNSRangeSetter(id self, SEL _cmd, NSRange value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithRange:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
NSRange AP_dynamicNSRangeGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.rangeValue;
}
void AP_dynamicUIOffsetSetter(id self, SEL _cmd, UIOffset value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithUIOffset:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
UIOffset AP_dynamicUIOffsetGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.UIOffsetValue;
}
void AP_dynamicUIEdgeInsetsSetter(id self, SEL _cmd, UIEdgeInsets value) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = [NSValue valueWithUIEdgeInsets:value];
    objc_setAssociatedObject(self, attribute.property_t, boxValue, attribute.policy);
}
UIEdgeInsets AP_dynamicUIEdgeInsetsGetter(id self, SEL _cmd) {
    APAutoPropertyAttribute *attribute = AP_propertyAttribute(self, _cmd);
    NSValue *boxValue = objc_getAssociatedObject(self, attribute.property_t);
    return boxValue.UIEdgeInsetsValue;
}

@end
