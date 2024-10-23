# quick_tests.sh
#!/bin/bash
export bash_DEPLOY_DIR="$HOME/Bugfinder/deploy/setup_scratch/bash_init"
cd ~/Bugfinder
git switch rtmp-breakout

git restore * && git pull
git switch rtmp-breakout
chmod +x $bash_DEPLOY_DIR/*.sh
cp -rav $bash_DEPLOY_DIR/quick_tests.sh ~/quick_tests.sh
sudo chmod +x ~/quick_tests.sh
