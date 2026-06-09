# 设置入口说明

本版本新增了仿原插件入口：启动后会尝试注册到 `wcplugins.dylib` 的 `WCPluginsMgr` 插件管理器。

## 主入口

微信 → 我 → 插件管理 → WeChatLiquidGlass → 设置页

插件管理列表里显示：

- 标题：WeChatLiquidGlass
- 版本：Version 1.0-1-1
- 控制器：WCLG27SettingsViewController

## 备用入口

为了防止部分环境没有安装或没有加载 `wcplugins.dylib`，仍然保留：

- 长按底部 TabBar 右侧搜索按钮
- 长按首页右上角搜索按钮

## 配置清理入口

设置页：

```text
操作 → 清除插件配置并关闭
```

如果微信已经卡死，无法进入设置页，可以新建清理标记文件：

```text
/var/mobile/Library/Preferences/wclg27_clear_config
```

再杀掉微信并重新打开。插件会自动删除历史配置、关闭总开关，并移除这个标记文件。

## 实现方式

通过运行时检测 `WCPluginsMgr`：

- `NSClassFromString(@"WCPluginsMgr")`
- `sharedInstance`
- `registerControllerWithTitle:version:controller:`

不链接、不修改、不绕过 `wcplugins.dylib`，也不处理原插件授权逻辑。
