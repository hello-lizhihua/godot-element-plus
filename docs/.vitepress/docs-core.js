// 由旧文档站 docs.js 迁移：演示构建器，按容器 id 自守卫

  "use strict";

  /* ---------------- 站点骨架 ---------------- */


  /* ---------------- 工具 ---------------- */
  function el(tag, cls, text) {
    var node = document.createElement(tag);
    if (cls) node.className = cls;
    if (text != null) node.textContent = text;
    return node;
  }

  function consoleOf(stage) {
    return stage.querySelector(".demo-console");
  }

  function logEvent(consoleEl, name, detail) {
    if (!consoleEl) return;
    consoleEl.textContent = "";
    consoleEl.appendChild(el("span", "ev-name", name));
    if (detail) consoleEl.appendChild(document.createTextNode(" → " + detail));
  }

  /* ---------------- GDScript 代码高亮 ---------------- */
  var KEYWORDS =
    "var|func|extends|class_name|return|if|elif|else|for|while|pass|and|or|not|in|const|" +
    "static|enum|match|break|continue|true|false|null|self|signal|preload|new";

  function escapeHtml(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  function highlightGd(src) {
    var re = new RegExp(
      "(#[^\\n]*)|(\"(?:[^\"\\\\]|\\\\.)*\")|\\b(" + KEYWORDS + ")\\b|\\b(\\d+(?:\\.\\d+)?)\\b",
      "g"
    );
    return escapeHtml(src).replace(re, function (m, comment, str, kw, num) {
      if (comment) return '<span class="tok-comment">' + comment + "</span>";
      if (str) return '<span class="tok-string">' + str + "</span>";
      if (kw) return '<span class="tok-kw">' + kw + "</span>";
      if (num) return '<span class="tok-num">' + num + "</span>";
      return m;
    });
  }

  function highlightCodeBlocks() {
    var blocks = document.querySelectorAll("pre.code-block code");
    Array.prototype.forEach.call(blocks, function (node) {
      if (node.getAttribute("data-lang") === "bash") return;
      node.innerHTML = highlightGd(node.textContent);
    });
  }

  /* ---------------- 主题页演示：色卡与标尺 ---------------- */
  var PALETTE = [
    ["CHASSIS_FILL", "圆形底盘与图标按钮底色", "rgba(20,22,28,0.62)"],
    ["POPOUT_FILL", "弹出面板底色", "rgba(20,22,28,0.78)"],
    ["DOCK_FILL", "停靠面板底色", "rgba(13,15,20,0.82)"],
    ["BORDER", "底盘描边", "rgba(255,255,255,0.20)"],
    ["BORDER_STRONG", "底盘与弹出面板描边", "rgba(255,255,255,0.32)"],
    ["BORDER_SOFT", "停靠面板左缘分隔线", "rgba(255,255,255,0.14)"],
    ["BORDER_ACTIVE", "滑块拇指描边", "rgba(255,255,255,0.50)"],
    ["ROW_IDLE", "行/筛选项默认底", "rgba(255,255,255,0.06)"],
    ["ROW_HOVER", "行悬停底", "rgba(255,255,255,0.10)"],
    ["ROW_ACTIVE", "行选中底", "rgba(255,255,255,0.22)"],
    ["TEXT_MAIN", "主文字", "#f0ede6"],
    ["TEXT_DIM", "次文字（72% 不透明）", "rgba(240,237,230,0.72)"],
    ["TEXT_FAINT", "弱文字（55% 不透明）", "rgba(240,237,230,0.55)"],
    ["ACCENT", "琥珀强调色", "#ffcc33"],
    ["ACCENT_WASH", "琥珀选中底（30% 不透明）", "rgba(255,204,51,0.30)"],
    ["HINT_COLOR", "提示小字主体（浅背景可读）", "rgba(41,43,51,0.82)"],
    ["HINT_HALO", "提示小字描影", "rgba(255,255,255,0.55)"],
  ];

  function initThemeDemo() {
    var grid = document.getElementById("theme-swatches");
    if (grid) {
      PALETTE.forEach(function (item) {
        var card = el("div", "swatch");
        var view = el("div", "swatch-view");
        ["on-dark", "on-light"].forEach(function (cls) {
          var cell = el("div", "cell " + cls);
          var overlay = document.createElement("i");
          overlay.style.background = item[2];
          cell.appendChild(overlay);
          view.appendChild(cell);
        });
        card.appendChild(view);
        var meta = el("div", "swatch-meta");
        meta.appendChild(el("div", "swatch-name", item[0]));
        meta.appendChild(el("div", "swatch-value", item[2]));
        meta.appendChild(el("div", "swatch-desc", item[1]));
        card.appendChild(meta);
        grid.appendChild(card);
      });
    }

    var ruler = document.getElementById("theme-ruler");
    if (ruler) {
      var SPACING = [
        ["GAP_XS", 4], ["GAP_S", 6], ["GAP_M", 8], ["GAP_L", 12],
        ["PAD_M", 14], ["PAD_L", 20], ["EDGE_L", 24],
      ];
      var SCALE = 6; // 标尺放大倍数，便于观察
      SPACING.forEach(function (item) {
        var row = el("div", "ruler-row");
        row.appendChild(el("span", "r-name", item[0]));
        row.appendChild(el("span", "r-val", "= " + item[1]));
        var bar = el("span", "ruler-bar");
        bar.style.width = item[1] * SCALE + "px";
        row.appendChild(bar);
        ruler.appendChild(row);
      });
    }
  }

  /* ---------------- 滑块演示（胶囊底 + 无胶囊对照） ---------------- */
  function initSliderDemo() {
    var stage = document.getElementById("demo-slider");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    function makeSlider(initial, capsule) {
      var MIN = 1, MAX = 10, STEP = 1;
      var TRACK_W = 170;
      var value = initial;
      var dragging = false;

      var minus = el("div", "ps-btn light", "−");
      var plus = el("div", "ps-btn light", "＋");

      var area = el("div", "ps-track-area");
      var track = el("div", "ps-track");
      var fill = el("div", "ps-fill");
      track.appendChild(fill);
      area.appendChild(track);
      for (var i = 0; i < MAX - MIN + 1; i++) {
        var tick = el("div", "ps-tick");
        tick.style.left = ((i / (MAX - MIN)) * TRACK_W) + "px";
        area.appendChild(tick);
      }
      var thumb = el("div", "ps-thumb");
      area.appendChild(thumb);

      var valueChip = el("span", "ps-value-chip", String(value));
      var readout = el("div", "ps-readout");
      readout.appendChild(document.createTextNode("当前级别 "));
      readout.appendChild(valueChip);

      var wrap = el("div", capsule ? "ps-wrap ps-capsule" : "ps-wrap");
      wrap.appendChild(minus);
      wrap.appendChild(area);
      wrap.appendChild(plus);
      wrap.appendChild(readout);

      function levelFromEvent(e) {
        var rect = area.getBoundingClientRect();
        var ratio = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width));
        return MIN + ratio * (MAX - MIN);
      }

      function render() {
        var ratio = (value - MIN) / (MAX - MIN);
        fill.style.width = ratio * TRACK_W + "px";
        thumb.style.left = ratio * TRACK_W + "px";
        valueChip.textContent = String(value);
      }

      function setValue(v, emit) {
        var nv = Math.min(MAX, Math.max(MIN, Math.round(v / STEP) * STEP));
        var changed = nv !== value;
        value = nv;
        render();
        if (changed && emit) logEvent(consoleEl, "value_changed", "level: " + value);
      }

      minus.addEventListener("click", function () { setValue(value - STEP, true); });
      plus.addEventListener("click", function () { setValue(value + STEP, true); });
      area.addEventListener("pointerdown", function (e) {
        dragging = true;
        if (area.setPointerCapture) area.setPointerCapture(e.pointerId);
        setValue(levelFromEvent(e), true);
      });
      area.addEventListener("pointermove", function (e) {
        if (dragging) setValue(levelFromEvent(e), true);
      });
      area.addEventListener("pointerup", function () { dragging = false; });
      area.addEventListener("pointercancel", function () { dragging = false; });

      render();
      return wrap;
    }

    var capsuleGroup = el("div", "demo-group");
    capsuleGroup.appendChild(el("div", "demo-label", "胶囊底样式（浅色背景上保持可读）"));
    capsuleGroup.appendChild(makeSlider(5, true));
    var plainGroup = el("div", "demo-group");
    plainGroup.appendChild(el("div", "demo-label", "无胶囊对照"));
    plainGroup.appendChild(makeSlider(3, false));

    stage.insertBefore(capsuleGroup, consoleEl);
    stage.insertBefore(plainGroup, consoleEl);
  }

  /* ---------------- 筛选按钮演示 ---------------- */
  function initChipDemo() {
    var stage = document.getElementById("demo-chip");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    // 单选行：排序
    var sortGroup = el("div", "demo-group");
    sortGroup.appendChild(el("div", "demo-label", "单选 · 排序（点选切换高亮）"));
    var sortRow = el("div", "el-chip-row");
    sortGroup.appendChild(sortRow);
    var sortActive = 0;
    var sortChips = ["面积", "人口", "名称"].map(function (text, index) {
      var chip = el("span", "el-chip", text);
      chip.addEventListener("click", function () {
        sortActive = index;
        renderSort();
        logEvent(consoleEl, "chip_clicked", "index: " + index + "（单选行，回推 set_active_indexes）");
      });
      sortRow.appendChild(chip);
      return chip;
    });
    function renderSort() {
      sortChips.forEach(function (chip, index) {
        chip.className = "el-chip" + (index === sortActive ? " selected" : "");
      });
    }
    renderSort();

    // 多选行：示例分组
    var orgGroup = el("div", "demo-group");
    orgGroup.appendChild(el("div", "demo-label", "多选 · 分组（点选切换、再点取消）"));
    var orgRow = el("div", "el-chip-row");
    orgGroup.appendChild(orgRow);
    var orgActive = {};
    var orgNames = ["分组 A", "分组 B", "分组 C", "分组 D", "分组 E"];
    orgNames.forEach(function (text, index) {
      var chip = el("span", "el-chip", text);
      chip.addEventListener("click", function () {
        orgActive[index] = !orgActive[index];
        chip.className = "el-chip" + (orgActive[index] ? " selected" : "");
        var picked = orgNames.filter(function (_, i) { return orgActive[i]; });
        logEvent(consoleEl, "chip_clicked", "index: " + index + "（多选行，当前选中 " + picked.length + " 项）");
      });
      orgRow.appendChild(chip);
    });

    stage.insertBefore(sortGroup, consoleEl);
    stage.insertBefore(orgGroup, consoleEl);
  }

  /* ---------------- 图标按钮演示 ---------------- */
  var ICON_SVGS = {
    gear:
      '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/>' +
      '<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>',
    list: '<svg viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></svg>',
    back: '<svg viewBox="0 0 24 24"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>',
    maximizeWindow: '<svg viewBox="0 0 24 24"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"/></svg>',
    maximizeFullscreen:
      '<svg viewBox="0 0 24 24"><rect x="8" y="4" width="12" height="12" rx="2"/>' +
      '<rect x="4" y="8" width="12" height="12" rx="2"/></svg>',
  };

  function makeIconButton(x, y, svg) {
    var btn = el("div", "el-icon-btn");
    btn.style.right = x + "px";
    btn.style.top = y + "px";
    btn.innerHTML = svg;
    btn.addEventListener("pointerdown", function () { btn.classList.add("pressed"); });
    ["pointerup", "pointerleave", "pointercancel"].forEach(function (evt) {
      btn.addEventListener(evt, function () { btn.classList.remove("pressed"); });
    });
    return btn;
  }

  function initIconButtonDemo() {
    var stage = document.getElementById("demo-icon-button");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    // 齿轮：模拟右上角按钮组（演示区内缩为 16 / 56，真实场景 margin 为 40 / 96）
    var gear = makeIconButton(16, 16, ICON_SVGS.gear);
    gear.addEventListener("click", function () {
      logEvent(consoleEl, "pressed", 'icon: "gear"（打开设置面板）');
    });
    stage.appendChild(gear);

    // 最大化：点击在窗口态 / 全屏态两种图标间切换
    var maximize = makeIconButton(56, 16, ICON_SVGS.maximizeWindow);
    var fullscreen = false;
    maximize.addEventListener("click", function () {
      fullscreen = !fullscreen;
      maximize.innerHTML = fullscreen ? ICON_SVGS.maximizeFullscreen : ICON_SVGS.maximizeWindow;
      logEvent(consoleEl, "pressed", fullscreen
        ? "切换到无边框全屏（图标：双叠方框）"
        : "切换到最大化窗口（图标：四角外扩括号）");
    });
    stage.appendChild(maximize);

    // 其余图标参考：list 与 back
    var label = el("div", "demo-label", "其他图标（list 列表 / back 返回箭头）");
    label.style.marginTop = "88px";
    stage.appendChild(label);
    var row = el("div", "el-chip-row");
    ["list", "back"].forEach(function (name) {
      var demo = el("span", "el-icon-btn");
      demo.style.position = "static";
      demo.style.marginRight = "10px";
      demo.innerHTML = ICON_SVGS[name];
      demo.addEventListener("click", function () {
        logEvent(consoleEl, "pressed", 'icon: "' + name + '"');
      });
      var holder = el("span");
      holder.style.display = "inline-flex";
      holder.appendChild(demo);
      row.appendChild(holder);
    });
    stage.appendChild(row);
  }

  /* ---------------- 设置面板演示 ---------------- */
  function initSettingsDemo() {
    var stage = document.getElementById("demo-settings");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var OPTIONS = [["白天", "day"], ["夜晚", "night"]];
    var value = "day";
    var isOpen = false;

    var gear = makeIconButton(16, 16, ICON_SVGS.gear);
    var popout = el("div", "el-popout");
    popout.style.top = "58px";
    popout.style.right = "16px";
    popout.style.display = "none";

    function renderRows() {
      popout.textContent = "";
      OPTIONS.forEach(function (option) {
        var row = el("div", "el-row" + (option[1] === value ? " selected" : ""), option[0]);
        row.addEventListener("click", function (e) {
          e.stopPropagation();
          value = option[1];
          renderRows();
          stage.classList.toggle("night", value === "night");
          logEvent(consoleEl, "option_selected", 'value: "' + value + '"（使用方就地生效后回设 value）');
        });
        popout.appendChild(row);
      });
    }

    function setOpen(open) {
      isOpen = open;
      popout.style.display = open ? "block" : "none";
      if (open) logEvent(consoleEl, "opened", "无（使用方收到后收起其他面板）");
    }

    gear.addEventListener("click", function (e) {
      e.stopPropagation();
      setOpen(!isOpen);
    });
    stage.addEventListener("click", function (e) {
      if (!isOpen) return;
      if (popout.contains(e.target) || gear.contains(e.target)) return;
      setOpen(false); // 演示为吞掉式收起（pass_through_outside = false）
    });

    renderRows();
    stage.appendChild(gear);
    stage.appendChild(popout);
  }

  /* ---------------- 停靠面板演示 ---------------- */
  function initDockDemo() {
    var stage = document.getElementById("demo-dock");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var DATA = [
      ["中国", 960.0], ["俄罗斯", 1709.8], ["加拿大", 998.5], ["美国", 937.2],
      ["巴西", 851.6], ["澳大利亚", 769.2], ["印度", 298.0], ["阿根廷", 278.0],
      ["哈萨克斯坦", 272.5], ["阿尔及利亚", 238.2], ["刚果（金）", 234.5], ["沙特阿拉伯", 215.0],
    ];

    var dock = el("div", "el-dock");
    var header = el("div", "el-dock-header");
    var title = el("span", "el-dock-title", "列表面板");
    var count = el("span", "el-dock-count", String(DATA.length));
    var toggle = el("span", "el-dock-toggle", "‹");
    header.appendChild(title);
    header.appendChild(count);
    header.appendChild(toggle);

    var body = el("div", "el-dock-body");
    DATA.forEach(function (item) {
      var row = el("div", "el-dock-item");
      row.appendChild(el("span", null, item[0]));
      var num = el("span", "num", item[1].toFixed(1));
      row.appendChild(num);
      body.appendChild(row);
    });

    var fab = el("button", "el-dock-fab", "›");
    fab.type = "button";
    dock.appendChild(header);
    dock.appendChild(body);
    stage.appendChild(fab);
    stage.appendChild(dock);

    var expanded = true;
    function setExpanded(next) {
      expanded = next;
      dock.classList.toggle("collapsed", !expanded);
      fab.style.display = expanded ? "none" : "flex";
      toggle.textContent = expanded ? "‹" : "›";
      logEvent(consoleEl, "collapse_toggled", "expanded: " + expanded);
    }
    fab.addEventListener("click", function () { setExpanded(true); });
    toggle.addEventListener("click", function (e) {
      e.stopPropagation();
      setExpanded(!expanded);
    });
    dock.addEventListener("click", function () {
      if (!expanded) setExpanded(true);
    });
  }

  /* ---------------- 分组列表演示（手风琴化） ---------------- */
  function initGroupListDemo() {
    var stage = document.getElementById("demo-group-list");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var GROUPS = [
      {
        name: "asia", title: "亚洲", items: [
          { name: "中国", area: 960.0, population: 14.1 },
          { name: "印度", area: 298.0, population: 14.3 },
          { name: "印度尼西亚", area: 191.4, population: 2.7 },
          { name: "日本", area: 37.8, population: 1.25 },
        ],
      },
      {
        name: "europe", title: "欧洲", items: [
          { name: "俄罗斯", area: 1709.8, population: 1.44 },
          { name: "法国", area: 55.2, population: 0.68 },
          { name: "德国", area: 35.8, population: 0.83 },
          { name: "意大利", area: 30.1, population: 0.59 },
        ],
      },
      {
        name: "africa", title: "非洲", items: [
          { name: "阿尔及利亚", area: 238.2, population: 0.45 },
          { name: "南非", area: 121.9, population: 0.6 },
          { name: "埃及", area: 100.1, population: 1.1 },
          { name: "尼日利亚", area: 92.4, population: 2.2 },
        ],
      },
    ];
    var SORT_KEYS = [["面积", "area"], ["人口", "population"]];
    var sortKey = "area";
    var selectedItem = null;
    var openSection = 0; // 手风琴：当前展开的非空分组序号，-1 全部收起（对应 open_section 默认 0）

    // 排序条目（单选 chip）
    var sortGroup = el("div", "demo-group");
    sortGroup.appendChild(el("div", "demo-label", "排序条目（组内按所选键降序重排）"));
    var sortRow = el("div", "el-chip-row");
    sortGroup.appendChild(sortRow);
    var sortChips = SORT_KEYS.map(function (key) {
      var chip = el("span", "el-chip", key[0]);
      chip.addEventListener("click", function () {
        sortKey = key[1];
        renderSortChips();
        render();
        logEvent(consoleEl, "rows_changed", "重排完成，共 " + rowCount() + " 行（保持选中与展开）");
      });
      sortRow.appendChild(chip);
      return chip;
    });
    function renderSortChips() {
      sortChips.forEach(function (chip, index) {
        chip.className = "el-chip" + (SORT_KEYS[index][1] === sortKey ? " selected" : "");
      });
    }
    renderSortChips();

    // 列表本体（分组标题行即手风琴标题：标题 + 计数 + 右端箭头）
    var wrap = el("div", "gl-wrap");

    function flatIndex(item) {
      var base = 0;
      for (var i = 0; i < GROUPS.length; i++) {
        var at = GROUPS[i].items.indexOf(item);
        if (at >= 0) return base + at;
        base += GROUPS[i].items.length;
      }
      return -1;
    }

    function rowCount() {
      var total = 0;
      GROUPS.forEach(function (group) { total += 1 + group.items.length; });
      return total;
    }

    // set_data 数组中非空分组的序号
    function sectionIndexOf(groupIndex) {
      var ordinal = -1;
      for (var i = 0; i <= groupIndex; i++) {
        if (GROUPS[i].items.length > 0) ordinal++;
      }
      return ordinal;
    }

    function groupIndexOf(item) {
      for (var i = 0; i < GROUPS.length; i++) {
        if (GROUPS[i].items.indexOf(item) >= 0) return i;
      }
      return -1;
    }

    function render() {
      wrap.textContent = "";
      GROUPS.forEach(function (group, groupIndex) {
        var section = sectionIndexOf(groupIndex);
        var isOpen = section === openSection;
        var titleRow = el("div", "gl-title-row");
        titleRow.appendChild(el("span", null, group.title));
        titleRow.appendChild(el("span", "g-count", group.items.length + " 项"));
        titleRow.appendChild(el("span", "g-arrow", isOpen ? "▾" : "▸"));
        titleRow.addEventListener("click", function () {
          var expanded = section !== openSection;
          openSection = expanded ? section : -1;
          render();
          logEvent(consoleEl, "section_toggled", "section_index: " + section + ", expanded: " + expanded);
        });
        wrap.appendChild(titleRow);
        if (!isOpen) return;

        var items = group.items.slice().sort(function (a, b) { return b[sortKey] - a[sortKey]; });
        items.forEach(function (item) {
          var row = el("div", "gl-item-row" + (item === selectedItem ? " selected" : ""));
          row.appendChild(el("span", "i-name", item.name));
          row.appendChild(el("span", "i-col", "面积 " + item.area.toFixed(1)));
          row.appendChild(el("span", "i-col", "人口 " + item.population + " 亿"));
          row.addEventListener("click", function () {
            selectedItem = selectedItem === item ? null : item; // 再点同一行取消选中
            if (selectedItem) openSection = section; // set_selected 语义：所在分组自动展开
            render();
            logEvent(consoleEl, "item_clicked",
              "item: " + item.name + ", index: " + flatIndex(item) + "（载荷索引）");
          });
          wrap.appendChild(row);

          // 选中行展开详情（等价于 meta "details" 的统一显隐）
          if (item === selectedItem) {
            if (row.scrollIntoView) row.scrollIntoView({ block: "nearest" });
            var detail = el("div", "gl-detail");
            var area = el("span", "d-label", "面积");
            area.appendChild(document.createElement("b")).textContent = item.area.toFixed(1) + " 万平方公里";
            var pop = el("span", "d-label", "人口");
            pop.appendChild(document.createElement("b")).textContent = item.population + " 亿";
            detail.appendChild(area);
            detail.appendChild(pop);
            wrap.appendChild(detail);
          }
        });
      });
    }

    stage.insertBefore(sortGroup, consoleEl);
    stage.insertBefore(wrap, consoleEl);
    render();
  }

  /* ---------------- 按钮演示 ---------------- */
  function initButtonDemo() {
    var stage = document.getElementById("demo-button");
    if (!stage) return;
    var consoleEl = consoleOf(stage);
    var row = el("div", "el-chip-row demo-dark-strip");
    [["default", "默认按钮"], ["primary", "主要按钮"], ["ghost", "幽灵按钮"]].forEach(function (item) {
      var kind = item[0];
      var btn = el("span", "el-btn" + (kind === "default" ? "" : " " + kind), item[1]);
      btn.addEventListener("click", function () {
        logEvent(consoleEl, "pressed", 'kind: "' + kind + '"');
      });
      row.appendChild(btn);
    });
    stage.insertBefore(row, consoleEl);
  }

  /* ---------------- 输入框演示 ---------------- */
  function initInputDemo() {
    var stage = document.getElementById("demo-input");
    if (!stage) return;
    var consoleEl = consoleOf(stage);
    var input = document.createElement("input");
    input.className = "el-input";
    input.placeholder = "输入国家名称，回车提交";
    input.addEventListener("input", function () {
      logEvent(consoleEl, "text_changed", '"' + input.value + '"');
    });
    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter") logEvent(consoleEl, "text_submitted", '"' + input.value + '"');
    });
    stage.insertBefore(input, consoleEl);
  }

  /* ---------------- 开关演示 ---------------- */
  function initSwitchDemo() {
    var stage = document.getElementById("demo-switch");
    if (!stage) return;
    var consoleEl = consoleOf(stage);
    var row = el("div");

    function makeSwitch(initialChecked, label) {
      var sw = el("span", "el-switch" + (initialChecked ? " on" : ""));
      sw.appendChild(el("span", "knob"));
      sw.addEventListener("click", function () {
        var checked = !sw.classList.contains("on");
        sw.classList.toggle("on", checked);
        logEvent(consoleEl, "toggled", "checked: " + checked);
      });
      var field = el("span", "el-field");
      field.appendChild(sw);
      field.appendChild(el("span", "f-label", label));
      return field;
    }

    row.appendChild(makeSwitch(false, "checked = false"));
    row.appendChild(makeSwitch(true, "checked = true"));
    stage.insertBefore(row, consoleEl);
  }

  /* ---------------- 标签演示 ---------------- */
  function initTagDemo() {
    var stage = document.getElementById("demo-tag");
    if (!stage) return;
    var consoleEl = consoleOf(stage);
    var KINDS = ["accent", "info", "dim"];
    var row = el("div", "el-chip-row");
    [["新上线", "accent"], ["进行中", "info"], ["已归档", "dim"]].forEach(function (item) {
      var tag = el("span", "el-tag " + item[1], item[0]);
      tag.style.cursor = "pointer";
      tag.addEventListener("click", function () {
        var at = KINDS.indexOf(tag.classList.contains("accent") ? "accent"
          : tag.classList.contains("info") ? "info" : "dim");
        var next = KINDS[(at + 1) % KINDS.length];
        tag.className = "el-tag " + next;
        logEvent(consoleEl, "set_kind", 'kind: "' + next + '"（点击循环切换配色）');
      });
      row.appendChild(tag);
    });
    stage.insertBefore(row, consoleEl);
  }

  /* ---------------- 单选按钮组演示 ---------------- */
  function initRadioGroupDemo() {
    var stage = document.getElementById("demo-radio-group");
    if (!stage) return;
    var consoleEl = consoleOf(stage);
    var row = el("div", "el-chip-row");
    var selected = 0;
    var chips = ["面积", "人口", "名称"].map(function (text, index) {
      var chip = el("span", "el-chip" + (index === selected ? " selected" : ""), text);
      chip.addEventListener("click", function () {
        if (selected === index) return; // 单选：重复点击已选中项不发事件
        selected = index;
        renderChips();
        logEvent(consoleEl, "selected_changed", "index: " + index + "（单选状态由组内维护）");
      });
      row.appendChild(chip);
      return chip;
    });
    function renderChips() {
      chips.forEach(function (chip, index) {
        chip.className = "el-chip" + (index === selected ? " selected" : "");
      });
    }
    stage.insertBefore(row, consoleEl);
  }

  /* ---------------- 复选按钮组演示 ---------------- */
  function initCheckboxGroupDemo() {
    var stage = document.getElementById("demo-checkbox-group");
    if (!stage) return;
    var consoleEl = consoleOf(stage);
    var row = el("div", "el-chip-row");
    var checked = {};
    [["分组 A", 1], ["分组 B", 2], ["分组 C", 3], ["分组 D", 4], ["分组 E", 5]].forEach(function (item) {
      var chip = el("span", "el-chip", item[0]);
      chip.addEventListener("click", function () {
        checked[item[1]] = !checked[item[1]];
        chip.className = "el-chip" + (checked[item[1]] ? " selected" : "");
        logEvent(consoleEl, "option_toggled", "value: " + item[1] + (checked[item[1]] ? "（勾选）" : "（取消勾选）"));
      });
      row.appendChild(chip);
    });
    stage.insertBefore(row, consoleEl);
  }

  /* ---------------- 手风琴演示 ---------------- */
  function initAccordionDemo() {
    var stage = document.getElementById("demo-accordion");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var DATA = [
      { title: "亚洲", items: ["中国", "印度", "印度尼西亚", "日本"] },
      { title: "欧洲", items: ["俄罗斯", "法国", "德国", "意大利"] },
      { title: "非洲", items: ["阿尔及利亚", "南非", "埃及", "尼日利亚"] },
    ];
    var accordionMode = true;
    var openIndex = 0; // 手风琴模式：当前展开分组序号
    var openSet = { 0: true }; // 独立开合模式：序号 -> 展开态

    var modeBtn = el("span", "el-btn", "切换为独立开合");
    modeBtn.style.marginBottom = "14px";
    var list = el("div", "pa-list");

    function isOpen(index) {
      return accordionMode ? index === openIndex : !!openSet[index];
    }

    function render() {
      list.textContent = "";
      DATA.forEach(function (group, index) {
        var open = isOpen(index);
        var titleRow = el("div", "pa-title-row" + (open ? " active" : ""));
        titleRow.appendChild(el("span", "a-title", group.title));
        titleRow.appendChild(el("span", "a-count", group.items.length + " 项"));
        titleRow.appendChild(el("span", "a-arrow", open ? "▾" : "▸"));
        titleRow.addEventListener("click", function () {
          var expanded;
          if (accordionMode) {
            expanded = index !== openIndex;
            openIndex = expanded ? index : -1;
          } else {
            openSet[index] = !openSet[index];
            expanded = openSet[index];
          }
          render();
          logEvent(consoleEl, "section_toggled", "section_index: " + index + ", expanded: " + expanded);
        });
        list.appendChild(titleRow);
        if (!open) return;
        var content = el("div", "pa-content");
        group.items.forEach(function (name) {
          var row = el("div", "gl-item-row");
          row.appendChild(el("span", "i-name", name));
          content.appendChild(row);
        });
        list.appendChild(content);
      });
    }

    modeBtn.addEventListener("click", function () {
      accordionMode = !accordionMode;
      if (accordionMode) openIndex = 0;
      modeBtn.textContent = accordionMode ? "切换为独立开合" : "切换为手风琴模式";
      render();
    });

    render();
    stage.insertBefore(modeBtn, consoleEl);
    stage.insertBefore(list, consoleEl);
  }

  /* ---------------- 选择器演示（单选 + 多选并排） ---------------- */
  function initSelectDemo() {
    var stage = document.getElementById("demo-select");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    function labelFor(options, v) {
      for (var i = 0; i < options.length; i++) {
        if (options[i][1] === v) return options[i][0];
      }
      return v;
    }

    function makeHolder() {
      var holder = el("span");
      holder.style.position = "relative";
      holder.style.display = "inline-block";
      return holder;
    }

    // ---- 单选示例：时段 ----
    var OPTIONS = [["白天", "day"], ["夜晚", "night"], ["黄昏", "dusk"]];
    var value = "day";

    var holder = makeHolder();
    var box = el("div", "el-select-box");
    var boxLabel = el("span", "el-select-label", labelFor(OPTIONS, value));
    box.appendChild(boxLabel);
    box.appendChild(el("span", "arrow", "▾"));
    var panel = el("div", "el-popout");
    panel.style.top = "40px";
    panel.style.left = "0";
    panel.style.display = "none";

    function renderPanel() {
      panel.textContent = "";
      OPTIONS.forEach(function (option) {
        var row = el("div", "el-select-row" + (option[1] === value ? " selected" : ""), option[0]);
        row.addEventListener("click", function (e) {
          e.stopPropagation();
          value = option[1];
          boxLabel.textContent = labelFor(OPTIONS, value);
          renderPanel(); // 重建行节点，移动当前项高亮与行尾选中点
          setSingle(false);
          logEvent(consoleEl, "option_selected", 'value: "' + value + '"（发出并收起面板）');
        });
        panel.appendChild(row);
      });
    }

    var isOpen = false;
    function setSingle(open) {
      isOpen = open;
      panel.style.display = open ? "block" : "none";
      if (open) logEvent(consoleEl, "opened", "无");
    }

    box.addEventListener("click", function (e) {
      e.stopPropagation();
      setSingle(!isOpen);
    });

    renderPanel();
    holder.appendChild(box);
    holder.appendChild(panel);

    // ---- 多选示例：大洲（multiple = true） ----
    var MULTI_OPTIONS = [["亚洲", "asia"], ["欧洲", "europe"], ["非洲", "africa"]];
    var values = []; // 多选模式勾选值集合
    var PLACEHOLDER = "选择大洲";

    var multiHolder = makeHolder();
    var multiBox = el("div", "el-select-box");
    var multiLabel = el("span", "el-select-label placeholder", PLACEHOLDER);
    multiBox.appendChild(multiLabel);
    multiBox.appendChild(el("span", "arrow", "▾"));
    var multiPanel = el("div", "el-popout");
    multiPanel.style.top = "40px";
    multiPanel.style.left = "0";
    multiPanel.style.display = "none";

    function renderMultiLabel() {
      if (!values.length) {
        multiLabel.textContent = PLACEHOLDER; // 多选无选中显示 placeholder
        multiLabel.className = "el-select-label placeholder";
      } else {
        var first = labelFor(MULTI_OPTIONS, values[0]);
        multiLabel.textContent = values.length > 1 ? first + " 等 " + values.length + " 项" : first;
        multiLabel.className = "el-select-label";
      }
    }

    function renderMultiPanel() {
      multiPanel.textContent = "";
      MULTI_OPTIONS.forEach(function (option) {
        var checked = values.indexOf(option[1]) >= 0;
        var row = el("div", "el-select-row" + (checked ? " checked" : ""));
        row.appendChild(el("span", "el-check", "✓")); // 行首琥珀对勾
        row.appendChild(el("span", null, option[0]));
        row.addEventListener("click", function (e) {
          e.stopPropagation();
          var removed = false;
          var at = values.indexOf(option[1]);
          if (at >= 0) { values.splice(at, 1); removed = true; } else { values.push(option[1]); }
          renderMultiPanel();
          renderMultiLabel();
          logEvent(consoleEl, "option_toggled", 'value: "' + option[1] + '"' + (removed ? "（取消勾选）" : "（勾选）"));
        });
        multiPanel.appendChild(row);
      });
    }

    var multiOpen = false;
    function setMulti(open) {
      multiOpen = open;
      multiPanel.style.display = open ? "block" : "none";
      if (open) logEvent(consoleEl, "opened", "无");
    }

    multiBox.addEventListener("click", function (e) {
      e.stopPropagation();
      setMulti(!multiOpen);
    });

    renderMultiPanel();
    renderMultiLabel();
    multiHolder.appendChild(multiBox);
    multiHolder.appendChild(multiPanel);

    // 点面板外收起任意展开的面板
    stage.addEventListener("click", function (e) {
      if (isOpen && !panel.contains(e.target) && !box.contains(e.target)) setSingle(false);
      if (multiOpen && !multiPanel.contains(e.target) && !multiBox.contains(e.target)) setMulti(false);
    });

    var singleGroup = el("div", "demo-group");
    singleGroup.appendChild(el("div", "demo-label", "单选 · 时段（点击选中并收起，行尾选中点）"));
    singleGroup.appendChild(holder);
    var multiGroup = el("div", "demo-group");
    multiGroup.appendChild(el("div", "demo-label", "多选 · 大洲（点击切换勾选、面板保持展开，行首琥珀对勾）"));
    multiGroup.appendChild(multiHolder);

    stage.insertBefore(singleGroup, consoleEl);
    stage.insertBefore(multiGroup, consoleEl);
  }

  /* ---------------- 进度条演示 ---------------- */
  function initProgressDemo() {
    var stage = document.getElementById("demo-progress");
    if (!stage) return;

    var row = el("div", "el-progress");
    var track = el("div", "el-progress-track");
    var fill = el("div", "el-progress-fill");
    track.appendChild(fill);
    var percent = el("span", "el-progress-percent", "0%");
    row.appendChild(track);
    row.appendChild(percent);

    // 滑块联动（0-100）
    var area = el("div", "ps-track-area");
    area.style.width = "260px";
    area.style.marginTop = "20px";
    var ptrack = el("div", "ps-track");
    var pfill = el("div", "ps-fill");
    ptrack.appendChild(pfill);
    area.appendChild(ptrack);
    var thumb = el("div", "ps-thumb");
    area.appendChild(thumb);

    stage.appendChild(row);
    stage.appendChild(area);

    var TRACK_W = 260;
    var value = 36;
    var dragging = false;

    function render() {
      fill.style.width = value + "%";
      pfill.style.width = (value / 100) * TRACK_W + "px";
      thumb.style.left = (value / 100) * TRACK_W + "px";
      percent.textContent = Math.round(value) + "%";
    }

    function setValue(v) {
      value = Math.min(100, Math.max(0, v));
      render();
    }

    function valueFromEvent(e) {
      var rect = area.getBoundingClientRect();
      var ratio = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width));
      return ratio * 100;
    }

    area.addEventListener("pointerdown", function (e) {
      dragging = true;
      if (area.setPointerCapture) area.setPointerCapture(e.pointerId);
      setValue(valueFromEvent(e));
    });
    area.addEventListener("pointermove", function (e) {
      if (dragging) setValue(valueFromEvent(e));
    });
    area.addEventListener("pointerup", function () { dragging = false; });
    area.addEventListener("pointercancel", function () { dragging = false; });

    render();
  }

  /* ---------------- 消息提示演示 ---------------- */
  function initMessageDemo() {
    var stage = document.getElementById("demo-message");
    if (!stage) return;

    var host = el("div", "el-message-host");
    stage.appendChild(host);
    var queue = [];
    var showing = false;

    function pump() {
      if (showing || !queue.length) return;
      showing = true;
      var item = queue.shift();
      var node = el("div", "el-message", item.text);
      host.appendChild(node);
      setTimeout(function () {
        node.classList.add("hide");
        setTimeout(function () {
          if (node.remove) node.remove();
          showing = false;
          pump();
        }, 320);
      }, item.duration * 1000);
    }

    function showText(text, duration) {
      queue.push({ text: text, duration: duration == null ? 2.0 : duration });
      pump(); // 重复调用排队显示
    }

    var row = el("div", "el-chip-row");
    row.style.marginTop = "26px";
    [["普通提示", "已加载 12 个国家", 2.0], ["成功提示", "保存成功", 2.0], ["长时提示", "网络错误，正在重试", 3.2]]
      .forEach(function (item) {
        var btn = el("span", "el-btn", item[0]);
        btn.addEventListener("click", function () { showText(item[1], item[2]); });
        row.appendChild(btn);
      });
    stage.insertBefore(row, host.nextSibling);
  }

  /* ---------------- 对话框演示 ---------------- */
  function initDialogDemo() {
    var stage = document.getElementById("demo-dialog");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var openBtn = el("span", "el-btn primary", "打开对话框");
    var dialog = null;

    function close() {
      if (!dialog) return;
      if (dialog.remove) dialog.remove();
      dialog = null;
      logEvent(consoleEl, "closed", "无");
    }

    function open() {
      if (dialog) return;
      dialog = el("div", "el-dialog-mask");
      var panel = el("div", "el-dialog");
      var header = el("div", "el-dialog-header");
      header.appendChild(el("span", "el-dialog-title", "删除确认"));
      var closeBtn = el("span", "el-dialog-close", "×");
      header.appendChild(closeBtn);
      var body = el("div", "el-dialog-body", "确认删除所选的 3 个国家？遮罩与面板就地消费点击：点遮罩不关闭（visible_modal = true），点右上角 × 关闭。");
      panel.appendChild(header);
      panel.appendChild(body);
      dialog.appendChild(panel);
      dialog.addEventListener("click", function (e) {
        if (e.stopPropagation) e.stopPropagation(); // 遮罩与面板就地消费点击
      });
      closeBtn.addEventListener("click", function (e) {
        if (e.stopPropagation) e.stopPropagation();
        close();
      });
      stage.appendChild(dialog);
      logEvent(consoleEl, "opened", "无");
    }

    openBtn.addEventListener("click", function (e) {
      if (e.stopPropagation) e.stopPropagation();
      open();
    });
    stage.insertBefore(openBtn, consoleEl);
  }

  /* ---------------- 卡片演示 ---------------- */
  function initCardDemo() {
    var stage = document.getElementById("demo-card");
    if (!stage) return;

    var card = el("div", "el-card");
    card.appendChild(el("div", "el-card-header", "国家概览"));
    var body = el("div", "el-card-body");
    body.appendChild(el("div", null, "当前收录 12 个国家，覆盖 3 个大洲。"));
    var meta = el("div");
    meta.style.marginTop = "8px";
    meta.appendChild(el("span", "el-tag accent", "已同步"));
    meta.appendChild(el("span", "el-tag dim", "离线数据"));
    body.appendChild(meta);
    card.appendChild(body);
    stage.appendChild(card);
  }

  /* ---------------- 分割线演示 ---------------- */
  function initDividerDemo() {
    var stage = document.getElementById("demo-divider");
    if (!stage) return;

    function divider(text) {
      var node = el("div", "el-divider");
      node.appendChild(el("span", "line"));
      if (text) node.appendChild(el("span", "d-text", text));
      node.appendChild(el("span", "line"));
      return node;
    }

    var above = el("div", null, "上方的说明文字，字号 13，弱化色。");
    above.style.cssText = "font-size:13px;color:rgba(41,43,51,0.72);text-shadow:0 1px 0 rgba(255,255,255,0.55);";
    var below = el("div", null, "下方的说明文字，与上方便于对照线与文案的断开效果。");
    below.style.cssText = above.style.cssText;
    stage.appendChild(above);
    stage.appendChild(divider(""));
    stage.appendChild(divider("筛选条件"));
    stage.appendChild(below);
  }

  /* ---------------- 徽章演示 ---------------- */
  function initBadgeDemo() {
    var stage = document.getElementById("demo-badge");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var count = 5;
    var show = true;

    var holder = el("span");
    holder.style.position = "relative";
    holder.style.display = "inline-flex";
    var icon = el("span", "el-icon-btn");
    icon.style.position = "static";
    icon.innerHTML = ICON_SVGS.gear;
    var badge = el("span", "el-badge pill", String(count));
    badge.style.top = "-6px";
    badge.style.right = "-6px";
    holder.appendChild(icon);
    holder.appendChild(badge);

    function renderState() {
      if (!show) {
        badge.style.display = "none";
      } else {
        badge.style.display = "flex";
        if (count > 0) {
          badge.className = "el-badge pill";
          badge.textContent = String(count);
        } else {
          badge.className = "el-badge"; // 等于 0 显示小圆点
          badge.textContent = "";
        }
      }
      consoleEl.textContent = "count: " + count + "，show: " + show +
        (show ? (count > 0 ? "（数字胶囊）" : "（小圆点）") : "（隐藏）");
    }

    var row = el("div", "el-chip-row");
    row.style.marginTop = "20px";
    [["＋1", function () { count += 1; }], ["−1", function () { count = Math.max(0, count - 1); }],
     ["显示切换", function () { show = !show; }]].forEach(function (item) {
      var btn = el("span", "el-btn", item[0]);
      btn.addEventListener("click", function () { item[1](); renderState(); });
      row.appendChild(btn);
    });

    stage.insertBefore(holder, consoleEl);
    stage.insertBefore(row, consoleEl);
    renderState();
  }

  /* ---------------- 页签演示 ---------------- */
  function initTabsDemo() {
    var stage = document.getElementById("demo-tabs");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var TITLES = ["总览", "成员", "设置"];
    var BODIES = [
      "概要内容：当前收录 12 个国家，覆盖 3 个大洲。",
      "成员列表内容：中国、俄罗斯、美国、巴西……",
      "设置内容：排序方式、显示列与数据刷新选项。",
    ];
    var active = 0;

    var tabs = el("div", "el-tabs");
    var bar = el("div", "el-tab-bar");
    var content = el("div", "el-tab-content");
    var tabEls = TITLES.map(function (title, index) {
      var tab = el("div", "el-tab", title);
      tab.addEventListener("click", function () {
        if (active === index) return;
        active = index;
        render();
        logEvent(consoleEl, "tab_changed", "index: " + index);
      });
      bar.appendChild(tab);
      return tab;
    });
    tabs.appendChild(bar);
    tabs.appendChild(content);

    function render() {
      tabEls.forEach(function (tab, index) {
        tab.className = "el-tab" + (index === active ? " active" : "");
      });
      content.textContent = BODIES[active];
    }
    render();
    stage.insertBefore(tabs, consoleEl);
  }

  /* ---------------- 警示条演示 ---------------- */
  function initAlertDemo() {
    var stage = document.getElementById("demo-alert");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var KINDS = ["info", "success", "warning", "danger"];
    var TEXTS = {
      info: "提示：国家数据已同步完成。",
      success: "成功：偏好设置已保存。",
      warning: "警告：网络延迟较高，操作可能变慢。",
      danger: "错误：连接已断开，请检查网络。",
    };
    var kind = "info";
    var hidden = false;

    var chipRow = el("div", "el-chip-row");
    var chips = KINDS.map(function (name) {
      var chip = el("span", "el-chip" + (name === kind ? " selected" : ""), name);
      chip.addEventListener("click", function () {
        kind = name;
        hidden = false;
        renderChips();
        renderAlert();
        logEvent(consoleEl, "set_kind", 'kind: "' + kind + '"');
      });
      chipRow.appendChild(chip);
      return chip;
    });
    function renderChips() {
      chips.forEach(function (chip, index) {
        chip.className = "el-chip" + (KINDS[index] === kind ? " selected" : "");
      });
    }

    var alertWrap = el("div", "demo-dark-strip");
    alertWrap.style.marginTop = "14px";
    var alertBox = el("div", "el-alert info");
    alertBox.style.flex = "1";
    var alertText = el("span", null, TEXTS[kind]);
    alertBox.appendChild(alertText);
    var closeBtn = el("span", "a-close", "×");
    alertBox.appendChild(closeBtn);

    function renderAlert() {
      alertBox.className = "el-alert " + kind;
      alertBox.style.display = hidden ? "none" : "flex";
      alertText.textContent = TEXTS[kind];
    }

    closeBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      hidden = true;
      renderAlert();
      logEvent(consoleEl, "closed", "无（面板隐藏）");
    });

    var restoreBtn = el("span", "el-btn", "重新显示");
    restoreBtn.style.marginTop = "12px";
    restoreBtn.addEventListener("click", function () {
      hidden = false;
      renderAlert();
    });

    alertWrap.appendChild(alertBox);
    renderChips();
    renderAlert();
    stage.insertBefore(chipRow, consoleEl);
    stage.insertBefore(alertWrap, consoleEl);
    stage.insertBefore(restoreBtn, consoleEl);

    // 四种语义配色参考
    var label = el("div", "demo-label", "四种语义配色");
    label.style.marginTop = "22px";
    stage.insertBefore(label, consoleEl);
    KINDS.forEach(function (name) {
      var refWrap = el("div", "demo-dark-strip");
      refWrap.style.marginTop = "8px";
      refWrap.appendChild(el("div", "el-alert " + name, TEXTS[name]));
      stage.insertBefore(refWrap, consoleEl);
    });
  }

  /* ---------------- 悬停提示演示 ---------------- */
  function initTooltipDemo() {
    var stage = document.getElementById("demo-tooltip");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var placement = "top";

    // 宿主图标 + 气泡
    var holder = el("span");
    holder.style.position = "relative";
    holder.style.display = "inline-flex";
    var icon = el("span", "el-icon-btn");
    icon.style.position = "static";
    icon.innerHTML = ICON_SVGS.gear;
    var tip = el("span", "el-tooltip above", "全局设置");
    tip.appendChild(el("span", "t-arrow"));
    tip.style.display = "none";
    holder.appendChild(icon);
    holder.appendChild(tip);

    function applyPlacement() {
      tip.className = "el-tooltip " + (placement === "top" ? "above" : "below");
    }
    function setVisible(visible) {
      tip.style.display = visible ? "block" : "none";
    }

    // 悬停显隐自动接线（等价 attach_to 的 mouse_entered/exited）
    icon.addEventListener("mouseenter", function () { setVisible(true); });
    icon.addEventListener("mouseleave", function () { setVisible(false); });

    // placement 切换（单选 chips）
    var chipRow = el("div", "el-chip-row");
    chipRow.style.marginTop = "30px";
    var chips = [["top", "上方"], ["bottom", "下方"]].map(function (item) {
      var chip = el("span", "el-chip" + (item[0] === placement ? " selected" : ""), "placement = " + item[0] + "（" + item[1] + "）");
      chip.addEventListener("click", function () {
        placement = item[0];
        chips.forEach(function (c, index) {
          c.className = "el-chip" + (["top", "bottom"][index] === placement ? " selected" : "");
        });
        applyPlacement();
        logEvent(consoleEl, "set_placement", 'placement: "' + placement + '"');
      });
      chipRow.appendChild(chip);
      return chip;
    });

    // 编程控制按钮
    var btnRow = el("div", "el-chip-row");
    btnRow.style.marginTop = "10px";
    [["show_tip()", true], ["hide_tip()", false]].forEach(function (item) {
      var btn = el("span", "el-btn", item[0]);
      btn.addEventListener("click", function () {
        setVisible(item[1]);
        logEvent(consoleEl, item[0], (item[1] ? "显示" : "隐藏") + "（placement: " + placement + "）");
      });
      btnRow.appendChild(btn);
    });

    stage.insertBefore(holder, consoleEl);
    stage.insertBefore(chipRow, consoleEl);
    stage.insertBefore(btnRow, consoleEl);
  }

  /* ---------------- 分页器演示 ---------------- */
  function initPaginationDemo() {
    var stage = document.getElementById("demo-pagination");
    if (!stage) return;
    var consoleEl = consoleOf(stage);

    var total = 12;
    var current = 3;
    var bar = el("div", "el-pagination");

    function sequence() {
      if (total <= 7) {
        var all = [];
        for (var p = 1; p <= total; p++) all.push(p);
        return all;
      }
      var keep = { 1: true };
      keep[total] = true;
      for (var d = -1; d <= 1; d++) {
        var n = current + d;
        if (n >= 1 && n <= total) keep[n] = true;
      }
      var nums = Object.keys(keep).map(Number).sort(function (a, b) { return a - b; });
      var seq = [];
      nums.forEach(function (num, index) {
        if (index > 0 && num - nums[index - 1] > 1) seq.push("…");
        seq.push(num);
      });
      return seq;
    }

    function go(page, emit) {
      var next = Math.min(total, Math.max(1, page)); // 超范围钳制
      var changed = next !== current;
      current = next;
      render();
      if (changed && emit) logEvent(consoleEl, "page_changed", "page: " + current);
    }

    function render() {
      bar.textContent = "";
      var prev = el("span", "el-page" + (current <= 1 ? " disabled" : ""), "‹");
      prev.addEventListener("click", function () { go(current - 1, true); });
      bar.appendChild(prev);
      sequence().forEach(function (item) {
        if (item === "…") {
          bar.appendChild(el("span", "el-page dots", "…"));
          return;
        }
        var chip = el("span", "el-page" + (item === current ? " current" : ""), String(item));
        chip.addEventListener("click", function () { go(item, true); });
        bar.appendChild(chip);
      });
      var next = el("span", "el-page" + (current >= total ? " disabled" : ""), "›");
      next.addEventListener("click", function () { go(current + 1, true); });
      bar.appendChild(next);
    }

    render();
    stage.insertBefore(bar, consoleEl);
  }


export function initDocs(path) {
  if (typeof document === "undefined") return;
  if (window.__docsInitedPath === path) return;
  window.__docsInitedPath = path;
  highlightCodeBlocks();
  initThemeDemo();
  initSliderDemo();
  initChipDemo();
  initIconButtonDemo();
  initSettingsDemo();
  initDockDemo();
  initGroupListDemo();
  initButtonDemo();
  initInputDemo();
  initSwitchDemo();
  initTagDemo();
  initRadioGroupDemo();
  initCheckboxGroupDemo();
  initAccordionDemo();
  initSelectDemo();
  initProgressDemo();
  initMessageDemo();
  initDialogDemo();
  initCardDemo();
  initDividerDemo();
  initBadgeDemo();
  initTabsDemo();
  initAlertDemo();
  initTooltipDemo();
  initPaginationDemo();
}
