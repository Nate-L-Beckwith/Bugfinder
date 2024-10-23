# quick_tests.sh
#!/bin/bash
export bash_DEPLOY_DIR="$HOME/Bugfinder/deploy/setup_scratch/bash_init"

git restore * && git pull
chmod +x $bash_DEPLOY_DIR/*.sh
cp -rav $bash_DEPLOY_DIR/quick_tests.sh ~/quick_tests.sh
sudo chmod +x ~/quick_tests.sh
