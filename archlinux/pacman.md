pacman -S

## pacman 用法

- [pacman (简体中文) - ArchLinux wiki](<https://wiki.archlinux.org/index.php/Pacman_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [pacman (简体中文)/Tips and tricks (简体中文)](<https://wiki.archlinux.org/index.php/Pacman_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)/Tips_and_tricks_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

### 更新

- `pacman -Syu`：对整个系统进行更新
- `pacman -Syuu` 降级一些过于新的软件包

如果你已经使用`pacman -Sy`将本地的包数据库与远程的仓库进行了同步，也可以只执行：`pacman -Su`

### 安装包

- `sudo pacman -S 包名`：例如，执行 pacman -S firefox 将安装 Firefox。你也可以同时安装多个包，只需以空格分隔包名即可。添加`--needed`选项可以忽略已经安装的软件。
- `sudo pacman -Sy 包名`：与上面命令不同的是，该命令将在同步包数据库后再执行安装。
- `sudo pacman -Sv 包名`：在显示一些操作信息后执行安装。
- `sudo pacman -U 文件`：安装本地包，其扩展名为 pkg.tar.gz。
- `sudo pacman -U http://www.example.com/repo/example.pkg.tar.xz`：安装一个远程包

### 删除包

- `sudo pacman -R 包名`：该命令将只删除包，保留其全部已经安装的依赖关系
- `sudo pacman -Rs 包名`：在删除包的同时，删除其所有没有被其他已安装软件包使用的依赖关系
- `sudo pacman -Rn 包名`：避免备份配置文件

### 搜索查询包

- [查询包数据库 - ArchWiki](<https://wiki.archlinux.org/index.php/Pacman_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E6%9F%A5%E8%AF%A2%E5%8C%85%E6%95%B0%E6%8D%AE%E5%BA%93>)

pacman 使用 `-Q` 参数查询本地软件包数据库，`-S` 查询同步数据库，以及 `-F` 查询文件数据库。

### 其他用法

- `sudo pacman -Sw 包名`：只下载包，不安装。
- `sudo pacman -Sc`：清理未安装的包文件，包文件位于 /var/cache/pacman/pkg/ 目录。
- `sudo pacman -Scc`：清理所有的缓存文件。
- `sudo pacman -R $(pacman -Qdtq)` # 清除系统中无用的包

如果你要查找包含特定文件的包：

```bash
# 同步数据库
pacman -Fy
# 查找包含该文件的包
pacman -F file_name
```

```bash
# Qqen 选项备份的是除了 aur 和自己打包安装的以外的包
pacman -Qqen > listQqen.txt
# Qqem 选项备份的是 aur 中的和自己打包安装的包，可以理解为 Qqen 的补集
pacman -Qqem > listQqem.txt

pacman -Qqe
```
