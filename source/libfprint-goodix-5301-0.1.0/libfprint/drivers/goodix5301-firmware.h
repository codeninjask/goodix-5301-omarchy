/* Exact firmware identifiers observed on the Dell 27c6:5301 reader.
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */
#pragma once

#include <glib.h>
#include <string.h>

static inline gboolean
gdx_firmware_supported (const guint8 *payload, gsize len)
{
  static const gchar * const versions[] = {
    "GF3208_HT_APP_10035",
    "GF5288_HT_APP_10035",
  };

  if (!payload)
    return FALSE;

  /* Firmware strings may be NUL padded. Reject embedded NULs followed by
   * nonzero data, prefixes, suffixes, and different firmware revisions. */
  while (len && payload[len - 1] == 0)
    len--;
  for (gsize i = 0; i < G_N_ELEMENTS (versions); i++)
    if (len == strlen (versions[i]) && memcmp (payload, versions[i], len) == 0)
      return TRUE;

  return FALSE;
}
