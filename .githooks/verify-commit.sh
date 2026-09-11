#!/bin/bash
# Verify signatures on release tags
git tag -v "$1" 2>/dev/null
