#!/usr/bin/env bash

# This script is used to output a summary of the job to the Github Summary.
# https://github.blog/2022-05-09-supercharging-github-actions-with-job-summaries/
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#adding-a-job-summary

# Usage (after checking out the repository):
# - name: Update Step Summary
#   run: .github/actions-scripts/output-job-summary.sh
#   id: step-summary
#   if: always()
#   shell: bash
#   env: # Optional
#     ADDITIONAL_OUTPUTS: "Event=${{ github.event_name }},PR=${{ github.event.pull_request.number}}" # Optional K=V pairs to add to the table, comma separated
#     DEBUG: "false" #Optional

# If run with debug=true in the environment, the script will output all environment variables to the step summary.
# Any inputs will automatically be added to the table

# Define a list of rows for the table
rows=(
  "Environment"
  "AWS Account ID"
  "Shared AWS Account ID"
  "Github Actor"
  "Project Type"
  "Github Ref"
  "Github Ref Type"
  "Git SHA"
  "Github Target Branch (Base Ref)"
  "S3 Artifact URL"
  "Github Workflow Ref"
  "Github Runner Name"
)

# Define the corresponding environment variables for each row
env_vars=(
  "INPUT_ENVIRONMENT"
  "INPUT_AWS_ACCOUNT_ID"
  "SHARED_AWS_ACCOUNT_ID"
  "GITHUB_ACTOR"
  "INPUT_PROJECT_TYPE"
  "GITHUB_REF"
  "GITHUB_REF_TYPE"
  "GITHUB_SHA"
  "GITHUB_BASE_REF"
  "S3_ARTIFACT_URL"
  "GITHUB_WORKFLOW_REF"
  "RUNNER_NAME"
)

# Detect the project type from the repository name if not provided as an input
function detect_project_type() {
  if [ -z "$INPUT_PROJECT_TYPE" ]; then
    if [[ "$GITHUB_REPOSITORY" =~ sammcj/exampleA-* ]]; then
      INPUT_PROJECT_TYPE="ProjectA"
    elif [[ "$GITHUB_REPOSITORY" =~ sammcj/exampleB-* ]]; then
      INPUT_PROJECT_TYPE="ProjectB"
    else
      echo "Common / Other"
    fi
  fi
}

function markdown_table() {
  # Initialize the table with headers
  markdown_table="| Job Summary | $(TZ=':Australia/Melbourne' date) |\n| --- | --- |\n"

  # Generate the markdown table
  # Loop through the rows and update the table with their corresponding environment variables, ignore any empty values
  for i in "${!rows[@]}"; do
    row=${rows[$i]}
    env_var=${env_vars[$i]}
    value=${!env_var}
    if [ -n "$value" ]; then
      markdown_table+="| $row | $value |\n"
    fi
  done

  # If the environment variable $ADDITIONAL_OUTPUTS contains a string -
  # split it into an array of K=V pairs and append the key to the rows and value env_vars arrays.
  # e.g. "INPUT_AWS_ACCOUNT_ID=1234,INPUT_AWS_REGION=ap-southeast-2", ignore any with empty values
  if [ -n "$ADDITIONAL_OUTPUTS" ]; then
    IFS=',' read -ra additional_outputs <<<"$ADDITIONAL_OUTPUTS"
    for additional_output in "${additional_outputs[@]}"; do
      IFS='=' read -ra output <<<"$additional_output"
      key=${output[0]}
      value=${output[1]}
      if [ -n "$value" ]; then
        rows+=("$key")
        env_vars+=("$value")
        markdown_table+="| $key | $value |\n"
      fi
    done
  fi

  # Loop through any environment variables starting with INPUT_ and add them to the table
  for env_var in $(env | grep -E '^INPUT_' | cut -d '=' -f 1); do
    value=${!env_var}
    if [ -n "$value" ]; then
      rows+=("$env_var")
      env_vars+=("$value")
      markdown_table+="| $env_var | $value |\n"
    fi
  done

  # Add any other useful information to the table
  markdown_table+="| Runner Uptime | $(uptime) |\n"
}

function debug() {
  # shellcheck disable=SC2129
  echo "Debug mode enabled" >>"$GITHUB_STEP_SUMMARY"

  # Print all environment variables
  env | sort >>"$GITHUB_STEP_SUMMARY"

  echo -e "\n" >>"$GITHUB_STEP_SUMMARY"
}

# Detect the type of project (KIS/KLUE/Common)
detect_project_type

# Create the table
markdown_table

if [[ $DEBUG == 'true' ]]; then
  debug
fi

# Output the completed markdown table to the step summary
#shellcheck disable=SC2129
echo -e "Step Summary \n" >>"$GITHUB_STEP_SUMMARY"
echo -e "$markdown_table" >>"$GITHUB_STEP_SUMMARY"

echo "_Markdown table generated by the output-job-summary script_" >>"$GITHUB_STEP_SUMMARY"
