#!/bin/bash

# Directory to store GuardDuty findings
output_dir="GuardDuty_Findings_Export"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Function to get GuardDuty findings
get_guardduty_findings() {
    region=$1
    detector_ids=$(aws guardduty list-detectors --region "$region" --query 'DetectorIds' --output text)

    for detector_id in $detector_ids; do
        aws guardduty list-findings --detector-id "$detector_id" --region "$region" --output json > "$output_dir/guardduty_findings_${region}.json"
    done
}

# Get all available regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region and get GuardDuty findings
for region in $regions; do
    echo "Fetching GuardDuty findings for region: $region"
    get_guardduty_findings "$region"
done

echo "GuardDuty findings export complete. Files are saved in the '$output_dir' directory."


