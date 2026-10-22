# li-sky Scoop bucket

个人 Scoop 软件源，目前包含：

- [kbshare](https://github.com/li-sky/ununifying_kboard_share)：Windows x64 客户端，跨 Windows / Linux 共享键盘、鼠标和剪贴板。
- [xiaohe-shuangpin](https://github.com/li-sky/xiaohe-shuangpin-windows)：为 Windows 10/11 微软拼音自动导入并启用小鹤双拼。

## kbshare 安装

先安装 [Scoop](https://scoop.sh/)，然后在 PowerShell 中运行：

```powershell
scoop bucket add li-sky https://github.com/li-sky/scoop-bucket
scoop install li-sky/kbshare
```

运行 `kbshare`，或从开始菜单启动 **kbshare**。首次运行会打开配置界面。
运行 `kbshare-config` 或开始菜单中的 **kbshare Configuration** 可单独编辑配置。
两端需分别配置本机和对端 ID、对端地址，并允许所配置的网络端口。

```powershell
scoop update
scoop update kbshare
```

升级前请从托盘菜单退出 kbshare。

配置、证书、信任库和日志统一保存在 Scoop 的 `persist/kbshare/data` 目录（默认是 `$HOME\scoop\persist\kbshare\data`），升级和普通卸载会保留它们。
`kbshare` 不带参数时使用此目录的配置；传入参数时原样交给程序，例如 `kbshare --config C:\my-config\config.json`。
`kbshare-config` 不带参数时编辑持久化配置，也可传入其他配置路径。

## 小鹤双拼安装

添加本源后执行：

```powershell
scoop install li-sky/xiaohe-shuangpin
```

安装时自动导入当前用户的微软拼音注册表设置，并启用小鹤双拼；需要已添加微软拼音输入法，不需要管理员权限，不支持全局安装。
清单直接下载固定版本的 `.reg` 文件；安装、备份和恢复脚本均由本仓库维护，不需要 ZIP 打包或小鹤仓库的 CI。
首次安装会备份被修改的三个值，更新与重装不会覆盖原备份。恢复安装前设置：

```powershell
xiaohe-shuangpin -Mode Restore
```

普通卸载会保留输入法设置和备份；如需还原，请先恢复再卸载。
如果输入法未刷新，切换输入法或注销重新登录。注册表来源和手动使用方法见[项目说明](https://github.com/li-sky/xiaohe-shuangpin-windows)。

## kbshare 版本与维护

直接使用 [kbshare 主仓库的正式 Release](https://github.com/li-sky/ununifying_kboard_share/releases) 中的 Windows x64 安装包，Scoop 版本与上游版本保持一致。
`bucket/kbshare.json` 的 `checkver` / `autoupdate` 指向主仓库，校验值来自其 `SHA256SUMS`。
这些字段供维护者的 Scoop 更新工具使用；用户安装的版本以本仓库已提交的清单为准。

安装钩子仅创建启动命令和初始配置，沿用 `persist/kbshare/data` 保存用户数据。
此前的 `0.1.0.2` 是上游尚无正式 Release 时的临时版本：`0.1.0` 为源码版本，`.2` 是构建流水线序号。旧安装可直接升级到 `1.0.1`，升级前请退出 kbshare。
本仓库不再重复构建或发布 kbshare 安装包。
