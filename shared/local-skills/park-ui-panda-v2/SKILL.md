---
name: park-ui-panda-v2
description: Set up Park UI (Ark UI + Panda CSS) on Panda v2, or migrate a project's hand-written CSS and home-made UI primitives onto it in phases. Use when adding Park UI or Ark components, porting Park registry files to Panda v2, replacing manual CSS with Panda recipes or JSX, or tuning Panda production CSS output.
---

# Park UI on Panda v2

Park UI ships for Panda v1. This skill is the path to run it on Panda v2 and to move an existing app onto it without breaking the app halfway. Write styles with the `panda-css` skill, design tokens and recipes with `panda-css-theming`, and look up component APIs in the `ark-ui` skill.

## Steps

1. **Read the project.** Read the existing stylesheet tokens, the home-made primitives, and how dark mode and the language are switched. If two sibling projects already run Park UI, read their `panda.config.ts`, `postcss.config.*` and `src/theme` before choosing settings. Done when you can name the palette, fonts, radii, dark-mode mechanism and i18n library.

2. **Settle the decisions with the user**: scope (whole app phased, primitives only, or one screen) and direction (keep the current identity, or redesign through a `DESIGN.md`). Done when both are answered. Do not pick a redesign yourself.

3. **Install pinned versions** at least two weeks old: `@pandacss/dev`, `@pandacss/vite` (or the postcss plugin), `@pandacss/preset-base`, `@pandacss/preset-panda` and `@ark-ui/react`. Every `@pandacss/*` package must be on the same version. Add `panda codegen` to `postinstall` and to the build and check scripts, and add `styled-system` to `.gitignore` and the tsconfig/Vite aliases. Done when `panda doctor` reports no problems.

4. **Fetch Park files from the registry**, not with the CLI: `https://park-ui.com/registry/react/<id>.json`, starting with `__init`, then each component and its `registryDependencies`. The CLI prompts interactively and needs a tsconfig `baseUrl`. Put theme files in `src/theme` and components in `src/components/ui`. Done when every registry dependency is on disk.

5. **Port to v2.** Replace `createStyleContext` with `createSlotRecipeContext` (slot recipes) or `createRecipeContext`. List the presets explicitly. Replace Lucide icons with the project's own icon set. Drop `'use client'` in apps that don't use React server components. Remove any hard-coded English (`aria-label="Close"`) so labels come from i18n. Done when `tsc` passes and grep finds no `createStyleContext` or `lucide-react`.

6. **Build the theme from the existing identity.** Map Park's 12-step `gray` and the accent palette (`solid`, `subtle`, `surface`, `outline`, `plain`) onto the project's own colours, and override `fontSizes`, `radii`, `fonts`, `durations` and `zIndex` to the project's values. Done when every text token passes WCAG AA on every surface it sits on (run the antislop contrast script), and failures already in the old palette are fixed, not copied.

7. **Wrap, don't rewrite call sites.** Re-implement the home-made primitives over Park components and keep their props and legacy hook classes. Then rewrite the old CSS selectors that targeted the replaced markup to Ark `data-part` attributes. Done when grep finds no stale selectors (such as `.seg button` or `.tabs button`), and every place that rendered the old markup without the primitive (a raw `div.dialog`, a file-picker `<label>`) now uses a component or recipe class.

8. **Migrate one area per commit.** Convert an area's CSS to recipes, `css()` or Panda JSX, and delete its legacy rules in the same commit. Done for an area when its legacy CSS file is gone.

9. **Turn on production optimisation and prove it** (settings under Gotchas). Done when the production build's preview runs in a real browser with no console errors, recipes render styled, and the CSS size is compared before and after.

10. **Verify each phase in a real browser** against the deployed or main build: dialogs, tabs, segment controls, light and dark mode, keyboard use (arrow keys, Escape, focus ring), and phone width. Done when each changed component has been clicked, and the dev server and browser sessions you opened are closed.

## Gotchas

- **Cascade during a phased migration.** Unlayered legacy CSS beats every Panda layer. Keep it unlayered so layout overrides keep working, but move global element resets (`button { background: none; padding: 0 }`) into `@layer base`, or they erase every recipe. Keep `preflight: false` until the legacy CSS is gone, because the app relies on browser default styles.
- **Dark mode.** Park's colours switch on `.dark`/`.light` classes. If the app uses `data-theme` or `light-dark()`, also set the resolved class from both the boot script and the theme setter.
- **i18n.** Wrap the app in Ark's `LocaleProvider` and feed it the i18n library's current language, so Ark's text direction and formatting follow the language.
- **Runtime variants.** A recipe variant passed as a runtime value (`variant={map[v]}`) emits only its default styles. List those recipes in `staticCss.recipes` with `['*']`.
- **`jsxStyleProps: 'all'`** makes Panda read same-named props on *every* component, not just Panda's, which emits junk classes. Do not give app components props named like CSS properties (`appearance`, `position`, `color`).
- **Hashing.** Panda 2.1.1's hashed runtime passes an array to `toHash`, so every recipe throws `charCodeAt is not a function` in production only; use 2.1.2 or later before enabling `hash`. Re-test by calling every recipe with the hashed codegen, then load the production preview. Read token variables in JavaScript through `token.var()`, never hand-written `var(--…)` names, since names are hashed.
- **v2 pruning** is `optimize: { removeUnusedTokens, removeUnusedKeyframes, smartCompoundVariants }` plus `minify` and `hash` in production. v2 has no `lightningcss` key. Panda emits one stylesheet, so CSS that the old app loaded lazily per chunk now loads up front; measure first-load gzipped CSS before and after.
- **Keyframes** belong in the theme (`theme.extend.keyframes`); `@keyframes` inside `css()` emits broken output.
- **Background shorthands with `/`** (`center / 40px 3px`) trigger a false opacity-modifier warning; write `bgImage`, `bgPosition`, `bgSize`, `bgRepeat` instead.
- **Ark Dialog.** Elements rendered outside `Dialog.Root` cannot use `Dialog.Header` or `Dialog.Title`. Give them the recipe classes (`dialog().header`, `dialog().content`) instead. If the app already closes dialogs on Escape globally, set `closeOnEscape={false}` so they don't close twice.
- **Ark FileUpload** replaces `<label><input type=file>` and accepts extension filters (`.kif,.csa`). Use `useFileUpload` and call `clearFiles()` after accepting, so the same file can be chosen again.
- **Lint.** Run Panda's rules inside oxlint with `"jsPlugins": ["@pandacss/eslint-plugin/oxlint"]` and the recommended rule names under `@pandacss/…`; no ESLint install is needed. Pin the plugin to the same version as `@pandacss/dev`. Turn on `@pandacss/no-important` after removing migration `!important`s so they cannot come back. Prove it fires by linting a scratch file with an un-prefixed `:hover`.
- **Hashing and dev.** With `hash` on in production, a build rewrites the shared `styled-system/` runtime with hashed names; a dev server started earlier keeps emitting unhashed CSS and the page renders unstyled. Restart dev after building, and never build while capturing browser evidence.
