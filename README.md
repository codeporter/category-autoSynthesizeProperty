# 分类自动合成属性
一个给分类中的属性自动合成setter和getter方法并绑定ivar的工具库 

### 使用方法
将AutoProperty目录中的文件拖入到工程即可生效，不需要#import操作  
在分类.m文件中，给需要自动合成的属性通过`@dynamic`标记后，就可以正常使用  
用法如下:  

```
@interface NSObject (category)

@property (nonatomic, strong) id cate_obj;
@property (nonatomic, assign) int cate_number;

@end

@implementation NSObject (category)
@dynamic cate_obj, cate_number;


@end
```

目前支持的属性关键字有：  `assign`,`strong`,`weak`,`atomic`,`nonatomic`

  
支持的属性类型：  
1、`int`，`float`等基本数据类型  
2、任何oc对象类型  
3、`char *`,`void *`指针类型  
4、oc中定义的结构体，`CGRect`，`CGSize`，`CGPoint`, `CGVector`, `CGAffineTransform`, `CATransform3D`,`NSRange`, `UIOffset`, `UIEdgeInsets`,不支持自定义的结构体和联合体。
