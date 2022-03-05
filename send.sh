#!/bin/bash

mdbook build
git add .
git commit -m "io_3_fix"
git push
