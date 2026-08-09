# xhs-product-poster

小红书产品封面生成 skill。**写 HTML 再用 Chrome 截图**输出 1080×1440 PNG，不用 AI 生图。

[English](./README.md)

![模板预览](./examples/template-previews/README-strip.png)

## 为什么不用 AI 生图

试过一轮 AI 生图做封面，问题很一致：中文错别字、logo 画得像山寨、没法嵌真实产品界面、改一个字要整张重生成而且其他元素全跟着变。

改成写 HTML/CSS 再截图，这几件事全解决了：

| | AI 生图 | HTML 截图 |
|---|---|---|
| 中文文字 | 常年错别字、糊字、多字少字 | 零错误，所见即所得 |
| 品牌 logo | 画不准，越画越像山寨 | CSS/SVG 精确绘制或直接嵌官方文件 |
| 真实产品界面 | 无法嵌入 | 真截图放进设备 mockup |
| 改一个字 | 整张重生成，其他元素全变 | 改一行 HTML 重新截图 |
| 系列一致性 | 每张都在漂移 | 参数化，天然一致 |

代价是 **token 消耗比生图高**（要写完整 HTML 文档），首次调版式也要迭代几轮。换来的是可控、可复现、可批量——改 logo 和标题都是一行的事。

## 依赖

**必需**

- **Playwright CLI** —— `pip install playwright && playwright install chromium`，或 `brew install playwright`
- **Chrome / Chromium** —— 模板默认 `--channel chrome`，没装 Chrome 就去掉这个参数，用 Playwright 自带的 Chromium
- **中文字体** —— 模板已配 fallback 链（Noto Sans SC → PingFang SC → Microsoft YaHei → Source Han Sans SC → Hiragino Sans GB）。联网时从 Google Fonts 拉，离线自动回落系统字体，效果几乎无差

**可选**

- **ImageMagick 7**（`magick`）—— 裁切截图、遮盖敏感信息。做真实 mockup 基本都要用

## 快速开始

```bash
git clone https://github.com/EwingYangs/xhs-product-poster.git
cd xhs-product-poster

# 先渲染一个自带模板，确认环境没问题
bash scripts/render.sh assets/template-cover.html /tmp/out.png
open /tmp/out.png
```

作为 agent skill 使用，复制到 skills 目录：

```bash
cp -r xhs-product-poster ~/.claude/skills/
```

然后直接让 agent 做封面，它会挑模板、把你的截图放进设备 mockup、渲染出图。

## 做自己的封面

1. 从 `assets/` 复制一个模板到工作目录，把产品截图放同目录
2. 改 CSS 变量（`--red` = 内容来源平台色，`--purple` = 目的地工具色）、标题、mockup 里的 `<img src>`
3. 渲染：
   ```bash
   playwright screenshot --channel chrome --viewport-size "1080,1440" \
     --wait-for-timeout 3500 "file://$PWD/index.html" cover.png
   ```
4. **打开 PNG 逐项检查。** 固定画布上的布局溢出是静默的——渲染不报错，只是底栏没了

## 目录结构

```
assets/
├── template-cover.html      活泼渐变（默认）
├── tagwall-cover.html       能力标签墙
├── bigtype-cover.html       大字报撞色
├── neon-cover.html          暗黑霓虹玻璃
├── cliptape-cover.html      黑黄剪贴，双 iPhone
├── dualdevice-cover.html    MacBook 与 iPad 同框
├── kit.css                  设备 mockup（MacBook / iPad / iPhone）+ logo 锁定组
├── demo-*.png               占位截图（假数据，可安全分发）
└── _mock-src/               生成上面这些占位图的 HTML
examples/
└── template-previews/       每个模板的渲染预览
scripts/
└── render.sh                一行渲染的封装
SKILL.md                     完整的 agent 指令、工作流、踩坑表
```

## 设备 mockup

`kit.css` 提供三种，屏幕比例都是对的：

- `.mac` —— MacBook，屏幕 16:10，底座宽于屏幕
- `.ipad` —— iPad 竖屏，1668/2388，窄边框 + 摄像头点
- `.phone` —— iPhone，1170/2532，灵动岛

两台设备并排等高，解这个方程：

```
MacBook 高 = (W1 - 24)/1.6 + 46
iPad   高 = (W2 - 26)/0.6985 + 26
约束    W1 + W2 = 可用宽度 - 间隙
```

例：可用 1000px、间隙 34px → iPad ≈ 314px，MacBook ≈ 652px，两者高约 438px。

## 重要：你得有自己的截图

这**不是 AI 生图工具**。它的效果全靠把*真实*产品界面嵌进设备 mockup。仓库里的 `demo-*.png` 是假数据 mock UI，只是让模板开箱能渲染出来的占位图，换成你自己的截图才有意义。

挑图原则：选信息密度高的界面（卡片画廊 > 表格 > 纯文字），裁到最密的那块区域，保证海报尺寸下文字还能看清。

## 合规提示

`SKILL.md` 里沉淀了一些实际被打回后总结的规则：

- 有几个描述自动化的说法容易被判违规，skill 里列了替代说法
- **图片里不能有外链域名和二维码**。真实界面截图经常自带 URL，必须裁掉或遮盖：
  ```bash
  magick shot.png -fill "$(magick shot.png -format '%[pixel:p{1500,527}]' info:)" \
    -draw "rectangle 170,498 1120,558" out.png
  ```
- 标题 20 字以内，**字母和标点各算一个整字**，不是半个。填完要回读校验，超了会被静默截断

## 踩过的坑

完整版在 `SKILL.md`，这里挑几个最常撞的：

| 坑 | 修复 |
|---|---|
| 标题字号过大折成 3 行，底部内容被挤出画布 | 中文大标题 ≤112px，渲染后数行数 |
| 截图整图塞进 mockup，文字小到不可读 | `width:126%~150%` + `object-position` 裁最有信息量的区域 |
| 设备和卡片同页时设备盖住卡片 | 给设备容器 `flex:none`，只让底栏用 `margin-top:auto` |
| 高亮块用 `::before` + `z-index:-1` 不显示 | 被父级背景吞掉，改用 `linear-gradient` 做底或给 span 实底 |
| mockup 里塞官网 banner 插画 | 挑卡片、字段、正文这类高密度区，装饰图等于浪费画布 |

## License

MIT © EwingYangs
