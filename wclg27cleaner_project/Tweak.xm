#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - Cleaner Constants

static NSString * const kWCLG27CleanerAutoCleanKey = @"wclg27cleaner_auto_clean_enabled";

static NSArray<NSString *> *WCLG27CleanerPrefixes(void) {
    return @[
        @"wclg27_",
        @"wcliquidglass27_",
        @"WCLG27",
        @"WCLG_",
        @"WCLG",
        @"WeChatLiquidGlass"
    ];
}

static NSArray<NSString *> *WCLG27CleanerExactKeys(void) {
    return @[
        @"wclg27_enabled",
        @"wclg27_feature_tabbar",
        @"wclg27_feature_navbar",
        @"wclg27_feature_search_glass",
        @"wclg27_feature_input_glass",
        @"wclg27_feature_bubble_glass",
        @"wclg27_feature_chat_title_capsule",
        @"wclg27_feature_moments_nav",
        @"wclg27_feature_hide_home_title",
        @"wclg27_feature_tab_right_search",
        @"wclg27_feature_home_search_button",
        @"wclg27_feature_home_pure_bg",
        @"wclg27_feature_hide_pinned_bg",
        @"wclg27_strength_global",
        @"wclg27_strength_tabbar",
        @"wclg27_strength_navbar",
        @"wclg27_strength_search",
        @"wclg27_strength_input",
        @"wclg27_strength_bubble",
        @"wclg27_strength_title",
        @"wclg27_strength_moments",
        @"wclg27_tint_color_r",
        @"wclg27_tint_color_g",
        @"wclg27_tint_color_b",
        @"wclg27_tint_color_a",
        @"wclg27_home_color_r",
        @"wclg27_home_color_g",
        @"wclg27_home_color_b",
        @"wclg27_home_color_a",
        @"wclg27_clear_config",
        @"wclg27_disable",
        @"wcliquidglass27_clear_config",
        @"wcliquidglass27_disable"
    ];
}

static NSUserDefaults *WCLG27CleanerDefaults(void) {
    return [NSUserDefaults standardUserDefaults];
}

static NSString *WCLG27CleanerFlagPath(NSString *name) {
    return [@"/var/mobile/Library/Preferences" stringByAppendingPathComponent:name];
}

#pragma mark - Cleaner Core

static NSUInteger WCLG27CleanerRemoveMatchingDefaults(void) {
    NSUserDefaults *defaults = WCLG27CleanerDefaults();
    NSDictionary *dict = [defaults dictionaryRepresentation];
    NSMutableSet<NSString *> *keysToRemove = [NSMutableSet set];

    for (NSString *key in WCLG27CleanerExactKeys()) {
        if (dict[key] != nil) {
            [keysToRemove addObject:key];
        }
    }

    for (NSString *key in dict.allKeys) {
        for (NSString *prefix in WCLG27CleanerPrefixes()) {
            if ([key hasPrefix:prefix]) {
                [keysToRemove addObject:key];
                break;
            }
        }
    }

    for (NSString *key in keysToRemove) {
        [defaults removeObjectForKey:key];
    }

    /*
     清理后主动写入总开关关闭。
     这样即使用户马上启用新版 wcliquidglass27，也不会自动沿用旧的开启状态。
     新版插件进入设置页后可重新开启。
    */
    [defaults setBool:NO forKey:@"wclg27_enabled"];
    [defaults synchronize];

    return keysToRemove.count;
}

static void WCLG27CleanerRemoveExternalFlags(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *names = @[
        @"wclg27_clear_config",
        @"wclg27_disable",
        @"wcliquidglass27_clear_config",
        @"wcliquidglass27_disable"
    ];
    for (NSString *name in names) {
        NSString *path = WCLG27CleanerFlagPath(name);
        if ([fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:nil];
        }
    }
}

static NSUInteger WCLG27CleanerRunFullClean(void) {
    NSUInteger count = WCLG27CleanerRemoveMatchingDefaults();
    WCLG27CleanerRemoveExternalFlags();
    return count;
}

#pragma mark - UI Helpers

static UIViewController *WCLG27CleanerTopViewController(void) {
    UIWindow *keyWindow = nil;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
            if (keyWindow) break;
        }
    }

    if (!keyWindow) {
        SEL keyWindowSel = NSSelectorFromString(@"keyWindow");
        if ([UIApplication.sharedApplication respondsToSelector:keyWindowSel]) {
            keyWindow = ((UIWindow *(*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, keyWindowSel);
        }
    }
    if (!keyWindow) keyWindow = UIApplication.sharedApplication.windows.firstObject;

    UIViewController *top = keyWindow.rootViewController;
    while (top.presentedViewController) top = top.presentedViewController;

    if ([top isKindOfClass:[UITabBarController class]]) {
        UIViewController *selected = ((UITabBarController *)top).selectedViewController;
        if (selected) top = selected;
    }
    if ([top isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)top).visibleViewController;
        if (visible) top = visible;
    }

    return top;
}

