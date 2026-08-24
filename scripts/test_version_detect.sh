#!/bin/sh
# Validate the version-detection grep used by the nextcloud role.
echo "=== current install (expect 31.0.13) ==="
grep -oP "(?<=OC_VersionString = ')[^']+" /var/www/html/nextcloud/version.php

echo "=== 34.0.3 archive version.php (expect 34.0.3) ==="
grep -oP "(?<=OC_VersionString = ')[^']+" /tmp/nextcloud/version.php

echo "=== missing file (expect empty, exit!=0) ==="
out=$(grep -oP "(?<=OC_VersionString = ')[^']+" /nonexistent/version.php 2>/dev/null)
echo "output=[$out] exit=$?"
