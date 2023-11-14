#!/bin/bash

# Navigate to the root directory of your repository
cd /path/to/your/repo

# Update the submodule
echo "Checking for updates in the settings submodule..."
cd settings
git checkout master
git pull origin master
cd ..

# Check if there are any changes
if [ -n "$(git diff --submodule)" ]; then
    echo "Updates found in the submodule. Committing them..."
    git add settings
    git commit -m "Updated settings submodule to the latest version"
    git push
    echo "Updates committed and pushed."
else
    echo "No updates in the submodule."
fi