static void WCLG27CleanerShowAlert(NSString *title, NSString *message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *top = WCLG27CleanerTopViewController();
        if (!top) return;
        if ([top isKindOfClass:NSClassFromString(@"UIAlertController")]) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
        [top presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - Cleaner View Controller

@interface WCLG27CleanerViewController : UIViewController
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation WCLG27CleanerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"LiquidGlass 配置清理";
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.07 blue:0.11 alpha:1.0];

    if (self.navigationController && self.navigationController.viewControllers.firstObject == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(close)];
    }

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[
        (__bridge id)[UIColor colorWithRed:0.05 green:0.07 blue:0.13 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.14 green:0.08 blue:0.25 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.03 green:0.12 blue:0.18 alpha:1].CGColor
    ];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.frame = self.view.bounds;
    gradient.needsDisplayOnBoundsChange = YES;
    [self.view.layer insertSublayer:gradient atIndex:0];

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat x = 20;
    CGFloat y = 28;
    CGFloat cardWidth = width - 40;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x, y, cardWidth, 42)];
    title.text = @"LiquidGlass 配置清理";
    title.font = [UIFont boldSystemFontOfSize:28];
    title.textColor = UIColor.whiteColor;
    [scroll addSubview:title];

    y += 52;

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(x, y, cardWidth, 52)];
    sub.text = @"用于 wcliquidglass27 出问题时，单独清除旧配置。建议先用 loadcontrol 禁用 wcliquidglass27，再启用本清理插件。";
    sub.font = [UIFont systemFontOfSize:14];
    sub.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.72];
    sub.numberOfLines = 0;
    [scroll addSubview:sub];

    y += 72;

    UIView *card = [self cardWithFrame:CGRectMake(x, y, cardWidth, 252)];
    [scroll addSubview:card];

    UILabel *cardTitle = [[UILabel alloc] initWithFrame:CGRectMake(18, 18, cardWidth - 36, 24)];
    cardTitle.text = @"清理操作";
    cardTitle.font = [UIFont boldSystemFontOfSize:18];
    cardTitle.textColor = UIColor.whiteColor;
    [card addSubview:cardTitle];

    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(18, 52, cardWidth - 36, 76)];
    desc.text = @"点击下面按钮会删除 wcliquidglass27 / WeChatLiquidGlass 相关偏好配置，并把 wclg27_enabled 写为关闭。不会删除微信聊天数据。";
    desc.font = [UIFont systemFontOfSize:14];
    desc.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.72];
    desc.numberOfLines = 0;
    [card addSubview:desc];

    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cleanButton.frame = CGRectMake(18, 140, cardWidth - 36, 48);
    cleanButton.layer.cornerRadius = 18;
    cleanButton.layer.masksToBounds = YES;
    cleanButton.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.88];
    [cleanButton setTitle:@"清除 wcliquidglass27 配置" forState:UIControlStateNormal];
    [cleanButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    cleanButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [cleanButton addTarget:self action:@selector(confirmClean) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:cleanButton];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(18, 202, cardWidth - 36, 34)];
    hint.text = @"清理后建议完全杀掉微信后台再重新打开。";
    hint.textAlignment = NSTextAlignmentCenter;
    hint.font = [UIFont systemFontOfSize:14];
    hint.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.82];
    hint.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08];
    hint.layer.cornerRadius = 15;
    hint.layer.masksToBounds = YES;
    [card addSubview:hint];

    y += 272;

    UIView *statusCard = [self cardWithFrame:CGRectMake(x, y, cardWidth, 126)];
    [scroll addSubview:statusCard];

    UILabel *statusTitle = [[UILabel alloc] initWithFrame:CGRectMake(18, 18, cardWidth - 36, 24)];
    statusTitle.text = @"当前说明";
    statusTitle.font = [UIFont boldSystemFontOfSize:18];
    statusTitle.textColor = UIColor.whiteColor;
    [statusCard addSubview:statusTitle];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 52, cardWidth - 36, 56)];
    self.statusLabel.text = @"本插件只负责清理 LiquidGlass 相关配置，不负责 UI 美化。清理完成后可关闭或卸载本插件。";
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.72];
    self.statusLabel.numberOfLines = 0;
    [statusCard addSubview:self.statusLabel];

    scroll.contentSize = CGSizeMake(width, y + 160);
}

- (UIView *)cardWithFrame:(CGRect)frame {
    UIView *card = [[UIView alloc] initWithFrame:frame];
    card.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.10];
    card.layer.cornerRadius = 24;
    card.layer.masksToBounds = NO;
    card.layer.borderWidth = 1;
    card.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.16].CGColor;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.shadowOpacity = 0.26;
    card.layer.shadowRadius = 18;
    card.layer.shadowOffset = CGSizeMake(0, 10);

    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark]];
    blur.frame = card.bounds;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blur.layer.cornerRadius = 24;
    blur.layer.masksToBounds = YES;
    [card insertSubview:blur atIndex:0];

    return card;
}

