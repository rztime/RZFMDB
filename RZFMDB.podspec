Pod::Spec.new do |s|
  s.name         = "RZFMDB"
  s.version      = "0.0.1"
  s.summary      = "对FMDB的封装，以Model的形式，一行代码进行增删改查"

  s.description  = <<-DESC
                   对FMDB的封装，以Model的形式，一行代码进行增删改查，Model的属性可以为任意类型（字符串，整型，浮点型等，NSArray *, NSArray <NSOBject *> *，NSObject *，NSDictionary *，NSData, NSDate等等）。
                   当Model中嵌套多层次的数组、模型数组、字典数组等等，会加大消耗，所以尽量只包含字符串浮点型等等不包含嵌套和数组的属性，可以提高运行效率   
                   DESC
  s.homepage     = "https://github.com/rztime/RZFMDB"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "rztime" => "rztime@vip.qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/rztime/RZFMDB.git", :tag => "#{s.version}" }


  s.source_files  = "RZFMDB/Core/*.{h,m}"
  s.dependency 'MJExtension'
  s.dependency 'FMDB'
  
  s.prefix_header_contents = <<-EOS
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
EOS
  
end
