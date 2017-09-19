---
title: "An R-docker hello world example"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```


# What we are doing

This document will run you through the steps to building, running and connecting a docker container that runs R.  We will

* Set up a dockerfile 
* Set up a composer file
* Build a container
* Run a container with Rstudio
* Connect to that container and run a script
* Write the output back to a mounted data folder on the host
* Look at how to set up other connections that you might use often

To play along at home, clone or download the directory from https://github.com/SymbolixAU/r_docker_hello

# About docker

Docker is a management system/environment for using containers. 
**Containers** are built on top of **hosts**  . They share the same kernel and hardware controllers but might have a different linux flavour or set of libraries on top.

We set up container **images** that are like snapshots of the container we want - all the libraries, files etc.  We then **run** the container to set up a temporary instance that contains all our working files.  When we are done we **stop** the ontainer and **all data and any local changes are lost forever!!!**  To save the output of a container instance we must write the data back to the host or somewehere else that's permanent.

If you do active development work only on the container, or save precious output, it will be lost and noone can bring it back.

This is an excellent practical introduction:
https://youtu.be/YFl2mCHdv24

I am assuming that you are working on a machine that already has a docker server running and configured.

# This example

Clone or download the repository from https://github.com/SymbolixAU/r_docker_hello. Change directory to `R_docker_hello`.

Inside this folder you will find:

* `Dockerfile`: This lives in the top directory and specifies our build options.
* Analysis folder: Holds a simple `hello_world.R` script that we will run in our container
* Data folder: The simplest input data you will ever see. We will also mount this folder when we run the container and we will write our output back to it.
* DockerConfig: We like some particular libraries, so I've made a `requirements.R` that will be run whenever we start our container.

# Building a docker container

Dockerfiles are used to build up an image.  we start **FROM** a base image then we **COPY** files or **RUN** extra commands or set specific **ENV** variables.  The Dockerfile lives in the top of the project and must be called **Dockerfile** with a capital **D**.

In this example, we are starting from the rocker/studio image.  These are public (not official) but are built by a team lead by Dirk Eddelbuettel so they are gonna be solid. rocker also have images for r-base (rocker/r-base) and a geospatial suite (rocker/rstudio-geospatial). This has all the basic spatial libraries (sp, sf) installed plus all the stuff you require outside of R to make them work (e.g. GDAL). 

To install extra libraries we specify them in `requirements.R`.  We copy this onto the instance and run it to install the libraries.

Finally we copy our files over - the `Analysis` folder and the `Data` folder.  We put these in the home directory of our user, called `rstudio`.  

```{r, echo = FALSE}
system("cat ../../Docker_examples/R_Helloworld/Dockerfile")
```


## Build it

Type the following command into the command line.  You must be in the same directory as your Dockerfile.

```
sudo docker build --rm --force-rm -t rstudio/hello-world .
```

the `--rm --force-rm` just forces the container to delete itself once its scripts run or you log out.  It just stops us filling up the server with lots of containers doing nothing.  Once this has built run

```
sudo docker image list 
```

to see your image added to the list.  We've called it `rstudio/hello-world` but you can call it anything.

## Run it

We want to use this image to access rstudio so we want it running as a background service (i.e. in detacted mode) we use the flag `-d` to do this.  If you want to access a bash shell or other interactive mode, you need to specify `-it`.

Rstudio runs on port 8787 within the container.  We need to map this to an  unused port on the host machine with a `-p <host port>:<container port>`  We will use 28787, but this can be any used port.

We will call our container `hello-world`.  This is the simple run command:

```
sudo docker run -d --rm -p 28787:8787 --name hello-world rstudio/hello-world
```

Run this command and access the container through your webbrowser at `<yourhostip:28787>`. Username and password are both `rstudio`. 

In rstudio, type

```
source("Analysis/hello.world.R")

```

You will see that you can see the Analysis and Data folder but there are two problems.  

In order to write to a file within Docker (through rstudio) you need to have the right userid.  With these rocker images you can get that by specifying -e USERID=$UID in the run command.  Then you can write and you can make changes to files and save them within the container.  This will be useful for things like PTV_SAMP where you want to load up a script, make some small local changes and run it.

It's all well and good to write to the local container but this data won't be permanent.  We can write our output back to the host directory by mounting a host directory as a volume on the container with -v /full/path/to/dir .  This is also useful in development as you can make changes in your permanent host folder which are then immediately available on the container without rebuilding it.

Before we fix the problem we need to stop the container that's running (it's no good for us):

```
sudo docker stop hello-world
```

Now lets try again.  If you look in run_docker.sh you will see a better version and explanation. Basically its:

```
DATA_DIR=${PWD}/Data
sudo docker run -d --rm -p 28787:8787 --name hello-world2 -e USERID=$UID -e PASSWORD=rstudio -v $DATA_DIR:/home/rstudio/Data rstudio/hello-world
```

Note in the above I have also set the password manually -- you can make it anything you want.

Run the commands above, log into <yourhostip:28787> and try sourcing the script.  It should run and write to the Data folder.  

Finally, go back to the command line once more. Type ls Data and you should see the output file there also.

One more thing.  In the rstudio window, open up Analysis/hello.world.R  add a line to the bottom - any command you want and save it and run it.  

Final question - if I check the contents of Analysis/hello.world.R on the command line (i.e. back on the host) will it have your new line?  Why?

### One last challenge:  
(Stop the old container first).  Now run it again, but set it up so you can make changes into hello.world.R on the command line and immediately have them show up and work in Rstudio.








