# WeChatLiquidGlass.dylib 外层分析摘要

仅基于 Mach-O 外层元数据、符号表和字符串做功能归类，没有提供授权绕过、补丁、解密或复用原插件闭源代码。

## 基本信息

- 文件：`WeChatLiquidGlass.dylib`
- 类型：Mach-O universal dylib
- 架构：arm64 + arm64e
- 注入框架：MobileSubstrate / CydiaSubstrate
- 主要系统框架：Foundation、UIKit、CoreGraphics、QuartzCore、Security、SafariServices、AVFoundation、AudioToolbox

## 功能模块归类

从导出符号看，UI 功能主要集中在以下前缀：

- `WCLGApplyChatBottomGlassToInputToolView`：聊天底部输入栏玻璃化
- `WCLGApplyChatBubbleGlassToMessageView`：聊天气泡玻璃化
- `WCLGApplyChatTitleCapsuleToBar`：聊天标题胶囊样式
- `WCLGApplyChatTopMorphActionToController`：聊天顶部操作区变形/菜单
- `WCLGApplySearchTabBarToTabBar`：底部搜索胶囊
- `WCLGApplyGlassSizeModeToTabBar`：TabBar 尺寸模式
- `WCLGApplyNativeTabBarBackgroundCleanup`：清理原生 TabBar 背景
- `WCLGApplyMomentsNavigationBarTransparencyIfNeeded`：朋友圈导航栏透明处理
- `WCLGHomeTextHeaderWrapperView`：主页文字头部视图
- `WCLGSettingsViewController`：插件设置页
- `WCLGColorPickerViewController`：颜色选择器

## 配置项归类

可见的 UI 配置键包括：

- `wclg_chat_bottom_glass`
- `wclg_chat_bubble_glass`
- `wclg_search_tabbar_placeholder_text`
- `wclg_home_text_header_enabled`
- `wclg_hide_home_wechat_title`
- `wclg_home_background_pure_color`
- `wclg_hide_pinned_mainframe_background`
- `flg_unified_glass_size_mode`
- `flg_tabbar_right_search`
- `flg_search_tabbar`

## 授权相关指示器

原插件中存在以下授权/同步相关符号和配置项，本工程没有复用或实现：

- `WCLGAccessRefreshLocalAuthorization`
- `WCLGAccessRefreshOfficialAccountAuthorization`
- `WCLGAccessRequestServerSync`
- `WCLGAccessStartServerSync`
- `WCLGAccessCookieForFeature`
- `WCLGKeyServerAuthAllowed`
- `WCLGKeyServerAuthToken`
- `WCLGKeyServerAuthDeviceID`
- `WCLGKeyServerAuthExpiresAt`
- `WCLGKeyServerAuthFeatures`
- `WCLGKeyLocalOfficialOK`

## 干净重写策略

新工程不复制原插件代码，只按功能效果重新实现：

1. 使用 UIKit 基础类 hook：`UITabBar`、`UINavigationBar`、`UITableView`、`UICollectionView`、`UIViewController`。
2. 使用运行时检测 `UIGlassEffect`，避免直接依赖 iOS 26 SDK 符号。
3. iOS 26+ 优先系统 Liquid Glass，低版本或失败时回退系统 blur。
4. 对 WeChat 具体类名只做字符串启发式识别，不硬编码原插件私有实现。
5. 不包含授权、联网、设备标识、token、公众号校验和服务端同步逻辑。
