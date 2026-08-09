---
name: social-media-cover
description: Generate social media cover images (Xiaohongshu/RedNote, Douyin, Bilibili, WeChat) as 1080×1440 PNGs by writing single-file HTML and screenshotting it with Chrome — not by AI image generation. Use when the user wants covers, posters, mockup images, or a visually consistent image series. Triggers on 自媒体封面, 小红书封面, 抖音封面, 产品封面, 做图, 海报, mockup 配图, cover image, thumbnail.
---

# 自媒体封面图（HTML → PNG）

## 核心原则

**不用 AI 生图画封面主体。** 封面 = 单文件 HTML + CSS，用 Chrome 截图输出 1080×1440 PNG（3:4，小红书 / 抖音图文 / B站动态通用）。

为什么不用 AI 生图：

| 问题 | AI 生图 | HTML 截图 |
|---|---|---|
| 中文文字 | 常年错别字、糊字、多字少字 | 零错误，所见即所得 |
| 品牌 logo | 画不准，越画越像山寨 | CSS/SVG 精确绘制或直接嵌官方文件 |
| 真实产品界面 | 无法嵌入 | 真截图放进设备 mockup |
| 改一个字 | 整张重生成，其他元素全变 | 改一行 HTML 重新截图 |
| 系列一致性 | 每张都在漂移 | 参数化，天然一致 |

代价：token 消耗比生图高（要写完整 HTML），首次调版式要迭代几轮。换来的是**可控、可复现、可批量**。

## 依赖

必需：

- **Playwright CLI** — 渲染截图。`pip install playwright && playwright install chromium`，或 `brew install playwright`
- **Chrome 或 Chromium** — 模板默认 `--channel chrome`，没装 Chrome 就去掉这个参数用 Playwright 自带的 Chromium
- **中文字体** — 模板已配 fallback 链（Noto Sans SC → PingFang SC → Microsoft YaHei → Source Han Sans SC → Hiragino Sans GB）。联网时从 Google Fonts 拉 Noto Sans SC；离线或网络受限时自动回落到系统字体，效果几乎无差

可选：

- **ImageMagick 7**（`magick`）— 裁切截图、遮盖敏感信息。做 mockup 内容图基本都要用
- 查图片尺寸用 `magick identify -format "%wx%h" file.png`（跨平台，别用 macOS 专有的 `sips`）

## 工作流

### 0. 先建产品事实清单

在项目里建一个 `products.md`，写清每个产品的：官网、真实功能点、定价、目标用户、合规备注、教程链接。

**写文案前必须对照它 + fetch 官网核对。** 别凭印象写功能，更别把 A 产品的卖点复制给 B 产品——不同版本的功能差异往往很关键（例：「本地 Markdown / 图片本地保存」可能只有桌面版有，网页版没有）。这是最容易翻车、也最伤信任的一步。

### 1. 收集素材

优先用**真实产品界面截图**。这个 skill 的效果全靠它——mockup 里塞官网 banner 插画等于浪费一整块画布。

挑图原则：选视觉冲击强、信息密度高的界面（卡片画廊 > 表格 > 纯文字）。截图存原图 + 裁切版两份，方便复用。

### 2. 挑风格模板

`assets/` 里有 6 个，复制到任务目录，同目录放截图素材：

| 模板 | 风格 | 特点 | 适合 |
|---|---|---|---|
| `template-cover.html` | 活泼渐变（默认） | 紫渐变底 / 胶囊 / 气泡 / MacBook | 通用产品封面 |
| `tagwall-cover.html` | 能力标签墙 | 白底点阵，能力压成 5-6 字彩色贴纸铺满 | 一图看懂全部能力 |
| `bigtype-cover.html` | 大字报撞色 | 米色底黑框衬线大字 + 划线 + 印章 + 硬阴影 | 情绪钩子、测点击率 |
| `neon-cover.html` | 暗黑霓虹玻璃 | 深紫黑底 + 霓虹发光字 + 毛玻璃截图卡 | 科技感、信息流反差 |
| `cliptape-cover.html` | 黑黄剪贴 | 暖白底 + 黑描边胶囊 + 柠檬黄高亮块 + 双 iPhone | 手机端 App、黑白系品牌 |
| `dualdevice-cover.html` | 能力详解页 | badge + 大标题 + MacBook 与 iPad 同框 + 编号卡 | 商品图能力页、跨端展示 |

模板不是约束。用户给参考图就逆向复刻，给关键词就自由设计；打样满意后存进 `assets/` 命名 `<风格>-cover.html`。同一内容可以用不同风格各出一版，分帖发布测数据。

### 3. 设备 mockup（`assets/kit.css`）

共用库，`<link rel="stylesheet" href="kit.css">` 即可：

- **MacBook**（`.mac`）— 屏幕 16:10，底座宽于屏幕
- **iPad**（`.ipad`）— 竖屏 1668/2388，窄深色边框，顶部摄像头点
- **iPhone**（`.phone`）— 屏幕 1170/2532，灵动岛

手机端产品用 iPhone，桌面端用 MacBook，跨端可一图双 mockup。

