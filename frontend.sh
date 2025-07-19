#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOGS_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE_NAME="$LOGS_FOLDER/$LOGS_FILE-$TIMESTAMP"



VALIDATE(){

    if [ $1 -ne 0 ]
        then
        echo -e "$2 ...$R failue"
        exit 1
        else
        echo -e "$2 ... $G success"
fi
}

echo "script installed date: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT(){
if [ $USERID -ne 0 ]
then 
    echo "Error: you must have super prvillages"
    exit 1
fi
}

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "install nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "remove exists files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "download file"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "moving html file"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip the file"

cp /home/ec-user/shell-script/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "add config file"


systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restrat the server"
