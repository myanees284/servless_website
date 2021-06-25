#!/usr/bin/env bash
aws s3 sync $1 s3://$2
echo "website url is:" $3