- (void)close {
    if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)confirmClean {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认清除配置？"
                                                                   message:@"会删除 wcliquidglass27 / WeChatLiquidGlass 相关偏好配置，并把插件总开关写为关闭。不会删除微信聊天数据。"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"清除" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action) {
        NSUInteger count = WCLG27CleanerRunFullClean();
        self.statusLabel.text = [NSString stringWithFormat:@"已清除 %lu 个配置项。建议现在完全杀掉微信后台，然后重新打开微信。", (unsigned long)count];

        UIAlertController *done = [UIAlertController alertControllerWithTitle:@"清理完成"
                                                                      message:[NSString stringWithFormat:@"已清除 %lu 个配置项，并已关闭 wcliquidglass27 总开关。", (unsigned long)count]
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [done addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:done animated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end

#pragma mark - WCPlugins Entry

static BOOL WCLG27CleanerRegistered = NO;

static BOOL WCLG27CleanerPluginEntryAlreadyExists(id manager, NSString *controllerName) {
    if (!manager || ![manager respondsToSelector:@selector(plugins)]) return NO;
    NSArray *plugins = ((id (*)(id, SEL))objc_msgSend)(manager, @selector(plugins));
    if (![plugins isKindOfClass:[NSArray class]]) return NO;

    for (id plugin in plugins) {
        NSString *title = nil;
        NSString *controller = nil;
        if ([plugin respondsToSelector:@selector(title)]) {
            title = ((id (*)(id, SEL))objc_msgSend)(plugin, @selector(title));
        }
        if ([plugin respondsToSelector:@selector(controller)]) {
            controller = ((id (*)(id, SEL))objc_msgSend)(plugin, @selector(controller));
        }

        if ([controller isKindOfClass:[NSString class]] && [controller isEqualToString:controllerName]) return YES;
        if ([title isKindOfClass:[NSString class]] && [title isEqualToString:@"LiquidGlass配置清理"]) return YES;
    }

    return NO;
}

static void WCLG27CleanerRegisterEntry(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (WCLG27CleanerRegistered) return;

        Class mgrClass = NSClassFromString(@"WCPluginsMgr");
        if (!mgrClass || ![mgrClass respondsToSelector:@selector(sharedInstance)]) return;

        id manager = ((id (*)(id, SEL))objc_msgSend)((id)mgrClass, @selector(sharedInstance));
        if (!manager || ![manager respondsToSelector:@selector(registerControllerWithTitle:version:controller:)]) return;

        NSString *controllerName = NSStringFromClass([WCLG27CleanerViewController class]);
        if (WCLG27CleanerPluginEntryAlreadyExists(manager, controllerName)) {
            WCLG27CleanerRegistered = YES;
            return;
        }

        ((void (*)(id, SEL, id, id, id))objc_msgSend)(manager,
                                                      @selector(registerControllerWithTitle:version:controller:),
                                                      @"LiquidGlass配置清理",
                                                      @"Version 1.0-1",
                                                      controllerName);
        WCLG27CleanerRegistered = YES;
    });
}

static void WCLG27CleanerScheduleRegisterEntry(void) {
    WCLG27CleanerRegisterEntry();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27CleanerRegisterEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27CleanerRegisterEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27CleanerRegisterEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27CleanerRegisterEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27CleanerRegisterEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27CleanerRegisterEntry(); });
}

#pragma mark - Auto Clean

static void WCLG27CleanerAutoCleanOnLaunch(void) {
    /*
     救援插件默认每次加载都自动清理一次。
     这样当 wcliquidglass27 卡死时，用户只要：
     1. 用 loadcontrol 禁用 wcliquidglass27；
     2. 启用本 cleaner；
     3. 打开微信；
     就能自动清理，无需先找到设置页。

     如果想关闭自动清理，可将 wclg27cleaner_auto_clean_enabled 设置为 NO。
    */
    NSUserDefaults *defaults = WCLG27CleanerDefaults();
    if ([defaults objectForKey:kWCLG27CleanerAutoCleanKey] &&
        ![defaults boolForKey:kWCLG27CleanerAutoCleanKey]) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUInteger count = WCLG27CleanerRunFullClean();
        NSString *msg = [NSString stringWithFormat:@"已自动清除 %lu 个 wcliquidglass27 配置项，并已关闭 wclg27_enabled。建议完全杀掉微信后重新打开。", (unsigned long)count];
        WCLG27CleanerShowAlert(@"LiquidGlass 配置已清理", msg);
    });
}

#pragma mark - Constructor

%ctor {
    @autoreleasepool {
        if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.tencent.xin"]) return;

        WCLG27CleanerScheduleRegisterEntry();
        WCLG27CleanerAutoCleanOnLaunch();

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(__unused NSNotification *note) {
            WCLG27CleanerScheduleRegisterEntry();
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(__unused NSNotification *note) {
            WCLG27CleanerScheduleRegisterEntry();
        }];
    }
}


#pragma mark - Cleaner Plugin Manager Strong Registration Patch

%hook WCPluginsViewController
- (void)viewDidLoad {
    WCLG27CleanerRegisterEntry();
    %orig;
}
- (void)viewWillAppear:(BOOL)animated {
    WCLG27CleanerRegisterEntry();
    %orig;
}
- (void)reloadTableData {
    WCLG27CleanerRegisterEntry();
    %orig;
}
%end

