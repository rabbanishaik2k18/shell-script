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



dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Diable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enable nodejs"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "install nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "added user"
else
echo "expense user already exists...skipping"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "create directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Zip file"


cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip file"

cd /app

npm install &>>$LOG_FILE_NAME
VALIDATE $? "install dependices"

cp /home/ec2-user/expense-shell/shell-script/backend.service /etc/systemd/system/backend.service -y &>>$LOG_FILE_NAME
VALIDATE $? "add systemctl file"


systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Reloaded modify file"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "systemctl start"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enable systemctl"


dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "install mysql"


mysql -h 172.31.27.20 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "connect mysql"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "systemctl restart"
