#quick_tests.sh
#!/bin/bash

git restore *
git pull
sudo chmod +x deploy/setup_scratch/bash_init/*.sh
sudo deploy/setup_scratch/bash_init/nginx_setup.sh
