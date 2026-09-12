# 飘哥撩 AI · 封面模板

基于 [EwingYangs/social-media-cover](https://github.com/EwingYangs/social-media-cover) fork。

**纯 HTML + 截图出 PNG，不调用 AI 生图 API**（有利于规避「整图 AI 生成」链路；发布含合成内容时仍建议按小红书规则声明）。

## 模板

| 文件 | 风格 |
| --- | --- |
| `paper-question.html` | 纸感大字提问（虚线圈装饰） |
| `dark-block.html` | 深色块面 + 橙色侧条 |
| `swiss-tool.html` | 瑞士风工具实测封面 |

画布：小红书竖版 **1080×1440**。改标题文字即可。

## 渲染

仓库根目录已有 `scripts/render.sh`。也可对本目录文件：

```bash
# 需已安装 Playwright Chromium
npx playwright screenshot --viewport-size=1080,1440 \
  --wait-for-timeout=2000 \
  "file://$PWD/paper-question.html" paper-question.png
```

更稳的方式：用仓库自带流程，或对带 `id="cover"` / `id="xhs-01"` 的节点做 element screenshot。

## 账号

面向小红书「飘哥撩 AI」干货号：工具实测 / 对比提问封面。
