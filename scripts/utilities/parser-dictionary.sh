#!/usr/bin/env bash
# ~/.local/bin/sdcv-clean
# Sdcv con limpieza HTML automática optimizada para scripts

sdcv -n "$@" | \
    sed '/^Found /d; /^\\/d; /^-->.*\\/d' | \
    html2text \
        --body-width 0 \
        --ignore-emphasis \
        --ignore-links \
        --ignore-images \
        --ignore-tables \
        --single-line-break \
        --ignore-mailto-links
