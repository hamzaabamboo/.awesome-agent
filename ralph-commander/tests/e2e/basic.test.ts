import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Ralph Commander/i);
});

test('shows status grid', async ({ page }) => {
  await page.goto('/');
  const iterationLabel = page.locator('label', { hasText: /Iteration/i });
  await expect(iterationLabel).toBeVisible();
});
