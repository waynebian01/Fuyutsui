---
description: 获取原作者更新，并创建供代码比审的 GitHub PR 专用临时分支（提取自历史成功流程）
---

当你看到这个工作流时，用户的意图是想安全地查看原作者的最新代码，并自己挑选保留修改。在这个过程中，你不能直接影响或修改本地主干代码，必须在远端提供 PR 对比环境。

### 请依次安静并在后台自动执行以下系统命令：

// turbo
1. 确保用户在安全的主干分支上：
`git checkout main`

// turbo
2. 添加原作者的库 (如果未添加) 然后获取最新代码：
`git remote add upstream https://github.com/waynebian01/Fuyutsui.git` (如报错可以忽略)
`git fetch upstream`

// turbo
3. 删除旧的残留临时分支，并从原作者最新节点签出新分支：
`git branch -D upstream-updates`
`git checkout -b upstream-updates upstream/main`

// turbo
4. 将它推送到用户个人的原端 Github，以支持网页端比对：
`git push origin upstream-updates`

// turbo
5. 完成后，立刻将用户本地分支切换回 main，保护他们的本地开发环境：
`git checkout main`

### 步骤执行完毕后对用户的回复：
请不要在对话框中给用户展示枯燥的代码执行日志。请直接向他们提供以下这个对比页面的直达链接：
👉 `https://github.com/xhang59160-byte/Fuyutsui/compare/main...upstream-updates`

并且询问他们：
“你想在网页上自己点合并，还是需要我像上次那样帮你合并（如果有想排除或者保护的不更新的文件，请直接在这个对话告诉我）？”
