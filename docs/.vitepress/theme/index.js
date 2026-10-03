import DefaultTheme from "vitepress/theme";
import "./docs.css";
import { useRoute } from "vitepress";
import { watch } from "vue";
import { initDocs } from "../docs-core.js";

export default {
  extends: DefaultTheme,
  setup() {
    if (typeof window === "undefined") return;
    const route = useRoute();
    watch(
      () => route.path,
      (path) => {
        let tries = 0;
        const tick = () => {
          tries += 1;
          const ready = document.querySelector(".vp-doc .demo-stage, .vp-doc .demo-console, .vp-doc table");
          if (ready) {
            initDocs(path);
            return;
          }
          if (tries < 30) setTimeout(tick, 120);
        };
        setTimeout(tick, 60);
      },
      { immediate: true },
    );
  },
};
