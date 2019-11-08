# YouTube Stream Statistics 

A bash script useful for gathering data from YouTube streams, specifically current live stream viewers. 

## Table of Contents

1. [Dependencies](https://github.com/jivandabeast/youtubestreamstatistics#dependencies)
2. [Configuring the mySQL script](https://github.com/jivandabeast/youtubestreamstatistics#the-mysql-version-this-is-the-recommended-version)
3. [Configuring the basic script](https://github.com/jivandabeast/youtubestreamstatistics#the-basic-version)
4. [Deploying the script](https://github.com/jivandabeast/youtubestreamstatistics#deploying-the-scripts)
5. [Graphing the data you've collected with R](https://github.com/jivandabeast/youtubestreamstatistics#graphing-the-data-with-r)

# Dependencies

The script is very minimalistic and depends on a few packages (some which should have shipped with your operating system):
* `curl` 
* `date`
* `jq`

Obviously, if you plan on using the mySQL version of the script then you will require mySQL (`mysql-server`)

# Configuring the Scripts

## The mySQL Version *this is the recommended version*

1. Configure mySQL
   - [Install mySQL](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-18-04)
   - Set up a username and password for the script to use (I'd recommend NOT using the root account)
   - Add a table with two columns: One for the time, and one for the viewer count
     - `CREATE TABLE ViewCount(Time INTEGER, Viewers INTEGER, PRIMARY KEY (Time));`
     - In this case, you'll notice the "Time" column is an integer value because we are recording the time in the epoch format
     - *If you create your table with different table names and/or different data types, you will need to edit the last line of the script in accordance with your changes*
     
2. Edit the variables in lines 4-6 to match accordingly with the Username, Password, and Database that you have configured in mySQL
3. Edit line 9 to add in the Stream ID for the YouTube stream that you want data from
   - `curl -X GET "https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&id=` [YouTube Stream ID]`&key=AIzaSyAzRmWRQKbQpnAIH-Ws0ruzgxafjECdBCg" > temp.json`
   - The Stream ID is everything after `watch?v=` in the stream link

## The Basic Version

1. Edit the variable in line 4 of the script to contain the name/location of the file that you wish to store all your data in
2. Edit line 11 to add in the Stream ID for the YouTube stream that you want data from
   - `curl -X GET "https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&id=` [YouTube Stream ID]`&key=AIzaSyAzRmWRQKbQpnAIH-Ws0ruzgxafjECdBCg" > temp.json`
   - The Stream ID is everything after `watch?v=` in the stream link
3. If you wish to change the format at which the date is being recorded into the file, you can either uncomment line 7 (and comment line 8) OR customize it to your liking. For that you can use [this documentation](https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/)

# Deploying the Scripts

My recommendation for deploying the script is to start a `cron` job that will execute the script on specific intervals. The steps to do this are easy, and are as follows:

1. [Use this website to generate the command](https://crontab-generator.org/)
   - The command that you're going to want to enter into the website is going to look something like this:
     -  `/bin/sh /path/to/SQLViewCountWithTime.sh`
   - Configure all the other options, and then when you generate the command you should get something that looks along the lines of (it most likely will **not** look exactly like this, but it should give you a general idea):
      - `*/5 * * * *  /bin/sh /path/to/SQLViewCountWithTime.sh >/dev/null 2>&1`
2. Run `crontab -e` in your terminal, if this is your first time using the command it will ask you for your preferred text editor, choose your preference and move on.
3. Once you are in the file, copy and paste the line generated from step 1 into the end of the file
4. Save and quit
5. Wait for your intervals in which the command is supposed to run, check the database for data that has been entered, if it's there you're done
6. If the data is not there, you likely have an issue with either your `crontab` or the script.
   - The first step to debugging is just running the script without `cron` to ensure that it is operating properly
   - If running the script manually was successful, check your file permissions as they may be hindering `cron`'s ability to run the script

# Graphing the Data with R

In my experience, Excel did not play well with the data that I wanted to graph (though I did make a lot of changes to how the data was collected after I tested it, so YMMV). Therefore, I decided that a program like [R](https://www.r-project.org/) was the best option for visualizing my data. I also ended up with a lot of data, so this was a more efficent way of graphing that data.

The steps to graph your data using R are as follows: 
1. Run R
2. If you don't already have it, install the package `anytime` and then load it into the environment
   - `install.packages("anytime")`
   - `library(anytime)`
3. Export your mySQL data from the database and import it into the environment
   - To export your mySQL data, open a shell and run (fill in all bracketed terms):
     - `mysql -u [USERNAME] -p[PASSWORD] -D [DATABASE] -e "SELECT * FROM ViewCount" > [OUTPUTFILE]
     - **Note**: There is no space between `-p` and your password
   - To import it into the environment, run: 
     - `myData <- read.delim(file.choose(), header=TRUE)`
4. Create a new dataset containing the epoch time column, and then convert it to a better format
   - `times <- myData$EpochTime`
   - `times <- anytime(times)`
5. Plot the data on the graph
   - `plot(ViewCount ~ times, myData, xaxt = "n", type = "l")`
6. Edit the x-axis labels 
   - `axis(1, times, format(times, "%T"), cex.axis = .7)`
