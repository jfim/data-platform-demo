## Installation steps
Install docker & docker-compose
git clone https://github.com/jfim/data-platform-demo.git
cd data-platform-demo/data-platform/50drelephant
copy or create your hadoop cluster config in hadoop-conf.
docker-compose build
docker-compose up
docker-compose start
Then when it's up, you can connect to http://localhost:8080/new# (or use the hostname of the machine where you are running docker from)
Once your service is running, you can load data into mysql and see the same in UI
Run "docker ps" command and copy container id for 50drelephant_dr-elephant-mysql_1
Refresh UI and you will see all the applications
