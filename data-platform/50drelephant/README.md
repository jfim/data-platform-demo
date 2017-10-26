## Installation steps
Install docker & docker-compose
git clone https://github.com/jfim/data-platform-demo.git
cd data-platform-demo/data-platform/50drelephant
copy or create your hadoop cluster config in hadoop-conf.
docker-compose build
docker-compose up
docker-compose start
Then when it's up, you can connect to http://localhost:8080 (or use the hostname of the machine where you are running docker from)
