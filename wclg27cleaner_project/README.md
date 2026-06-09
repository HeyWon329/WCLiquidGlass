# LiquidGlass Config Cleaner

这是一个单独的救援插件，用来清除 `wcliquidglass27` / `WeChatLiquidGlass` 相关配置。

## 使用场景

如果 `wcliquidglass27` 开启某些选项后导致微信卡死：

1. 用 loadcontrol 禁用 `wcliquidglass27`
2. 启用 `wclg27cleaner`
3. 打开微信
4. cleaner 会自动清理一次 LiquidGlass 配置
5. 也可以进入 `插件管理 -> LiquidGlass配置清理` 手动清理
6. 清理完成后，杀掉微信后台再重开
7. 后续可以禁用或卸载本 cleaner

## 插件入口

已注册到 `wcplugins.dylib` 的插件收纳/插件管理里：

```text
微信 -> 我 -> 插件管理 -> LiquidGlass配置清理
```

为了防止刚启动时 `WCPluginsMgr` 还没初始化，代码会在 0 / 0.8 / 2 / 4 / 7 秒多次尝试注册入口。

## 自动清理

本插件默认每次注入微信都会自动清理一次。  
原因是它定位为救援插件：当主插件卡死时，你可能还没法进入插件管理页，所以打开微信后先自动清理。

如果不想自动清理，可把：

```text
wclg27cleaner_auto_clean_enabled = NO
```

写入微信偏好。

## 清理范围

只清理偏好配置 key，不删除微信聊天记录，不删除微信账号数据。

会清理这些前缀相关 key：

- `wclg27_`
- `wcliquidglass27_`
- `WCLG27`
- `WCLG_`
- `WCLG`
- `WeChatLiquidGlass`

清理后会主动写入：

```objc
wclg27_enabled = NO
```

这样新版 `wcliquidglass27` 不会马上沿用旧开启状态。

## 构建

Rootless:

```bash
THEOS_PACKAGE_SCHEME=rootless make package FINALPACKAGE=1
```

Rootful:

```bash
make package FINALPACKAGE=1
```
