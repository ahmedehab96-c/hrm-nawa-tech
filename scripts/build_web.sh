#!/usr/bin/env bash
# Build Flutter web for SaaS / production deploy (same as build_web_portfolio.sh).
set -euo pipefail
exec "$(dirname "$0")/build_web_portfolio.sh"
