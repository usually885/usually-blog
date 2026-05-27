# 发布文章一条命令

以后如果你的 Markdown 在博客仓库外面，比如：

`D:\OneDrive\文档\xss进阶.md`

并且图片还是 Typora 的本机路径，直接在博客目录执行：

```powershell
cd D:\hugo_extended_withdeploy_0.161.1_windows-amd64\blog
.\scripts\publish-post.ps1 -SourceMarkdown "D:\OneDrive\文档\xss进阶.md" -BundleName "xss-ctfhub"
git add .
git commit -m "update xss-ctfhub"
git push origin main
```

说明：

- `-SourceMarkdown` 是你的原始 `.md` 文件，脚本只读取，不会修改它。
- `-BundleName` 是博客里的文章名。
- 脚本会自动：
  - 读取 Markdown
  - 把图片复制到 Hugo 文章目录
  - 把图片路径改成 Hugo 可发布格式
  - 保留或生成 `index.md`
  - 本地执行一次 `hugo --gc --minify`

如果你想顺手把文章目录加入 git 暂存区，可以这样：

```powershell
.\scripts\publish-post.ps1 -SourceMarkdown "D:\OneDrive\文档\xss进阶.md" -BundleName "xss-ctfhub" -Stage
```