截图先裁到与容器一致的比例再 100% 填充。iPad 竖屏裁 0.6985；横图要竖裁就取信息最密的一竖条，别整图缩。

**两台设备同框**：外层容器必须 `flex:none`（否则在 flex column 里被压缩、设备盖住下面的卡片）。两台**并排等高**——留约 36px 间隙、顶底齐平、标签同一水平基线。等高解方程：

```
MacBook 高 = (W1 - 24)/1.6 + 46
iPad   高 = (W2 - 26)/0.6985 + 26
约束    W1 + W2 = 可用宽度 - 间隙
```

联立解出两个宽度。例：可用 1000px、间隙 34px → iPad ≈ 314px，MacBook ≈ 652px，两者高约 438px。

### 4. 改参数

- 品牌色 CSS 变量：`--red` = 内容来源平台色，`--purple` = 目的地工具色。背景渐变跟目的地色调走
- 标题 / 金句 / 胶囊 / 气泡文案（**必须原创，不抄别人帖子**）
- mockup 内截图 `src` + `object-position` / `width` 裁切（放大到文字可读）

### 5. 渲染

```bash
playwright screenshot --channel chrome --viewport-size "1080,1440" \
  --wait-for-timeout 3500 "file://$PWD/index.html" output/01-封面.png
```

`--wait-for-timeout` 是给 Google Fonts 留加载时间，别省。

### 6. 必须 Read 渲染出的 PNG 检查

这一步不能跳。逐项核对：标题是否折行、内容是否溢出画布、底部栏是否可见、文字逐字核对。

CSS 布局在 1080×1440 这种固定画布上很容易溢出，而且**溢出是静默的**——渲染不报错，只有看图才发现底栏被挤没了。

### 7. 给用户看，确认后再铺内容页

```bash
open "$FILE"          # macOS
xdg-open "$FILE"      # Linux
start "$FILE"         # Windows
```

内容页复用封面的 token 与元素（胶囊、气泡、mockup、渐变底），每页只讲一个点。整篇 4–8 张，最后一张放 CTA。输出 `02-xx.png` 依次编号。

## Common Mistakes（实战踩坑表）

| 坑 | 修复 |
|---|---|
| 标题字号过大 → 折成 3 行 → 底部内容被挤出画布 | 中文大标题 ≤112px；渲染后 Read PNG 数行数 |
| 截图整图塞进 mockup → 文字小到不可读 | `width:126%~150%` + `object-position` 裁最有信息量的区域 |
| 用低清 logo 图片放大 → 糊 | 优先用官方 SVG，或用 CSS 画（圆角方块 + 粗体字） |
| logo 自带圆角底色还套一层色块 | 用 `.mk.full` 整块铺满，阴影走 `drop-shadow` 贴合圆角 |
| 直接套设计系统默认风格（瑞士风） | 内容平台要「活泼 SaaS 风」：渐变底 / 胶囊 / 气泡 / 星光 |
| 完全复刻用户发的参考图 | 版式可借鉴，标题金句必须原创 |
| MacBook mockup 画成 16:8 带鱼屏 | 屏幕内容区 16:10、屏幕别撑满画布、底座比屏幕略宽 |
| 页码写死 /8 但实际只发 3 张 | 页码 = 实际图数；尾页钩子不能指向不存在的下一页 |
| 胶囊卖点跨产品复制导致失实 | 每个卖点回 `products.md` + 官网核对 |
| mockup 里塞官网 banner 插画区 | 挑高信息密度区（卡片、字段、正文），装饰图等于浪费画布 |
| 设备 + 卡片同页时设备盖住卡片 | flex column 里给设备容器 `flex:none`，只让底栏用 `margin-top:auto` |
| 高亮块用 `::before` + `z-index:-1` 不显示 | 被父级背景吞掉。改用 `background:linear-gradient(transparent 56%, 高亮色 56% 94%, transparent 94%)` 或直接给 span 实底 |
| 文案 AI 味重 | 禁 emoji 匀速排比、禁编造数字；用认知翻转开头、金句结尾 |

## 合规红线（以小红书审核为例）

- 禁用词：**自动同步、自动抓取、自动获取**。换成「一键落地 / 一键收进 / 设置一次后续自己进来 / 智能归类」
- 图片和文案**不放外链域名、不放二维码**。真实界面截图里常带 URL，务必裁掉或用取样底色遮盖：
  ```bash
  magick shot.png -fill "$(magick shot.png -format '%[pixel:p{1500,527}]' info:)" \
    -draw "rectangle 170,498 1120,558" out.png
  ```
- 文案不抄竞品，只借鉴版式结构
- 标题 20 字以内（**字母、标点各算一个字**，不是半个）。填完必须回读校验

## 归档

产物别放 `/tmp`（很多机器有定时清理）。建议结构：

```
<产品>/YYYY-MM-DD 标题/
├── 01-封面.png、02-xx.png …
├── 文案.md        ← 标题(含备选) + 正文 + 标签 + 图片清单
└── _src/          ← index.html + kit.css + 截图素材（可复现）
```

`_src/` 自包含——把 `kit.css` 和用到的图都复制进去，别用相对路径引用外部目录，否则以后重渲染会断。
