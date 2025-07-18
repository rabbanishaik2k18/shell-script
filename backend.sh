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



dnf module disable nodejs -y 
VALIDATE $? "Diable nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enable nodejs"

dnf install nodejs -y
VALIDATE $? "install nodejs"

useradd expense
VALIDATE $? "add user"

mkdir /app
VALIDATE $? "create directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Zip file"


cd /app
VALIDATE $? "change direcotry"

npm install
VALIDATE $? "install dependices"

cp /home/ec2-user/backend.service /etc/systemd/system/backend.service
VALIDATE $? "add systemctl file"


systemctl daemon-reload
VALIDATE $? "Reloaded modify file"

systemctl start backend
VALIDATE $? "systemctl start"

systemctl enable backend
VALIDATE $? "enable systemctl"


dnf install mysql -y
VALIDATE $? "install mysql"


mysql -h 172.31.27.20 -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "connect mysql"

systemctl restart backend
VALIDATE $? "systemctl restart"
