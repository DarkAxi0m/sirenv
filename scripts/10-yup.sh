#!/bin/bash
#
#

echo --Docker------------
docker ps --format '📌 {{.Names}} ({{.Image}}) - {{.Status}}'
echo --------------------
