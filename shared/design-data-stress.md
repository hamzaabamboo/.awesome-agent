# Data stress in design and dogfood

Use `break-ui` for data-bearing component/layout work and content-edge-case QA. Complete the normal-state browser pass first, then read its complete SKILL.md and CATALOG.md before the stress pass. Keep the existing task scope and one isolated browser session.

When project source is in scope, map rendered fields to their component and validation/API limits. Otherwise mark limits unknown and use existing approved inputs. This narrowly scoped source read is separate from black-box dogfood observations. Change fixtures or add a dev-only data switch only when the task permits local application edits. For read-only audits, report unavailable cases without adding scaffolding or changing production data.

Preserve the component, controls, identity colors and workflows. Supply plausible schema-backed values through its existing data boundary, not CSS edits that manufacture a failure. Cover normal, worst-case, empty and one-item states plus applicable catalog cases. Inspect rendered results at the real container width, a narrow viewport and enlarged text. CSS reasoning alone cannot pass visual acceptance.

When fixes are already authorized, use the upstream `<component> + fix` variant, resolve ordinary choices from project conventions, and verify normal and stressed states afterward. Otherwise report findings without product fixes. Keep regression fixtures dev-only; remove temporary instrumentation and close owned resources at the task's final wrap-up unless leaving them running was explicitly requested.
