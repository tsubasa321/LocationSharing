//
//  LocaleContainer.h
//  KiiSDK-Private
//
//  Created by Yongping on 4/22/16.
//  Copyright © 2016 Kii Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

/** LocaleContainer contains a NSLocale instance and a BCP 47 tag string.

 LocaleContainer is used to set (/get) locale to (/from) KiiUser instance.<br>
 See <[KiiUser locale]> and <[KiiUserFields locale]>.

 You may need to only work with <[LocaleContainer locale]> property in most cases.<br>
 <[LocaleContainer localeString]> is for keeping the original string received from
 Kii Cloud.<br>
 NSLocale may convert the tag to different shape if the tag is generated by other
 devices. (Android, Unity, JS, etc.).<br>
 For instance, "az-latn-az" from server, after converted to NSLocale, the localeString
 will become "az-az". In this case, "az-latn-az" will be stored in
 <[LocaleContainer localeString]> and you can check the value If you need to get it.
 */
NS_ASSUME_NONNULL_BEGIN
@interface LocaleContainer : NSObject

/** NSLocale instance. */
@property(nonatomic, readonly)NSLocale *locale;

/** BCP 47 format locale string, like en-US */
@property(nonatomic, readonly)NSString *localeString;

/** Init LocaleContainer with BCP 47 format tag

 You may use <[LocaleContainer init]> in most cases. Kii Cloud SDK uses
 this initializer when retrieved user's locale from server.
 Initializer substutute <[LocaleContainer locale]> with NSLocale instance converted
 through <[NSLocale initWithLocaleIdentifier:]>
 @param bcp47tag BCP 47 format tag
 */
-(id)initWithBcp47Tag: (NSString *)bcp47tag;

/** Init LocaleContainer with NSLocale instance

 You may use <[LocaleContainer init]> in most cases. You use it when need to set
 other locale than <[NSLocale currentLocale]>.
 Initializer substutute <[LocaleContainer localeString]> with the string obtained by
 <[NSLocale localeIdentifer]>.
 @param locale NSLocale instance.
 */
-(id)initWithLocale:(NSLocale *)locale;

/** Init LocaleContainer with <[NSLocale currentLocale]>

 <[LocaleContainer locale]> property is initilized with <[NSLocale currentLocale]>.
 Initializer substutute <[LocaleContainer localeString]> with the string obtained by
 <[NSLocale localeIdentifer]>.
 */
-(id)init;
@end
NS_ASSUME_NONNULL_END
