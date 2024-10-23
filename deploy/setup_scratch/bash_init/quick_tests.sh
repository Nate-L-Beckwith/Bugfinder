# quick_tests.sh
#!/bin/bash
export BASH_DEPLOY_DIR="$HOME/Bugfinder/deploy/setup_scratch/bash_init"

# Restore all files to the last committed state
# Pull the latest changes and rebase
git pull --rebase
git pull --rebase
chmod +x $BASH_DEPLOY_DIR/*.sh
cp -rav $bash_DEPLOY_DIR/quick_tests.sh ~/quick_tests.sh
sudo chmod +x ~/quick_tests.sh
