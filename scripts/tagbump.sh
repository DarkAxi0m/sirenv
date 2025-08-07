#!/bin/bash

# Fetch tags from remote
git fetch --tags

# Get the latest tag; if none exists, set to default "v1.0.0"
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")

# Extract major, minor, patch versions
IFS='.' read -r major minor patch <<< "${latest_tag//v/}"

# Ask user for version increment type
echo "Current version: $latest_tag"
echo "Select version update type:"
echo "1) Major"
echo "2) Minor"
echo "3) Patch"
read -p "Enter choice [1/2/3]: " version_choice

# Increment based on user choice
case $version_choice in
    1)
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    2)
        minor=$((minor + 1))
        patch=0
        ;;
    3)
        patch=$((patch + 1))
        ;;
    *)
        echo "Invalid choice. Aborting."
        exit 1
        ;;
esac

# Set the new tag
new_tag="v${major}.${minor}.${patch}"

# Get the current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Warn if not on 'main' or 'master'
if [[ "$current_branch" != "main" && "$current_branch" != "master" ]]; then
    read -p "You are on branch '$current_branch', not 'main' or 'master'. Continue? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "Aborting."
        exit 1
    fi
fi

versionfile="./composer.json"

# Check if composer.json exists
if [[ -f "$versionfile" ]]; then
    # Read the contents of composer.json
    current=$(cat "$versionfile")

    # Update the JSON with the new version
    updated_json=$(echo "$current" | jq --arg v "$new_tag" '.extra.version = $v')

    # Write the updated JSON back to composer.json
    echo "$updated_json" > "$versionfile"

    echo "Version updated to $new_version in $versionfile"
else
    echo "composer.json not found."
fi


# Commit changes
git add .
git commit -m "Update to ${new_tag}"

# Create new tag
git tag "$new_tag"

# Push commit and tag to remote
git push origin "$current_branch"
git push origin "$new_tag"

echo "Updated to $new_tag and pushed to remote on branch $current_branch."

