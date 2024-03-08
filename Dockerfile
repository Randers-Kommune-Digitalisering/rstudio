from rocker/rstudio:latest

# Install dependencies
RUN apt-get update && apt-get -y install inotify-tools

# Copy scripts and make them executable
COPY backup.sh /usr/local/sbin/backup.sh
RUN chmod +x /usr/local/sbin/backup.sh
COPY restore.sh /usr/local/sbin/restore.sh
RUN chmod +x /usr/local/sbin/restore.sh
COPY bootstrap.sh /usr/local/sbin/bootstrap.sh
RUN chmod +x /usr/local/sbin/bootstrap.sh

# Start image with the new bootstrap
CMD /usr/local/sbin/bootstrap.sh