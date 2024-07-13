# auto-push

### 通过Git自动上传本地内容到远程仓库

初次使用git请先安装最新版本的git，然后

```
git config --global user.name Github账户名称
git config --global user.email Github账户邮箱
```

配置SSH密钥

```
ssh-keygen -t rsa -b 4096 -C "github的邮箱"
```

按照提示，一路回车即可生成SSH密钥对

查询公钥

```
cat ~/.ssh/id_rsa.pub
```

接下来，需要将公钥添加到GitHub账号中。

登录GitHub账号，点击头像，选择“Settings”->“SSH and GPG keys”->“New SSH key”，将刚刚生成的公钥粘贴到“Key”文本框中，点击“Add SSH key”按钮即可。

下载脚本

```
curl -L https://raw.githubusercontent.com/spiritLHLS/auto-push/main/push.sh -o push.sh && chmod +x push.sh
```

然后修改本仓库shell脚本，将其设置为定时任务即可(注意执行路径)

```
bash push.sh
```

首次推送需要手动运行一次

```
root@localhost:~# bash push.sh
Initialized empty Git repository in /root/temp/.git/
Switched to a new branch 'main'
The authenticity of host 'github.com (140.82.121.4)' can't be established.
ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

输入yes以确认host，后续就能定时运行了

##### 修复

有时候推送报错，得按照下面的方式修改Git缓冲区大小为1G，这样才能推送上去，如果文件更大自行修改大小

```
git config --global http.postBuffer 1048576
```

如果脚本选择使用了```rsync```进行配置，那么务必事先进行```rsync```的安装，大部分Linux系统默认不安装这个组件的，所以得自行安装。

##### 定时

可以使用Linux中的cron来定时运行脚本文件

Cron是Linux中的一个基于时间的作业调度程序，可以在指定的时间运行指定的命令或脚本。

要设置每天定时运行/root/push.sh文件，请按照以下步骤操作：

打开终端，输入以下命令打开cron定时任务编辑器：

```
crontab -e
```

如果是第一次使用cron，可能会提示选择默认的编辑器，请选择您习惯使用的编辑器，例如vim或nano。

在打开的文件末尾添加以下内容：

```
0 0 * * * /bin/bash /root/push.sh
```

解释一下这个语句：

```
        0 0 * * * 意味着在每天的0点0分运行该命令（即每天午夜）。
        /bin/bash 指定要运行的Shell。
        /root/push.sh 是要运行的脚本的完整路径。
```


保存并退出编辑器。

这样就完成了定时运行脚本的设置。

Cron会在每天的0点0分自动运行/root/push.sh文件。

### 通过Git自动修改该GitHub账号下的所有项目文件的某一行

检测所有公开仓库，匹配到以某字符串开头的行，覆写该行

支持修改是原创的项目还是含Fork的项目

修改autochange.sh再执行即可，其他要求同push.sh一致

效果图：

![图片](https://github.com/spiritLHLS/auto-push/assets/103393591/4a63832c-5dc6-41ae-8993-3b9e8e4f4773)

这样就能更新本作者名下所有的仓库含有同样开头的行为对应的东西
