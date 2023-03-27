# auto-push

通过Git自动上传内容到远程仓库

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

然后修改本仓库shell脚本，将其设置为定时任务即可(注意执行路径)

```
bash push.sh
```
