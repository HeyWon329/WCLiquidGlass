# 设计说明

这个 cleaner 和 `wcliquidglass27` 是两个独立 tweak：

- `wcliquidglass27`：负责 UI 美化
- `wclg27cleaner`：负责清除 `wcliquidglass27` 配置

## 为什么要单独做 cleaner

如果 UI 美化插件某个开关导致微信卡死，用户可能进不了原插件设置页。  
此时可以通过 loadcontrol 禁用 `wcliquidglass27`，只启用本 cleaner 来清理配置。

## 为什么不删除整个 com.tencent.xin.plist

微信本身也会把大量自己的设置存在 standardUserDefaults 中。直接删除整个偏好文件可能影响微信设置，所以 cleaner 只按 key 前缀删除 LiquidGlass 相关配置。

## 插件收纳注册

本插件会向 `WCPluginsMgr` 注册：

```text
标题：LiquidGlass配置清理
版本：Version 1.0-1
控制器：WCLG27CleanerViewController
```

注册接口：

```objc
registerControllerWithTitle:version:controller:
```

这和主插件入口方式一致。
