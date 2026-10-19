/* Firmware validation must not regress when the reader reports another name.
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */
#include "drivers/goodix5301-firmware.h"

static void
test_firmware (void)
{
  const gchar *versions[] = { "GF3208_HT_APP_10035", "GF5288_HT_APP_10035" };
  const gchar *invalid[] = {
    "", "GF3208_HT_APP_1003", "GF5288_HT_APP_10036",
    "xGF3208_HT_APP_10035", "GF5288_HT_APP_10035x",
  };

  const guint8 embedded[] = "GF3208_HT_APP_10035\0garbage";

  for (gsize i = 0; i < G_N_ELEMENTS (versions); i++)
    {
      guint8 padded[32] = { 0 };
      gsize len = strlen (versions[i]);
      memcpy (padded, versions[i], len);
      g_assert_true (gdx_firmware_supported (padded, len));
      g_assert_true (gdx_firmware_supported (padded, len + 1));
      g_assert_true (gdx_firmware_supported (padded, sizeof (padded)));
      for (gsize truncated = 0; truncated < len; truncated++)
        g_assert_false (gdx_firmware_supported (padded, truncated));
    }
  for (gsize i = 0; i < G_N_ELEMENTS (invalid); i++)
    g_assert_false (gdx_firmware_supported ((const guint8 *) invalid[i], strlen (invalid[i])));
  g_assert_false (gdx_firmware_supported (embedded, sizeof (embedded) - 1));
  g_assert_false (gdx_firmware_supported (NULL, 0));
}

int
main (int argc, char **argv)
{
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/goodix5301/firmware", test_firmware);
  return g_test_run ();
}
