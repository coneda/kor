## Installation (Docker)

These are our instructions to run ConedaKOR with [docker](https://docker.com). We wrote them to enable you to have a instance of ConedaKOR up and running as fast as possible to learn about it and to discover its functionality. We expect this to take 10 minutes or less. These steps should work on Windows, MacOS and Linux.

[some warning that this shouldn't be used in production without understanding how docker volumes work]

### What you will need

We are going to install docker which we will then use to download and run ConedaKOR. For this to work, you will need administrator rights on your computer. Although most of the steps are happening on the terminal, you don't need any prior experience with the terminal. If you are on Windows, make sure you have a recent enough version (see https://docs.microsoft.com/en-us/windows/wsl/install for details).

### 1: Download docker & docker compose

Docker is a set of tools for running containers on your Computer. What is a container? In short, its a process (think program) that runs in an isolated way: It has restricted access to your computer and it can be removed without trace if necessary. Docker containers, by default, only see the contents of a "image". These images then contain everything the process needs to run (system libraries, scripting languages, dictionaries etc.). Its not unusual to run several containers to provide a single application like ConedaKOR.

~~We don't want to start, configure and maintain multiple containers which is why we use docker-compose to do it for us: It manages all containers required, sets communication routes between them and handles any persistent storage.~~

If you don't have it already, start by installing docker ~~and docker compose~~ :

* On Windows and MacOS, go to https://www.docker.com/get-started/ and follow the instructions to install "Docker Desktop" for your OS
* On Debian-based Linux, e.g. Ubuntu, run "sudo apt-get install docker.io docker-compose" in a terminal

If, on Windows, you are prompted to install wsl 2, please install it following the given instructions.

To be on the safe side, restart your computer after docker has been installed.

### 2: Download ConedaKOR

You'll need to download the ConedaKOR source code because it contains configuration and setup instructions for the docker containers. Go to https://github.com/coneda/kor and Click on "Releases" on the right side of the page. Once there, find the section for the most recent version (for example v5.0.0) and click "Source code (zip)". Extract the zip file so that there is a folder on your Desktop called like the version you just downloaded (for example "kor-5.0.0"). For the following instructions, replace "v5.0.0" with the version you downloaded.

### 3: Run the containers

1. make sure your system is up to date
2. [Windows] Click the Windows start menu, type cmd and select "Command Prompt" to open a terminal.
3. [Windows] type `cd Desktop\kor-5.0.0` and hit enter
4. [MacOS & Linux] open your terminal application
5. [MacOS & Linux] type `cd ~/Desktop/kor-5.0.0`
6. again in your terminal, type `docker-compose up` and hit enter

The last command will likely take several minutes to finish. Once the terminal calms down and there is no more output, open your web browser and go to `http://localhost:8080`. You should see the ConedaKOR user interface. To log in, use "admin" for both username and password.

To stop all containers, press `ctrl-c` on your keyboard. After a couple of seconds, all containers should have shut down. The data is not deleted and will be available when you start the containers the next time. To remove the data, run `docker-compose down -v`.

If, at a later time, you'd like to start over at [[#2-Download-ConedaKOR|step 2]], to get access to new features and bugfixes, make sure to run `docker-compose build` just before running `docker-compose up` to build the new image.

### 4 Import / export

Data in Kor has the form of database entries and some files. Together these constitute a valid data snapshot. First, make sure your docker ConedaKOR is up and running. You can then extract a snapshot like so: Open a new (additional) command prompt and navigate to the ConedaKOR installation directory, like in step 3. Then run:

    docker-compose exec kor bin/docker snapshot > mysnapshot.tar.gz

This creates a the file `mysnapshot.tar.gz`. It contains all data required to restore the ConedaKOR installation. To restore from it, use

    docker-compose exec -T kor bin/docker restore < mysnapshot.tar.gz

Note the inverted "<" pipe character.

### 5 Known Problems

Docker uses ip ranges that might conflict with some public WIFI networks. One example is the onboard WIFI provided by Deutsche Bahn on some of their trains. Please refer to https://stackoverflow.com/questions/40082608/how-to-delete-interface-docker0 for a solution.
