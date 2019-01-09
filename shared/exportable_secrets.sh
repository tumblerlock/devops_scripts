#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

#
# This is a utility function which:
# - fetches values from AWS SSM at a given path
# - reformats them for use as environment variabls
#
exportable_secrets () {
  local environment_path="$1"
  local aws_region="$2"

  aws ssm get-parameters-by-path \
    --region="$aws_region" \
    --path="$environment_path" \
    --with-decryption \
  | jq --raw-output \
    '
      .Parameters[] |
      {
        name: .Name | capture("/(.*/)(?<parsed_name>.*)") | .parsed_name,
        value: .Value
      } |
      "\(.name)=\"\(.value)\""
    ' \
  | tr '"' "'"
}

