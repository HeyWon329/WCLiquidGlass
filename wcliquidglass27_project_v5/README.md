# WCLiquidGlass27

独立重写的微信 UI Liquid Glass 美化插件工程，目标适配 iOS 26 / iOS 27。

> 说明：本工程不包含原插件授权、联网校验、设备绑定逻辑；设置页仅参考截图里的视觉风格重新实现。

## 构建

rootless：

```bash
THEOS_PACKAGE_SCHEME=rootless make package FINALPACKAGE=1
```

rootful：

```bash
make package FINALPACKAGE=1
```

## 安装

编译后安装生成的 deb，重启微信。

## 设置入口

主入口：

- 微信 → 我 → 插件管理 → WeChatLiquidGlass

备用入口：

- 长按底部 TabBar 右侧搜索按钮
- 长按首页右上角搜索按钮

## 当前功能

- 深色玻璃风格设置页
- 插件总开关
- 各模块单独开关
- 自定义玻璃强度
- 颜色选择器
- TabBar 玻璃
- 导航栏玻璃
- 搜索框玻璃
- 聊天输入栏玻璃
- 聊天气泡/卡片玻璃
- 聊天标题胶囊
- 朋友圈导航栏优化
- 首页标题隐藏
- 首页背景纯色
- 置顶聊天背景隐藏
- TabBar 右侧搜索按钮
- 清除插件配置并关闭

## 配置清理

设置页里有：

```text
操作 → 清除插件配置并关闭
```

它会删除本插件保存的历史配置，并把总开关设为关闭。适合更新插件前使用，避免新版继续读取旧参数。

如果微信已经卡到进不去设置页，可以用 Filza / SSH 新建这个空文件：

```text
/var/mobile/Library/Preferences/wclg27_clear_config
```

然后完全杀掉微信并重新打开。插件启动时会检测这个文件，自动清理配置、关闭插件，并删除这个标记文件。

## 兼容说明

- iOS 26+：运行时检测 `UIGlassEffect`，存在则优先使用系统玻璃效果。
- iOS 27：不硬编码 iOS 26 私有实现，优先运行时检测，失败则回退到 `UIBlurEffect`。
- 低版本：使用 `UIBlurEffectStyleSystemMaterial` 或 `UIBlurEffectStyleLight` 回退。

## 注意

微信内部 View 类名可能随版本变化。聊天气泡、置顶聊天背景、输入栏等模块采用启发式识别，真机上如有误识别或未生效，需要根据截图继续补关键词。

更多入口说明见 `ENTRY.md`。
