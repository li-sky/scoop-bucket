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

## kbshare 构建与维护

上游尚无正式 Release，因此本 bucket 从上游 Rust `v2` 分支构建并在本仓库发布 Windows x64 安装包。**不包含任何本地未提交修改**。
每个 Release 记录准确的上游 commit；版本为 `<上游 Cargo 版本>.<Actions run number>`，末位是 bucket 构建号。

在 Actions 中手动运行 **Publish kbshare**，填写上游分支、tag 或 commit（默认 `v2`）：

```sh
gh workflow run publish-kbshare.yml -R li-sky/scoop-bucket -f source_ref=v2
```

流程构建主程序和配置编辑器，计算 SHA-256，使用真实 Scoop 验证安装、快捷方式与卸载重装后的持久化，然后发布 Release 并更新 `bucket/kbshare.json`。安装包不包含示例证书或私钥；每台机器自行生成身份。
清单提供 `checkver` / `autoupdate` 元数据。发布流程本身负责提交清单，无需额外 token 或定时任务。

kbshare 的许可证按上游 `Cargo.toml` 声明为 MIT。
