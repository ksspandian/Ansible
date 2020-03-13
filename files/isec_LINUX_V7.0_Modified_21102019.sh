#!/bin/bash

##########################################################
# ISEC Command Roll-out Script                           #
# This script is used for LINUX ISEC TECH SPEC checking. #
# Author: Scott Windham / Jim Baker                      #
# Version: 1.0 Date:06/02/2009                           #
# Version: 2.0 Date:07/29/2009 add SSH check             #
# Version: 3.0 Date:08/19/2009 add greater SUDO check    #
# History:                                               #
# Version: 4.0 Date:11/08/2011 - Warren W. Smith         #
#              - Modified to match Linux iSeC Tech Spec  #
#                V1.2 release August 4, 2011.            #
#              - Added section numbers to outputs for    #
#                easier spreadsheet manipulation.        #
#              - Corrected several bugs & added numerous #
#                checks for more accuracy.               #
# Version: 4.5 Date:12/28/2011 - Warren W. Smith         #
#              - Fixed some bugs for RHEL6.x             #
#              - Updated AD.1.1.10 Exemptions sections   #
#                to be more clear on errors found.       #
# Version: 5.0 Date:01/09/2012 - Warren W. Smith         #
#              - Updated timer to be less confusing.     #
#              - Updated to support SuSE Linux           #
# Version: 5.5 Date:05/04/2012 - Warren W. Smith         #
#              - Updated to fix several bugs with FTP    #
#                checks.                                 #
#              - Updated to fix some SuSE related bugs   #
# Version: 6.0 Date:08/17/2012 - Warren W. Smith         #
#              - Updated to meet new iSeC V2.0A released #
#                May 8, 2012 (Linux/SSh/Sudo).           #
#              - Fixed bug found with timer causing      #
#                issues with question prompts for        #
#                sshd_confg and sudoers files if not     #
#                found.                                  #
#              - Added in new code provided by the team  #
#                to aid in additional checks not         #
#                originally done.                        #
# Version 6.5 Date:10/17/2012 - Warren W. Smith          #
#              - Updated to meet new iSeC V2.1 released  #
#                August 2, 2012 (Linux).                 #
#              - Updated to meed new sudo iSeC V2.1      #
#                released August 2, 2012                 #
#              - Added checks for Privileged Monitoring  #
# Version 6.6 Date:11/12/2012 - Warren W. Smith          #
#              - Updated due to bug found in RHEL6 and   #
#                grep & sed not using Locale correctly   #
#                and therefore failing ranges.           #
# Version 6.7 Date:02/05/2013 - Warren W. Smith          #
#              - Fixed bug in OSR check for other write  #
#                and any execute search incorrectly.     #
#              - Fixed bug with output in SSH where one  #
#                section was labeled wrong.              #
#              - Now up to date with iSeC template       #
#                version V2.1A released 12/20/2012.      #
#Version 6.8 Date 03/05/2013 - Warren W. Smith           #
#               Updated to add some additional code to   #
#               allow for intergrationwith TADDM tool.   #
#Version 6.9 Date 04/20/2013 - Warren W. Smith           #
#              - Updated to fix egrep range error on     #
#                SuSe 11.  NOT FULLY TESTED!             #
#Version 6.10 Date 06/13/2013 - Warren W. Smith          #
#              - Fixed bug in check for PASS_MIN_LEN     #
#Version 6.11 Date 09/19/2013 - Warren W. Smith          #
#              - Updated AV.1.2.6 to use logrotate       #
#Version 7.0  Date 02/03/2014 - Warren W. Smith          #
#              - Updated to be compliant with Linux iSeC #
#                tech spec version 3.0C                  #
#              - Also updated for sudo and ssh iSeC tech #
#                specs both version 3.0B                 #
#              - Fixed checking of sudo noexec checking  #
#                that broke with RHEL6.x and newer       #
#                version of sudo for any OS.             #
##########################################################

#Variables:
LOGFILE=/tmp/ISEC_`uname -n`.`date +%m%d%y`.output.txt
isecTIMEOUT=120 #This is in 5 second intervals, so 120 = 600 seconds = 10 minutes.
PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/sbin:$PATH
export PATH
TALLY2=1
LOGIT=Logit;

#Set this variable to 1 if you don't want to run interactive
#and it won't ask any questions for file(s) not found:
INTERSIL=0

#Set this variable to a 1 if being executed via TADDM tool.
#WARNING - ALSO set INTERSIL variable above to a 1!
TADDMSIL=0

##
#Set this variable to a 0 if you are scanning servers that belong
#to a HIPAA account and require the additional HIPAA checks.
#(iSeC sections AD.10.1.2.1 ~ AD.10.1.4.3)
##
HIPAA_Check=1

##
#Set this variable to a 0 if you are scanning servers that belong
#to an account using the Privileged Monitoring Service.
#(iSeC sections AD.20.1.2.1 ~ AD.20.1.2.4)
##
PMS_Check=1

###################################
#The below sections numbers are used to create the CSV output file
#for importing into a spreadsheet.
###################################
##
#This is for the Linux OS iSeC:
##
LINUX_OS_isec="AD.1.1.1.1 AD.1.1.1.2 AD.1.1.2 AD.1.1.3.1 AD.1.1.3.2 AD.1.1.4.1 AD.1.1.4.2 AD.1.1.4.3 AD.1.1.4.4 AD.1.1.5 AD.1.1.6 AD.1.1.7.1 AD.1.1.7.2 AD.1.1.7.3 AD.1.1.8.1 AD.1.1.8.2 AD.1.1.8.3 AD.1.1.9.0 AD.1.1.9.1 AD.1.1.10.0 AD.1.1.10.1 AD.1.1.10.2 AD.1.1.11.0 AD.1.1.11.1 AD.1.1.12.0 AD.1.1.12.1 AD.1.1.13.0 AD.1.1.13.1 AD.1.1.13.2 AD.1.1.13.3 AD.1.1.13.4 AD.1.2.1.1 AD.1.2.1.2 AD.1.2.1.3 AD.1.2.1.4 AD.1.2.1.5 AD.1.2.2 AD.1.2.3.1 AD.1.2.3.2 AD.1.2.4.1 AD.1.2.4.2 AD.1.2.5 AD.1.2.6 AD.1.3.0. AD.1.4.1 AD.1.4.2 AD.1.4.3 AD.1.4.4 AD.1.4.5 AD.1.5.1.1 AD.1.5.1.2 AD.1.5.1.3 AD.1.5.1.4 AD.1.5.1.5 AD.1.5.1.6 AD.1.5.1.7 AD.1.5.1.8 AD.1.5.2.1 AD.1.5.2.2 AD.1.5.3.1 AD.1.5.3.2 AD.1.5.4.1 AD.1.5.4.2 AD.1.5.5 AD.1.5.6 AD.1.5.7 AD.1.5.8.1 AD.1.5.8.2 AD.1.5.8.3 AD.1.5.8.4 AD.1.5.8.5 AD.1.5.8.6 AD.1.5.8.7 AD.1.5.8.8 AD.1.5.9.1 AD.1.5.9.2 AD.1.5.9.3 AD.1.5.9.4 AD.1.5.9.5 AD.1.5.9.6 AD.1.5.9.7 AD.1.5.9.8 AD.1.5.9.9 AD.1.5.9.10 AD.1.5.9.11 AD.1.5.9.12 AD.1.5.9.13 AD.1.5.9.14 AD.1.5.9.15 AD.1.5.9.16 AD.1.5.9.17 AD.1.5.9.18 AD.1.5.9.19 AD.1.5.9.20 AD.1.5.9.21 AD.1.5.9.22 AD.1.5.9.23 AD.1.5.9.24 AD.1.5.10.1 AD.1.5.10.2 AD.1.5.11 AD.1.5.12.0 AD.1.5.12.2 AD.1.5.12.3 AD.1.5.12.4 AD.1.7.0 AD.1.8.1 AD.1.8.2.1 AD.1.8.2.2 AD.1.8.3.1 AD.1.8.3.2 AD.1.8.3.3 AD.1.8.4.1 AD.1.8.4.2 AD.1.8.5.1 AD.1.8.5.2 AD.1.8.6.1 AD.1.8.6.2 AD.1.8.7.1 AD.1.8.7.2 AD.1.8.8 AD.1.8.9 AD.1.8.10 AD.1.8.11 AD.1.8.12.1.1 AD.1.8.12.1.2 AD.1.8.12.2 AD.1.8.12.3 AD.1.8.12.4 AD.1.8.12.5 AD.1.8.12.6 AD.1.8.12.7 AD.1.8.13.0 AD.1.8.13.1 AD.1.8.13.2 AD.1.8.13.3 AD.1.8.13.4 AD.1.8.14.1 AD.1.8.14.2 AD.1.8.14.3 AD.1.8.15.1 AD.1.8.15.2 AD.1.8.15.3 AD.1.8.17.1 AD.1.8.17.2 AD.1.8.17.3 AD.1.8.18.2 AD.1.8.18.3 AD.1.8.19.2 AD.1.8.19.3 AD.1.8.20.1 AD.1.8.20.2 AD.1.8.20.3 AD.1.8.21.1 AD.1.8.21.2 AD.1.8.21.3 AD.1.8.22.1 AD.1.8.22.2 AD.1.8.22.3 AD.1.8.22.4 AD.1.9.1.1 AD.1.9.1.2 AD.1.9.1.2.1 AD.1.9.1.3 AD.1.9.1.4 AD.1.9.1.5 AD.1.9.1.6 AD.1.9.1.7 AD.2.0.1 AD.2.1.1 AD.2.1.2 AD.2.1.3 AD.2.1.4 AD.3.0.0 AD.5.0.0 AD.5.0.1 AD.5.0.2 AD.10.1.2.1 AD.10.1.2.2 AD.10.1.4.0 AD.10.1.4.1 AD.10.1.4.6 AD.10.1.4.7 AD.10.1.4.8 AD.10.1.4.9 AD.10.1.4.10 AD.10.1.4.2 AD.10.1.4.3 AD.20.1.2.1 AD.20.1.2.2 AD.20.1.2.3.1 AD.20.1.2.3.2 AD.20.1.2.3.3 AD.20.1.2.3.4 AD.20.1.2.3.5 AD.20.1.2.3.6 AD.20.1.2.3.7 AD.20.1.2.3.8 AD.20.1.2.3.9 AD.20.1.2.3.10 AD.20.1.2.3.11 AD.20.1.2.3.12 AD.20.1.2.3.13 AD.20.1.2.3.14 AD.20.1.2.3.15 AD.20.1.2.3.16 AD.20.1.2.3.17 AD.20.1.2.3.18 AD.20.1.2.3.19 AD.20.1.2.3.20 AD.20.1.2.3.21 AD.20.1.2.3.22 AD.20.1.2.3.23 AD.20.1.2.4"

##
#This is for the SSH iSeC:
##
SSH_isec="AV.1.1.0 AV.1.1.1 AV.1.1.2 AV.1.1.3 AV.1.2.1.1 AV.1.2.1.2 AV.1.2.1.3 AV.1.2.2 AV.1.2.3.1 AV.1.2.3.2 AV.1.2.3.3 AV.1.2.3.4 AV.1.2.3.5 AV.1.2.3.6 AV.1.2.4.1 AV.1.2.4.2 AV.1.2.4.3 AV.1.2.4.4 AV.1.2.4 AV.1.3.0 AV.1.4.1 AV.1.4.2 AV.1.4.3 AV.1.4.4 AV.1.4.5 AV.1.4.6 AV.1.4.7 AV.1.4.8 AV.1.4.9 AV.1.4.10 AV.1.4.11 AV.1.4.12 AV.1.4.13 AV.1.4.14 AV.1.4.15 AV.1.4.16 AV.1.4.17 AV.1.4.18 AV.1.5.1 AV.1.5.2 AV.1.5.3 AV.1.5.4 AV.1.5.5 AV.1.5.6 AV.1.5.7 AV.1.7.1.1 AV.1.7.1.2 AV.1.7.2 AV.1.7.3.1 AV.1.7.3.2 AV.1.7.3.3 AV.1.7.4 AV.1.7.5 AV.1.7.6 AV.1.7.7 AV.1.7.8 AV.1.7.9 AV.1.7.10 AV.1.7.11 AV.1.8.0.1 AV.1.8.1.1 AV.1.8.1.2 AV.1.8.1.3 AV.1.8.1.4 AV.1.8.1.5 AV.1.8.2.0 AV.1.8.2.1 AV.1.8.2.2 AV.1.8.2.3 AV.1.8.2.4 AV.1.8.2.5 AV.1.8.2.6 AV.1.8.2.7 AV.1.8.2.8 AV.1.8.2.9 AV.1.8.2.10 AV.1.8.2.11 AV.1.8.2.12 AV.1.8.2.13 AV.1.8.2.14 AV.1.8.2.15 AV.1.8.2.16 AV.1.8.2.17 AV.1.8.2.18 AV.1.8.2.19 AV.1.8.2.20 AV.1.8.2.21 AV.1.8.2.22 AV.1.8.2.23 AV.1.8.2.24 AV.1.8.2.25 AV.1.8.2.26 AV.1.8.2.27 AV.1.8.2.28 AV.1.8.2.29 AV.1.8.2.30 AV.1.8.2.31 AV.1.8.2.32 AV.1.8.2.33 AV.1.8.2.34 AV.1.8.2.35 AV.1.8.2.36 AV.1.8.2.37 AV.1.8.2.38 AV.1.8.2.39 AV.1.8.2.40 AV.1.8.2.41 AV.1.8.2.42 AV.1.8.2.43 AV.1.8.2.44 AV.1.8.2.45 AV.1.8.2.46 AV.1.8.2.47 AV.1.8.2.49 AV.1.8.2.50 AV.1.8.3.1 AV.1.8.3.2 AV.1.8.3.3 AV.1.8.3.4 AV.1.8.3.5 AV.1.8.3.6 AV.1.8.3.7 AV.1.8.3.8 AV.1.8.3.9 AV.1.8.3.10 AV.1.8.4.1 AV.1.8.4.2 AV.1.8.4.3 AV.1.8.4.4 AV.1.8.4.5 AV.1.8.4.6 AV.1.8.4.7 AV.1.8.5.1 AV.1.8.5.2 AV.1.8.5.3 AV.1.8.5.4 AV.1.8.5.5 AV.1.8.5.6 AV.1.8.5.7 AV.1.8.5.8 AV.1.8.5.10 AV.1.8.5.11 AV.1.8.5.12 AV.1.8.5.13 AV.1.8.5.14 AV.1.9.1 AV.1.9.2 AV.1.9.3 AV.2.0.1.1 AV.2.0.1.2 AV.2.0.1.3 AV.2.0.1.4 AV.2.1.1.1 AV.2.1.1.2 AV.2.1.1.3 AV.2.1.1.4 AV.2.1.1.5 AV.2.1.1.6 AV.2.1.1.7 AV.2.1.2 AV.2.2.1.1 AV.2.2.1.2 AV.2.2.1.3 AV.2.2.1.4 AV.3.0.0 AV.5.0.0 AV.5.0.1 AV.5.0.2 AV.10.1.1.2 AV.10.1.2.2 AV.10.1.4.1 AV.10.1.4.2"

##
#This is for the SUDO iSeC:
##
SUDO_isec="ZY.1.1.0 ZY.1.2.1 ZY.1.2.2 ZY.1.2.3 ZY.1.2.4 ZY.1.3.0 ZY.1.4.1 ZY.1.4.2.0 ZY.1.4.2.1 ZY.1.4.2.2 ZY.1.4.3.1 ZY.1.4.3.2 ZY.1.4.3.3 ZY.1.4.4 ZY.1.4.5 ZY.1.4.6 ZY.1.5.0 ZY.1.7.0 ZY.1.8.1.0 ZY.1.8.1.1 ZY.1.8.1.2 ZY.1.8.1.3 ZY.1.8.1.4 ZY.1.8.1.5 ZY.1.8.2.0 ZY.1.8.2.1 ZY.1.8.2.2 ZY.1.8.2.3 ZY.1.9.0 ZY.2.0.0 ZY.2.1.1 ZY.2.1.2 ZY.3.0.0 ZY.5.0.0 ZY.5.0.1"

###################################
#Logging Function
###################################
Logit () {

#This is for logging the process of the script:
echo $@ >> $LOGFILE
return
} #Logit

###################################
#Pre-checks:
###################################
if [ `id -unr` = "root" ]; then
   echo ""
   if [ -f /etc/redhat-release ]; then 
      echo -e "\t\tYou are running: ${RED}REDHAT${BLUE}"
      echo -e "\tScript is running please wait...."
      echo -e "\tThis script does not do any system changes"
      OSFlavor=RedHat
   elif [ -f /etc/SuSE-release ]; then
      echo -e "\t\tYou are running: ${RED}SuSE${BLUE}"
      echo -e "\tScript is running please wait...."
      echo -e "\tThis script does not do any system changes"
      OSFlavor=SuSE
   else
      echo -e "\tLooks like you may not be running: RedHat or SuSE"
      echo -e "\tThis script is setup for Redhat Linux or SuSE Linux."
      echo -e "\tYou can #ed out exit from line 71 to continue"
      echo -e "\tNOTE: THIS SCRIPT HAS NOT BEEN TESTED ON ANY Linux OS BUT SuSE & REDHAT!!"
      echo -e "\tThis script does not do any system changes"
      echo ""
      exit
   fi
else
   echo -e "\tPlease execute this script as user (root) or sudo $0"
   echo -e "Exiting...."
   exit 1
   echo ""
fi


##
#Going to move the FTP check & test to the top since multiple
#sections check against it....
##
FTPEnabled=1
if [ -f /etc/inetd.conf ]; then
   grep "^ftp" /etc/inetd.conf > /dev/null 2>&1
   if ((!$?)); then
      FTPEnabled=0
      grep "^ftp" /etc/inetd.conf | grep -q "vsftpd"
      if ((!$?)); then
         FTPfile=/etc/vsftpd.ftpusers
      else
         FTPfile=/etc/ftpusers
      fi
   fi
elif [ -d /etc/xinetd.d ]; then
   ls /etc/xinetd.d | grep -q ftp
   if ((!$?)); then
      for file in `ls /etc/xinetd.d | grep ftp`
      do
      cat /etc/xinetd.d/$file | grep -v "^#" | grep -w disable | grep -q no
      if ((!$?)); then
         TestFile=`cat /etc/xinetd.d/$file | grep -v "^#" | grep -w server | awk '{print $3}'`
         if [[ -n $TestFile ]] && [[ -x $TestFile ]]; then
            FTPEnabled=0
            echo $TestFile | grep -q "vsftpd"
            if ((!$?)); then
               FTPfile=/etc/vsftpd.ftpusers
            else
               FTPfile=/etc/ftpusers
            fi
         fi
      fi
      done
   fi
fi
if ((!$FTPEnabled)); then
   echo $FTPfile | grep -q vsftpd
   if ((!$?)); then
      FTPType=VSFTP
   else
      FTPType=FTP
   fi
fi
##
#End FTP check & testing
##

#Ensure we have a clean output/log file to start with:
cat /dev/null > $LOGFILE

#Put in a secondary script to show the user that some progress
#is happening since this script can take more time to run
#than many users are comfortable with....
#It will only run for 10 minutes in case someone breaks out
#of the primary script for whatever reason.

#We won't use this progress stuff if being used by TADDM.
#It gets a tad messy as we use EOF below and can't have tabs
#which would have made it more user readable in the future.
if ((!$TADDMSIL)); then

#Ensure our secondary script is not already running:
ps -ef | grep isec_LINUX_progress.sh | grep -v grep > /dev/null 2>&1
if ((!$?)); then
   BadPID=`ps -ef | grep isec_LINUX_progress.sh | grep -v grep | awk '{print $2}'`
   kill -9 $BadPID
fi

#Put in a little blurb to be patient...
echo -e "\n\n\tRunning iSeC scan now."
echo -e "\tPlease be patient, depending on the system"
echo -e "\tthis may take some time....\n\n"

#Question file to pause the whirligig if the script
#needs to prompt for info.
echo 0 > /tmp/isec_question_prompt
cat /dev/null > /tmp/isec_LINUX_progress.sh
cat > /tmp/isec_LINUX_progress.sh <<EOF
#!/bin/bash
x=1
y=0
z=0
until [ \$x -eq 0 ]
do
if [ \$y -eq 4 ]; then
y=0
fi
if [ \$y -eq 0 ]; then
CHAR="|"
elif [ \$y -eq 1 ]; then
CHAR="/"
else [ \$y -eq 2 ]
CHAR="-"
fi
echo -e "\$CHAR\b\c"
sleep 2
grep "iSeC Scanning is completed" $LOGFILE > /dev/null 2>&1
if ((!\$?)); then
x=0
elif [ \`cat /tmp/isec_question_prompt\` -eq 1 ]; then
until [ \`cat /tmp/isec_question_prompt\` -eq 0 ]
do
sleep 5
done
fi
ps -ef | grep $0 | grep -v grep > /dev/null 2>&1
if ((\$?)); then
echo
echo
echo "The $0 script has been killed or stopped running unexpectedly"
echo "Any results from the time it did run would have been recorded"
echo "to: $LOGFILE"
echo
echo
exit 1
fi
if [ \$y -eq $isecTIMEOUT ]; then
ps -ef | grep $0 | grep -v grep > /dev/null 2>&1
if ((!\$?)); then
echo
echo
echo "WARNING - The iSeC script has been running for 10 minutes!"
echo "That is far longer than normal."
echo "If you believe the script is still running normally then do nothing."
echo "HOWEVER, if you feel something is wrong, please control C to"
echo "break out of the script and check for errors."
echo
echo
else
exit 0
fi
fi
((y+=1))
((z+=1))
done
EOF
chmod 744 /tmp/isec_LINUX_progress.sh
/tmp/isec_LINUX_progress.sh &

#End of if statement for TADDMSIL check
fi


if [ -f $LOGFILE ] ; then

$LOGIT "Server Name: `hostname`"
$LOGIT ""
if [ -f /etc/redhat-release ]; then 
   $LOGIT  "## You are Running REDHAT ##" 
   cat /etc/redhat-release >> $LOGFILE
       RHVER=`sed -rn 's/.*([0-9])\.[0-9].*/\1/p' /etc/redhat-release`
#   grep -q Enterprise /etc/redhat-release
#   if (($?)); then
#      RHVER=`awk '{print $5}' /etc/redhat-release | cut -c1`
#   else
#      RHVER=`awk '{print $3}' /etc/redhat-release | cut -c1`
#   fi
elif [ -f /etc/SuSE-release ]; then
   $LOGIT "## You are Running SuSE ##"
   cat /etc/SuSE-release >> $LOGFILE
   SVER=`cat /etc/SuSE-release | grep "VERSION" | awk '{print $3}'`
else
   $LOGIT "Looks like you may not be running REDHAT or SuSE!"
   $LOGIT "Script may have false errors or missed checks!"
   RHVER=X
   SVER=X
fi

$LOGIT ""
# kernel-release
$LOGIT "## Linux Kernel Version ##"
LINUX_ver=`uname -sr`
$LOGIT "$LINUX_ver"

$LOGIT ""
$LOGIT ""

#$LOGIT "1.1.x Password Requirements"
#$LOGIT "==========================="
PMD=`cat /etc/login.defs |grep "^PASS_MAX_DAYS" | awk '{print $2}'`
if [ $PMD -le 90 ] ; then
   $LOGIT "AD.1.1.1.1 : The default PASS_MAX_DAYS is OK"
else
   $LOGIT "AD.1.1.1.1 : WARNING - The default PASS_MAX_DAYS is set incorrrectly to: $PMD"
fi
cat /etc/login.defs |grep "^PASS_MAX_DAYS" >> $LOGFILE

$LOGIT ""
cat /dev/null > PMDTestOut
for TestUser in `cat /etc/shadow | grep -v "^#" | awk -F':' '{print $1}'`
do
TestUserPasswd=`grep "^$TestUser:" /etc/shadow | awk -F':' '{print $2}'`
echo $TestUserPasswd | grep -q "^!"
TestUserPasswdLocked=$?
TestUserGID=`grep "^$TestUser:" /etc/passwd | awk -F':' '{print $4}'`
TestUserPMD=`grep "^$TestUser:" /etc/shadow | awk -F':' '{print $5}'`
if [[ $OSFlavor = "RedHat" && $RHVER -le 5 ]] || [[ $OSFlavor = "SuSE" && $SVER -le 9 ]] || [[ $SVER = "X" && $RHVER = "X" ]]; then
   if [[ $TestUserPasswd != "*" && $TestUserPasswdLocked -eq 1 && $TestUserPasswd != "LK" ]] && [[ $TestUserGID -gt 99 ]]; then
      if [[ $TestUserPMD -gt 90 ]] || [[ -z $TestUserPMD ]] ; then
         echo "ID=$TestUser : PASS_MAX_DAYS=$TestUserPMD" >> PMDTestOut
      fi
   fi
else
   if [[ $TestUserPasswd != "*" && $TestUserPasswdLocked -eq 1 && $TestUserPasswd != "LK" ]] && [[ $TestUserGID -gt 199 ]]; then
      if [[ $TestUserPMD -gt 90 ]] || [[ -z $TestUserPMD ]] ; then
         echo "ID=$TestUser : PASS_MAX_DAYS=$TestUserPMD" >> PMDTestOut
      fi
   fi
fi
done
if [ -s PMDTestOut ]; then
   $LOGIT "AD.1.1.1.2 : WARNING - User(s) exist with PASS_MAX_DAYS field not set or greater than 90:"
   cat PMDTestOut >> $LOGFILE
else
   $LOGIT "AD.1.1.1.2 : All users have PASS_MAX_DAYS field set to 90 or less, or are locked."
   rm PMDTestOut
fi


$LOGIT ""
##Updated iSeC 3.0B REMOVES the option to use /etc/login.defs and can now only use
##files in the /etc/pam.d directory!
#Base tech spec says only 1 of 3 options needs to be satisfied (for RH only)iSeC v2.x:
#PML=`grep "^PASS_MIN_LEN" /etc/login.defs | awk '{print $2}'`
#if [[ -z $PML ]]; then
#   $LOGIT "AD.1.1.2 : The PASS_MIN_LEN is not configured in /etc/login.defs"
#   OPTION=1
#elif [[ $PML -lt 8 ]]; then
#   $LOGIT "AD.1.1.2 : The PASS_MIN_LEN in /etc/login.defs is: $PML"
#   OPTION=1
#else
#   $LOGIT "AD.1.1.2 : The PASS_MIN_LEN in /etc/login.defs is: $PML"
#   OPTION=0
#fi
#grep "^PASS_MIN_LEN" /etc/login.defs >> $LOGFILE
##Force it to do a pam.d check now:
OPTION=1
if (($OPTION)); then
   if [ -f /etc/pam.d/system-auth ]; then
      cat /etc/pam.d/system-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_cracklib.so" | grep "retry=3" | grep "minlen=8" | grep "dcredit=-1" | grep "ucredit=0" | grep "lcredit=-1" | grep "ocredit=0" | grep "type=reject_username" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.1.2 : The retry/minlen/dcredit/ucredit/lcredit/ocredit/type settings are NOT all configured in /etc/pam.d/system-auth"
         OPTION=1
         OPTION1=1
      else
         $LOGIT "AD.1.1.2 : The retry/minlen/dcredit/ucredit/lcredit/ocredit/type settings are all configured in /etc/pam.d/system-auth :"
         cat /etc/pam.d/system-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_cracklib.so" | grep "retry=3" | grep "minlen=8" | grep "dcredit=-1" | grep "ucredit=0" | grep "lcredit=-1" | grep "ocredit=0" | grep "type=reject_username" >> $LOGFILE
         OPTION=0
         OPTION1=0
      fi
      if (($OPTION)); then
         cat /etc/pam.d/system-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_passwdqc.so" | grep "min=disabled,8,8,8,8" | grep "passphrase=0" | grep "random=0" | grep "enforce=everyone" > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.1.2 : The min/passphrase/random/enforce settings are NOT all configured in /etc/pam.d/system-auth"
            OPTION=1
            OPTION2=1
         else
            $LOGIT "AD.1.1.2 : The min/passphrase/random/enforce settings are all configured in /etc/pam.d/system-auth :"
            cat /etc/pam.d/system-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_passwdqc.so" | grep "min=disabled,8,8,8,8" | grep "passphrase=0" | grep "random=0" | grep "enforce=everyone" >> $LOGFILE
            OPTION=0
            OPTION2=0
         fi
      fi
      if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
         if ((!$OPTION)); then
            if [ -f /etc/pam.d/password-auth ]; then
               if ((!$OPTION1)); then
                  cat /etc/pam.d/password-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_cracklib.so" | grep "retry=3" | grep "minlen=8" | grep "dcredit=-1" | grep "ucredit=0" | grep "lcredit=-1" | grep "ocredit=0" | grep "type=reject_username" > /dev/null 2>&1
                  if (($?)); then
                     $LOGIT "AD.1.1.2 : The retry/minlen/dcredit/ucredit/lcredit/ocredit/type settings are NOT also configured in /etc/pam.d/password-auth"
                     OPTION=1
                  else
                     $LOGIT "AD.1.1.2 : The retry/minlen/dcredit/ucredit/lcredit/ocredit/type settings are all also configured in /etc/pam.d/password-auth :"
                     cat /etc/pam.d/password-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_cracklib.so" | grep "retry=3" | grep "minlen=8" | grep "dcredit=-1" | grep "ucredit=0" | grep "lcredit=-1" | grep "ocredit=0" | grep "type=reject_username" >> $LOGFILE
                     OPTION=0
                  fi
               else
                  cat /etc/pam.d/password-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_passwdqc.so" | grep "min=disabled,8,8,8,8" | grep "passphrase=0" | grep "random=0" | grep "enforce=everyone" > /dev/null 2>&1
                  if (($?)); then
                     $LOGIT "AD.1.1.2 : The min/passphrase/random/enforce settings are NOT also configured in /etc/pam.d/password-auth"
                     OPTION=1
                  else
                     $LOGIT "AD.1.1.2 : The min/passphrase/random/enforce settings are also configured in /etc/pam.d/password-auth :"
                     cat /etc/pam.d/password-auth | grep -v "^#" | grep "^password" | grep "required" | grep "pam_passwdqc.so" | grep "min=disabled,8,8,8,8" | grep "passphrase=0" | grep "random=0" | grep "enforce=everyone" >> $LOGFILE
                     OPTION=0
                  fi
               fi
            else
               $LOGIT "AD1.1.2 : The /etc/pam.d/system-auth file does not exist!"
               OPTION=1
            fi
         fi
      else
         $LOGIT "AD.1.1.2 : Note that this is not a RHEL V6 or later OS."
      fi
   else
      $LOGIT "AD.1.1.2 : The /etc/pam.d/system-auth file does not exist."
   fi
   if (($OPTION)); then
      if [ $OSFlavor = "SuSE" ] && [ $SVER -ge 9 ]; then
         if [ -f /etc/security/pam_pwcheck.conf ]; then
            cat /etc/security/pam_pwcheck.conf | grep -v "^#" | grep "minlen" > /dev/null 2>&1
            if ((!$?)); then
               $LOGIT "AD.1.1.2 : The minlen setting was found in /etc/security/pam_pwcheck.conf:"
               cat /etc/security/pam_pwcheck.conf | grep -v "^#" | grep "minlen" >> $LOGFILE
               $LOGIT "PLEASE VERIFY IF THE SETTING IS CORRECT!"
            else
               $LOGIT "AD.1.1.2 : The minlen setting was NOT found in /etc/security/pam_pwcheck.conf!"
            fi
         fi
      fi
   fi
fi
if ((!$OPTION)); then
   $LOGIT "AD.1.1.2 : The PASS_MIN_LEN parameter is set correctly."
else
   $LOGIT "AD.1.1.2 : WARNING - The PASS_MIN_LEN parameter is not set correctly!"
fi

$LOGIT ""
MPA=`grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}'`
if [[ -z $MPA ]]; then
   $LOGIT "AD.1.1.3.1 : WARNING - The PASS_MIN_DAYS parameter does not exist in /etc/login.defs"
elif [ $MPA -ne 1 ]; then
   $LOGIT "AD.1.1.3.1 : WARNING - The PASS_MIN_DAYS parameter is NOT set incorrectly!"
   grep "^PASS_MIN_DAYS" /etc/login.defs >> $LOGFILE
else
   $LOGIT "AD.1.1.3.1 : The PASS_MIN_DAYS parameter is set correctly."
   grep "^PASS_MIN_DAYS" /etc/login.defs >> $LOGFILE
fi

$LOGIT ""
cat /dev/null > MPATestOut
for TestUser in `cat /etc/shadow | grep -v "^#" | awk -F':' '{print $1}'`
do
TestUserPasswd=`grep "^$TestUser:" /etc/shadow | awk -F':' '{print $2}'`
echo $TestUserPasswd | grep -q "^!"
TestUserPasswdLocked=$?
TestUserMPA=`grep "^$TestUser:" /etc/shadow | awk -F':' '{print $4}'`
if [[ $TestUserPasswd != "*" ]] && [[ $TestUserPasswdLocked -eq 1 ]] && [[ $TestUserPasswd != "LK" ]]; then
   if [[ -z $TestUserMPA ]] || [[ $TestUserMPA -ne 1 ]]; then
      echo "$TestUser : $TestUserMPA" >> MPATestOut
   fi
fi
done
if [ -s MPATestOut ]; then
   $LOGIT "AD.1.1.3.2 : WARNING - User(s) exist with PASS_MIN_DAYS field not set to 1:"
   cat MPATestOut >> $LOGFILE
else
   $LOGIT "AD.1.1.3.2 : All users with a password assigned have PASS_MIN_DAYS field set to 1."
fi
rm MPATestOut

if [ $OSFlavor = "RedHat" ]; then
   $LOGIT ""
   if [ -f /etc/pam.d/system-auth ]; then
      grep "^password" /etc/pam.d/system-auth | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.1.4.1 : WARNING - The password history settings are not configured in /etc/pam.d/system-auth"
         OPTION=1
      else
         $LOGIT "AD.1.1.4.1 : The password history settings are configured in /etc/pam.d/system-auth"
         grep "^password" /etc/pam.d/system-auth | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
         OPTION=0
      fi
      if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
         if ((!$OPTION)); then
            if [ -f /etc/pam.d/password-auth ]; then
               grep "^password" /etc/pam.d/password-auth | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
               if (($?)); then
                  $LOGIT "AD.1.1.4.1 : WARNING - The password history settings are not configured in /etc/pam.d/password-auth"
               else
                  $LOGIT "AD.1.1.4.1 : The password history settings are configured in /etc/pam.d/password-auth"
                  grep "^password" /etc/pam.d/password-auth | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
               fi
            else
               $LOGIT "AD.1.1.4.1 : WARNING - The /etc/pam.d/password-auth file does NOT exist!"
            fi
         fi
      else
         $LOGIT "AD.1.1.4.1 : Note that this is not a RHEL V6 or later OS."
      fi
   else
      $LOGIT "AD.1.1.4.1 : The /etc/pam.d/system-auth file does not exist. Checking other control files...."
      if [ -f /etc/pam.d/login ]; then
         grep "^password" /etc/pam.d/login | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.1.4.1 : WARNING - The password history settings are not configured in /etc/pam.d/login"
         else
            $LOGIT "AD.1.1.4.1 : The password history settings are configured in /etc/pam.d/login"
            grep "^password" /etc/pam.d/login | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.1.4.1 : WARNING - The /etc/pam.d/login file does not exist."
      fi
      if [ -f /etc/pam.d/passwd ]; then
         grep "^password" /etc/pam.d/passwd | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.1.4.1 : WARNING - The password history settings are not configured in /etc/pam.d/passwd"
         else
            $LOGIT "AD.1.1.4.1 : The password history settings are configured in /etc/pam.d/passwd"
            grep "^password" /etc/pam.d/passwd | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.1.4.1 : WARNING - The /etc/pam.d/passwd file does not exist."
      fi
      if [ -f /etc/pam.d/sshd ]; then
         grep "^password" /etc/pam.d/sshd | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.1.4.1 : WARNING - The password history settings are not configured in /etc/pam.d/sshd"
         else
            $LOGIT "AD.1.1.4.1 : The password history settings are configured in /etc/pam.d/sshd"
            grep "^password" /etc/pam.d/sshd | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.1.4.1 : WARNING - The /etc/pam.d/sshd file does not exist."
      fi
      if [ -f /etc/pam.d/su ]; then
         grep "^password" /etc/pam.d/su | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.1.4.1 : WARNING - The password history settings are not configured in /etc/pam.d/su"
         else
            $LOGIT "AD.1.1.4.1 : The password history settings are configured in /etc/pam.d/su"
            grep "^password" /etc/pam.d/su | egrep 'sufficient|required' | grep "pam_unix.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.1.4.1 : WARNING - The /etc/pam.d/su file does not exist."
      fi
   fi
else
   $LOGIT ""
   $LOGIT "AD.1.1.4.1 : N/A - This is a $OSFlavor server."
fi

if [ $OSFlavor = "SuSE" ]; then
   $LOGIT ""
   if [ -f /etc/pam.d/common-password ]; then
      grep "^password" /etc/pam.d/common-password | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
      if (($?)); then
         SUSEOption2=1
      else
         $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/common-password"
         grep "^password" /etc/pam.d/common-password | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
         SUSEOption2=0
      fi
      if (($SUSEOption2)); then
         grep "^password" /etc/pam.d/common-password | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' > /dev/null 2>&1
         if ((!$?)); then
            grep "^password" /etc/pam.d/common-password | egrep 'sufficient|required' | grep "pam_pwcheck.so" | grep "remember=8" > /dev/null 2>&1
            if ((!$?)); then
               $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/common-password"
               grep "^password" /etc/pam.d/common-password | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' >> $LOGFILE
            else
               $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/common-password"
            fi
         else
            $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/common-password"
         fi
      fi
   else
      $LOGIT "AD.1.1.4.2 : The /etc/pam.d/common-password file does not exist. Checking other control files...."
      if [ -f /etc/pam.d/login ]; then
         grep "^password" /etc/pam.d/login | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            SUSEOption2=1
         else
            $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/login"
            grep "^password" /etc/pam.d/login | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
            SUSEOption2=0
         fi
         if (($SUSEOption2)); then
            grep "^password" /etc/pam.d/login | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' > /dev/null 2>&1
            if ((!$?)); then
               grep "^password" /etc/pam.d/login | egrep 'sufficient|required' | grep "pam_pwcheck.so" | grep "remember=8" > /dev/null 2>&1
               if ((!$?)); then
                  $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/login"
                  grep "^password" /etc/pam.d/login | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' >> $LOGFILE
               else
                  $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/login"
               fi
            else
               $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/login"
            fi
         fi
      else
         $LOGIT "AD.1.1.4.2 : WARNING - The /etc/pam.d/login file does not exist."
      fi
      if [ -f /etc/pam.d/passwd ]; then
         grep "^password" /etc/pam.d/passwd | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            SUSEOption2=1
         else
            $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/passwd"
            grep "^password" /etc/pam.d/passwd | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
            SUSEOption2=0
         fi
         if (($SUSEOption2)); then
            grep "^password" /etc/pam.d/passwd | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' > /dev/null 2>&1
            if ((!$?)); then
               grep "^password" /etc/pam.d/passwd | egrep 'sufficient|required' | grep "pam_pwcheck.so" | grep "remember=8" > /dev/null 2>&1
               if ((!$?)); then
                  $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/passwd"
                  grep "^password" /etc/pam.d/passwd | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' >> $LOGFILE
               else
                  $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/passwd"
               fi
            else
               $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/passwd"
            fi
         fi
      else
         $LOGIT "AD.1.1.4.2 : WARNING - The /etc/pam.d/passwd file does not exist."
      fi
      if [ -f /etc/pam.d/sshd ]; then
         grep "^password" /etc/pam.d/sshd | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            SUSEOption2=1
         else
            $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/sshd"
            grep "^password" /etc/pam.d/sshd | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
            SUSEOption2=0
         fi
         if (($SUSEOption2)); then
            grep "^password" /etc/pam.d/sshd | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' > /dev/null 2>&1
            if ((!$?)); then
               grep "^password" /etc/pam.d/sshd | egrep 'sufficient|required' | grep "pam_pwcheck.so" | grep "remember=8" > /dev/null 2>&1
               if ((!$?)); then
                  $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/sshd"
                  grep "^password" /etc/pam.d/sshd | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512'  >> $LOGFILE
               else
                  $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/sshd"
               fi
            else
               $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/sshd"
            fi
         fi
      else
         $LOGIT "AD.1.1.4.2 : WARNING - The /etc/pam.d/sshd file does not exist."
      fi
      if [ -f /etc/pam.d/su ]; then
         grep "^password" /etc/pam.d/su | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" > /dev/null 2>&1
         if (($?)); then
            SUSEOption2=1
         else
            $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/su"
            grep "^password" /etc/pam.d/su | egrep 'sufficient|required' | grep "pam_unix_passwd.so" | grep "remember=7" | grep "use_authtok" | egrep 'md5|sha512' | grep "shadow" >> $LOGFILE
            SUSEOption2=0
         fi
         if (($SUSEOption2)); then
            grep "^password" /etc/pam.d/su | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' > /dev/null 2>&1
            if ((!$?)); then
               grep "^password" /etc/pam.d/su | egrep 'sufficient|required' | grep "pam_pwcheck.so" | grep "remember=8" > /dev/null 2>&1
               if ((!$?)); then
                  $LOGIT "AD.1.1.4.2 : The password history settings are configured in /etc/pam.d/su"
                  grep "^password" /etc/pam.d/su | egrep 'sufficient|required' | grep "pam_unix2.so" | egrep 'md5|sha512' >> $LOGFILE
               else
                  $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/su"
               fi
            else
               $LOGIT "AD.1.1.4.2 : WARNING - The password history settings are not configured in /etc/pam.d/su"
            fi
         fi
      else
         $LOGIT "AD.1.1.4.2 : WARNING - The /etc/pam.d/su file does not exist."
      fi
   fi
   if [ -f /etc/security/pam_pwcheck.conf ]; then
      cat /etc/security/pam_pwcheck.conf | grep -v "^#" |grep "remember=8" | egrep 'md5|sha512' > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.1.4.2 : WARNING - The md5/sha512 and/or remember=8 setting(s) do not exist in /etc/security/pam_pwcheck.conf file!"
      else
         $LOGIT "AD.1.1.4.2 : The md5/sha512 and remember=8 settings appear in /etc/security/pam_pwcheck.conf:"
         cat /etc/security/pam_pwcheck.conf | grep -v "^#" |grep "remember=8" | egrep 'md5|sha512' >> $LOGFILE
      fi
   else
      $LOGIT "AD.1.1.4.2 : WARNING - The /etc/security/pam_pwcheck.conf file does not exist!"
   fi
   if [ -f /etc/security/pam_unix2.conf ]; then
      cat /etc/security/pam_unix2.conf | grep -v "^#" | grep "shadow" | egrep 'md5|sha512' > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.1.4.2 : WARNING - The md5/sha512 and/or shadow setting(s) do not exist in /etc/security/pam_unix2.conf file!"
      else
         $LOGIT "AD.1.1.4.2 : THe md5/sha512 and shadow settings appear in /etc/security/pam_unix2.conf:"
         cat /etc/security/pam_unix2.conf | grep -v "^#" | grep "shadow" | egrep 'md5|sha512' >> $LOGFILE
      fi
   else
      $LOGIT "AD.1.1.4.2 : WARNING - The /etc/security/pam_unix2.conf files does not exist!"
   fi
else
   $LOGIT ""
   $LOGIT "AD.1.1.4.2 : N/A - This is a $OSFlavor server."
fi


$LOGIT ""
if [ $OSFlavor = "RedHat" ] || [ $OSFlavor = "SuSE" ]; then
   $LOGIT "AD.1.1.4.3 : N/A - This is a $OSFlavor server."
else
   $LOGIT "AD.1.1.4.3 : WARNING - THIS SCRIPT IS NOT CONFIGURED TO CHECK DEBIAN!"
fi

$LOGIT ""
$LOGIT "AD.1.1.5 : This is a process directive and cannot be health checked."

$LOGIT ""
if [ $OSFlavor = "RedHat" ] || [ $OSFlavor = "SuSE" ]; then
   if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 5 ]; then
      if [ -f /etc/pam.d/system-auth ]; then
         cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" > /dev/null 2>&1
         if ((!$?)); then
            FoundLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | awk -F':' '{print $1}'`
            cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
            if ((!$?)); then
               FirstSufficientLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
               if [ $FoundLine -lt $FirstSufficientLine ]; then
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so/pam_tally2.so deny=5' was found in /etc/pam.d/system-auth file and is in the correct position."
                  cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" >> $LOGFILE
                  $LOGIT ""
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so/pam_tally2.so deny=5' was found in /etc/pam.d/system-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
               fi
            else
               $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so/pam_tally2.so deny=5' was found in /etc/pam.d/system-auth file and is in the correct position."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so/pam_tally2.so deny=5' was not found in the /etc/pam.d/system-auth file."
         fi
         cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
         if ((!$?)); then
            FoundLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
            cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
            if ((!$?)); then
               FirstSufficientLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
               if [ $FoundLine -lt $FirstSufficientLine ]; then
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so/pam_tally2.so' was found in /etc/pam.d/system-auth file and is in the correct position."
                  cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' >> $LOGFILE
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so/pam_tally2.so' was found in /etc/pam.d/system-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
               fi
            else
               $LOGIT "AD.1.1.6 : The 'account required pam_tally.so/pam_tally2.so' was found in /etc/pam.d/system-auth file and is in the correct position."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so/pam_tally2.so' was not found in the /etc/pam.d/system-auth file."
         fi
         if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
            if [ -f /etc/pam.d/password-auth ]; then
               cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" > /dev/null 2>&1
               if ((!$?)); then
                  FoundLine=`cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | awk -F':' '{print $1}'`
                  cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
                  if ((!$?)); then
                     FirstSufficientLine=`cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                     if [ $FoundLine -lt $FirstSufficientLine ]; then
                        $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so/pam_tally2.so deny=5' was found in /etc/pam.d/password-auth file and is in the correct position."
                        cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" >> $LOGFILE
                        $LOGIT ""
                     else
                        $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so/pam_tally2.so deny=5' was found in /etc/pam.d/password-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                     fi
                  else
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so/pam_tally2.so deny=5' was found in /etc/pam.d/password-auth file and is in the correct position."
                  fi
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so/pam_tally2.so deny=5' was not found in the /etc/pam.d/password-auth file."
               fi
               cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
               if ((!$?)); then
                  FoundLine=`cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
                  cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
                  if ((!$?)); then
                     FirstSufficientLine=`cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                     if [ $FoundLine -lt $FirstSufficientLine ]; then
                        $LOGIT "AD.1.1.6 : The 'account required pam_tally.so/pam_tally2.so' was found in /etc/pam.d/password-auth file and is in the correct position."
                        cat /etc/pam.d/password-auth | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' >> $LOGFILE
                     else
                        $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so/pam_tally2.so' was found in /etc/pam.d/password-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                     fi
                  else
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so/pam_tally2.so' was found in /etc/pam.d/password-auth file and is in the correct position."
                  fi
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so/pam_tally2.so' was not found in the /etc/pam.d/password-auth file."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/password-auth file does NOT exist!"
            fi
         else
            $LOGIT "AD.1.1.6 : Note that this is not a RHEL V6 or later OS."
         fi
      else
         $LOGIT "AD.1.1.6 : The /etc/pam.d/system-auth file does not exist. Checking other control files...."
         if [ -f /etc/pam.d/login ]; then
            cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | awk -F':' '{print $1}'`
               cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/login file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was found in /etc/pam.d/login file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/login file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was not found in the /etc/pam.d/login file."
            fi
            cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/login file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/login file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/login file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/login file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/login file does not exist."
         fi
         if [ -f /etc/pam.d/passwd ]; then
            cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | awk -F':' '{print $1}'`
               cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/passwd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was found in /etc/pam.d/passwd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/passwd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was not found in the /etc/pam.d/passwd file."
            fi
            cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/passwd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/passwd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/passwd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/passwd file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/passwd file does not exist."
         fi
         if [ -f /etc/pam.d/sshd ]; then
            cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | awk -F':' '{print $1}'`
               cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/sshd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was found in /etc/pam.d/sshd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/sshd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was not found in the /etc/pam.d/sshd file."
            fi
            cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/sshd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/sshd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/sshd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/sshd file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/sshd file does not exist."
         fi
         if [ -f /etc/pam.d/su ]; then
            cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | awk -F':' '{print $1}'`
               cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/su file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was found in /etc/pam.d/su file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5' was found in /etc/pam.d/su file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5' was not found in the /etc/pam.d/su file."
            fi
            cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/su file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/su file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/su file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/su file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/su file does not exist."
         fi
      fi
   #
   ##Do different checks for RH 4 and lower and SLE9:
   elif [[ $OSFlavor = "RedHat" && $RHVER -le 4 ]] || [[ $OSFlavor = "SuSE" && $SVER = "9" ]]; then
      if [ -f /etc/pam.d/system-auth ]; then
         cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" > /dev/null 2>&1
         if ((!$?)); then
            FoundLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" | awk -F':' '{print $1}'`
            cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
            if ((!$?)); then
               FirstSufficientLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
               if [ $FoundLine -lt $FirstSufficientLine ]; then
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/system-auth file and is in the correct position."
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/system-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
               fi
            else
               $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/system-auth file and is in the correct position."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was not found in the /etc/pam.d/system-auth file."
         fi
         cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" > /dev/null 2>&1
         if ((!$?)); then
            FoundLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" | awk -F':' '{print $1}'`
            cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
            if ((!$?)); then
               FirstSufficientLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
               if [ $FoundLine -lt $FirstSufficientLine ]; then
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/system-auth file and is in the correct position."
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/system-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
               fi
            else
               $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/system-auth file and is in the correct position."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was not found in the /etc/pam.d/system-auth file."
         fi
      else
         $LOGIT "AD.1.1.6 : The /etc/pam.d/system-auth file does not exist. Checking other control files...."
         if [ -f /etc/pam.d/login ]; then
            cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/login file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/login file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/login file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was not found in the /etc/pam.d/login file."
            fi
            cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/login file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/login file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/login file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was not found in the /etc/pam.d/login file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/login file does not exist."
         fi
         if [ -f /etc/pam.d/passwd ]; then
            cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/passwd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/passwd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/passwd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was not found in the /etc/pam.d/passwd file."
            fi
            cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/passwd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/passwd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/passwd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was not found in the /etc/pam.d/passwd file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/passwd file does not exist."
         fi
         if [ -f /etc/pam.d/sshd ]; then
            cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/sshd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/sshd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/sshd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was not found in the /etc/pam.d/sshd file."
            fi
            cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/sshd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/sshd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/sshd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was not found in the /etc/pam.d/sshd file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/sshd file does not exist."
         fi
         if [ -f /etc/pam.d/su ]; then
            cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/su file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/su file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so no_magic_root' was found in /etc/pam.d/su file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so no_magic_root' was not found in the /etc/pam.d/su file."
            fi
            cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "reset" | grep "no_magic_root" | awk -F':' '{print $1}'`
               cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/su file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/su file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so deny=5 reset no_magic_root' was found in /etc/pam.d/su file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so deny=5 reset no_magic_root' was not found in the /etc/pam.d/su file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/su file does not exist."
         fi
      fi
   
   
   
   
   
   #
   ##Do different checks for SLE10:
   elif [[ $OSFlavor = "SuSE" && $SVER = "10" ]]; then
      if [ -f /etc/pam.d/system-auth ]; then
         cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" > /dev/null 2>&1
         if ((!$?)); then
            FoundLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" | awk -F':' '{print $1}'`
            cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
            if ((!$?)); then
               FirstSufficientLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
               if [ $FoundLine -lt $FirstSufficientLine ]; then
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/system-auth file and is in the correct position."
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/system-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
               fi
            else
               $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/system-auth file and is in the correct position."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was not found in the /etc/pam.d/system-auth file."
         fi
         cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
         if ((!$?)); then
            FoundLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
            cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
            if ((!$?)); then
               FirstSufficientLine=`cat /etc/pam.d/system-auth | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
               if [ $FoundLine -lt $FirstSufficientLine ]; then
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/system-auth file and is in the correct position."
               else
                  $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/system-auth file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
               fi
            else
               $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/system-auth file and is in the correct position."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/system-auth file."
         fi
      else
         $LOGIT "AD.1.1.6 : The /etc/pam.d/system-auth file does not exist. Checking other control files...."
         if [ -f /etc/pam.d/login ]; then
            cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" | awk -F':' '{print $1}'`
               cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/login file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/login file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/login file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was not found in the /etc/pam.d/login file."
            fi
            cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^account " | grep -n "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/login | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/login | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/login file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/login file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/login file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/login file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/login file does not exist."
         fi
         if [ -f /etc/pam.d/passwd ]; then
            cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" | awk -F':' '{print $1}'`
               cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/passwd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/passwd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/passwd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was not found in the /etc/pam.d/passwd file."
            fi
            cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/passwd | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/passwd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/passwd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/passwd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/passwd file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/passwd file does not exist."
         fi
         if [ -f /etc/pam.d/sshd ]; then
            cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" | awk -F':' '{print $1}'`
               cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/sshd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/sshd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/sshd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was not found in the /etc/pam.d/sshd file."
            fi
            cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/sshd | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/sshd file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/sshd file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/sshd file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/sshd file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/sshd file does not exist."
         fi
         if [ -f /etc/pam.d/su ]; then
            cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^auth " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | grep "deny=5" | grep "onerr=fail" | grep "per_user" | grep "no_lock_time" | awk -F':' '{print $1}'`
               cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^auth " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/su file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/su file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was found in /etc/pam.d/su file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'auth required pam_tally.so deny=5 onerr=fail per_user no_lock_time' was not found in the /etc/pam.d/su file."
            fi
            cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^account " | grep "required" | egrep 'pam_tally.so|pam_tally2.so' | awk -F':' '{print $1}'`
               cat /etc/pam.d/su | grep -v "pam_deny.so" | grep "^account " | grep "sufficient" > /dev/null 2>&1
               if ((!$?)); then
                  FirstSufficientLine=`cat /etc/pam.d/su | grep -v "pam_deny.so" | grep -n "^account " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
                  if [ $FoundLine -lt $FirstSufficientLine ]; then
                     $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/su file and is in the correct position."
                  else
                     $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was found in /etc/pam.d/su file BUT is in the wrong position within the file and does not precede any lines of the same module type with a control flag of sufficient with the exception of pam_deny.so"
                  fi
               else
                  $LOGIT "AD.1.1.6 : The 'account required pam_tally.so' was found in /etc/pam.d/su file and is in the correct position."
               fi
            else
               $LOGIT "AD.1.1.6 : WARNING - 'account required pam_tally.so' was not found in the /etc/pam.d/su file."
            fi
         else
            $LOGIT "AD.1.1.6 : WARNING - The /etc/pam.d/su file does not exist."
         fi
      fi
   fi
else
   $LOGIT "AD.1.1.6 : WARNING - THIS IS NOT A RedHat OR SUSE SERVER. THIS SCRIPT IS NOT CONFIGURED TO CHECK THIS SECTION!!!"
fi

$LOGIT ""
RootPass=`grep "^root:" /etc/shadow | awk -F':' '{print $2}'`
RootPassMax=`grep "^root:" /etc/shadow | awk -F':' '{print $5}'`
RootPassMin=`grep "^root:" /etc/shadow | awk -F':' '{print $4}'`
echo $RootPass | grep "^!" > /dev/null 2>&1
RootPassLocked=$?
if [[ ! -z $RootPass ]] && [[ $RootPassLocked -ne 0 && $RootPass != "LK" && $RootPass != "*" ]] && [[ $RootPassMax -le 90 ]] && [[ $RootPassMin -eq 1 ]]; then
   $LOGIT "AD.1.1.7.1 : User root has password assigned with Min/Max Password Age set correctly."
else
   $LOGIT "AD.1.1.7.1 : WARNING - User root does not have password set and/or Min/Max Password Age is incorrect"
fi
$LOGIT "AD.1.1.7.1 : ID=root : Password=$RootPass : Max Age=$RootPassMax : Min Age=$RootPassMin"

$LOGIT ""
if [ -f /etc/securetty ]; then
   TTYAccess=`cat /etc/securetty | grep -vc "^#"`
   if [ $TTYAccess -gt 2 ]; then
      $LOGIT "AD.1.1.7.2 : WARNING - Root login access does not appear to be restricted in /etc/securetty"
      $LOGIT "AD.1.1.7.2 : Here is the contents of the /etc/securetty file:"
      cat /etc/securetty >> $LOGFILE
      $LOGIT ""
   else
      $LOGIT "AD.1.1.7.2 : Root login access is restricted in the /etc/securetty file."
   fi
else
   $LOGIT "AD.1.1.7.2 : WARNING - The /etc/securetty file does not exist!"
fi
if [ -f /etc/ssh/sshd_config ]; then
   grep "^PermitRootLogin" /etc/ssh/sshd_config | grep -q "no"
   if (($?)); then
      $LOGIT "AD.1.1.7.2 : WARNING - Root logins are not disabled in sshd_config"
      grep "^PermitRootLogin" /etc/ssh/sshd_config >> $LOGFILE
   else
      $LOGIT "AD.1.1.7.2 : Root logins are disabled in sshd_config"
      grep "^PermitRootLogin" /etc/ssh/sshd_config | grep "no" >> $LOGFILE
   fi
else
   $LOGIT "AD.1.1.7.2 : WARNING - The sshd_config file could not be found!"
   $LOGIT "AD.1.1.7.2 : Please review the detailed SSH check portion of the log file below"
   $LOGIT "AD.1.1.7.2 : and check the status of the PermitRootLogin section for status."
fi

$LOGIT ""
cat /dev/null > AD1173_temp
for SysID in bin daemon adm lp sync shutdown halt mail uucp operator games gopher ftp nobody dbus usbmuxd rpc avahi-autoipd vcsa rtkit saslauth postfix avahi ntp apache radvd rpcuser nfsnobody qemu haldaemon nm-openconnect pulse gsanslcd gdm sshd tcpdump
do
grep -q "^$SysID:" /etc/shadow
if ((!$?)); then
   TestPasswd=`grep "^$SysID:" /etc/shadow | awk -F':' '{print $2}'`
   if [ -n $Testpasswd ]; then
      echo $TestPasswd | grep -q "^!"
      TestPasswdLocked=$?
      if [[ $TestPasswd != "*" && $TestPasswdLocked -eq 1 && $Testpasswd != "LK" ]]; then
         echo $SysID >> AD1173_temp
      fi
   else
      echo "Empty shadow paramter: $SysID" >> AD1173_temp
   fi
fi
done
if [ -s AD1173_temp ]; then
   $LOGIT "AD.1.1.7.3 : WARNING - Some system ID(s) exist that appear to have a password assigned to them:"
   cat AD1173_temp >> $LOGFILE
else
   $LOGIT "AD.1.1.7.3 : All existing system IDs appear to have no password assigned to them or are locked."
fi
rm -rf AD1173_temp

$LOGIT ""
sudo -h > /dev/null 2>&1
if (($?)); then
   if [ ! -x /usr/bin/sudo ]; then
      if [ ! -x /usr/local/bin/sudo ]; then
         SudoFound=1
      else
         SudoFound=0
      fi
   else
      SudoFound=0
   fi
else
   SudoFound=0
fi
if ((!$SudoFound)); then
   $LOGIT "AD.1.1.8.1 : Sudo is installed."
else
   $LOGIT "AD.1.1.8.1 : WARNING - Sudo does not appear to be installed."
fi

$LOGIT ""
PID=$$
sort -t : -k 3n /etc/passwd|grep -v \^# > passwd.$PID
if [[ -z `cat passwd.$PID | awk -F: '{print $3}' | uniq -d` ]]; then 
   $LOGIT "AD.1.1.8.2 : No duplicate UID found"
else
   cat passwd.$PID | awk -F: '{print $3}' | uniq -d | while read SAME_IDS >> $LOGFILE
   do
   $LOGIT "AD.1.1.8.2 : WARNING - UID '$SAME_IDS' is associated with multiple user accounts."
   done
fi
if [ -f passwd.$PID ]; then rm passwd.$PID;fi

$LOGIT ""
PID=$$
sort -t : -k 3n /etc/group|grep -v \^# > group.$PID
if [[ -z `cat group.$PID | awk -F: '{print $3}' | uniq -d` ]]; then 
   $LOGIT "AD.1.1.8.3 : No duplicate GID found"
else
   cat group.$PID | awk -F: '{print $3}' | uniq -d | while read SAME_GIDS >> $LOGFILE
   do
   $LOGIT "AD.1.1.8.3 : WARNING - GID '$SAME_GIDS' is associated with multiple user accounts."
   done
fi
if [ -f group.$PID ]; then rm group.$PID;fi

$LOGIT ""
cat /dev/null > AD.1.1.9.0_temp
if [[ $OSFlavor = "RedHat" && $RHVER -ge 6 ]] || [[ $OSFlavor = "SuSE" && $SVER -ge 10 ]]; then
   for USER in `cat /etc/passwd | grep -v "/sbin/nologin" | grep -v "/bin/false" | awk -F':' '{print $1}'`
   do
   USERGID=`grep "^$USER:" /etc/passwd | awk -F':' '{print $4}'`
   if [[ -z $USERGID ]] || [[ $USERGID -le 199 ]]; then
      USERPasswd=`grep "^$USER:" /etc/shadow | awk -F':' '{print $2}'`
      echo $USERPasswd | grep "^!" > /dev/null 2>&1
      USERPasswdLocked=$?
      USERPasswdMax=`grep "^$USER:" /etc/shadow | awk -F':' '{print $5}'`
      if [[ ! -z $USERPasswd && $USERPasswdLocked -eq 1 && $USERPasswd != "LK" && $USERPasswd != "*" ]] && [[ -z $USERPasswdMax || $USERPasswdMax -gt 90 ]]; then
         echo "User=$USER : GID=$USERGID : MaxPassword=$USERPasswdMax" >> AD.1.1.9.0_temp
      fi
   fi
   done
   if [ -s AD.1.1.9.0_temp ]; then
      $LOGIT "AD.1.1.9.0 : WARNING - Login abled user(s) exist with GID <= 199 that have a non-expiring password set:"
      cat AD.1.1.9.0_temp >> $LOGFILE
   else
      $LOGIT "AD.1.1.9.0 : All login abled user(s) with GID <= 199 have a password set to expire."
   fi
else
   for USER in `cat /etc/passwd | grep -v "/sbin/nologin" | grep -v "/bin/false" | awk -F':' '{print $1}'`
   do
   USERGID=`grep "^$USER:" /etc/passwd | awk -F':' '{print $4}'`
   if [[ -z $USERGID ]] || [[ $USERGID -le 99 ]]; then
      USERPasswd=`grep "^$USER:" /etc/shadow | awk -F':' '{print $2}'`
      echo $USERPasswd | grep "^!" > /dev/null 2>&1
      USERPasswdLocked=$?
      USERPasswdMax=`grep "^$USER:" /etc/shadow | awk -F':' '{print $5}'`
      if [[ ! -z $USERPasswd && $USERPasswdLocked -eq 1 && $USERPasswd != "LK" && $USERPasswd != "*" ]] && [[ -z $USERPasswdMax || $USERPasswdMax -gt 90 ]]; then
         echo "User=$USER : GID=$USERGID : MaxPassword=$USERPasswdMax" >> AD.1.1.9.0_temp
      fi
   fi
   done
   if [ -s AD.1.1.9.0_temp ]; then
      $LOGIT "AD.1.1.9.0 : WARNING - Login abled user(s) exist with GID <= 99 that have a non-expiring password set:"
      cat AD.1.1.9.0_temp >> $LOGFILE
   else
      $LOGIT "AD.1.1.9.0 : All login abled user(s) with GID <= 99 have a password set to expire."
   fi
fi
rm -rf AD.1.1.9.0_temp

$LOGIT ""
$LOGIT "AD.1.1.9.1 : Please refer to section 1.1.10.1 below as it is the same thing."

#Process the Exemptions to password rules...
$LOGIT ""
cat /dev/null > PasswdExemptTemp
if [ -s PMDTestOut ]; then
   for USER in `cat PMDTestOut | awk -F'=' '{print $2}' | awk '{print $1}'`
   do
   grep "^$USER:" /etc/passwd | grep -v "bin/false" | grep -v "/sbin/nologin" > /dev/null 2>&1
   if ((!$?)); then
      echo $USER >> PasswdExemptTemp
   fi
   done
   if [ -s PasswdExemptTemp ]; then
      $LOGIT "AD.1.1.10.1 : WARNING - User(s) exist with non-expiring password that is not set to /bin/false or /sbin/nologin in /etc/passwd:"
      cat PasswdExemptTemp >> $LOGFILE
   else
      $LOGIT "AD.1.1.10.1 : All user(s) with non-expiring passwords are set to /bin/false or /sbin/nologin in /etc/passwd"
   fi
   cat /dev/null > PasswdExemptTemp
   $LOGIT ""

   if ((!$FTPEnabled)); then
      $LOGIT "AD.1.1.10.2 : This server has $FTPType installed and enabled."
      if [ -f $FTPfile ]; then
         for USER in `cat PMDTestOut | awk -F'=' '{print $2}' | awk '{print $1}'`
         do
         grep -q "^$USER" $FTPfile
         if (($?)); then
            echo $USER > PasswdExemptTemp
         fi
         done
         if [ -s PasswdExemptTemp ]; then
            $LOGIT "AD.1.1.10.2 : WARNING - Users with non-expiring passwords exist that are NOT configured in $FTPfile"
            cat PasswdExemptTemp >> $LOGFILE
         else
            $LOGIT "AD.1.1.10.2 : All users with non-expiring passwords are configured in $FTPfile"
         fi
      else
         $LOGIT "AD.1.1.10.2 : WARNING - The $FTPfile does NOT exist!"
      fi
   else
      $LOGIT "AD.1.1.10.2 : N/A - No ftp server is installed and enabled."
   fi
   cat /dev/null > PasswdExemptTemp
   $LOGIT ""
   for USER in `cat PMDTestOut | awk -F'=' '{print $2}' | awk '{print $1}'`
   do
   USERpassword=`grep "^$USER:" /etc/shadow | awk -F':' '{print $2}'`
   echo $USERpassword | grep -q "^!"
   if (($?)); then
      echo $USER >> PasswdExemptTemp
   fi
   done
   if [ -s PasswdExemptTemp ]; then
      $LOGIT "AD.1.1.11.1 : WARNING - Users with non-expiring passwords exist without '!!' or '!' in field 2 of the /etc/shadow file:"
      cat PasswdExemptTemp >> $LOGFILE
   else
      $LOGIT "AD.1.1.11.1 : All users with non-expiring passwords are locked and have '!!' or '!' in field 2 of the /etc/shadow file."
   fi
   cat /dev/null > PasswdExemptTemp
   $LOGIT ""
   for USER in `cat PMDTestOut | awk -F'=' '{print $2}' | awk '{print $1}'`
   do
   USERpassword=`grep "^$USER:" /etc/shadow | awk -F':' '{print $2}'`
   echo $USERpassword | grep -q "^!"
   USERpasswordLK=$?
   if [[ $USERpassword != "x" ]] && [[ $USERpasswordLK -eq 1 ]] && [[ $USERpassword != "*" ]]; then
      echo $USER >> PasswdExemptTemp
   fi
   done
   if [ -s PasswdExemptTemp ]; then
      $LOGIT "AD.1.1.12.1 : WARNING - Users with non-expiring passwords exist without '!', '!!', 'x', or '*' in field 2 of the /etc/shadow file:"
      cat PasswdExemptTemp >> $LOGFILE
   else
      $LOGIT "AD.1.1.12.1 : All users with non-expiring passwords are locked and/or have no password set."
   fi
   cat /dev/null > PasswdExemptTemp
   $LOGIT ""
   if [ -f /etc/pam.d/system-auth ]; then
      grep "^auth" /etc/pam.d/system-auth | grep "required" | grep "pam_listfile.so" | grep "item=user" | grep "sense=deny" | grep "file=/etc/security" | grep "onerr=succeed" > /dev/null 2>&1
      if ((!$?)); then
         FoundLine=`grep -n "^auth" /etc/pam.d/system-auth | grep "required" | grep "pam_listfile.so" | grep "item=user" | grep "sense=deny" | grep "file=/etc/security" | grep "onerr=succeed" | awk -F':' '{print $1}'`
         SecurityFile=`grep "^auth" /etc/pam.d/system-auth | grep "required" | grep "pam_listfile.so" | grep "item=user" | grep "sense=deny" | grep "file=/etc/security" | grep "onerr=succeed" | xargs -n 1 | sort -u|xargs | awk '{print $2}' | awk -F'=' '{print $2}'`
         FirstSufficientLine=`cat /etc/pam.d/system-auth | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
         if [ $FoundLine -lt $FirstSufficientLine ]; then
            $LOGIT "AD.1.1.13.1 : The necessary auth entry has been found in /etc/pam.d/system-auth and is in the correct position:"
            grep "^auth" /etc/pam.d/system-auth >> $LOGFILE
            $LOGIT ""
         else
            $LOGIT "AD.1.1.13.1 : WARNING - The necessary auth entry is in the /etc/pam.d/system-auth file BUT is in the incorrect position!"
            grep "^auth" /etc/pam.d/system-auth >> $LOGFILE
            $LOGIT ""
         fi
         if [ -f $SecurityFile ]; then
            FilePerms=`ls -ald $SecurityFile | awk '{print $1}' | cut -c6-10`
            if [ $FilePerms != "-----" ]; then
               $LOGIT "AD.1.1.13.1 : WARNING - The permissions on the \$FILENAME file are not 0640!"
            else
               $LOGIT "AD.1.1.13.1 : The permissions on the \$FILENAME are correct."
            fi
            ls -ald $SecurityFile >> $LOGFILE
            $LOGIT ""
            for USER in `cat PMDTestOut | awk -F'=' '{print $2}' | awk '{print $1}'`
            do
            grep -q ^$USER $SecurityFile
            if (($?)); then
               echo $USER >> PasswdExemptTemp
            fi
            done
            if [ -s PasswdExemptTemp ]; then
               $LOGIT "AD.1.1.13.2 : WARNING - User(s) with non-expiring passwords exist that are not in $SecurityFile:"
               cat PasswdExemptTemp >> $LOGFILE
            else
               $LOGIT "AD.1.1.13.2 : All user(s) with non-expiring passwords are listed in the $SecurityFile."
            fi
         else
            $LOGIT "AD.1.1.13.1 : WARNING - The /etc/security/\$FILENAME file does not exist as set in the system-auth file"
            $LOGIT ""
            $LOGIT "AD.1.1.13.2 : WARNING - The /etc/security/\$FILENAME file does not exist as set in the system-auth file"
         fi
      else
         $LOGIT "AD.1.1.13.1 : WARNING - The necessary auth entry in /etc/pam.d/system-auth file does NOT exist"
         $LOGIT ""
         $LOGIT "AD.1.1.13.2 : WARNING - The necessary auth entry in /etc/pam.d/system-auth file does NOT exist"
      fi
      if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
         if [ -f /etc/pam.d/password-auth ]; then
            grep "^auth" /etc/pam.d/password-auth | grep "required" | grep "pam_listfile.so" | grep "item=user" | grep "sense=deny" | grep "file=/etc/security" | grep "onerr=succeed" > /dev/null 2>&1
            if ((!$?)); then
               FoundLine=`grep -n "^auth" /etc/pam.d/password-auth | grep "required" | grep "pam_listfile.so" | grep "item=user" | grep "sense=deny" | grep "file=/etc/security" | grep "onerr=succeed" | awk -F':' '{print $1}'`
               SecurityFile=`grep "^auth" /etc/pam.d/password-auth | grep "required" | grep "pam_listfile.so" | grep "item=user" | grep "sense=deny" | grep "file=/etc/security" | grep "onerr=succeed" | xargs -n 1 | sort -u|xargs | awk '{print $2}' | awk -F'=' '{print $2}'`
               FirstSufficientLine=`cat /etc/pam.d/password-auth | grep -n "^auth " | grep "sufficient" | head -1 | awk -F':' '{print $1}'`
               if [ $FoundLine -lt $FirstSufficientLine ]; then
                  $LOGIT "AD.1.1.13.1 : The necessary auth entry has been found in /etc/pam.d/password-auth and is in the correct position:"
                  grep "^auth" /etc/pam.d/password-auth >> $LOGFILE
                  $LOGIT ""
               else
                  $LOGIT "AD.1.1.13.1 : WARNING - The necessary auth entry is in the /etc/pam.d/password-auth file BUT is in the incorrect position!"
                  grep "^auth" /etc/pam.d/password-auth >> $LOGFILE
                  $LOGIT ""
               fi
               if [ -f $SecurityFile ]; then
                  FilePerms=`ls -ald $SecurityFile | awk '{print $1}' | cut -c6-10`
                  if [ $FilePerms != "-----" ]; then
                     $LOGIT "AD.1.1.13.1 : WARNING - The permissions on the \$FILENAME file are not 0640!"
                  else
                     $LOGIT "AD.1.1.13.1 : The permissions on the \$FILENAME are correct."
                  fi
                  ls -ald $SecurityFile >> $LOGFILE
                  $LOGIT ""
                  for USER in `cat PMDTestOut | awk -F'=' '{print $2}' | awk '{print $1}'`
                  do
                  grep -q ^$USER $SecurityFile
                  if (($?)); then
                     echo $USER >> PasswdExemptTemp
                  fi
                  done
                  if [ -s PasswdExemptTemp ]; then
                     $LOGIT "AD.1.1.13.2 : WARNING - User(s) with non-expiring passwords exist that are not in $SecurityFile:"
                     cat PasswdExemptTemp >> $LOGFILE
                  else
                     $LOGIT "AD.1.1.13.2 : All user(s) with non-expiring passwords are listed in the $SecurityFile."
                  fi
               else
                  $LOGIT "AD.1.1.13.1 : WARNING - The /etc/security/\$FILENAME file does not exist as set in the password-auth file"
                  $LOGIT ""
                  $LOGIT "AD.1.1.13.2 : WARNING - The /etc/security/\$FILENAME file does not exist as set in the password-auth file"
               fi
            else
               $LOGIT "AD.1.1.13.1 : WARNING - The necessary auth entry in /etc/pam.d/password-auth file does NOT exist"
               $LOGIT ""
               $LOGIT "AD.1.1.13.2 : WARNING - The necessary auth entry in /etc/pam.d/password-auth file does NOT exist"
            fi
         else
            $LOGIT "AD.1.1.13.1 : WARNING - The /etc/pam.d/password-auth file does NOT exist!"
            $LOGIT ""
            $LOGIT "AD.1.1.13.2 : WARNING - The /etc/pam.d/password-auth file does NOT exist!"
         fi
      else
         $LOGIT "AD.1.1.13.1 : Note that this is not a RHEL V6 or later OS."
      fi
   else
      $LOGIT "AD.1.1.13.1 : WARNING - The /etc/pam.d/system-auth file does not exist!"
      $LOGIT ""
      $LOGIT "AD.1.1.13.2 : WARNING - The /etc/pam.d/system-auth file does not exist!"
   fi
   cat /dev/null > PasswdExemptTemp
   $LOGIT ""
   if ((!$FTPEnabled)); then
      $LOGIT "AD.1.1.13.3 : This server has $FTPType installed and enabled."
      if [ -f $FTPfile ]; then
         for USER in `cat PMDTestOut | awk -F'=' '{print $2}' | awk '{print $1}'`
         do
         grep -q "^$USER" $FTPfile
         if (($?)); then
            echo $USER >> PasswdExemptTemp
         fi
         done
         if [ -s PasswdExemptTemp ]; then
            $LOGIT "AD.1.1.13.3 : WARNING - Users with non-expiring passwords exist that are NOT configured in $FTPfile"
            cat PasswdExemptTemp >> $LOGFILE
         else
            $LOGIT "AD.1.1.13.3 : All users with non-expiring passwords are configured in $FTPfile"
         fi
      else
         $LOGIT "AD.1.1.13.3 : WARNING - The $FTPfile does NOT exist!"
      fi
   else
      $LOGIT "AD.1.1.13.3 : N/A - No ftp server is installed and enabled."
   fi
   $LOGIT ""
   if [ -f /etc/ssh/sshd_config ]; then
      SSHD_FILE=/etc/ssh/sshd_config
   elif [ -f /usr/local/etc/ssh/sshd_config ]; then
      SSHD_FILE=/usr/local/etc/ssh/sshd_config
   else
      SSHD_FILE=NOT_FOUND
   fi
   if [ $SSHD_FILE != "NOT_FOUND" ]; then
      grep "^UsePAM" $SSHD_FILE | grep -q "yes"
      if (($?)); then
         $LOGIT "AD.1.1.13.4 : WARNING - The 'UsePAM yes' parameter does not exist in the $SSHD_FILE file"
      else
         $LOGIT "AD.1.1.13.4 : The 'UsePAM yes' parameter exists in the $SSHD_FILE file."
         grep "^UsePAM" $SSHD_FILE | grep "yes" >> $LOGFILE
      fi
   else
      $LOGIT "AD.1.1.13.4 : WARNING - The sshd_config file could not be found!"
   fi
else
   $LOGIT "AD.1.1.10.1 : N/A - There were no login abled users with non-expiring passwords found."
   $LOGIT ""
   $LOGIT "AD.1.1.10.2 : N/A - There were no login abled users with non-expiring passwords found."
   $LOGIT ""
   $LOGIT "AD.1.1.11.1 : N/A - There were no login abled users with non-expiring passwords found."
   $LOGIT ""
   $LOGIT "AD.1.1.12.1 : N/A - There were no login abled users with non-expiring passwords found."
   $LOGIT ""
   $LOGIT "AD.1.1.13.1 : N/A - There were no login abled users with non-expiring passwords found."
   $LOGIT ""
   $LOGIT "AD.1.1.13.2 : N/A - There were no login abled users with non-expiring passwords found."
   $LOGIT ""
   $LOGIT "AD.1.1.13.3 : N/A - There were no login abled users with non-expiring passwords found."
   $LOGIT ""
   $LOGIT "AD.1.1.13.4 : N/A - There were no login abled users with non-expiring passwords found."
fi
#Clean up our temp files:
rm -rf PasswdExemptTemp PMDTestOut

$LOGIT ""
$LOGIT ""
#$LOGIT "1.2 Logging"
#$LOGIT "==========="

$LOGIT ""
if [ -f /etc/syslog.conf ]; then
   cat /etc/syslog.conf | grep -v "^#" | grep "\*.info" | grep "authpriv.none" | grep "/var/log/messages" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.2.1.1 : WARNING - The '*.info' and/or 'authpriv.none' are not configured for /var/log/messages in /etc/syslog.conf!"
      $LOGIT ""
   else
      $LOGIT "AD.1.2.1.1 : The '*.info' and/or 'authpriv.none' are configured for /var/log/messages in /etc/syslog.conf:"
      cat /etc/syslog.conf | grep -v "^#" | grep "\*.info" | grep "authpriv.none" | grep "/var/log/messages" >> $LOGFILE
      $LOGIT ""
   fi
   cat /etc/syslog.conf | grep -v "^#" | grep "authpriv.\*" | grep "/var/log/secure" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.2.1.1 : WARNING - The 'authpriv.*' is not configured for /var/log/secure in /etc/syslog.conf!"
   else
      $LOGIT "AD.1.2.1.1 : The 'authpriv.*' is configured for /var/log/secure in /etc/syslog.conf:"
      cat /etc/syslog.conf | grep -v "^#" | grep "authpriv.\*" | grep "/var/log/secure" >> $LOGFILE
   fi
else
   if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
      if ((!$?)); then
         $LOGIT "AD.1.2.1.1 : The /etc/syslog.conf file does not exist."
         $LOGIT "AD.1.2.1.1 : This is a RHEL $SVER server. It should use /etc/rsyslog.conf instead."
      else
         $LOGIT "AD.1.2.1.1 : WARNING - The /etc/syslog.conf file does not exist."
      fi
   fi
fi

$LOGIT ""
if [ -f /etc/syslog-ng/syslog-ng.conf ]; then
   cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^filter f_authpriv" | grep "facility" | grep "\(auth,authpriv\)" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.2.1.2 : WARNING - The /etc/syslog-ng/syslog-ng.conf file does not contain the 'filter f_authpriv { facility(authpriv); };' paramter!"
   else
      $LOGIT "AD.1.2.1.2 : The /etc/syslog-ng/syslog-ng.conf file does contain the 'filter f_authpriv { facility(authpriv); };' paramter!"
      cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^filter f_authpriv" | grep "facility" | grep "authpriv" >> $LOGFILE
   fi
   cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^destination authpriv" | grep "file" | grep "/var/log/secure" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.2.1.2 : WARNING - The /etc/syslog-ng/syslog-ng.conf file does not contain the 'destination authpriv { file(/var/log/secure); };' parameter!"
   else
      $LOGIT "AD.1.2.1.2 : The /etc/syslog-ng/syslog-ng.conf file does not contain the 'destination authpriv { file(/var/log/secure); };' parameter."
      cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^destination authpriv" | grep "file" | grep "/var/log/secure" >> $LOGFILE
   fi
#   cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^source src" | grep "internal" > /dev/null 2>&1
#   if (($?)); then
#      $LOGIT "AD.1.2.1.2 : WARNING - The /etc/syslog-ng/syslog-ng.conf file does not contain the 'source src { internal(); };' parameter!"
#   else
#      $LOGIT "AD.1.2.1.2 : The /etc/syslog-ng/syslog-ng.conf file does contain the 'source src { internal(); };' parameter!"
#      cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^source src" | grep "internal" >> $LOGFILE
#   fi
   cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^log" | grep "source" | grep "src" | grep "filter" | grep "f_authpriv" | grep "destination" | grep "authpriv" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.2.1.2 : WARNING - The /etc/syslog-ng/syslog-ng.conf file does not contain the 'log { source(src); filter(f_authpriv); destination(authpriv); };'!"
   else
      $LOGIT "AD.1.2.1.2 : The /etc/syslog-ng/syslog-ng.conf file does contain the 'log { source(src); filter(f_authpriv); destination(authpriv); };'."
      cat /etc/syslog-ng/syslog-ng.conf | grep -v "^#" | grep "^log" | grep "source" | grep "src" | grep "filter" | grep "f_authpriv" | grep "destination" | grep "authpriv" >> $LOGFILE
   fi
else
   $LOGIT "AD.1.2.1.2 : N/A - This system does not use syslog-ng"
fi

$LOGIT ""
if [ -f /etc/rsyslog.conf ]; then
   if [[ $OSFlavor = "RedHat" ]] && [[ $RHVER -le 4 ]] || [[ $OSFlavor = "SuSE" ]] && [[ $SVER -le 10 ]]; then
      cat /etc/rsyslog.conf | grep -v "^#" | grep "^filter f_authpriv" | grep "facility" | grep "authpriv" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.2.1.3 : WARNING - The /etc/rsyslog.conf file does not contain the 'filter f_authpriv { facility(authpriv); };' paramter!"
      else
         $LOGIT "AD.1.2.1.3 : The /etc/rsyslog.conf file does contain the 'filter f_authpriv { facility(authpriv); };' paramter!"
         cat /etc/rsyslog.conf | grep -v "^#" | grep "^filter f_authpriv" | grep "facility" | grep "authpriv" >> $LOGFILE
      fi
      cat /etc/rsyslog.conf | grep -v "^#" | grep "^destination authpriv" | grep "file" | grep "/var/log/secure" | grep "RSYSLOG_TraditionalFileFormat" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.2.1.3 : WARNING - The /etc/rsyslog.conf file does not contain the 'destination authpriv { file(\"/var/log/secure;RSYSLOG_TraditionalFileFormat\"); };' parameter!"
      else
         $LOGIT "AD.1.2.1.3 : The /etc/rsyslog.conf file does not contain the 'destination authpriv { file(\"/var/log/secure;RSYSLOG_TraditionalFileFormat\"); };' parameter."
         cat /etc/rsyslog.conf | grep -v "^#" | grep "^destination authpriv" | grep "file" | grep "/var/log/secure" | grep "RSYSLOG_TraditionalFileFormat" >> $LOGFILE
      fi
      cat /etc/rsyslog.conf | grep -v "^#" | grep "^source src" | grep "internal" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.2.1.3 : WARNING - The /etc/rsyslog.conf file does not contain the 'source src { internal(); };' parameter!"
      else
         $LOGIT "AD.1.2.1.3 : The /etc/rsyslog.conf file does contain the 'source src { internal(); };' parameter!"
         cat /etc/rsyslog.conf | grep -v "^#" | grep "^source src" | grep "internal" >> $LOGFILE
      fi
      cat /etc/rsyslog.conf | grep -v "^#" | grep "^log" | grep "source" | grep "src" | grep "filter" | grep "f_authpriv" | grep "destination" | grep "authpriv" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.2.1.3 : WARNING - The /etc/rsyslog.conf file does not contain the 'log { source(src); filter(f_authpriv); destination(authpriv); };'!"
      else
         $LOGIT "AD.1.2.1.3 : The /etc/rsyslog.conf file does contain the 'log { source(src); filter(f_authpriv); destination(authpriv); };'."
         cat /etc/rsyslog.conf | grep -v "^#" | grep "^log" | grep "source" | grep "src" | grep "filter" | grep "f_authpriv" | grep "destination" | grep "authpriv" >> $LOGFILE
      fi
   else
      $LOGIT "AD.1.2.1.3 : N/A - This is not a RHEL 4 or lower OR SuSE 10 or lower system"
   fi
else
   $LOGIT "AD.1.2.1.3 : N/A - This system does not use rsyslog"
fi

$LOGIT ""
if [ -f /etc/rsyslog.conf ]; then
   if [[ $OSFlavor = "RedHat" ]] && [[ $RHVER -ge 5 ]] || [[ $OSFlavor = "SuSE" ]] && [[ $SVER -eq 11 ]]; then
      cat /etc/rsyslog.conf | grep -v "^#" | grep "ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat" > /dev/null 2>&1
      if ((!$?)); then
         cat /etc/rsyslog.conf | grep -v "^#" | grep "\*.info" | grep "mail.none" | grep "authpriv.none" | grep "/var/log/messages" > /dev/null 2>&1
         if (($?)); then 
            $LOGIT "AD.1.2.1.4 : WARNING - The /etc/rsyslog.conf file does not contain the '*.info;mail.none;authpriv.none;cron.none /var/log/messages' paramter!"
         else
            $LOGIT "AD.1.2.1.4 : The /etc/rsyslog.conf file does contain the '*.info;mail.none;authpriv.none;cron.none /var/log/messages' parameter."
            cat /etc/rsyslog.conf | grep -v "^#" | grep "ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat" >> $LOGFILE
            cat /etc/rsyslog.conf | grep -v "^#" | grep "\*.info" | grep "mail.none" | grep "authpriv.none" | grep "cron.none" | grep "/var/log/messages" >> $LOGFILE
         fi
         cat /etc/rsyslog.conf | grep -v "^#" | grep "^authpriv.\*" | grep "/var/log/secure" > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.2.1.4 : WARNING - The /etc/rsyslog.conf file does not contain the 'authpriv.* /var/log/secure' parameter!"
         else
            $LOGIT "AD.1.2.1.4 : The /etc/rsyslog.conf file does contain the 'authpriv.* /var/log/secure' paramter."
            cat /etc/rsyslog.conf | grep -v "^#" | grep "ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat" >> $LOGFILE
            cat /etc/rsyslog.conf | grep -v "^#" | grep "^authpriv.\*" | grep "/var/log/secure" >> $LOGFILE
         fi
      else
         cat /etc/rsyslog.conf | grep -v "^#" | grep "\*.info" | grep "mail.none" | grep "authpriv.none" | grep "/var/log/messages" | grep "RSYSLOG_TraditionalFileFormat" > dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.2.1.4 : WARNING - The /etc/rsyslog.conf file does not contain the '*.info;mail.none;authpriv.none /var/log/messages;RSYSLOG_TraditionalFileFormat' paramter!"
         else
            $LOGIT "AD.1.2.1.4 : The /etc/rsyslog.conf file does contain the '*.info;mail.none;authpriv.none;cron.none /var/log/messages;RSYSLOG_TraditionalFileFormat' paramter."
            cat /etc/rsyslog.conf | grep -v "^#" | grep "\*.info" | grep "mail.none" | grep "authpriv.none" | grep "/var/log/messages" | grep "RSYSLOG_TraditionalFileFormat" >> $LOGFILE
         fi
         cat /etc/rsyslog.conf | grep -v "^#" | grep "^authpriv.\*" | grep "/var/log/secure" | grep "RSYSLOG_TraditionalFileFormat" > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.2.1.4 : WARNING - The /etc/rsyslog.conf file does not contain the 'authpriv.* /var/log/secure;RSYSLOG_TraditionalFileFormat' parameter!"
         else
            $LOGIT "AD.1.2.1.4 : The /etc/rsyslog.conf file does contain the 'authpriv.* /var/log/secure;RSYSLOG_TraditionalFileFormat' parameter."
            cat /etc/rsyslog.conf | grep -v "^#" | grep "^authpriv.\*" | grep "/var/log/secure" | grep "RSYSLOG_TraditionalFileFormat" >> $LOGFILE
         fi
      fi 
   else
      $LOGIT "AD.1.2.1.4 : N/A - This is not a RHEL 5 or higher OR SuSE 11 system"
   fi
else
   $LOGIT "AD.1.2.1.4 : N/A - This system does not use rsyslog"
fi

$LOGIT ""
if [[ $OSFlavor != "RedHat" ]] && [[ $OSFlavor != "SuSE" ]]; then
   $LOGIT "AD.1.2.1.5 : WARNING - This is not a supported OS. Checking this section is being skipped!!!"
else
   $LOGIT "AD.1.2.1.5 : N/A - This is a $OSFlavor OS"
fi

$LOGIT ""
if [ ! -f /var/log/wtmp ]; then
   $LOGIT "AD.1.2.2 : WARNING - The /var/log/wtmp file does NOT exist!"
else
   $LOGIT "AD.1.2.2 : The /var/log/wtmp file exists:"
   ls -al /var/log/wtmp >> $LOGFILE
fi

$LOGIT ""
if [ ! -f /var/log/messages ]; then
   $LOGIT "AD.1.2.3.1 : WARNING - The /var/log/messages file does NOT exist!"
else
   $LOGIT "AD.1.2.3.1 : The /var/log/messages file exists:"
   ls -al /var/log/messages >> $LOGFILE
fi

$LOGIT ""
if [[ $OSFlavor != "RedHat" ]] && [[ $OSFlavor != "SuSE" ]]; then
   if [ ! -f /var/log/syslog ]; then
      $LOGIT "AD.1.2.3.2 : WARNING - The /var/log/syslog file does NOT exist!"
   else
      $LOGIT "AD.1.2.3.2 : The /var/log/syslog file exists:"
      ls -al /var/log/syslog >> $LOGFILE
   fi
else
   $LOGIT "AD.1.2.3.2 : N/A - This is a $OSFlavor OS"
fi

$LOGIT ""
if [ $OSFlavor = "RedHat" ]; then
   cat /etc/pam.d/system-auth-ac | grep -q pam_tally.so
   if ((!$?)); then
      if [ ! -f /var/log/faillog ]; then
         $LOGIT "AD.1.2.4.1 : WARNING - System is using pam_tally.so and the /var/log/faillog file does NOT exist!"
      else
         $LOGIT "AD.1.2.4.1 : The /var/log/faillog file exists:"
         ls -al /var/log/faillog >> $LOGFILE
      fi
   else
      cat /etc/pam.d/system-auth-ac | grep -q pam_tally2.so
      if ((!$?)); then
         $LOGIT "AD.1.2.4.1 : N/A - System is using pam_tally2.so."
      else
         if [ ! -f /var/log/faillog ]; then
            $LOGIT "AD.1.2.4.1 : WARNING - System is not using pam_tally2.so and the /var/log/faillog file does NOT exist!"
         else
            $LOGIT "AD.1.2.4.1 : The /var/log/faillog file exists:"
            ls -al /var/log/faillog >> $LOGFILE
         fi
      fi
   fi
else
   grep -q pam_tally.so /etc/pam.d/*
   if ((!$?)); then
      if [ ! -f /var/log/faillog ]; then
         $LOGIT "AD.1.2.4.1 : WARNING - System is using pam_tally.so and the /var/log/faillog file does NOT exist!"
      else
         $LOGIT "AD.1.2.4.1 : The /var/log/faillog file exists:"
         ls -al /var/log/faillog >> $LOGFILE
      fi
   else
      grep -q pam_tally2.so /etc/pam.d/*
      if ((!$?)); then
         $LOGIT "AD.1.2.4.1 : N/A - System is using pam_tally2.so."
      else
         if [ ! -f /var/log/faillog ]; then
            $LOGIT "AD.1.2.4.1 : WARNING - System is not using pam_tally2.so and the /var/log/faillog file does NOT exist!"
         else
            $LOGIT "AD.1.2.4.1 : The /var/log/faillog file exists:"
            ls -al /var/log/faillog >> $LOGFILE
         fi
      fi
   fi
fi

$LOGIT ""
if [ $OSFlavor = "RedHat" ]; then
   cat /etc/pam.d/system-auth-ac | grep -q pam_tally2.so
   if ((!$?)); then
      if [ ! -f /var/log/tallylog ]; then
         $LOGIT "AD.1.2.4.2 : WARNING - System is using pam_tally2.so and the /var/log/tallylog file does NOT exist!"
      else
         $LOGIT "AD.1.2.4.2 : The /var/log/tallylog file exists:"
         ls -al /var/log/tallylog >> $LOGFILE
      fi
   else
      cat /etc/pam.d/system-auth-ac | grep -q pam_tally.so
      if ((!$?)); then
         $LOGIT "AD.1.2.4.2 : N/A - System is using pam_tally.so."
      else
         $LOGIT "AD.1.2.4.2 : WARNING - System does NOT have pam_tally.so NOR pam_tally2.so configured!"
      fi
   fi
else
   grep -q pam_tally2.so /etc/pam.d/*
   if ((!$?)); then
      if [ ! -f /var/log/tallylog ]; then
         $LOGIT "AD.1.2.4.2 : WARNING - System is using pam_tally2.so and the /var/log/tallylog file does NOT exist!"
      else
         $LOGIT "AD.1.2.4.2 : The /var/log/tallylog file exists:"
         ls -al /var/log/tallylog >> $LOGFILE
      fi
   else
      grep -q pam_tally.so /etc/pam.d/*
      if ((!$?)); then
         $LOGIT "AD.1.2.4.2 : N/A - System is using pam_tally.so."
      else
         $LOGIT "AD.1.2.4.2 : WARNING - System does NOT have pam_tally.so NOR pam_tally2.so configured!"
      fi
   fi
fi

$LOGIT ""
if [ -f /var/log/secure ]; then
   $LOGIT "AD.1.2.5 : The /var/log/secure file exists:"
   ls -al /var/log/secure >> $LOGFILE
elif [ -f /var/log/auth.log ]; then
   $LOGIT "AD.1.2.5 : The /var/log/auth.log file exists:"
   ls -al /var/log/auth.log >> $LOGFILE
else
   $LOGIT "AD.1.2.5 : WARNING - Neither the /var/log/secure nor the /var/log/auth.log files exist!"
fi

$LOGIT ""
ShowLogList=1
NinetyDayLogRotate=1
if [ -f /etc/cron.daily/logrotate ]; then
   if [ -f /etc/logrotate.conf ]; then
      grep "^rotate" /etc/logrotate.conf > /dev/null 2>&1
      if ((!$?)); then
         RotateDays=`grep "^rotate" /etc/logrotate.conf | awk '{print $2}' | head -1`
         if [ $RotateDays -lt 13 ]; then
            $LOGIT "AD.1.2.6 : WARNING - The system is NOT keeping 90 days worth of log files. It is only keeping $RotateDays week(s) of log files."
         else
            NinetyDayLogRotate=0
            if [ -f /etc/logrotate.d/syslog ]; then
               LogsToRotate=`egrep -c '/var/log/cron|/var/log/maillog|/var/log/messages|/var/log/secure' /etc/logrotate.d/syslog`
               if [ $LogsToRotate -lt 4 ]; then
                  $LOGIT "AD.1.2.6 : WARNING - No all system logs appear to be configured for rotation."
                  $LOGIT "AD.1.2.6 : Any logs configured are listed below:"
                  grep '/var/log/cron|/var/log/maillog|/var/log/messages|/var/log/secure' /etc/logrotate.d/syslog >> $LOGFILE
               else
                  $LOGIT "AD.1.2.6 : The system is keeping at least 90 days worth of log files."
                  grep "^rotate" /etc/logrotate.conf | head -1 >> $LOGFILE
               fi
            else
               $LOGIT "AD.1.2.6 : WARNING - No system logs appear to be configured for rotation, although the server is configured for 90 days of retention."
            fi
         fi
      else
         $LOGIT "AD.1.2.6 : WARNING - The rotate paramter is not set in /etc/logrotate.conf!"
         ShowLogList=0
      fi
   else
      $LOGIT "AD.1.2.6 : WARNING - The /etc/logrotate.conf file does not exist!"
      ShowLogList=0
   fi
else
   $LOGIT "AD.1.2.6 : WARNING - The /etc/cron.daily/logrotate file does not exist!"
   ShowLogList=0
fi
if ((!$ShowLogList)); then
   $LOGIT "AD.1.2.6 : Here is a long listing of the system log files. Ensure there are at least 90 days worth:"
   for file in messages secure wtmp faillog
   do
   ls -al /var/log/$file | awk '{print $9,"==== "$6,$7,$8}' >> $LOGFILE
   done
fi


$LOGIT ""
$LOGIT ""
#$LOGIT "1.4 System Settings"
#$LOGIT "==================="

$LOGIT ""
cat /dev/null > AD.1.4.1_temp
AD141check=0
cat /etc/pam.d/other | grep "^auth" | grep "required" | grep -q "pam_deny.so"
if (($?)); then
   AD141check=1
else
   cat /etc/pam.d/other | grep "^auth" | grep "required" | grep "pam_deny.so" >> AD.1.4.1_temp
fi
cat /etc/pam.d/other | grep "^account" | grep "required" | grep -q "pam_deny.so"
if (($?)); then
   AD141check=1
else
   cat /etc/pam.d/other | grep "^account" | grep "required" | grep "pam_deny.so" >> AD.1.4.1_temp
fi
if (($AD141check)); then
   $LOGIT "AD.1.4.1 : WARNING - One or both required entries in /etc/pam.d/other are missing!"
   if [ -s AD.1.4.1_temp ]; then
      $LOGIT "AD.1.4.1 : Here is what was found in /etc/pam.d/other:"
   fi
else
   $LOGIT "AD.1.4.1 : Both required entries in /etc/pam.d/other are configured:"
fi
cat AD.1.4.1_temp >> $LOGFILE
rm -rf AD.1.4.1_temp
if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
   if [ -f /etc/pam.d/system-auth ]; then
      AD141check=0
      cat /dev/null > AD.1.4.1_temp
      cat /etc/pam.d/password-auth | grep "^auth" | grep "required" | grep -q "pam_deny.so"
      if (($?)); then
         AD141check=1
      else
         cat /etc/pam.d/password-auth | grep "^auth" | grep "required" | grep "pam_deny.so" >> AD.1.4.1_temp
      fi
      cat /etc/pam.d/password-auth | grep "^account" | grep "required" | grep -q "pam_deny.so"
      if (($?)); then
         AD141check=1
      else
         cat /etc/pam.d/password-auth | grep "^account" | grep "required" | grep "pam_deny.so" >> AD.1.4.1_temp
      fi
      if (($AD141check)); then
         $LOGIT "AD.1.4.1 : WARNING - One or both required entries in /etc/pam.d/password-auth are missing!"
         if [ -s AD.1.4.1_temp ]; then
            $LOGIT "AD.1.4.1 : Here is what was found in /etc/pam.d/password-auth:"
         fi
      else
         $LOGIT "AD.1.4.1 : Both required entries in /etc/pam.d/password-auth are configured:"
      fi
      cat AD.1.4.1_temp >> $LOGFILE
      rm -rf AD.1.4.1_temp
   else
      $LOGIT "AD.1.4.1 : The /etc/pam.d/system-auth file is not in use."
   fi
else
   $LOGIT "AD.1.4.1 : Note that this is not a RHEL V6 or later OS."
fi

$LOGIT ""
if ((!$FTPEnabled)); then
   if [ -f $FTPfile ]; then
      grep -q "^root" $FTPfile
      if (($?)); then
         $LOGIT "AD.1.4.2 : WARNING - User root does NOT exist in $FTPfile"
      else
         $LOGIT "AD.1.4.2 : User root exists in $FTPfile"
      fi
   else
      $LOGIT "AD.1.4.2 : WARNING - This server has $FTPType installed and enabled, but the $FTPfile file does not exist!"
   fi
else
   $LOGIT "AD.1.4.2 : N/A - FTP is not installed and enabled on this server."
fi

$LOGIT ""
cat /dev/null > AD143_temp
for ID in `cat /etc/passwd | awk -F':' '{print $1}'`
do
FIELD2=`grep "^$ID:" /etc/passwd | awk -F':' '{print $2}'`
if [ $FIELD2 != "x" ]; then
   echo "$ID : $FIELD2" >> AD143_temp
fi
done
if [ -s AD143_temp ]; then
   $LOGIT "AD.1.4.3 : WARNING - The /etc/passwd file appears to contain entry(ies) in field 2 that are not shadowed passwords:"
   cat AD143_temp >> $LOGFILE
else
   $LOGIT "AD.1.4.3 : All entries in the /etc/passwd file are shadowed and no password(s) were found."
fi
rm -rf AD143_temp

$LOGIT ""
cat /dev/null > AD144_temp
for ID in `cat /etc/shadow | awk -F':' '{print $1}'`
do
IDPasswd=`grep "^$ID:" /etc/shadow | awk -F':' '{print $2}'`
if [[ -z $IDPasswd ]]; then
   echo $ID >> AD144_temp
fi
done
if [ -s AD144_temp ]; then
   $LOGIT "AD.1.4.4 : WARNING - Some ID(s) exist that appear to have no encrypted password in /etc/shadow:"
   cat AD144_temp >> $LOGFILE
else
   $LOGIT "AD.1.4.4 : All ID(s) appear to have encrypted password(s) in /etc/shadow."
fi
rm -rf AD144_temp

$LOGIT ""
$LOGIT "AD.1.4.5 : Anonymous FTP files stored into a writeable directory...THIS SCRIPT CANNOT CHECK THIS SECTION!"

$LOGIT ""
$LOGIT ""
#$LOGIT "1.5.x Network Settings"
#$LOGIT "======================"

$LOGIT ""
##
#Things get complicated here. Too many kinds of FTP to check.
#We will attempt to check VSFTP and wu-ftp
##
rpm -qa | grep -q wu-ftpd
if (($?)); then
   WUFTPD=1
   WUFTPDanon=1
else
   WUFTPD=0
   chkconfig --list | grep -iq wu-ftpd
   if ((!$?)); then
      chkconfig --list | grep -i wu-ftpd | grep -q on
      if ((!$?)); then
         grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
         if ((!$?)); then
            WUFTPDanon=0
         else
            WUFTPDanon=1
         fi
      else
         WUFTPD=1
         WUFTPDanon=1
      fi
   elif [ -f /etc/inetd.conf ]; then
      grep "^ftp" /etc/inetd.conf | grep -vq vsftp
      if ((!$?)); then
         WUFTPD=0
         grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
         if ((!$?)); then
            WUFTPDanon=0
         else
            WUFTPDanon=1
         fi
      else
         WUFTPD=0
         WUFTPDanon=1
      fi
   else
      WUFTPD=0
      WUFTPDanon=1
   fi
fi
rpm -qa | grep -q vsftpd
if (($?)); then
   VSFTPD=1
   VSFTPDanon=1
   chkconfig --list | grep -iq vsftpd >> $LOGFILE
   if ((!$?)); then
      chkconfig --list | grep -i vsftpd | grep -q on
      if ((!$?)); then
         TestFile=`cat /etc/xinetd.d/vsftpd | grep -v "^#" | grep -w server | awk '{print $3}'`
         if [[ -n $TestFile ]] && [[ -x $TestFile ]]; then
            VSFTPD=0
            if [ -f /etc/vsftpd/vsftpd.conf ]; then
               VSFTPDfile=/etc/vsftpd/vsftpd.conf
            elif [ -f /etc/vsftpd.conf ]; then
               VSFTPDfile=/etc/vsftpd.conf
            elif [ -f /usr/local/etc/vsftpd.conf ]; then
               VSFTPDfile=/usr/local/etc/vsftpd.conf
            else
               VSFTPDfile=UNKNOWN
            fi
            if [ $VSFTPDfile != "UNKNOWN" ]; then
               grep -q "^anonymous_enable" $VSFTPDfile
               if ((!$?)); then
                  grep -q "^anonymous_enable" $VSFTPDfile | grep -iq yes
                  if ((!$?)); then
                     grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                     if ((!$?)); then
                        VSFTPDanon=0
                     else
                        VSFTPDanon=1
                     fi
                  else
                     VSFTPDanon=1
                  fi
               else
                  grep -q "anonymous_enable" $VSFTPDfile
                  if ((!$?)); then
                     grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                     if ((!$?)); then
                        VSFTPDanon=0
                     else
                        VSFTPDanon=1
                     fi
                  else
                     VSFTPDanon=1
                  fi
               fi
            else
               grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
               if ((!$?)); then
                  VSFTPDanon=0
               else
                  VSFTPDanon=1
               fi
            fi
         fi
      fi
   elif [ -f /etc/inetd.conf ]; then
      grep "^ftp" /etc/inetd.conf | grep -q vsftpd
      if ((!$?)); then
         VSFTPD=0
         if [ -f /etc/vsftpd/vsftpd.conf ]; then
            VSFTPDfile=/etc/vsftpd/vsftpd.conf
         elif [ -f /etc/vsftpd.conf ]; then
            VSFTPDfile=/etc/vsftpd.conf
         elif [ -f /usr/local/etc/vsftpd.conf ]; then
            VSFTPDfile=/usr/local/etc/vsftpd.conf
         else
            VSFTPDfile=UNKNOWN
         fi
         if [ $VSFTPDfile != "UNKNOWN" ]; then
            grep -q "^anonymous_enable" $VSFTPDfile
            if ((!$?)); then
               grep -q "^anonymous_enable" $VSFTPDfile | grep -iq yes
               if ((!$?)); then
                  grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                  if ((!$?)); then
                     VSFTPDanon=0
                  else
                     VSFTPDanon=1
                  fi
               else
                  VSFTPDanon=1
               fi
            else
               grep -q "anonymous_enable" $VSFTPDfile
               if ((!$?)); then
                  grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                  if ((!$?)); then
                     VSFTPDanon=0
                  else
                     VSFTPDanon=1
                  fi
               else
                  VSFTPDanon=1
               fi
            fi
         else
            grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
            if ((!$?)); then
               VSFTPDanon=0
            else
               VSFTPDanon=1
            fi
         fi
      else
         VSFTPD=1
         VSFTPDanon=1
      fi
   else
      VSFTPD=1
      VSFTPDanon=1
   fi
else
   chkconfig --list | grep -i vsftpd >> $LOGFILE
   if ((!$?)); then
      chkconfig --list | grep -i vsftpd | grep -q on
      if ((!$?)); then
         VSFTPD=0
         if [ -f /etc/vsftpd/vsftpd.conf ]; then
            VSFTPDfile=/etc/vsftpd/vsftpd.conf
         elif [ -f /etc/vsftpd.conf ]; then
            VSFTPDfile=/etc/vsftpd.conf
         elif [ -f /usr/local/etc/vsftpd.conf ]; then
            VSFTPDfile=/usr/local/etc/vsftpd.conf
         else
            VSFTPDfile=UNKNOWN
         fi
         if [ $VSFTPDfile != "UNKNOWN" ]; then
            grep -q "^anonymous_enable" $VSFTPDfile
            if ((!$?)); then
               grep -q "^anonymous_enable" $VSFTPDfile | grep -iq yes
               if ((!$?)); then
                  grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                  if ((!$?)); then
                     VSFTPDanon=0
                  else
                     VSFTPDanon=1
                  fi
               else
                  VSFTPDanon=1
               fi
            else
               grep -q "anonymous_enable" $VSFTPDfile
               if ((!$?)); then
                  grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                  if ((!$?)); then
                     VSFTPDanon=0
                  else
                     VSFTPDanon=1
                  fi
               else
                  VSFTPDanon=1
               fi
            fi
         else
            grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
            if ((!$?)); then
               VSFTPDanon=0
            else
               VSFTPDanon=1
            fi
         fi
      else
         VSFTPD=1
         VSFTPDanon=1
      fi
   elif [ -f /etc/inetd.conf ]; then
      grep "^ftp" /etc/inetd.conf | grep -q vsftpd
      if ((!$?)); then
         VSFTPD=0
         if [ -f /etc/vsftpd/vsftpd.conf ]; then
            VSFTPDfile=/etc/vsftpd/vsftpd.conf
         elif [ -f /etc/vsftpd.conf ]; then
            VSFTPDfile=/etc/vsftpd.conf
         elif [ -f /usr/local/etc/vsftpd.conf ]; then
            VSFTPDfile=/usr/local/etc/vsftpd.conf
         else
            VSFTPDfile=UNKNOWN
         fi
         if [ $VSFTPDfile != "UNKNOWN" ]; then
            grep -q "^anonymous_enable" $VSFTPDfile
            if ((!$?)); then
               grep -q "^anonymous_enable" $VSFTPDfile | grep -iq yes
               if ((!$?)); then
                  grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                  if ((!$?)); then
                     VSFTPDanon=0
                  else
                     VSFTPDanon=1
                  fi
               else
                  VSFTPDanon=1
               fi
            else
               grep -q "anonymous_enable" $VSFTPDfile
               if ((!$?)); then
                  grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
                  if ((!$?)); then
                     VSFTPDanon=0
                  else
                     VSFTPDanon=1
                  fi
               else
                  VSFTPDanon=1
               fi
            fi
         else
            grep "^ftp:" /etc/passwd | grep -vq "/sbin/nologin"
            if ((!$?)); then
               VSFTPDanon=0
            else
               VSFTPDanon=1
            fi
         fi
      else
         VSFTPD=1
         VSFTPDanon=1
      fi
   else
      VSFTPD=1
      VSFTPDanon=1
   fi
fi

if ((!$WUFTPD)) && ((!$WUFTPDanon)); then
   if [ -f /etc/inetd.conf ]; then
      grep "^ftp" /etc/inetd.conf | grep "-u" | grep -q 027
      if (($?)); then
         $LOGIT "AD.1.5.1.1 : WARNING - wu-ftpd is installed and anonymous FTP is enabled but '-u 027' is not configured in /etc/inetd.conf"
      else
         $LOGIT "AD.1.5.1.1 : The '-u 027' setting is configured in /etc/inetd.conf file."
      fi
   else
      $LOGIT "AD.1.5.1.1 : WARNING - wu-ftpd is installed and anonymous FTP is enabled but '-u 027' is not configured in /etc/inetd.conf"
   fi
else
   $LOGIT "AD.1.5.1.1 : N/A - wu-ftpd is not installed or anonymous FTP is not enabled."
fi

$LOGIT ""
#FTP is not installed:
if (($WUFTPD)) && (($VSFTPD)); then
   x=2
   until [ $x -eq 9 ]
   do
   $LOGIT "AD.1.5.1.$x : N/A - FTP is not installed on this server."
   $LOGIT ""
   ((x+=1))
   done
#FTP installed but anonymous FTP is not enabled:
elif [[ $WUFTPD -eq 0 && $WUFTPDanon -eq 1 ]] || [[ $VSFTPD -eq 0 && $VSFTPDanon -eq 1 ]]; then
   x=2
   until [ $x -eq 9 ]
   do
   $LOGIT "AD.1.5.1.$x : N/A - FTP is installed on this server, but anonymous ftp is NOT enabled."
   $LOGIT ""
   ((x+=1))
   done
#FTP installed and anonymous FTP is enabled so run the full gammit:
else
   AnonFTPHome=`grep "^ftp:" /etc/passwd | awk -F':' '{print $6}'`
   if [[ -n $AnonFTPHome ]] && [[ -d $AnonFTPHome ]]; then
      OWNER=`ls -ald $AnonFTPHome | awk '{print $3}'`
      HOMEPerms=`ls -ald $AnonFTPHome | awk '{print $1}' | cut -c6,9`
      if [[ $OWNER = "root" ]] && [[ $HOMEPerms = "--" ]]; then
         $LOGIT "AD.1.5.1.2 : The ftp home directory exists and is owned by root and writeable only by root:"
      else
         $LOGIT "AD.1.5.1.2 : WARNING - The ftp home directory exists and has incorrect permissions:"
      fi
      ls -ald $AnonFTPHome >> $LOGFILE
      $LOGIT ""
      if [ -d $AnonFTPHome/bin ]; then
         OWNER=`ls -ald $AnonFTPHome/bin | awk '{print $3}'`
         HOMEPerms=`ls -ald $AnonFTPHome/bin | awk '{print $1}' | cut -c6,9`
         if [[ $OWNER = "root" ]] && [[ $HOMEPerms = "--" ]]; then
            $LOGIT "AD.1.5.1.3 : The bin subdirectory of the ftp home is owned by root and writeable only by root:"
         else
            $LOGIT "AD.1.5.1.3 : WARNING - The bin subdirectory of the ftp home has incorrect permissions:"
         fi
         ls -ald $AnonFTPHome/bin >> $LOGFILE
         ls -al $AnonFTPHome/bin | egrep -vq '^total|^d' >> $LOGFILE
         if ((!$?)); then
            cat /dev/null > AD1513_temp
            for file in `ls -al $AnonFTPHome/bin | egrep -v '^total|^d' | awk '{print $9}'`
            do
            OTHER=`stat -L -t --format=%a $AnonFTPHome/bin/$file
            if [ $OTHER == "111" ]; then
               ls -al $AnonFTPHome/bin/$file >> AD1513_temp
            fi
            done
            if [ -s AD1513_temp ]; then
               $LOGIT "AD.1.5.1.3 : WARNING - File(s) exist in $AnonFTPHome/bin that are not set to mode 0111:"
               cat AD1513_temp >> $LOGFILE
            else
               $LOGIT "AD.1.5.1.3 : All file(s) in $AnonFTPHome/bin are set to mode 0111."
            fi
            rm -rf AD1513_temp
         else
            $LOGIT "AD.1.5.1.3 : No files exist in $AnonFTPHome/bin to check for mode 0111."
         fi
      else
         $LOGIT "AD.1.5.1.3 : N/A - The bin subdirectory of the ftp home does not exist."
      fi
      $LOGIT ""
      if [ -d $AnonFTPHome/lib ]; then
         OWNER=`ls -ald $AnonFTPHome/lib | awk '{print $3}'`
         HOMEPerms=`ls -ald $AnonFTPHome/lib | awk '{print $1}' | cut -c6,9`
         if [[ $OWNER = "root" ]] && [[ $HOMEPerms = "--" ]]; then
            $LOGIT "AD.1.5.1.4 : The lib subdirectory of the ftp home is owned by root and writeable only by root:"
         else
            $LOGIT "AD.1.5.1.4 : WARNING - The lib subdirectory of the ftp home has incorrect permissions:"
         fi
         ls -ald $AnonFTPHome/lib >> $LOGFILE
         ls -al $AnonFTPHome/lib | egrep -vq '^total|^d' >> $LOGFILE
         if ((!$?)); then
            cat /dev/null > AD1514_temp
            for file in `ls -al $AnonFTPHome/lib | egrep -v '^total|^d' | awk '{print $9}'`
            do
            OTHER=`stat -L -t --format=%a $AnonFTPHome/lib/$file
            if [ $OTHER == "555" ]; then
               ls -al $AnonFTPHome/lib/$file >> AD1514_temp
            fi
            done
            if [ -s AD1514_temp ]; then
               $LOGIT "AD.1.5.1.4 : WARNING - File(s) exist in $AnonFTPHome/lib that are not set to mode 0555:"
               cat AD1514_temp >> $LOGFILE
            else
               $LOGIT "AD.1.5.1.4 : All file(s) in $AnonFTPHome/lib are set to mode 0555."
            fi
            rm -rf AD1514_temp
         else
            $LOGIT "AD.1.5.1.4 : No files exist in $AnonFTPHome/lib to check for mode 0555."
         fi
      else
         $LOGIT "AD.1.5.1.4 : N/A - The lib subdirectory of the ftp home does not exist."
      fi
      $LOGIT ""
      if [ -d $AnonFTPHome/etc ]; then
         OWNER=`ls -ald $AnonFTPHome/etc | awk '{print $3}'`
         HOMEPerms=`ls -ald $AnonFTPHome/etc | awk '{print $1}' | cut -c6,9`
         if [[ $OWNER = "root" ]] && [[ $HOMEPerms = "--" ]]; then
            $LOGIT "AD.1.5.1.5 : The etc subdirectory of the ftp home is owned by root and writeable only by root:"
         else
            $LOGIT "AD.1.5.1.5 : WARNING - The etc subdirectory of the ftp home has incorrect permissions:"
         fi
         ls -ald $AnonFTPHome/etc >> $LOGFILE
         if [ -s $AnonFTPHome/etc/passwd ]; then
            cat /dev/null > AD1515_temp
            for ID in `cat $AnonFTPHome/etc/passwd | grep -v "^#" | awk -F':' '{print $1}'`
            do
            IDfield2=`grep "^$ID:" $AnonFTPHome/etc/passwd | awk -F':' '{print $2}'`
            if [ -n $IDfield2 ]; then
               echo "$ID : $IDfield2" >> AD1515_temp
            fi
            done
            if [ -s AD1515_temp ]; then
               $LOGIT "AD.1.5.1.5 : WARNING - The passwd file in $AnonFTPHome/etc contains entries in the password field:"
               cat AD1515_temp >> $LOGFILE
            else
               $LOGIT "AD.1.5.1.5 : The password fields in the passwd file residing in $AnonFTPHome/etc/passwd are all empty."
            fi
            rm -rf AD1515_temp
         else
            $LOGIT "AD.1.5.1.5 : There is no passwd file in $AnonFTPHome/etc/passwd."
         fi
      else
         $LOGIT "AD.1.5.1.5 : N/A - The etc subdirectory of the ftp home does not exist."
      fi
      $LOGIT ""
      ls $AnonFTPHome | egrep -wvq 'bin|lib|etc'
      if ((!$?)); then
         cat /dev/null > AD1516_temp
         for file in `ls $AnonFTPHome | egrep -wv 'bin|lib|etc'`
         do
         OWNER=`ls -ald $AnonFTPHome/$file | awk '{print $3}'`
         GROUP=`ls -ald $AnonFTPHome/$file | awk '{print $4}'`
         GRPWRITE=`ls -ald $AnonFTPHome/$file | awk '{print $1}' | cut -c6`
         GROUPID=`grep "^$GROUP:" /etc/group | awk -F':' '{print $3}'`
         OTHER=`ls -ald $AnonFTPHome/$file | awk '{print $1}' | cut -c8-10`
         if [ $OWNER != "root" ]; then
            ls -ald $AnonFTPHome/$file >> AD1516_temp
         elif [ $GRPWRITE = "w" ]; then
            if [ $GROUPID -gt 99 ]; then
               ls -ald $AnonFTPHome/$file >> AD1516_temp
            fi
         elif [[ $OTHER != "r-x" && $OTHER != "-wx" && $OTHER != "--x" && $OTHER != "---" ]]; then
            ls -ald $AnonFTPHome/$file >> AD1516_temp
         fi
         done
         if [ -s AD1516_temp ]; then
            $LOGIT "AD.1.5.1.6 : WARNING - Some file(s) and/or subdirectory(ies) exist in $AnonFTPHome that do not meet iSeC requirements!"
            cat AD1516_temp >> $LOGFILE
         else
            $LOGIT "AD.1.5.1.6 : All file(s) and subdirectory(ies) in $AnonFTPHome meet iSeC requirements."
         fi
         rm -rf AD1516_temp
      else
         $LOGIT "AD.1.5.1.6 : N/A - No other files or subdirectories exist in $AnonFTPHome."
      fi
   else
      x=2
      until [ $x -eq 7 ]
      do
      $LOGIT "AD.1.5.1.$x : N/A - The ftp home directory $AnonFTPHome does not exist."
      ((x+=1))
      done
   fi
   $LOGIT ""
   $LOGIT "AD.1.5.1.7 : FTP access to dirs containing classified data...THIS SCRIPT CANNOT CHECK THIS SECTION!"
   $LOGIT ""
   $LOGIT "AD.1.5.1.8 : Read or write access but not both via anonymous FTP...THIS SCRIPT CANNOT CHECK THIS SECTION!"
fi

$LOGIT ""
TFTPFound=1
if [ -f /etc/inetd.conf ]; then
   grep -wq "^tftp" /etc/inetd.conf
   if ((!$?)); then
      TFTPFound=0
      grep -w "^tftp" /etc/inetd.conf | grep -q "-s"
      if (($?)); then
         $LOGIT "AD.1.5.2.1 : WARNING - TFTP is enabled but the '-s' parameter is not used:"
      else
         $LOGIT "AD.1.5.2.1 : TFTP is enabled and the '-s' parameter is set correctly:"
      fi
      grep -w "^tftp" /etc/inetd.conf >> $LOGFILE
   fi
elif [ -f /etc/xinetd.d/tftp ]; then
   grep -w "disable" /etc/xinetd.d/tftp | grep -qi "no"
   if ((!$?)); then
      TFTPFound=0
      grep -w "server_args" /etc/xinetd.d/tftp | grep -q "-s"
      if ((!$?)); then
         $LOGIT "AD.1.5.2.1 : TFTP is enabled and the '-s' parameter is set correctly:"
      else
         $LOGIT "AD.1.5.2.1 : WARNING - TFTP is enabled but the '-s' parameter is not used:"
      fi
      grep -w "server_args" /etc/xinetd.d/tftp >> $LOGFILE
   fi
elif [ $TFTPFound -eq 1 ]; then
   $LOGIT "AD.1.5.2.1 : N/A - TFTP is not enabled on this server."
fi

$LOGIT ""
if [ $TFTPFound -eq 1 ]; then
   $LOGIT "AD.1.5.2.2 : N/A - TFTP is not enabled on this server."
else
   $LOGIT "AD.1.5.2.2 : Access via TFTP and unclassified data...THIS SCRIPT CANNOT CHECK THIS SECTION!"
fi

$LOGIT ""
/bin/ps -eo comm | /bin/grep -w nfsd > /dev/null 2>&1
if ((!$?)); then
   if [ -f /etc/exports ]; then
      OWNER=`ls -al /etc/exports | awk '{print $3}'`
      PERMS=`ls -al /etc/exports | awk '{print $1}'`
      if [[ $OWNER = "root" ]] && [[ $PERMS = "-rw-r--r--" ]]; then
         $LOGIT "AD.1.5.3.1 : NFS is running and the /etc/exports file exists with correct ownership and permissions:"
      else
         $LOGIT "AD.1.5.3.1 : WARNING - NFS is running and the /etc/exports file has incorrect ownership and/or permissions:"
      fi
      ls -al /etc/exports >> $LOGFILE
      $LOGIT ""
      $LOGIT "AD.1.5.3.2 : Classified data granted through NFS...THIS SCRIPT CANNOT CHECK THIS SECTION!"
      $LOGIT "AD.1.5.3.2 : Here is the contents of the /etc/exports file:"
      cat /etc/exports >> $LOGFILE
   else
      $LOGIT "AD.1.5.3.1 : WARNING - NFS is running and the /etc/exports file does NOT exist!"
      $LOGIT ""
      $LOGIT "AD.1.5.3.2 : Classified data granted through NFS...THIS SCRIPT CANNOT CHECK THIS SECTION!"
   fi
else
   $LOGIT "AD.1.5.3.1 : N/A - NFS Server is not active"
   $LOGIT ""
   $LOGIT "AD.1.5.3.2 : N/A - NFS Server is not active"
fi

$LOGIT ""
if [ -f /etc/hosts.equiv ]; then
   cat /etc/hosts.equiv | grep -v "^#" | grep -vq "^\$"
   if ((!$?)); then
      $LOGIT "AD.1.5.4.1 : WARNING - The /etc/hosts.equiv file exists and contains active entries:"
      cat /etc/hosts.equiv | grep -v "^#" | grep -vq "^\$" >> $LOGFILE
   else
      $LOGIT "AD.1.5.4.1 : The /etc/hosts.equiv file does NOT contain any active entries."
   fi
else
   $LOGIT "AD.1.5.4.1 : The /etc/hosts.equiv file does not exist."
fi

$LOGIT ""
if [ -s /etc/pam.d/rlogin ] || [ -s /etc/pam.d/rsh ]; then
   $LOGIT "AD.1.5.4.2 : The /etc/pam.d/rlogin and/or /etc/pam.d/rsh file(s) exist."
   grep "/lib/security/pam_rhosts_auth.so" /etc/pam.d/system-auth | grep -vq "^#"
   if ((!$?)); then
      grep "/lib/security/pam_rhosts_auth.so" /etc/pam.d/system-auth | grep -v "^#" | grep -q "no_hosts_equiv"
      if (($?)); then
         $LOGIT "AD.1.5.4.2 : WARNING - The /etc/pam.d/system-auth file contains the /lib/security/pam_rhosts_auth.so stanza, but does NOT contain the 'no_hosts_equiv' parameter!"
      else
         $LOGIT "AD.1.5.4.2 : The /etc/pam.d/system-auth file contains the /lib/security/pam_rhosts_auth.so stanza, and contains the 'no_hosts_equiv' parameter."
      fi
      grep "/lib/security/pam_rhosts_auth.so" /etc/pam.d/system-auth | grep -v "^#" >> $LOGFILE
   else
      $LOGIT "AD.1.5.4.2 : The /etc/pam.d/system-auth file does not contain the '/lib/security/pam_rhosts_auth.so' stanza."
   fi
else
   $LOGIT "AD.1.5.4.2 : N/A - The /etc/pam.d/rlogin and /etc/pam.d/rsh files do not exist."
fi

$LOGIT ""
if [ -f /etc/inetd.conf ]; then
   grep -w rexd /etc/inetd.conf | grep -vq "^#"
   if ((!$?)); then
      $LOGIT "AD.1.5.5 : WARNING - The rexd daemon is enabled in /etc/inetd.conf!"
      grep -w rexd /etc/inetd.conf | grep -v "^#" >> $LOGFILE
   else
      $LOGIT "AD.1.5.5 : The rexd daemon is NOT enabled in /etc/inetd.conf."
   fi
else
   $LOGIT "AD.1.5.5 : The /etc/inetd.conf file does not exist."
fi
if [ -s /etc/xinetd.d/rexd ]; then
   cat /etc/xinetd.d/rexd | grep "disable =" | grep -q "no"
   if (($?)); then
      $LOGIT "AD.1.5.5 : WARNING - The rexd daemon is enabled in /etc/xinetd.d/rexd!"
   else
      $LOGIT "AD.1.5.5 : The rexd daemon is NOT enabled in /etc/xinetd.d"
   fi
else
   $LOGIT "AD.1.5.5 : The rexd daemon is NOT enabled in /etc/xinetd.d"
fi

$LOGIT ""
chkconfig --list | grep -wq innd
if (($?)); then
   $LOGIT "AD.1.5.6 : N/A - NNTP is not configured or running on this server."
else
   $LOGIT "AD.1.5.6 : WARNING - NNTP is configured on this server. THIS SCRIPT CANNOT CHECK FOR CLASSIFIED CONFIDENTIAL DATA!"
fi

$LOGIT ""
if [ -f /usr/bin/xhost ]; then
   xfile=`stat -t --format=%A /usr/bin/xhost | cut -c10`
   if [ $xfile == x ]; then
      $LOGIT "AD.1.5.7 : WARNING - /usr/bin/xhost is world-executable, Xserver Access control not OK."
   else
      $LOGIT "AD.1.5.7 : X-Window access control is OK and is not disabled."
   fi
else
   $LOGIT "AD.1.5.7 : WARNING - /usr/bin/xhost file does not exist. Unable to check Xserver Access control!"
fi

$LOGIT ""
X=1
for setting in chargen daytime discard echo finger systat who netstat
do
CHECK=0
if [ -f /etc/inetd.conf ]; then
   cat /etc/inetd.conf | grep -v "^#" | grep -wq "^$setting"
   if ((!$?)); then
      $LOGIT "AD.1.5.8.$X : WARNING - $setting is enabled in /etc/inetd.conf. Unable to determine if this is an internet server."
      cat /etc/inetd.conf | grep -v "^#" | grep -w "^$setting" >> $LOGFILE
      CHECK=1
   fi
fi
chkconfig --list | grep -w $setting | grep -wq "on"
if ((!$?)); then
   $LOGIT "AD.1.5.8.$X : WARNING - $setting is enabled in xinetd. Unable to determine if this is an internet server."
   chkconfig --list | grep -w $setting | grep -w "on" >> $LOGFILE
   CHECK=1
fi
if ((!$CHECK)); then
   $LOGIT "AD.1.5.8.$X : $setting is disabled on this server."
fi
((X+=1))
$LOGIT ""
done

X=1
for setting in echo chargen rstatd tftp rwalld rusersd discard daytime bootps finger sprayd pcnfsd netstat rwho cmsd dtspcd ttdbserver
do
CHECK=0
if [ -f /etc/inetd.conf ]; then
   cat /etc/inetd.conf | grep -v "^#" | grep -wq "^$setting"
   if ((!$?)); then
      $LOGIT "AD.1.5.9.$X : WARNING - $setting is enabled in /etc/inetd.conf."
      cat /etc/inetd.conf | grep -v "^#" | grep -w "^$setting" >> $LOGFILE
      CHECK=1
   fi
fi
chkconfig --list | grep -w $setting | grep -wq "on"
if ((!$?)); then
   $LOGIT "AD.1.5.9.$X : WARNING - $setting is enabled in xinetd."
   chkconfig --list | grep -w $setting | grep -w "on" >> $LOGFILE
   CHECK=1
fi
if ((!$CHECK)); then
   $LOGIT "AD.1.5.9.$X : $setting is disabled on this server."
fi
((X+=1))
$LOGIT ""
done

ps -ef | grep snmpd | grep -vq grep
if ((!$?)); then
   if [ -f /etc/snmp/snmpd.conf ]; then
      cat /etc/snmp/snmpd.conf | grep -v "^#" | grep -w "^com2sec" | egrep -w 'publicsec|notConfigUser' | grep -w default | grep -wq public
      if ((!$?)); then
         $LOGIT "AD.1.5.9.18 : WARNING - SNMP is active and community name of 'public' appears in /etc/snmp/snmpd.conf"
         cat /etc/snmp/snmpd.conf | grep -v "^#" | grep -w "^com2sec" | egrep -w 'publicsec|notConfigUser' | grep -w default | grep -w public >> $LOGFILE
      else
         $LOGIT "AD.1.5.9.18 : SNMP is active and community name of 'public' does NOT apppear in /etc/snmp/snmpd.conf."
      fi
   else
      $LOGIT "AD.1.5.9.18 : WARNING - SNMP is active and the /etc/snmp/snmpd.conf file cannot be found. By default community name of 'public' will be allowed!"
   fi
else
   $LOGIT "AD.1.5.9.18 : N/A - SNMP is not active on this server."
fi

$LOGIT ""
ps -ef | grep snmpd | grep -vq grep
if ((!$?)); then
   if [ -f /etc/snmp/snmpd.conf ]; then
      cat /etc/snmp/snmpd.conf | grep -v "^#" | grep -w "^com2sec" | egrep -w 'publicsec|notConfigUser' | grep -w default | grep -wq private
      if ((!$?)); then
         $LOGIT "AD.1.5.9.19 : WARNING - SNMP is active and community name of 'private' appears in /etc/snmp/snmpd.conf"
         cat /etc/snmp/snmpd.conf | grep -v "^#" | grep -w "^com2sec" | egrep -w 'publicsec|notConfigUser' | grep -w default | grep -w private >> $LOGFILE
      else
         $LOGIT "AD.1.5.9.19 : SNMP is active and community name of 'private' does NOT apppear in /etc/snmp/snmpd.conf."
      fi
   else
      $LOGIT "AD.1.5.9.19 : WARNING - SNMP is active and the /etc/snmp/snmpd.conf file cannot be found!"
   fi
else
   $LOGIT "AD.1.5.9.19 : N/A - SNMP is not active on this server."
fi

$LOGIT ""
if [ -f /etc/sysctl.conf ]; then
   cat /etc/sysctl.conf | grep -v "^#" | grep "net.ipv4.tcp_syncookies" | grep -q 1
   if ((!$?)); then
      $LOGIT "AD.1.5.9.20 : The paramter 'net.ipv4.tcp_syncookies = 1' exists in /etc/sysctl.conf:"
      cat /etc/sysctl.conf | grep -v "^#" | grep "net.ipv4.tcp_syncookies" | grep 1 >> $LOGFILE
   else
      $LOGIT "AD.1.5.9.20 : WARNING - The paramter 'net.ipv4.tcp_syncookies = 1' does NOT exist in /etc/sysctl.conf!"
   fi
   $LOGIT ""
   cat /etc/sysctl.conf | grep -v "^#" | grep "net.ipv4.icmp_echo_ignore_broadcasts" | grep -q 1
   if ((!$?)); then
      $LOGIT "AD.1.5.9.21 : The paramter 'net.ipv4.icmp_echo_ignore_broadcasts = 1' exists in /etc/sysctl.conf:"
      cat /etc/sysctl.conf | grep -v "^#" | grep "net.ipv4.icmp_echo_ignore_broadcasts" | grep 1 >> $LOGFILE
   else
      $LOGIT "AD.1.5.9.21 : WARNING - The paramter 'net.ipv4.icmp_echo_ignore_broadcasts = 1' does NOT exist in /etc/sysctl.conf!"
   fi
   $LOGIT ""
   cat /etc/sysctl.conf | grep -v "^#" | grep "net.ipv4.conf.all.accept_redirects" | grep -q 0
   if ((!$?)); then
      $LOGIT "AD.1.5.9.22 : The paramter 'net.ipv4.conf.all.accept_redirects = 1' exists in /etc/sysctl.conf:"
      cat /etc/sysctl.conf | grep -v "^#" | grep "net.ipv4.conf.all.accept_redirects" | grep 0 >> $LOGFILE
   else
      $LOGIT "AD.1.5.9.22 : WARNING - The paramter 'net.ipv4.conf.all.accept_redirects = 0' does NOT exist in /etc/sysctl.conf!"
   fi
else
   X=20
   until [ $X -eq 23 ]
   do
   $LOGIT "AD.1.5.9.$X : WARNING - The /etc/sysctl.conf file canNOT be found!"
   ((X+=1))
   done
fi

$LOGIT ""
TELNETFound=1
if [ -f /etc/inetd.conf ]; then
   grep -wq "^telnet" /etc/inetd.conf
   if ((!$?)); then
      TELNETFound=0
      $LOGIT "AD.1.5.9.23 : WARNING - Telnet is enabled in /etc/inetd.conf"
      grep -w "^telnet" /etc/inetd.conf >> $LOGFILE
   fi
elif [ -f /etc/xinetd.d/telnet ]; then
   cat /etc/xinetd.d/telnet | grep -v "^#" | grep -w "disable" /etc/xinetd.d/telnet | grep -qi "no"
   if ((!$?)); then
      TELNETFound=0
      $LOGIT "AD.1.5.9.23 : WARNING - Telnet is enabled in /etc/xinetd.d/telnet"
      egrep -w 'service|disable' /etc/xinetd.d/telnet >> $LOGFILE
   fi
elif (($TELNETFound)); then
   $LOGIT "AD.1.5.9.23 : N/A - Telnet is not installed on this server."
fi

$LOGIT ""
if ((!$FTPEnabled)); then
   $LOGIT "AD.1.5.9.24 : WARNING - FTP is enabled on this server!"
else
   $LOGIT "AD.1.5.9.24 : FTP is not enabled on this server."
fi

##We need to add a little blurb here since some OS (i.e. SuSE) will
##put out a bogus error I can't get rid of to the screen

if ((!$TADDMSIL)); then
   echo 1 > /tmp/isec_question_prompt
   sleep 6
   echo -e "\nDoing some service status checks now."
   echo -e "On some Linux OS, this will cause an error to display to the screen"
   echo -e "which will say \"..dead\" or similar. Please IGNORE this error"
   echo -e "as it does not impact this script or its functionality.\n"
   echo 0 > /tmp/isec_question_prompt
   sleep 5
fi



$LOGIT ""
service --status-all | grep yppasswd | grep -q "running"
if ((!$?)); then
   $LOGIT "AD.1.5.10.1 : WARNING - The yppasswd daemon is running!"
   service --status-all | grep yppasswd | grep "running" >> $LOGFILE
else
   $LOGIT "AD.1.5.10.1 : The yppasswd daemon is disabled."
fi

$LOGIT ""
rpcinfo -u `hostname` ypserv > /dev/null 2>&1
if (($?)); then
   $LOGIT "AD.1.5.10.2 : N/A - NIS is not running on this server."
else
   $LOGIT "AD.1.5.10.2 : WARNING - NIS is running on this server..."
   $LOGIT "AD.1.5.10.2 : NIS maps used to store Confidential data...THIS SCRIPT CANNOT CHECK THIS SECTION!"
fi

$LOGIT ""
rpcinfo -u `hostname` ypserv > /dev/null 2>&1
if (($?)); then
   $LOGIT "AD.1.5.11 : N/A - NIS is not running on this server."
else
   $LOGIT "AD.1.5.11 : WARNING - NIS is running on this server."
   $LOGIT "AD.1.5.11 : NIS+ maps storing confidential data...THIS SCRIPT CANNOT CHECK THIS SECTION!"
fi

$LOGIT ""
X=2
for proc in rlogin rsh sendmail
do
if [ -x /sbin/service ]; then
   service --status-all | grep $proc | grep -q "running"
   if ((!$?)); then
      echo $proc | grep -q sendmail
      if ((!$?)); then
         ps -ef | grep "sendmail" | grep -q "\-bd"
         if ((!$?)); then
            $LOGIT "AD.1.5.12.$X : The service sendmail -bd is running. Unable to determine if this is a secure internal network!"
            ps -ef | grep "sendmail" | grep "\-bd" >> $LOGFILE
         else
            $LOGIT "AD.1.5.12.$X : The service sendmail is running, but without the '-bd' option."
            ps -ef|grep "sendmail"  >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.5.12.$X : The service $proc is running. Unable to determine if this is a secure internal network!"
         service --status-all | grep $proc | grep "running" >> $LOGFILE
      fi
   elif chkconfig --list | grep $proc | grep -q on; then
      echo $proc | grep -q sendmail
      if ((!$?)); then
         ps -ef | grep "sendmail" | grep -q "\-bd"
         if ((!$?)); then
            $LOGIT "AD.1.5.12.$X : The service sendmail -bd is running. Unable to determine if this is a secure internal network!"
            ps -ef | grep "sendmail" | grep "\-bd" >> $LOGFILE
         else
            $LOGIT "AD.1.5.12.$X : The service sendmail is running, but without the '-bd' option."
            ps -ef|grep "sendmail" >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.5.12.$X : The service $proc is running. Unable to determine if this is a secure internal network!"
         chkconfig --list | grep $proc | grep on >> $LOGFILE
      fi
   else
      $LOGIT "AD.1.5.12.$X : N/A - The service $proc is not running."
   fi
else
   if chkconfig --list | grep $proc | grep -q on; then
      echo $proc | grep -q sendmail
      if ((!$?)); then
         ps -ef | grep "sendmail" | grep -q "\-bd"
         if ((!$?)); then
            $LOGIT "AD.1.5.12.$X : The service sendmail -bd is running. Unable to determine if this is a secure internal network!"
            ps -ef | grep "sendmail" | grep "\-bd" >> $LOGFILE
         else
            $LOGIT "AD.1.5.12.$X : The service sendmail is running, but without the '-bd' option."
            ps -ef|grep "sendmail" >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.5.12.$X : The service $proc is running. Unable to determine if this is a secure internal network!"
         chkconfig --list | grep $proc | grep on >> $LOGFILE
      fi
   else
      $LOGIT "AD.1.5.12.$X : N/A - The service $proc is not running."
   fi
fi
$LOGIT ""
((X+=1))
done

$LOGIT ""
$LOGIT ""
#$LOGIT "1.8.x Protecting Resources - OSR's"
#$LOGIT "=================================="

$LOGIT ""
if [ -f ~root/.rhosts ]; then
   OWNER=`ls -al ~root/.rhosts | awk '{print $3}'`
   PERMS=`ls -al ~root/.rhosts | awk '{print $1}' | cut -c5,6,8,9`
   if [[ $OWNER = "root" ]] && [[ $PERMS = "----" ]]; then
      $LOGIT "AD.1.8.2.1 : The ~root/.rhosts file is owned by user root and resticted to read/write only by user root."
   else
      $LOGIT "AD.1.8.2.1 : WARNING - The ~root/.rhosts file is not restricted to read/write by only user root!"
   fi
   ls -al ~root/.rhosts >> $LOGFILE
else
   $LOGIT "AD.1.8.2.1 : N/A - The ~root/.rhosts file does not exist."
fi

$LOGIT ""
if [ -f ~root/.netrc ]; then
   OWNER=`ls -al ~root/.netrc | awk '{print $3}'`
   PERMS=`ls -al ~root/.netrc | awk '{print $1}' | cut -c5,6,8,9`
   if [[ $OWNER = "root" ]] && [[ $PERMS = "----" ]]; then
      $LOGIT "AD.1.8.2.2 : The ~root/.netrc file is owned by user root and resticted to read/write only by user root."
   else
      $LOGIT "AD.1.8.2.2 : WARNING - The ~root/.netrc file is not restricted to read/write by only user root!"
   fi
   ls -al ~root/.netrc >> $LOGFILE
else
   $LOGIT "AD.1.8.2.2 : N/A - The ~root/.netrc file does not exist."
fi

$LOGIT ""
X=1
for dir in / /usr /etc
do
PERMS=`ls -ald $dir | awk '{print $1}' | cut -c9`
if [ $PERMS != "-" ]; then
   $LOGIT "AD.1.8.3.$X : WARNING - Setting for other on directory $dir is not r-x or more restrictive!"
else
   $LOGIT "AD.1.8.3.$X : Setting for other on directory $dir is r-x or more restrictive."
fi
ls -ald $dir >> $LOGFILE
$LOGIT ""
((X+=1))
done

if [ -f /etc/security/opasswd ]; then
   PERMS=`ls -ald /etc/security/opasswd | awk '{print $1}' | cut -c4-10`
   if [ $PERMS != "-------" ]; then
      $LOGIT "AD.1.8.4.1 : WARNING - Permissions on /etc/security/opasswd are not *rw------- or more restrictive:"
   else
      $LOGIT "AD.1.8.4.1 : Permissions on /etc/security/opasswd are *rw------- or more restrictive:"
   fi
   ls -ald /etc/security/opasswd >> $LOGFILE
else
   $LOGIT "AD.1.8.4.1 : WARNING - The /etc/security/opasswd file does NOT exist!"
fi

$LOGIT ""
if [ -f /etc/shadow ]; then
   PERMS=`ls -ald /etc/shadow | awk '{print $1}' | cut -c4-10`
   GROUPname=`ls -ald /etc/shadow | awk '{print $4}'`
   if [ $PERMS = "-------" ]; then
      $LOGIT "AD.1.8.4.2 : Permissions on /etc/shadow are *rw------- or more restrictive:"
   elif [ $PERMS = "-r-----" ]; then
      grep -q "^$GROUPname:" /etc/group
      if ((!$?)); then
         GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
         if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
            if [[ $GROUPid -le 99 ]] || [[ $GROUPid -ge 101 && $GROUPid -le 199 ]]; then
               $LOGIT "AD.1.8.4.2 : Permissions on /etc/shadow allows read access by group and the associated group has GID <= 99 or GID >= 101 and <= 199:"
            else
               $LOGIT "AD.1.8.4.2 : WARNING - Permissions on /etc/shadow allows read access by group and the associated group does NOT have GID <= 99 or GID >= 101 and <= 199:"
            fi
         else
            if [ $GROUPid -le 99 ]; then
               $LOGIT "AD.1.8.4.2 : Permissions on /etc/shadow allows read access by group and the associated group has GID <= 99:"
            else
               $LOGIT "AD.1.8.4.2 : WARNING - Permissions on /etc/shadow allows read access by group and the associated group does NOT have GID <= 99:"
            fi
         fi
      else
         $LOGIT "AD.1.8.4.2 : WARNING - Permissions on /etc/shadow allows read access by group and the associated group has an unknown GID!"
      fi
   else
      $LOGIT "AD.1.8.4.2 : WARNING - Permissions on /etc/shadow are NOT *rw------- or more restrictive:"
   fi
   ls -ald /etc/shadow >> $LOGFILE
else
   $LOGIT "AD.1.8.4.2 : WARNING - The /etc/shadow file does NOT exist!"
fi

$LOGIT ""
PERMS=`ls -ald /var | awk '{print $1}' | cut -c9`
if [ $PERMS != "-" ]; then
   $LOGIT "AD.1.8.5.1 : WARNING - Setting for other on directory /var is not r-x or more restrictive!"
else
   $LOGIT "AD.1.8.5.1 : Setting for other on directory /var is r-x or more restrictive."
fi
ls -ald /var >> $LOGFILE

$LOGIT ""
PERMS=`ls -ald /var/log | awk '{print $1}' | cut -c9`
if [ $PERMS != "-" ]; then
   $LOGIT "AD.1.8.5.2 : WARNING - Setting for other on directory /var/log is not r-x or more restrictive!"
else
   $LOGIT "AD.1.8.5.2 : Setting for other on directory /var/log is r-x or more restrictive."
fi
ls -ald /var/log >> $LOGFILE
cat /dev/null > AD1852_temp
for dir in `ls -al /var/log | grep "^d" | awk '{print $9}'`
do
if [[ $dir != "." ]] && [[ $dir != ".." ]]; then
   PERMSall=`ls -ald /var/log/$dir | awk '{print $1}' | cut -c2-10`
   PERMS=`ls -ald /var/log/$dir | awk '{print $1}' | cut -c9`
   if [[ $PERMS != "-" ]] && [[ $PERMSall != "rwxrwxrwx" ]]; then
      ls -ald /var/log/$dir >> AD1852_temp
   fi
fi
done
if [ -s AD1852_temp ]; then
   $LOGIT "AD.1.8.5.2 : WARNING - Subdirectories of /var/log exist that are world writable and are not set to 1777:"
   cat AD1852_temp >> $LOGFILE
else
   $LOGIT "AD.1.8.5.2 : All subdirectories of /var/log are either not world writable or set to 1777."
fi
rm -rf AD1852_temp

$LOGIT ""
if [ -f /etc/pam.d/system-auth ]; then
   egrep "^account|^auth" /etc/pam.d/system-auth | grep "required" | grep "pam_tally2.so" > /dev/null 2>&1
   if ((!$?)); then
      TALLY2=0
   fi
fi
if (($TALLY2)); then
   if [ -f /var/log/faillog ]; then
      PERMS=`ls -ald /var/log/faillog | awk '{print $1}' | cut -c4-10`
      if [ $PERMS != "-------" ]; then
         $LOGIT "AD.1.8.6.1 : WARNING - Permissions on /var/log/faillog are not *rw------- or more restrictive:"
      else
         $LOGIT "AD.1.8.6.1 : Permissions on /var/log/faillog are *rw------- or more restrictive:"
      fi
      ls -ald /var/log/faillog >> $LOGFILE
   else
      $LOGIT "AD.1.8.6.1 : WARNING - The file /var/log/faillog does NOT exist!"
   fi
else
   $LOGIT "AD.1.8.6.1 : N/A - This system is using the pam_tally2.so parameter in /etc/pam.d/system-auth"
fi

$LOGIT ""
if ((!$TALLY2)); then
   if [ -f /var/log/tallylog ]; then
      PERMS=`ls -ald /var/log/tallylog | awk '{print $1}' | cut -c4-10`
      if [ $PERMS != "-------" ]; then
         $LOGIT "AD.1.8.6.2 : WARNING - Permissions on /var/log/tallylog are not *rw------- or more restrictive:"
      else
         $LOGIT "AD.1.8.6.2 : Permissions on /var/log/tallylog are *rw------- or more restrictive:"
      fi
      ls -ald /var/log/tallylog >> $LOGFILE
   else
      $LOGIT "AD.1.8.6.2 : WARNING - The file /var/log/tallylog does NOT exist!"
   fi
else
   $LOGIT "AD.1.8.6.2 : N/A - This system is not using the pam_tally2.so parameter in /etc/pam.d/system-auth"
fi

$LOGIT ""
X=1
for file in /var/log/messages /var/log/wtmp
do
if [ -f $file ]; then
   PERMS=`ls -ald $file | awk '{print $1}' | cut -c6,9`
   if [ $PERMS != "--" ]; then
      $LOGIT "AD.1.8.7.$X : WARNING - Permissions on $file are not set to *rwxr-xr-x or more restrictive:"
   else
      $LOGIT "AD.1.8.7.$X : Permissions on $file are set to *rwxr-xr-x or more restrictive:"
   fi
   ls -ald $file >> $LOGFILE
else
   $LOGIT "AD.1.8.7.$X : WARNING - The file $file does NOT exist!"
fi
((X+=1))
$LOGIT ""
done

if [ -f /var/log/secure ]; then
   PERMS=`ls -ald /var/log/secure | awk '{print $1}' | cut -c6,8-10`
   if [ $PERMS != "----" ]; then
      $LOGIT "AD.1.8.8 : WARNING - Permissions on /var/log/secure are not set to *rwxr-x--- or more restrictive:"
   else
      $LOGIT "AD.1.8.8 : Permissions on /var/log/secure are set to *rwxr-x--- or more restrictive:"
   fi
   ls -ald /var/log/secure >> $LOGFILE
elif [ -f /var/log/auth.log ]; then
   PERMS=`ls -ald /var/log/auth.log | awk '{print $1}' | cut -c6,8-10`
   if [ $PERMS != "----" ]; then
      $LOGIT "AD.1.8.8 : WARNING - Permissions on /var/log/auth.log are not set to *rwxr-x--- or more restrictive:"
   else
      $LOGIT "AD.1.8.8 : Permissions on /var/log/auth.log are set to *rwxr-x--- or more restrictive:"
   fi
   ls -ald /var/log/auth.log >> $LOGFILE
else
   $LOGIT "AD.1.8.8 : WARNING - Niether the /var/log/secure nor /var/log/auth.log files exist!"
fi

$LOGIT ""
PERMS=`ls -ald /tmp | awk '{print $1}' | cut -c1-10`
if [ $PERMS != "drwxrwxrwt" ]; then
   $LOGIT "AD.1.8.9 : WARNING - The permissions on /tmp are not set to drwxrwxrwt"
else
   $LOGIT "AD.1.8.9 : The permissions on /tmp are set to drwxrwxrwt"
fi
ls -ald /tmp >> $LOGFILE

$LOGIT ""
if [ -f /etc/snmpd.conf ]; then
   PERMS=`ls -al /etc/snmpd.conf | awk '{print $1}' | cut -c1,4,6-10`
   if [ $PERMS != "-------" ]; then
      $LOGIT "AD.1.8.10 : WARNING - The /etc/snmpd.conf file is not set to 0640 permissions:"
   else
      $LOGIT "AD.1.8.10 : The /etc/snmpd.conf file is set to 0640 permissions:"
   fi
   ls -al /etc/snmpd.conf >> $LOGFILE
elif [ -f /etc/snmp/snmpd.conf ]; then
   PERMS=`ls -al /etc/snmp/snmpd.conf | awk '{print $1}' | cut -c1,4,6-10`
   if [ $PERMS != "-------" ]; then
      $LOGIT "AD.1.8.10 : WARNING - The /etc/snmp/snmpd.conf file is not set to 0640 permissions:"
   else
      $LOGIT "AD.1.8.10 : The /etc/snmp/snmpd.conf file is set to 0640 permissions:"
   fi
   ls -al /etc/snmp/snmpd.conf >> $LOGFILE
elif [ -f /etc/snmpd/snmpd.conf ]; then
   PERMS=`ls -al /etc/snmpd/snmpd.conf | awk '{print $1}' | cut -c1,4,6-10`
   if [ $PERMS != "-------" ]; then
      $LOGIT "AD.1.8.10 : WARNING - The /etc/snmpd/snmpd.conf file is not set to 0640 permissions:"
   else
      $LOGIT "AD.1.8.10 : The /etc/snmpd/snmpd.conf file is set to 0640 permissions:"
   fi
   ls -al /etc/snmpd/snmpd.conf >> $LOGFILE
else
   $LOGIT "AD.1.8.10 : N/A - The snmpd.conf file does not exist."
fi

$LOGIT ""
if [ -d /var/tmp ]; then
   PERMS=`ls -ald /var/tmp | awk '{print $1}' | cut -c1-10`
   if [ $PERMS != "drwxrwxrwt" ]; then
      $LOGIT "AD.1.8.11 : WARNING - The /var/tmp directory is not set to 1777 permissions:"
   else
      $LOGIT "AD.1.8.11 : The /var/tmp directory is set to 1777 permissions:"
   fi
   ls -ald /var/tmp >> $LOGFILE
else
   $LOGIT "AD.1.8.11 : The /var/tmp directory does not exist on this server."
fi

$LOGIT ""
if (($TALLY2)); then
   if [ -f /var/log/faillog ]; then
      PERM=`ls -ald /var/log/faillog | awk '{print $1}' | cut -c6`
      GROUPname=`ls -ald /var/log/faillog | awk '{print $4}'`
      if [ $PERM = "w" ]; then
         grep -q "^$GROUPname:" /etc/group
         if ((!$?)); then
            GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
            if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
               if [[ $GROUPid -le 99 ]] || [[ $GROUPid -ge 101 && $GROUPid -le 199 ]]; then
                  $LOGIT "AD.1.8.12.1.1 : Permissions on /var/log/faillog allows write access by group and the associated group has GID <= 99 or GID >= 101 and <= 199:"
               else
                  $LOGIT "AD.1.8.12.1.1 : WARNING - Permissions on /var/log/faillog allows write access by group and the associated group does NOT have GID <= 99 or GID >= 101 and <= 199:"
               fi
            else
               if [ $GROUPid -le 99 ]; then
                  $LOGIT "AD.1.8.12.1.1 : Permissions on /var/log/faillog allows write access by group and the associated group has GID <= 99:"
               else
                  $LOGIT "AD.1.8.12.1.1 : WARNING - Permissions on /var/log/faillog allows write access by group and the associated group does NOT have GID <= 99:"
               fi
            fi
         else
            $LOGIT "AD.1.8.12.1.1 : WARNING - Permissions on /var/log/faillog allows write access by group and the associated group has an unknown GID!"
         fi
      else
         $LOGIT "AD.1.8.12.1.1 : Write access is not allowed for group for file /var/log/faillog"
      fi
      ls -ald /var/log/faillog >> $LOGFILE
   else
      $LOGIT "AD.1.8.12.1.1 : WARNING - The log file /var/log/faillog does NOT exist!"
   fi
else
   $LOGIT "AD.1.8.12.1.1 : N/A - This system uses the pam_tally2.so parameter."
fi

$LOGIT ""
if (($TALLY2)); then
   if [ -f /var/log/tallylog ]; then
      PERM=`ls -ald /var/log/tallylog | awk '{print $1}' | cut -c6`
      GROUPname=`ls -ald /var/log/tallylog | awk '{print $4}'`
      if [ $PERM = "w" ]; then
         grep -q "^$GROUPname:" /etc/group
         if ((!$?)); then
            GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
            if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
               if [[ $GROUPid -le 99 ]] || [[ $GROUPid -ge 101 && $GROUPid -le 199 ]]; then
                  $LOGIT "AD.1.8.12.1.2 : Permissions on /var/log/tallylog allows write access by group and the associated group has GID <= 99 or GID >= 101 and <= 199:"
               else
                  $LOGIT "AD.1.8.12.1.2 : WARNING - Permissions on /var/log/tallylog allows write access by group and the associated group does NOT have GID <= 99 or GID >= 101 and <= 199:"
               fi
            else
               if [ $GROUPid -le 99 ]; then
                  $LOGIT "AD.1.8.12.1.2 : Permissions on /var/log/tallylog allows write access by group and the associated group has GID <= 99:"
               else
                  $LOGIT "AD.1.8.12.1.2 : WARNING - Permissions on /var/log/tallylog allows write access by group and the associated group does NOT have GID <= 99:"
               fi
            fi
         else
            $LOGIT "AD.1.8.12.1.2 : WARNING - Permissions on /var/log/tallylog allows write access by group and the associated group has an unknown GID!"
         fi
      else
         $LOGIT "AD.1.8.12.1.2 : Write access is not allowed for group for file /var/log/tallylog"
      fi
      ls -ald /var/log/tallylog >> $LOGFILE
   else
      $LOGIT "AD.1.8.12.1.2 : WARNING - The log file /var/log/tallylog does NOT exist!"
   fi
else
   $LOGIT "AD.1.8.12.1.2 : N/A - This system does not use the pam_tally2.so parameter."
fi

$LOGIT ""
X=2
for file in /var/log/messages /var/log/wtmp /var/log/secure /var/log/auth.log
do
if [ -f $file ]; then
   PERM=`ls -ald $file | awk '{print $1}' | cut -c6`
   GROUPname=`ls -ald $file | awk '{print $4}'`
   if [ $PERM = "w" ]; then
      grep -q "^$GROUPname:" /etc/group
      if ((!$?)); then
         GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
         if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
            if [[ $GROUPid -le 99 ]] || [[ $GROUPid -ge 101 && $GROUPid -le 199 ]]; then
               $LOGIT "AD.1.8.12.$X : Permissions on $file allows write access by group and the associated group has GID <= 99 or GID >= 101 and <= 199:"
            else
               $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file allows write access by group and the associated group does NOT have GID <= 99 or GID >= 101 and <= 199:"
            fi
         else
            if [ $GROUPid -le 99 ]; then
               $LOGIT "AD.1.8.12.$X : Permissions on $file allows write access by group and the associated group has GID <= 99:"
            else
               $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file allows write access by group and the associated group does NOT have GID <= 99:"
            fi
         fi
      else
         $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file allows write access by group and the associated group has an unknown GID!"
      fi
   else
      $LOGIT "AD.1.8.12.$X : Write access is not allowed for group for file $file"
   fi
   ls -ald $file >> $LOGFILE
else
   $LOGIT "AD.1.8.12.$X : WARNING - The log file $file does NOT exist!"
fi
((X+=1))
$LOGIT ""
done

X=6
for file in /etc/profile.d/IBMsinit.sh /etc/profile.d/IBMsinit.csh
do
if [ -f $file ]; then
   PERM=`ls -ald $file | awk '{print $1}' | cut -c6`
   GROUPname=`ls -ald $file | awk '{print $4}'`
   if [ $PERM = "w" ]; then
      grep -q "^$GROUPname:" /etc/group
      if ((!$?)); then
         GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
         if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
            if [[ $GROUPid -le 99 ]] || [[ $GROUPid -ge 101 && $GROUPid -le 199 ]]; then
               $LOGIT "AD.1.8.12.$X : Permissions on $file allows write access by group and the associated group has GID <= 99 or GID >= 101 and <= 199:"
            else
               $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file allows write access by group and the associated group does NOT have GID <= 99 or GID >= 101 and <= 199:"
            fi
         else
            if [ $GROUPid -le 99 ]; then
               $LOGIT "AD.1.8.12.$X : Permissions on $file allows write access by group and the associated group has GID <= 99:"
            else
               $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file allows write access by group and the associated group does NOT have GID <= 99:"
            fi
         fi
      else
         $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file allows write access by group and the associated group has an unknown GID!"
      fi
   else
      $LOGIT "AD.1.8.12.$X : Write access is not allowed for group for file $file"
   fi
   PERM=`ls -ald $file | awk '{print $1}' | cut -c5,7`
   if [ $PERM != "rx" ]; then
      $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file are not set to r-x or acceptable rwx for group:"
   else
      $LOGIT "AD.1.8.12.$X : Permissions on $file are set to r-x or acceptable rwx for group."
   fi
   PERM=`ls -ald $file | awk '{print $1}' | cut -c8-10`
   if [ $PERM != "r-x" ]; then
      $LOGIT "AD.1.8.12.$X : WARNING - Permissions on $file are not set to r-x for other:"
   else
      $LOGIT "AD.1.8.12.$X : Permissions on $file are set to r-x for other:"
   fi
   ls -ald $file >> $LOGFILE
else
   $LOGIT "AD.1.8.12.$X : WARNING - The file $file does NOT exist!"
fi
((X+=1))
$LOGIT ""
done

cat /dev/null > AD1813_temp
cat /etc/inittab | grep -v "^#" | awk -F':' '{print $4}' | awk '{print $1}' > AD1813_temp
##Remove any duplicate entries, which are common in inittab
cat AD1813_temp | awk '! a[$0]++' > AD1813a_temp
rm -rf AD1813_temp
cat /dev/null > AD18132_temp
for entry in `cat AD1813a_temp`
do
echo $entry | grep "/" > /dev/null 2>&1
if (($?)); then
   echo $entry >> AD18132_temp
fi
done
if [ -s AD18132_temp ]; then
   $LOGIT "AD.1.8.13.2 : WARNING - Some entry(ies) exist in /etc/inittab that do not appear to contain the full path:"
   cat AD18132_temp >> $LOGFILE
else
   $LOGIT "AD.1.8.13.2 : All entry(ies) in /etc/inittab appear to contain the full path of waht is being executed."
fi
rm -rf AD18132_temp

$LOGIT ""
cat /dev/null > AD18133_temp
for entry in `cat AD1813a_temp`
do
if [ -e $entry ]; then
   PERM=`ls -ald $entry | awk '{print $1}' | cut -c9`
   if [ $PERM != "-" ]; then
      echo "The file being executed has an incorrect permission setting."  >> AD18133_temp
      echo "The file being checked was: $entry" >> AD18133_temp
      ls -ald $entry >> AD18133_temp
      echo "" >> AD18133_temp
   fi
fi
entryA=$entry
until [ `basename $entry` = "/" ]
do
entry=`dirname $entry`
if [[ ! -L $entry ]] && [[ -e $entry ]]; then
   PERM=`ls -ald $entry | awk '{print $1}' | cut -c9`
   if [ $PERM != "-" ]; then
      echo "The path for $entryA has an incorrect permission setting." >> AD18133_temp
      echo "The line being checked was: $entry" >> AD18133_temp
      ls -ald $entry >> AD18133_temp
      echo "" >> AD18133_temp
   fi
fi
done
done
if [ -s AD18133_temp ]; then
   $LOGIT "AD.1.8.13.3 : WARNING - Entry(ies) exist in /etc/inittab that have incorrect"
   $LOGIT "setttings for 'other' and are not set to r-x or more stringent:"
   cat AD18133_temp >> $LOGFILE
else
   $LOGIT "AD.1.8.13.3 : All active entry(ies) & all existing directories in their path"
   $LOGIT "AD.1.8.13.3 : have settings for 'other' set to r-x or more stringent."
fi
rm -rf AD18133_temp

$LOGIT ""
cat /dev/null > AD18134_temp
for entry in `cat AD1813a_temp`
do
if [ -e $entry ]; then
   PERM=`ls -ald $entry | awk '{print $1}' | cut -c9`
   GROUPname=`ls -ald $entry | awk '{print $4}'`
   if [ $PERM != "-" ]; then
      grep -q "^$GROUPname:" /etc/group
      if ((!$?)); then
         GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
      else
         GROUPid=999
      fi
      if [ $GROUPid -gt 99 ]; then
         echo "The file being executed has an incorrect permission and/or group setting."  >> AD18134_temp
         echo "The file being checked was: $entry" >> AD18134_temp
         ls -ald $entry >> AD18134_temp
         echo "" >> AD18134_temp
      fi
   fi
fi
entryA=$entry
until [ `basename $entry` = "/" ]
do
entry=`dirname $entry`
if [[ ! -L $entry ]] && [[ -e $entry ]]; then
   PERM=`ls -ald $entry | awk '{print $1}' | cut -c9`
   GROUPname=`ls -ald $entry | awk '{print $4}'`
   if [ $PERM != "-" ]; then
      grep -q "^$GROUPname:" /etc/group
      if ((!$?)); then
         GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
      else
         GROUPid=999
      fi
      if [ $GROUPid -gt 99 ]; then
         echo "The path for $entryA has an incorrect permission and/or group setting." >> AD18134_temp
         echo "The line being checked was: $entry" >> AD18134_temp
         ls -ald $entry >> AD18134_temp
         echo "" >> AD18134_temp
      fi
   fi
fi
done
done
if [ -s AD18134_temp ]; then
   $LOGIT "AD.1.8.13.4 : WARNING - Entry(ies) exist in /etc/inittab that have incorrect setttings for 'group'"
   $LOGIT "AD.1.8.13.4 : and are not set to r-x or more stringent and owned by GID > 99:"
   cat AD18134_temp >> $LOGFILE
else
   $LOGIT "AD.1.8.13.4 : All active entry(ies) & all existing directories in their path"
   $LOGIT "AD.1.8.13.4 : have settings for 'group' set to r-x or more stringent or owned by GID <= 99."
fi
rm -rf AD18134_temp AD1813a_temp

$LOGIT ""
#Examining the cron file is very complex given the huge number of ways
#the script/command can be configured in crontab (i.e. nohup, /usr/bin/su <command>, etc, etc).
#I will do my best to take it in steps and parse out what I can. The user may
#have to manually examine some entries, depending on the results, and I 
#will do do my best to aid in the manual checks if they are necessary.
$LOGIT ""
CrontabExists=0
CRON=/var/spool/cron/root
if [ -f $CRON ]; then
   cat $CRON | grep -v "^#" > OSRCronClean #gives ACTIVE cron entries
   cat OSRCronClean | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
   X=1 #First line to start checking
   cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
   for line in `cat OSRCronToCheck`
   do
   echo $line | grep "/" > /dev/null 2>&1
   if (($?)); then
      echo "The line being checked was:" >> OSRCronResult
      cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
      echo "The script attempted to check: $line" >> OSRCronResult
      echo "" >> OSRCronResult
   fi
   ((X+=1))
   done
   if [ -s OSRCronResult ]; then
      $LOGIT "AD.1.8.14.1 : WARNING - At least one active entry was found in root crontab that"
      $LOGIT "does not appear to specify the full path!"
      $LOGIT "Please review the results below and check for any false positives:"
      cat OSRCronResult >> $LOGFILE
      $LOGIT ""
      $LOGIT "!!! WARNING - THE ABOVE ENTRIES WILL NOT BE CHECKED IN THE NEXT TWO SECTIONS !!!"
      $LOGIT ""
   else
      $LOGIT "AD.1.8.14.1 : All active entry in root crontab specify the full path of the file/command/script to be executed."
   fi
else
   $LOGIT "AD.1.8.14.1 : N/A - There is no root crontab entry on this server."
   CrontabExists=1
fi

$LOGIT ""
if ((!$CrontabExists)); then
   cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
   X=1 #First line to start checking
   for line in `cat OSRCronToCheck`
   do
   if [ -e $line ]; then
      FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
      if [ $FILEPerm != "-" ]; then
         echo "The line being checked was:" >> OSRCronResult
         cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
         echo "The script attempted to check: $line" >> OSRCronResult
         ls -ald $line >> OSRCronResult
         echo "" >> OSRCronResult
      fi
   fi
   lineA=$line
   echo $line | grep "^/" > /dev/null 2>&1
   if ((!$?)); then
      until [ `basename $line` = "/" ]
      do
      line=`dirname $line`
      if [ ! -L $line ] && [ -e $line ]; then
         FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
         if [ $FILEPerm != "-" ]; then
            echo "The path for $lineA has an incorrect setting" >> OSRCronResult
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line" >> OSRCronResult
            ls -ald $line >> OSRCronResult
            echo "" >> OSRCronResult
         fi
      fi
      done
   fi
   ((X+=1))
   done
   if [ -s OSRCronResult ]; then
      $LOGIT "AD.1.8.14.2 : WARNING - An entry in root crontab has an incorrect setting for other:"
      cat OSRCronResult >> $LOGFILE
   else
      $LOGIT "AD.1.8.14.2 : All active & valid entries in root crontab have correct settings for other."
   fi
else
   $LOGIT "AD.1.8.14.2 : N/A - There is no crontab file for root."
fi

$LOGIT ""
if ((!$CrontabExists)); then
   cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
   X=1 #First line to start checking
   for line in `cat OSRCronToCheck`
   do
   if [ -e $line ]; then
      FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
      GROUPname=`ls -ald $line | awk '{print $4}'`
      if [ $FILEPerm != "-" ]; then
         grep -q "^$GROUPname:" /etc/group
         if ((!$?)); then
            GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
         else
            GROUPid=999
         fi
         if [ $GROUPid -gt 99 ]; then
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line" >> OSRCronResult
            ls -ald $line >> OSRCronResult
            echo "" >> OSRCronResult
         fi
      fi
   fi
   lineA=$line
   echo $line | grep "^/" > /dev/null 2>&1
   if ((!$?)); then
      until [ `basename $line` = "/" ]
      do
      line=`dirname $line`
      if [ ! -L $line ] && [ -e $line ]; then
         FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
         GROUPname=`ls -ald $line | awk '{print $4}'`
         if [ $FILEPerm != "-" ]; then
            grep -q "^$GROUPname:" /etc/group
            if ((!$?)); then
               GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
            else
               GROUPid=999
            fi
            if [ $GROUPid -gt 99 ]; then
               echo "The path for $lineA has an incorrect setting" >> OSRCronResult
               echo "The line being checked was:" >> OSRCronResult
               cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
               echo "The script attempted to check: $line" >> OSRCronResult
               ls -ald $line >> OSRCronResult
               echo "" >> OSRCronResult
            fi
         fi
      fi
      done
   fi
   ((X+=1))
   done
   if [ -s OSRCronResult ]; then
      $LOGIT "AD.1.8.14.3 : WARNING - An entry in root crontab has an incorrect setting and/or owner for group:"
      cat OSRCronResult >> $LOGFILE
   else
      $LOGIT "AD.1.8.14.3 : All active entries in root crontab have correct settings and/or owner for group."
   fi
else
   $LOGIT "AD.1.8.14.3 : N/A - There is no crontab for root."
fi

#Clean up our mess:
rm -rf OSRCronClean OSRCronResult OSRCronToCheck

$LOGIT ""
#Examining the /etc/crontab file is very complex given the huge number of ways
#the script/command can be configured in crontab (i.e. run-parts, /usr/bin/su <command>, etc, etc).
#I will do my best to take it in steps and parse out what I can. The user may
#have to manually examine some entries, depending on the results, and I 
#will do do my best to aid in the manual checks if they are necessary.
$LOGIT ""
CrontabExists=0
CRON=/etc/crontab
if [ -f $CRON ]; then
   if [ $OSFlavor = "SuSE" ] && [ $SVER -ge 11 ]; then
      cat $CRON | LANG=en_US.UTF-8 egrep -v '^#|^[a-Z]' | grep -wv "run-parts" > OSRCronPartlyClean #gives ACTIVE cron entries
      grep '.' OSRCronPartlyClean > OSRCronClean #remove any blank lines
      rm -rf OSRCronPartlyClean
      cat $CRON | LANG=en_US.UTF-8 egrep -v '^#|^[a-Z]' | grep "run-parts" > OSRCronPartlyClean.run-parts #gives ACTIVE directories
      grep '.' OSRCronPartlyClean.run-parts > OSRCronClean.run-parts #remove any blank lines
      rm -rf OSRCronPartlyClean.run-parts
   else
      cat $CRON | egrep -v '^#|^[a-Z]' | grep -wv "run-parts" > OSRCronPartlyClean #gives ACTIVE cron entries
      grep '.' OSRCronPartlyClean > OSRCronClean #remove any blank lines
      rm -rf OSRCronPartlyClean
      cat $CRON | egrep -v '^#|^[a-Z]' | grep "run-parts" > OSRCronPartlyClean.run-parts #gives ACTIVE directories
      grep '.' OSRCronPartlyClean.run-parts > OSRCronClean.run-parts #remove any blank lines
      rm -rf OSRCronPartlyClean.run-parts
   fi
   cat OSRCronClean.run-parts | awk '{print substr($0, index($0,$8)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck.run-parts #gives the potential directories to check
   cat OSRCronClean | grep -v "run-parts" | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
   X=1 #First line to start checking
   cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
   for line in `cat OSRCronToCheck`
   do
   echo $line | grep "/" > /dev/null 2>&1
   if (($?)); then
      echo "The line being checked was:" >> OSRCronResult
      cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
      echo "The script attempted to check: $line" >> OSRCronResult
      echo "" >> OSRCronResult
   fi
   ((X+=1))
   done
   X=1 #First line to start checking
   for line in `cat OSRCronToCheck.run-parts`
   do
   echo $line | grep "/" > /dev/null 2>&1
   if (($?)); then
      echo "The line being checked was:" >> OSRCronResult
      cat OSRCronClean.run-parts | awk -v XX=$X 'NR==XX' >> OSRCronResult
      echo "The script attempted to check: $line" >> OSRCronResult
      echo "" >> OSRCronResult
   fi
   ((X+=1))
   done
   if [ -s OSRCronResult ]; then
      $LOGIT "AD.1.8.15.1 : WARNING - At least one active entry was found in /etc/crontab that"
      $LOGIT "does not appear to specify the full path!"
      $LOGIT "Please review the results below and check for any false positives:"
      cat OSRCronResult >> $LOGFILE
      $LOGIT ""
      $LOGIT "!!! WARNING - THE ABOVE ENTRIES WILL NOT BE CHECKED IN THE NEXT TWO SECTIONS !!!"
      $LOGIT ""
   else
      $LOGIT "AD.1.8.15.1 : All active entry in /etc/crontab specify the full path of the file/command/script to be executed."
   fi
else
   $LOGIT "AD.1.8.15.1 : N/A - There is no /etc/crontab file on this server."
   CrontabExists=1
fi

if ((!$CrontabExists)); then
   $LOGIT ""
   cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
   X=1 #First line to start checking
   for line in `cat OSRCronToCheck`
   do
   if [ -e $line ]; then
      FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
      if [ $FILEPerm != "-" ]; then
         echo "The line being checked was:" >> OSRCronResult
         cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
         echo "The script attempted to check: $line" >> OSRCronResult
         ls -ald $line >> OSRCronResult
         echo "" >> OSRCronResult
      fi
   fi
   lineA=$line
   echo $line | grep "^/" > /dev/null 2>&1
   if ((!$?)); then
      until [ `basename $line` = "/" ]
      do
      line=`dirname $line`
      if [ ! -L $line ] && [ -e $line ]; then
         FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
         if [ $FILEPerm != "-" ]; then
            echo "The path for $lineA has an incorrect setting" >> OSRCronResult
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line" >> OSRCronResult
            ls -ald $line >> OSRCronResult
            echo "" >> OSRCronResult
         fi
      fi
      done
   fi
   ((X+=1))
   done
   X=1 #First line to start checking
   for line in `cat OSRCronToCheck.run-parts`
   do
   if [ -d $line ]; then
      for script in `ls -al $line | grep "^-" | awk '{print $9}'`
      do
      FILEPerm=`ls -ald $line/$script | awk '{print $1}' | cut -c9`
      if [ $FILEPerm != "-" ]; then
         echo "The line being checked was:" >> OSRCronResult
         cat OSRCronClean.run-parts | awk -v XX=$X 'NR==XX' >> OSRCronResult
         echo "The script attempted to check: $line/$script" >> OSRCronResult
         ls -ald $line/$script >> OSRCronResult
         echo "" >> OSRCronResult
      fi
      done
   fi
   lineA=$line
   line=$line/place_holder
   echo $line | grep "^/" > /dev/null 2>&1
   if ((!$?)); then
      until [ `basename $line` = "/" ]
      do
      line=`dirname $line`
      if [ ! -L $line ] && [ -e $line ]; then
         FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
         if [ $FILEPerm != "-" ]; then
            echo "The path for $lineA has an incorrect setting" >> OSRCronResult
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean.run-parts | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line" >> OSRCronResult
            ls -ald $line >> OSRCronResult
            echo "" >> OSRCronResult
         fi
      fi
      done
   fi
   ((X+=1))
   done
   if [ -s OSRCronResult ]; then
      $LOGIT "AD.1.8.15.2 : WARNING - An entry in /etc/crontab has an incorrect setting for other:"
      cat OSRCronResult >> $LOGFILE
   else
      $LOGIT "AD.1.8.15.2 : All active & valid entries in /etc/crontab have correct settings for other."
   fi
else
   $LOGIT "AD.1.8.15.2 : N/A - There is no /etc/crontab file on this server."
fi

if ((!$CrontabExists)); then
   $LOGIT ""
   cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
   X=1 #First line to start checking
   for line in `cat OSRCronToCheck`
   do
   if [ -e $line ]; then
      FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
      GROUPname=`ls -ald $line | awk '{print $4}'`
      if [ $FILEPerm != "-" ]; then
         grep -q "^$GROUPname:" /etc/group
         if ((!$?)); then
            GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
         else
            GROUPid=999
         fi
         if [ $GROUPid -gt 99 ]; then
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line" >> OSRCronResult
            ls -ald $line >> OSRCronResult
            echo "" >> OSRCronResult
         fi
      fi
   fi
   lineA=$line
   echo $line | grep "^/" > /dev/null 2>&1
   if ((!$?)); then
      until [ `basename $line` = "/" ]
      do
      line=`dirname $line`
      if [ ! -L $line ] && [ -e $line ]; then
         FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
         GROUPname=`ls -ald $line | awk '{print $4}'`
         if [ $FILEPerm != "-" ]; then
            grep -q "^$GROUPname:" /etc/group
            if ((!$?)); then
               GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
            else
               GROUPid=999
            fi
            if [ $GROUPid -gt 99 ]; then
               echo "The path for $lineA has an incorrect setting" >> OSRCronResult
               echo "The line being checked was:" >> OSRCronResult
               cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
               echo "The script attempted to check: $line" >> OSRCronResult
               ls -ald $line >> OSRCronResult
               echo "" >> OSRCronResult
            fi
         fi
      fi
      done
   fi
   ((X+=1))
   done
   X=1 #First line to start checking
   for line in `cat OSRCronToCheck.run-parts`
   do
   if [ -d $line ]; then
      for script in `ls -al $line | grep "^-" | awk '{print $9}'`
      do
      FILEPerm=`ls -ald $line/$script | awk '{print $1}' | cut -c9`
      GROUPname=`ls -ald $line/$script | awk '{print $4}'`
      if [ $FILEPerm != "-" ]; then
         grep -q "^$GROUPname:" /etc/group
         if ((!$?)); then
            GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
         else
            GROUPid=999
         fi
         if [ $GROUPid -gt 99 ]; then
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean.run-parts | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line/$script" >> OSRCronResult
            ls -ald $line/$script >> OSRCronResult
            echo "" >> OSRCronResult
         fi
      fi
      done
   fi
   lineA=$line
   line=$line/place_holder
   echo $line | grep "^/" > /dev/null 2>&1
   if ((!$?)); then
      until [ `basename $line` = "/" ]
      do
      line=`dirname $line`
      if [ ! -L $line ] && [ -e $line ]; then
         FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
         GROUPname=`ls -ald $line | awk '{print $4}'`
         if [ $FILEPerm != "-" ]; then
            grep -q "^$GROUPname:" /etc/group
            if ((!$?)); then
               GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
            else
               GROUPid=999
            fi
            if [ $GROUPid -gt 99 ]; then
               echo "The path for $lineA has an incorrect setting" >> OSRCronResult
               echo "The line being checked was:" >> OSRCronResult
               cat OSRCronClean.run-parts | awk -v XX=$X 'NR==XX' >> OSRCronResult
               echo "The script attempted to check: $line" >> OSRCronResult
               ls -ald $line >> OSRCronResult
               echo "" >> OSRCronResult
            fi
         fi
      fi
      done
   fi
   ((X+=1))
   done
   if [ -s OSRCronResult ]; then
      $LOGIT "AD.1.8.15.3 : WARNING - An entry in /etc/crontab has an incorrect setting and/or owner for group:"
      cat OSRCronResult >> $LOGFILE
   else
      $LOGIT "AD.1.8.15.3 : All active entries in /etc/crontab have correct settings and/or owner for group."
   fi
else
   $LOGIT "AD.1.8.15.3 : N/A - There is no /etc/crontab file on this server."
fi

#Clean up our mess:
rm -rf OSRCronClean OSRCronResult OSRCronToCheck OSRCronClean.run-parts OSRCronToCheck.run-parts

$LOGIT ""
if [ -f /etc/xinetd.conf ]; then
   cat /etc/xinetd.conf | grep -v "^#" | grep -w "server" | grep "=" > AD18171_temp
   if [ -s AD18171_temp ]; then
      X=1
      cat /dev/null > AD18171a_temp
      for entry in `cat AD18171_temp | awk -F'=' '{print $2}'`
      do
      echo $entry | grep -q "/"
      if (($?)); then
         echo "The line being checked was:" >> AD18171a_temp
         cat AD18171_temp | awk -v XX=$X 'NR==XX' >> AD18171a_temp
         echo "The script attempted to check: $entry" >> AD18171a_temp
         echo "" >> AD18171a_temp
      fi
      ((X+=1))
      done
      if [ -s AD18171a_temp ]; then
         $LOGIT "AD.1.8.17.1 : WARNING - Some active entry(ies) exist in /etc/xinetd.conf that"
         $LOGIT "do not appear to contain the full path of what is being executed:"
         cat AD18171a_temp >> $LOGFILE
      else
         $LOGIT "AD.1.8.17.1 : All active entries in /etc/xinetd.conf contain the full path of what is being executed."
      fi
      X=1
      cat /dev/null > AD18171a_temp
      for entry in `cat AD18171_temp | awk -F'=' '{print $2}'`
      do
      if [ -e $entry ]; then
         FILEPerm=`ls -ald $entry | awk '{print $1}' | cut -c9`
         if [ $FILEPerm != "-" ]; then
            echo "The line being checked was:" >> AD18171a_temp
            cat AD18171_temp | awk -v XX=$X 'NR==XX' >> AD18171a_temp
            echo "The script attempted to check: $entry" >> AD18171a_temp
            ls -ald $entry >> AD18171a_temp
            echo "" >> AD18171a_temp
         fi
      fi
      entryA=$entry
      echo $line | grep "^/" > /dev/null 2>&1
      if ((!$?)); then
         until [ `basename $line` = "/" ]
         do
         entry=`dirname $entry`
         if [ ! -L $entry ] && [ -e $entry ]; then
            FILEPerm=`ls -ald $entry | awk '{print $1}' | cut -c9`
            if [ $FILEPerm != "-" ]; then
               echo "The path for $entryA has an incorrect setting" >> AD18171a_temp
               echo "The line being checked was:" >> AD18171a_temp
               cat AD18171_temp | awk -v XX=$X 'NR==XX' >> AD18171a_temp
               echo "The script attempted to check: $entry" >> AD18171a_temp
               ls -ald $entry >> AD18171a_temp
               echo "" >> AD18171a_temp
            fi
         fi
         done
      fi
      ((X+=1))
      done
      if [ -s AD18171a_temp ]; then
         $LOGIT "AD.1.8.17.2 : WARNING - Some active entry(ies) exist in /etc/xinetd.conf that"
         $LOGIT "do not have settings for 'other' of r-x or more stringent:"
         cat AD18171a_temp >> $LOGFILE
      else
         $LOGIT "AD.1.8.17.2 : All active entries in /etc/xinetd.conf and all dirs in their path of settings for 'other' set to r-x or more stringent."
      fi
      $LOGIT ""
      X=1
      cat /dev/null > AD18171a_temp
      for entry in `cat AD18171_temp | awk -F'=' '{print $2}'`
      do
      if [ -e $entry ]; then
         FILEPerm=`ls -ald $entry | awk '{print $1}' | cut -c9`
         GROUPname=`ls -ald $entry | awk '{print $4}'`
         if [ $FILEPerm != "-" ]; then
            grep -q "^$GROUPname:" /etc/group
            if ((!$?)); then
               GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
            else
               GROUPid=999
            fi
            if [ $GROUPid -gt 99 ]; then
               echo "The line being checked was:" >> AD18171a_temp
               cat AD18171_temp | awk -v XX=$X 'NR==XX' >> AD18171a_temp
               echo "The script attempted to check: $entry" >> AD18171a_temp
               ls -ald $entry >> AD18171a_temp
               echo "" >> AD18171a_temp
            fi
         fi
      fi
      entryA=$entry
      echo $entry | grep "^/" > /dev/null 2>&1
      if ((!$?)); then
         until [ `basename $entry` = "/" ]
         do
         entry=`dirname $entry`
         if [ ! -L $entry ] && [ -e $entry ]; then
            FILEPerm=`ls -ald $entry | awk '{print $1}' | cut -c6`
            GROUPname=`ls -ald $entry | awk '{print $4}'`
            if [ $FILEPerm != "-" ]; then
               grep -q "^$GROUPname:" /etc/group
               if ((!$?)); then
                  GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
               else
                  GROUPid=999
               fi
               if [ $GROUPid -gt 99 ]; then
                  echo "The path for $entryA has an incorrect setting" >> AD18171a_temp
                  echo "The line being checked was:" >> AD18171a_temp
                  cat AD18171_temp | awk -v XX=$X 'NR==XX' >> AD18171a_temp
                  echo "The script attempted to check: $entry" >> AD18171a_temp
                  ls -ald $entry >> AD18171a_temp
                  echo "" >> AD18171a_temp
               fi
            fi
         fi
         done
      fi
      ((X+=1))
      done
      if [ -s AD18171a_temp ]; then
         $LOGIT "AD.1.8.17.3 : WARNING - Some active entry(ies) exist in /etc/xinetd.conf that"
         $LOGIT "do not have settings for 'group' of r-x or more stringent and not owned by GID <= 99:"
         cat AD18171a_temp >> $LOGFILE
      else
         $LOGIT "AD.1.8.17.3 : All active entries in /etc/xinetd.conf and all dirs in their path of settings for 'group' set to r-x or more stringent or are owned by GID <= 99"
      fi
   else
      $LOGIT "AD.1.8.17.1 : N/A - There are no active entries in /etc/xinetd.conf to be executed."
      $LOGIT ""
      $LOGIT "AD.1.8.17.2 : N/A - There are no active entries in /etc/xinetd.conf to be executed."
      $LOGIT ""
      $LOGIT "AD.1.8.17.3 : N/A - There are no active entries in /etc/xinetd.conf to be executed."
   fi
   rm -rf AD18171a_temp AD18171_temp
else
   $LOGIT "AD.1.8.17.1 : N/A - The /etc/xinetd.conf file does not exist."
   $LOGIT ""
   $LOGIT "AD.1.8.17.2 : N/A - The /etc/xinetd.conf file does not exist."
   $LOGIT ""
   $LOGIT "AD.1.8.17.3 : N/A - The /etc/xinetd.conf file does not exist."
fi

$LOGIT ""
cat /dev/null > AD18182_temp
for dir in rc0.d rc1.d rc2.d rc3.d rc4.d rc5.d rc6.d rcS.d
do
if [ -L /etc/$dir ]; then
   BASEDIR=/etc/`ls -al /etc/$dir | awk '{print $11}'`
elif [ -d /etc/$dir ]; then
   BASEDIR=/etc/$dir
elif [ -d /etc/init.d/$dir ]; then
   BASEDIR=/etc/init.d/$dir
elif [ -d /etc/rc.d/$dir ]; then
   BASEDIR=/etc/rc.d/$dir
else
   BASEDIR=X
fi
if [ $BASEDIR != "X" ]; then
   for file in `ls -al $BASEDIR | grep -v "^d" | awk '{print $9}'`
   do
   if [ -L $BASEDIR/$file ]; then
      if [ -e $BASEDIR/$file ]; then
         FileLink=`ls -al $BASEDIR/$file | grep -v "^d" | awk '{print $11}'`
         FILEPERM=`ls -alL $BASEDIR/$file | awk '{print $1}' | cut -c9`
      else
         echo "A broken link exists in $BASEDIR: " >> AD18182_temp
         ls -ald $BASEDIR/$file >> AD18182_temp
         FILEPERM="-"
      fi
   else
      FileLink="X"
      FILEPERM=`ls -al $BASEDIR/$file | awk '{print $1}' | cut -c9`
   fi
   if [ $FILEPERM != "-" ]; then
      if [ $FileLink = "X" ]; then
         echo "Directory=$BASEDIR : File=$file" >> AD18182_temp
         ls -al $BASEDIR/$file >> AD18182_temp
      else
         echo "Directory=$BASEDIR : File=$file : File linked to=$FileLink" >> AD18182_temp
         ls -alL $BASEDIR/$file >> AD18182_temp
      fi
      echo "" >> AD18182_temp
   fi
   done
fi
done
if [ -s AD18182_temp ]; then
   $LOGIT "AD.1.8.18.2 : WARNING - Some file(s) exist which have incorrect permissions set for 'other':"
   cat AD18182_temp >> $LOGFILE
else
   $LOGIT "AD.1.8.18.2 : All files linked to and actual files have permissions set for 'other' to r-x or more stringent."
fi
rm -rf AD18182_temp

$LOGIT ""
cat /dev/null > AD18183_temp
for dir in rc0.d rc1.d rc2.d rc3.d rc4.d rc5.d rc6.d rcS.d
do
if [ -L /etc/$dir ]; then
   BASEDIR=/etc/`ls -al /etc/$dir | awk '{print $11}'`
elif [ -d /etc/$dir ]; then
   BASEDIR=/etc/$dir
elif [ -d /etc/init.d/$dir ]; then
   BASEDIR=/etc/init.d/$dir
elif [ -d /etc/rc.d/$dir ]; then
   BASEDIR=/etc/rc.d/$dir
else
   BASEDIR=X
fi
if [ $BASEDIR != "X" ]; then
   for file in `ls -al $BASEDIR | grep -v "^d" | awk '{print $9}'`
   do
   if [ -L $BASEDIR/$file ]; then
      if [ -e $BASEDIR/$file ]; then
         FileLink=`ls -al $BASEDIR/$file | grep -v "^d" | awk '{print $11}'`
         FILEPERM=`ls -alL $BASEDIR/$file | awk '{print $1}' | cut -c9`
         GROUPname=`ls -alL $BASEDIR/$file | awk '{print $4}'`
      else
         echo "A broken link exists in $BASEDIR: " >> AD18183_temp
         ls -ald $BASEDIR/$file >> AD18183_temp
         FILEPERM="-"
      fi
   else
      FileLink="X"
      FILEPERM=`ls -al $BASEDIR/$file | awk '{print $1}' | cut -c9`
      GROUPname=`ls -al $BASEDIR/$file | awk '{print $4}'`
   fi
   if [ $FILEPERM != "-" ]; then
      grep -q "^$GROUPname:" /etc/group
      if ((!$?)); then
         GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
      else
         GROUPid=999
      fi
      if [ $GROUPid -gt 99 ]; then
         if [ $FileLink = "X" ]; then
            echo "Directory=$BASEDIR : File=$file" >> AD18183_temp
            ls -al $BASEDIR/$file >> AD18183_temp
         else
            echo "Directory=$BASEDIR : File=$file : File linked to=$FileLink" >> AD18183_temp
            ls -alL $BASEDIR/$file >> AD18183_temp
         fi
         echo "" >> AD18183_temp
      fi
   fi
   done
fi
done
if [ -s AD18183_temp ]; then
   $LOGIT "AD.1.8.18.3 : WARNING - Some file(s) exist which have incorrect permissions set for 'group' and GID < 99:"
   cat AD18183_temp >> $LOGFILE
else
   $LOGIT "AD.1.8.18.3 : All files linked to and actual files have permissions set for 'group' to r-x or more stringent."
fi
rm -rf AD18183_temp

$LOGIT ""
if [ -L /etc/init.d ]; then
   BASEDIR=/etc/`ls -al /etc/init.d | awk '{print $11}'`
elif [ -d /etc/init.d ]; then
   BASEDIR=/etc/init.d
else
   BASEDIR=X
fi
cat /dev/null > AD18192_temp
if [ $BASEDIR != "X" ]; then
   for file in `ls -al $BASEDIR | grep -v "^d" | awk '{print $9}'`
   do
   if [ -L $BASEDIR/$file ]; then
      if [ -e $BASEDIR/$file ]; then
         FileLink=`ls -al $BASEDIR/$file | grep -v "^d" | awk '{print $11}'`
         FILEPERM=`ls -alL $BASEDIR/$file | awk '{print $1}' | cut -c9`
      else
         echo "A broken link exists in $BASEDIR: " >> AD18192_temp
         ls -ald $BASEDIR/$file >> AD18192_temp
         FILEPERM="-"
      fi
   else
      FileLink="X"
      FILEPERM=`ls -al $BASEDIR/$file | awk '{print $1}' | cut -c9`
   fi
   if [ $FILEPERM != "-" ]; then
      if [ $FileLink = "X" ]; then
         echo "Directory=$BASEDIR : File=$file" >> AD18192_temp
         ls -al $BASEDIR/$file >> AD18192_temp
      else
         echo "Directory=$BASEDIR : File=$file : File linked to=$FileLink" >> AD18192_temp
         ls -alL $BASEDIR/$file >> AD18192_temp
      fi
      echo "" >> AD18192_temp
   fi
   done
fi
if [ -s AD18192_temp ]; then
   $LOGIT "AD.1.8.19.2 : WARNING - Some file(s) exist which have incorrect permissions set for 'other':"
   cat AD18192_temp >> $LOGFILE
elif [ $BASEDIR = "X" ]; then
   $LOGIT "AD.1.8.19.2 : N/A - Neither the /etc/init.d nor the /etc/rc.d/init.d directories exist."
else
   $LOGIT "AD.1.8.19.2 : All files linked to and actual files have permissions set for 'other' to r-x or more stringent."
fi
rm -rf AD18192_temp

$LOGIT ""
if [ -L /etc/init.d ]; then
   BASEDIR=/etc/`ls -al /etc/init.d | awk '{print $11}'`
elif [ -d /etc/init.d ]; then
   BASEDIR=/etc/init.d
else
   BASEDIR=X
fi
cat /dev/null > AD18193_temp
if [ $BASEDIR != "X" ]; then
   for file in `ls -al $BASEDIR | grep -v "^d" | awk '{print $9}'`
   do
   if [ -L $BASEDIR/$file ]; then
      if [ -e $BASEDIR/$file ]; then
         FileLink=`ls -al $BASEDIR/$file | grep -v "^d" | awk '{print $11}'`
         FILEPERM=`ls -alL $BASEDIR/$file | awk '{print $1}' | cut -c9`
         GROUPname=`ls -alL $BASEDIR/$file | awk '{print $4}'`
      else
         echo "A broken link exists in $BASEDIR: " >> AD18193_temp
         ls -ald $BASEDIR/$file >> AD18193_temp
         FILEPERM="-"
      fi
   else
      FileLink="X"
      FILEPERM=`ls -al $BASEDIR/$file | awk '{print $1}' | cut -c9`
      GROUPname=`ls -al $BASEDIR/$file | awk '{print $4}'`
   fi
   if [ $FILEPERM != "-" ]; then
      grep -q "^$GROUPname:" /etc/group
      if ((!$?)); then
         GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
      else
         GROUPid=999
      fi
      if [ $GROUPid -gt 99 ]; then
         if [ $FileLink = "X" ]; then
            echo "Directory=$BASEDIR : File=$file" >> AD18193_temp
            ls -al $BASEDIR/$file >> AD18193_temp
         else
            echo "Directory=$BASEDIR : File=$file : File linked to=$FileLink" >> AD18193_temp
            ls -alL $BASEDIR/$file >> AD18193_temp
         fi
         echo "" >> AD18193_temp
      fi
   fi
   done
fi
if [ -s AD18193_temp ]; then
   $LOGIT "AD.1.8.19.3 : WARNING - Some file(s) exist which have incorrect permissions set for 'group' and GID < 99:"
   cat AD18193_temp >> $LOGFILE
elif [ $BASEDIR = "X" ]; then
   $LOGIT "AD.1.8.19.2 : N/A - Neither the /etc/init.d nor the /etc/rc.d/init.d directories exist."
else
   $LOGIT "AD.1.8.19.3 : All files linked to and actual files have permissions set for 'group' to r-x or more stringent."
fi
rm -rf AD18193_temp

$LOGIT ""
if [ -d /etc/cron.d ]; then
   if [ `ls /etc/cron.d | wc -l` -gt 0 ]; then
      cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
      for file in `ls /etc/cron.d`
      do
      cat /etc/cron.d/$file | grep -v "^#" > OSRCronClean #gives ACTIVE cron entries
      cat OSRCronClean | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
      X=1 #First line to start checking
         for line in `cat OSRCronToCheck`
         do
         echo $line | grep "/" > /dev/null 2>&1
         if (($?)); then
            echo "The file being checked was: /etc/cron.d/$file" >> OSRCronResult
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line" >> OSRCronResult
            echo "" >> OSRCronResult
         fi
         ((X+=1))
         done
      done
      if [ -s OSRCronResult ]; then
         $LOGIT "AD.1.8.20.1 : WARNING - At least one active entry was found in /etc/cron.d that"
         $LOGIT "does not appear to specify the full path!"
         $LOGIT "Please review the results below and check for any false positives:"
         cat OSRCronResult >> $LOGFILE
         $LOGIT ""
         $LOGIT "!!! WARNING - THE ABOVE ENTRIES WILL NOT BE CHECKED IN THE NEXT TWO SECTIONS !!!"
         $LOGIT ""
      else
         $LOGIT "AD.1.8.20.1 : All active entry in /etc/cron.d specify the full path of the file/command/script to be executed."
      fi
   
   
      $LOGIT ""
      cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
      for file in `ls /etc/cron.d`
      do
      cat /etc/cron.d/$file | grep -v "^#" > OSRCronClean #gives ACTIVE cron entries
      cat OSRCronClean | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
      X=1 #First line to start checking
         for line in `cat OSRCronToCheck`
         do
         if [ -e $line ]; then
            FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
            if [ $FILEPerm != "-" ]; then
               echo "The line being checked was:" >> OSRCronResult
               cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
               echo "The script attempted to check: $line" >> OSRCronResult
               ls -ald $line >> OSRCronResult
               echo "" >> OSRCronResult
            fi
         fi
         lineA=$line
         echo $line | grep "^/" > /dev/null 2>&1
         if ((!$?)); then
            until [ `basename $line` = "/" ]
            do
            line=`dirname $line`
            if [ ! -L $line ] && [ -e $line ]; then
               FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
               if [ $FILEPerm != "-" ]; then
                  echo "The file being checked was: /etc/cron.d/$file" >> OSRCronResult
                  echo "The path for $lineA has an incorrect setting" >> OSRCronResult
                  echo "The line being checked was:" >> OSRCronResult
                  cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
                  echo "The script attempted to check: $line" >> OSRCronResult
                  ls -ald $line >> OSRCronResult
                  echo "" >> OSRCronResult
               fi
            fi
            done
         fi
         ((X+=1))
         done
      done
      if [ -s OSRCronResult ]; then
         $LOGIT "AD.1.8.20.2 : WARNING - An entry in /etc/cron.d has an incorrect setting for other:"
         cat OSRCronResult >> $LOGFILE
      else
         $LOGIT "AD.1.8.20.2 : All active & valid entries in /etc/cron.d have correct settings for other."
      fi
   
   
      $LOGIT ""
      cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
      for file in `ls /etc/cron.d`
      do
      cat /etc/cron.d/$file | grep -v "^#" > OSRCronClean #gives ACTIVE cron entries
      cat OSRCronClean | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
      X=1 #First line to start checking
         for line in `cat OSRCronToCheck`
         do
         if [ -e $line ]; then
            FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
            GROUPname=`ls -ald $line | awk '{print $4}'`
            if [ $FILEPerm != "-" ]; then
               grep -q "^$GROUPname:" /etc/group
               if ((!$?)); then
                  GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
               else
                  GROUPid=999
               fi
               if [ $GROUPid -gt 99 ]; then
                  echo "The file being checked was: /etc/cron.d/$file" >> OSRCronResult
                  echo "The line being checked was:" >> OSRCronResult
                  cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
                  echo "The script attempted to check: $line" >> OSRCronResult
                  ls -ald $line >> OSRCronResult
                  echo "" >> OSRCronResult
               fi
            fi
         fi
         lineA=$line
         echo $line | grep "^/" > /dev/null 2>&1
         if ((!$?)); then
            until [ `basename $line` = "/" ]
            do
            line=`dirname $line`
            if [ ! -L $line ] && [ -e $line ]; then
               FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
               GROUPname=`ls -ald $line | awk '{print $4}'`
               if [ $FILEPerm != "-" ]; then
                  grep -q "^$GROUPname:" /etc/group
                  if ((!$?)); then
                     GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
                  else
                     GROUPid=999
                  fi
                  if [ $GROUPid -gt 99 ]; then
                     echo "The file being checked was: /etc/cron.d/$file" >> OSRCronResult
                     echo "The path for $lineA has an incorrect setting" >> OSRCronResult
                     echo "The line being checked was:" >> OSRCronResult
                     cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
                     echo "The script attempted to check: $line" >> OSRCronResult
                     ls -ald $line >> OSRCronResult
                     echo "" >> OSRCronResult
                  fi
               fi
            fi
            done
         fi
         ((X+=1))
         done
      done
      if [ -s OSRCronResult ]; then
         $LOGIT "AD.1.8.20.3 : WARNING - An entry in /etc/cron.d has an incorrect setting and/or owner for group:"
         cat OSRCronResult >> $LOGFILE
      else
         $LOGIT "AD.1.8.20.3 : All active entries in /etc/cron.d have correct settings and/or owner for group."
      fi
   else
      $LOGIT "AD.1.8.20.1 : N/A - No active entries exist in /etc/cron.d"
      $LOGIT ""
      $LOGIT "AD.1.8.20.2 : N/A - No active entries exist in /etc/cron.d"
      $LOGIT ""
      $LOGIT "AD.1.8.20.3 : N/A - No active entries exist in /etc/cron.d"
   fi
else
   $LOGIT "AD.1.8.20.1 : N/A - The /etc/cron.d directory does not exist."
   $LOGIT ""
   $LOGIT "AD.1.8.20.2 : N/A - The /etc/cron.d directory does not exist."
   $LOGIT ""
   $LOGIT "AD.1.8.20.3 : N/A - The /etc/cron.d directory does not exist."
fi

#Clean up our mess:
rm -rf OSRCronClean OSRCronResult OSRCronToCheck

#The /var/spool/cron/tabs is only used by SuSe.
$LOGIT ""
if [ -d /var/spool/cron/tabs ]; then
   if [ `ls /var/spool/cron/tabs | wc -l` -gt 0 ]; then
      cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
      for file in `ls /var/spool/cron/tabs`
      do
      cat /var/spool/cron/tabs/$file | grep -v "^#" > OSRCronClean #gives ACTIVE cron entries
      cat OSRCronClean | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
      X=1 #First line to start checking
         for line in `cat OSRCronToCheck`
         do
         echo $line | grep "/" > /dev/null 2>&1
         if (($?)); then
            echo "The file being checked was: /var/spool/cron/tabs/$file" >> OSRCronResult
            echo "The line being checked was:" >> OSRCronResult
            cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
            echo "The script attempted to check: $line" >> OSRCronResult
            echo "" >> OSRCronResult
         fi
         ((X+=1))
         done
      done
      if [ -s OSRCronResult ]; then
         $LOGIT "AD.1.8.21.1 : WARNING - At least one active entry was found in /var/spool/cron/tabs that"
         $LOGIT "does not appear to specify the full path!"
         $LOGIT "Please review the results below and check for any false positives:"
         cat OSRCronResult >> $LOGFILE
         $LOGIT ""
         $LOGIT "!!! WARNING - THE ABOVE ENTRIES WILL NOT BE CHECKED IN THE NEXT TWO SECTIONS !!!"
         $LOGIT ""
      else
         $LOGIT "AD.1.8.21.1 : All active entry in /var/spool/cron/tabs specify the full path of the file/command/script to be executed."
      fi
   
   
      $LOGIT ""
      cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
      for file in `ls /var/spool/cron/tabs`
      do
      cat /var/spool/cron/tabs/$file | grep -v "^#" > OSRCronClean #gives ACTIVE cron entries
      cat OSRCronClean | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
      X=1 #First line to start checking
         for line in `cat OSRCronToCheck`
         do
         if [ -e $line ]; then
            FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
            if [ $FILEPerm != "-" ]; then
               echo "The line being checked was:" >> OSRCronResult
               cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
               echo "The script attempted to check: $line" >> OSRCronResult
               ls -ald $line >> OSRCronResult
               echo "" >> OSRCronResult
            fi
         fi
         lineA=$line
         echo $line | grep "^/" > /dev/null 2>&1
         if ((!$?)); then
            until [ `basename $line` = "/" ]
            do
            line=`dirname $line`
            if [ ! -L $line ] && [ -e $line ]; then
               FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c9`
               if [ $FILEPerm != "-" ]; then
                  echo "The file being checked was: /var/spool/cron/tabs/$file" >> OSRCronResult
                  echo "The path for $lineA has an incorrect setting" >> OSRCronResult
                  echo "The line being checked was:" >> OSRCronResult
                  cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
                  echo "The script attempted to check: $line" >> OSRCronResult
                  ls -ald $line >> OSRCronResult
                  echo "" >> OSRCronResult
               fi
            fi
            done
         fi
         ((X+=1))
         done
      done
      if [ -s OSRCronResult ]; then
         $LOGIT "AD.1.8.21.2 : WARNING - An entry in /var/spool/cron/tabs has an incorrect setting for other:"
         cat OSRCronResult >> $LOGFILE
      else
         $LOGIT "AD.1.8.21.2 : All active & valid entries in /var/spool/cron/tabs have correct settings for other."
      fi
   
   
      $LOGIT ""
      cat /dev/null > OSRCronResult #clean our results file to start fresh if any problems found
      for file in `ls /var/spool/cron/tabs`
      do
      cat /var/spool/cron/tabs/$file | grep -v "^#" > OSRCronClean #gives ACTIVE cron entries
      cat OSRCronClean | awk '{print substr($0, index($0,$6)) }' | cut -d'>' -f1 | awk -F"/" '{print substr($0, index($0,$1)) }' | awk '{print $1}' > OSRCronToCheck #gives the potential scripts/commands to check
      X=1 #First line to start checking
         for line in `cat OSRCronToCheck`
         do
         if [ -e $line ]; then
            FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
            GROUPname=`ls -ald $line | awk '{print $4}'`
            if [ $FILEPerm != "-" ]; then
               grep -q "^$GROUPname:" /etc/group
               if ((!$?)); then
                  GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
               else
                  GROUPid=999
               fi
               if [ $GROUPid -gt 99 ]; then
                  echo "The file being checked was: /var/spool/cron/tabs/$file" >> OSRCronResult
                  echo "The line being checked was:" >> OSRCronResult
                  cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
                  echo "The script attempted to check: $line" >> OSRCronResult
                  ls -ald $line >> OSRCronResult
                  echo "" >> OSRCronResult
               fi
            fi
         fi
         lineA=$line
         echo $line | grep "^/" > /dev/null 2>&1
         if ((!$?)); then
            until [ `basename $line` = "/" ]
            do
            line=`dirname $line`
            if [ ! -L $line ] && [ -e $line ]; then
               FILEPerm=`ls -ald $line | awk '{print $1}' | cut -c6`
               GROUPname=`ls -ald $line | awk '{print $4}'`
               if [ $FILEPerm != "-" ]; then
                  grep -q "^$GROUPname:" /etc/group
                  if ((!$?)); then
                     GROUPid=`grep "^$GROUPname:" /etc/group | awk -F':' '{print $3}'`
                  else
                     GROUPid=999
                  fi
                  if [ $GROUPid -gt 99 ]; then
                     echo "The file being checked was: /var/spool/cron/tabs/$file" >> OSRCronResult
                     echo "The path for $lineA has an incorrect setting" >> OSRCronResult
                     echo "The line being checked was:" >> OSRCronResult
                     cat OSRCronClean | awk -v XX=$X 'NR==XX' >> OSRCronResult
                     echo "The script attempted to check: $line" >> OSRCronResult
                     ls -ald $line >> OSRCronResult
                     echo "" >> OSRCronResult
                  fi
               fi
            fi
            done
         fi
         ((X+=1))
         done
      done
      if [ -s OSRCronResult ]; then
         $LOGIT "AD.1.8.21.3 : WARNING - An entry in /var/spool/cron/tabs has an incorrect setting and/or owner for group:"
         cat OSRCronResult >> $LOGFILE
      else
         $LOGIT "AD.1.8.21.3 : All active entries in /var/spool/cron/tabs have correct settings and/or owner for group."
      fi
   else
      $LOGIT "AD.1.8.21.1 : N/A - No active entries exist in /var/spool/cron/tabs"
      $LOGIT ""
      $LOGIT "AD.1.8.21.2 : N/A - No active entries exist in /var/spool/cron/tabs"
      $LOGIT ""
      $LOGIT "AD.1.8.21.3 : N/A - No active entries exist in /var/spool/cron/tabs"
   fi
else
   $LOGIT "AD.1.8.21.1 : N/A - The /var/spool/cron/tabs directory does not exist."
   $LOGIT ""
   $LOGIT "AD.1.8.21.2 : N/A - The /var/spool/cron/tabs directory does not exist."
   $LOGIT ""
   $LOGIT "AD.1.8.21.3 : N/A - The /var/spool/cron/tabs directory does not exist."
fi

#Clean up our mess:
rm -rf OSRCronClean OSRCronResult OSRCronToCheck


X=1
for dir in /opt /var /tmp
do
cat /dev/null > AD1822_temp
find $dir -type f -perm -a=w -perm -a=x >> AD1822_temp
sleep 2
$LOGIT ""
if [ -s AD1822_temp ]; then
   $LOGIT "AD.1.8.22.$X : WARNING - File(s) exist in $dir that have both other-write and any-execute permissions set!"
   for file in `cat AD1822_temp`
   do
   ls -al $file | awk '{print $1,$9}' >> $LOGFILE
   done
#   cat AD1822_temp >> $LOGFILE
else
   $LOGIT "AD.1.8.22.$X : No files exist in $dir that have both other-write and any-execute permissions set."
fi
((X+=1))
done

#Clean up our mess:
rm -rf AD1822_temp

$LOGIT ""
$LOGIT "AD.1.9.1.1 : The default setting in RedHat Linux is to create new user home directories with permissions 0700 and cannot be modified."

$LOGIT ""
if [ $OSFlavor = "RedHat" ]; then
   if [[ -z `grep -i umask /etc/bashrc` ]]; then
      $LOGIT "AD.1.9.1.2 : WARNING - System Default UMASK not defined in /etc/bashrc!"
   else
      grep -i "umask" /etc/bashrc | grep -q [0-9]77
      if (($?)); then
         $LOGIT "AD.1.9.1.2 : WARNING - System Default UMASK is set incorrectly in /etc/bashrc:"
         grep -i "umask" /etc/bashrc >> $LOGFILE
      else
         $LOGIT "AD.1.9.1.2 : System Default UMASK is set in /etc/bashrc:"
         grep -i "umask" /etc/bashrc | grep [0-9]77 >> $LOGFILE
      fi
   fi
elif [ $OSFlavor = "SuSE" ]; then
   if [ -f /etc/profile.local ]; then
      if [[ -z `grep -i umask /etc/profile.local` ]]; then
         $LOGIT "AD.1.9.1.2 : WARNING - System Default UMASK not defined in /etc/profile.local!"
      else
         grep -i "umask" /etc/profile.local | grep -q [0-9]77
         if (($?)); then
            $LOGIT "AD.1.9.1.2 : WARNING - System Default UMASK is set incorrectly in /etc/profile.local:"
            grep -i "umask" /etc/profile.local >> $LOGFILE
         else
            $LOGIT "AD.1.9.1.2 : System Default UMASK is set in /etc/profile.local:"
            grep -i "umask" /etc/profile.local | grep [0-9]77 >> $LOGFILE
         fi
      fi
   else
      $LOGIT "AD.1.9.1.2 : WARNING - The /etc/profile.local file does not exist!"
   fi
##Removed as this now appear in new section AD.1.9.1.2.1 below
#   if [ -f /etc/login.defs ]; then
#      if [[ -z `grep ^UMASK /etc/login.defs` ]]; then
#         $LOGIT "AD.1.9.1.2 : WARNING - System Default UMASK not defined in #/etc/login.defs!"
#      else
#         grep "^UMASK" /etc/login.defs | grep -q [0-9]77
#         if (($?)); then
#            $LOGIT "AD.1.9.1.2 : WARNING - System Default UMASK is set #incorrectly in /etc/login.defs:"
#            grep "^UMASK" /etc/login.defs >> $LOGFILE
#         else
#            $LOGIT "AD.1.9.1.2 : System Default UMASK is set in #/etc/login.defs:"
#           grep "^UMASK" /etc/login.defs | grep [0-9]77 >> $LOGFILE
#        fi
#      fi
#   fi
else
   $LOGIT ""
   $LOGIT "AD.1.9.1.2 : N/A - This is a $OSFLavor server."
fi

$LOGIT ""
if [ -f /etc/login.defs ]; then
   COUNT=`cat /etc/login.defs | grep -v "^#" | grep -ic umask`
   if [ $COUNT -le 1 ]; then
      cat /etc/login.defs | grep -v "^#" | grep -i umask > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.1.9.1.2.1 : WARNING - The umask paramter does not appear in the /etc/login.defs file."
      else
         cat /etc/login.defs | grep -v "^#" | grep -i umask | grep 077 > /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.1.9.1.2.1 : WARNING - The parameter umask 077 appears to be set incorrectly in the /etc/login.defs file:"
         else
            $LOGIT "AD.1.9.1.2.1 : The parameter umask 077 appears to be set correctly in the /etc/login.defs file:"
         fi
         cat /etc/login.defs | grep -v "^#" | grep -i umask >> $LOGFILE
      fi
   else
      $LOGIT "AD.1.9.1.2.1 : WARNING - The umask parameter has more than one entry in the /etc/login.defs file. Verify they are correct manually:"
      cat /etc/login.defs | grep -v "^#" | grep -i umask >> $LOGFILE
   fi
else
   $LOGIT "AD.1.9.1.2.1 : WARNING - The /etc/login.defs file does not exist!"
fi

$LOGIT ""
cat /dev/null > AD1913_temp
if [ -f /etc/profile.d/IBMsinit.sh ]; then
   grep "\$UID \-gt 199" /etc/profile.d/IBMsinit.sh | grep "if" | grep -v "^#" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.9.1.3 : WARNING - The required if statement does not exist in the /etc/profile.d/IBMsinit.sh file."
   else
      grep -A 2 "\$UID \-gt 199" /etc/profile.d/IBMsinit.sh | grep -A 2 "if" | grep -vA 2 "^#" >> AD1913_temp
      COUNT=`egrep -c "\$UID \-gt 199|umask 077|fi" AD1913_temp`
      if [ $COUNT -eq 3 ]; then
         $LOGIT "AD.1.9.1.3 : The /etc/profile.d/IBMsinit.sh file appears to contain the required if statement:"
      else
         $LOGIT "AD.1.9.1.3 : WARNING - The /etc/profile.d/IBMsinit.sh file does not appear to contain the required if statement:"
      fi
      cat AD1913_temp >> $LOGFILE
   fi
else
   $LOGIT "AD.1.9.1.3 : WARNING - The /etc/profile.d/IBMsinit.sh file does NOT exist!"
fi
rm -rf AD1913_temp

$LOGIT ""
cat /dev/null > AD1914_temp
if [ -f /etc/profile.d/IBMsinit.csh ]; then
   grep "\$uid > 199" /etc/profile.d/IBMsinit.csh | grep "if" | grep -v "^#" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.9.1.4 : WARNING - The required if statement does not exist in the /etc/profile.d/IBMsinit.csh file."
   else
      grep -A 2 "\$uid > 199" /etc/profile.d/IBMsinit.csh | grep -A 2 "if" | grep -vA 2 "^#" >> AD1914_temp
      COUNT=`egrep -c "\$uid > 199|umask 077|endif" AD1914_temp`
      if [ $COUNT -eq 3 ]; then
         $LOGIT "AD.1.9.1.4 : The /etc/profile.d/IBMsinit.csh file appears to contain the required if statement:"
      else
         $LOGIT "AD.1.9.1.4 : WARNING - The /etc/profile.d/IBMsinit.csh file does not appear to contain the required if statement:"
      fi
      cat AD1914_temp >> $LOGFILE
   fi
else
   $LOGIT "AD.1.9.1.4 : WARNING - The /etc/profile.d/IBMsinit.csh file does NOT exist!"
fi
rm -rf AD1914_temp

$LOGIT ""
cat /dev/null > AD1915_temp
cat /dev/null > AD1915_tempA
if [ -f /etc/profile ]; then
   grep "/etc/profile.d/IBMsinit.sh" /etc/profile | grep -v "^#" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.9.1.5 : WARNING - The required entry for the IBMsinit.sh script does not exist in /etc/profile."
      AD1915Check=1
   else
      $LOGIT "AD.1.9.1.5 : The required entry for the IBMsinit.sh script appears to exist in /etc/profile:"
      grep "/etc/profile.d/IBMsinit.sh" /etc/profile | grep -v "^#" >> $LOGFILE
      AD1915Check=0
      FoundLine=`grep -n "/etc/profile.d/IBMsinit.sh" /etc/profile | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
      cat /etc/profile | grep -v "^#" | grep -in umask | awk -F':' '{print $1}' >> AD1915_temp
      if [ -s AD1915_temp ]; then
         for x in `cat AD1915_temp`
         do
         if [ $x -gt $FoundLine ]; then
            $LOGIT "AD.1.9.1.5 : WARNING - The umask parameter exists after the invocation of the IBMsinit.sh script in /etc/profile!"
            echo $x >> AD1915_tempA
         fi
         done
         if [ -s AD1915_tempA ]; then
            $LOGIT "AD.1.9.1.5 : The following line numbers in /etc/profile contain the umask paramter, which come after the invocation of IBMsinit.sh:"
            cat AD1915_tempA >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.9.1.5 : No entries containing umask appear after the invocation of IBMsinit.sh in /etc/profile."
      fi
   fi
   if [ -f /etc/profile.local ]; then
      grep "/etc/profile.d/IBMsinit.sh" /etc/profile.local > /dev/null 2>&1
      if (($?)); then
         if (($AD1915Check)); then
            $LOGIT "AD.1.9.1.5 : WARNING - The required entry for the IBMsinit.sh script does not exist in /etc/profile.local!"
         fi
      else
         $LOGIT "AD.1.9.1.5 : The required entry for the IBMsinit.sh script appears to exist in the /etc/profile.local file:"
         grep "/etc/profile.d/IBMsinit.sh" /etc/profile.local >> $LOGFILE
         cat /dev/null > AD1915_temp
         cat /dev/null > AD1915_tempA
         FoundLine=`grep -n "/etc/profile.d/IBMsinit.sh" /etc/profile.local | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
         cat /etc/profile.local | grep -v "^#" | grep -in umask | awk -F':' '{print $1}' >> AD1915_temp
         if [ -s AD1915_temp ]; then
            for x in `cat AD1915_temp`
            do
            if [ $x -gt $FoundLine ]; then
               $LOGIT "AD.1.9.1.5 : WARNING - The umask parameter exists after the invocation of the IBMsinit.sh script in /etc/profile.local!"
               echo $x >> AD1915_tempA
            fi
            done
            if [ -s AD1915_tempA ]; then
               $LOGIT "AD.1.9.1.5 : The following line numbers in /etc/profile.local contain the umask paramter, which come after the invocation of IBMsinit.sh:"
               cat AD1915_tempA >> $LOGFILE
            fi
         else
            $LOGIT "AD.1.9.1.5 : No entries containing umask appear after the invocation of IBMsinit.sh in /etc/profilelocal."
         fi
      fi
   elif (($AD1915Check)); then
      $LOGIT "AD.1.9.1.5 : WARNING - The /etc/profile.local file does not exist for a secondary check!"
   fi
         
else
   $LOGIT "AD.1.9.1.5 : WARNING - The /etc/profile does NOT exist!"
fi
rm -rf AD1915_temp AD1915_tempA

$LOGIT ""
cat /dev/null > AD1916_temp
cat /dev/null > AD1916_tempA
if [ -f /etc/csh.login ]; then
   grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login | grep -v "^#" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.1.9.1.6 : WARNING - The required entry for the IBMsinit.csh script does not exist in /etc/csh.login."
      AD1915Check=1
   else
      $LOGIT "AD.1.9.1.6 : The required entry for the IBMsinit.csh script appears to exist in /etc/csh.login:"
      grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login | grep -v "^#" >> $LOGFILE
      AD1915Check=0
      FoundLine=`grep -n "/etc/profile.d/IBMsinit.csh" /etc/csh.login | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
      cat /etc/csh.login | grep -v "^#" | grep -in umask | awk -F':' '{print $1}' >> AD1916_temp
      if [ -s AD1916_temp ]; then
         for x in `cat AD1916_temp`
         do
         if [ $x -gt $FoundLine ]; then
            $LOGIT "AD.1.9.1.6 : WARNING - The umask parameter exists after the invocation of the IBMsinit.csh script in /etc/csh.login!"
            echo $x >> AD1916_tempA
         fi
         done
         if [ -s AD1916_tempA ]; then
            $LOGIT "AD.1.9.1.6 : The following line numbers in /etc/csh.login contain the umask paramter, which come after the invocation of IBMsinit.csh:"
            cat AD1916_tempA >> $LOGFILE
         fi
      else
         $LOGIT "AD.1.9.1.6 : No entries containing umask appear after the invocation of IBMsinit.csh in /etc/csh.login."
      fi
   fi
   if [ -f /etc/csh.login.local ]; then
      grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login.local > /dev/null 2>&1
      if (($?)); then
         if (($AD1915Check)); then
            $LOGIT "AD.1.9.1.6 : WARNING - The required entry for the IBMsinit.csh script does not exist in /etc/csh.login.local!"
         fi
      else
         $LOGIT "AD.1.9.1.6 : The required entry for the IBMsinit.csh script appears to exist in the /etc/csh.login.local file:"
         grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login.local >> $LOGFILE
         cat /dev/null > AD1916_temp
         cat /dev/null > AD1916_tempA
         FoundLine=`grep -n "/etc/profile.d/IBMsinit.csh" /etc/csh.login.local | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
         cat /etc/csh.login.local | grep -v "^#" | grep -in umask | awk -F':' '{print $1}' >> AD1916_temp
         if [ -s AD1916_temp ]; then
            for x in `cat AD1916_temp`
            do
            if [ $x -gt $FoundLine ]; then
               $LOGIT "AD.1.9.1.6 : WARNING - The umask parameter exists after the invocation of the IBMsinit.csh script in /etc/csh.login.local!"
               echo $x >> AD1916_tempA
            fi
            done
            if [ -s AD1916_tempA ]; then
               $LOGIT "AD.1.9.1.6 : The following line numbers in /etc/csh.login.local contain the umask paramter, which come after the invocation of IBMsinit.csh:"
               cat AD1916_tempA >> $LOGFILE
            fi
         else
            $LOGIT "AD.1.9.1.6 : No entries containing umask appear after the invocation of IBMsinit.csh in /etc/profilelocal."
         fi
      fi
   elif (($AD1915Check)); then
      $LOGIT "AD.1.9.1.6 : WARNING - The /etc/csh.login.local file does not exist for a secondary check!"
   fi
         
else
   $LOGIT "AD.1.9.1.6 : WARNING - The /etc/csh.login does NOT exist!"
fi
rm -rf AD1916_temp AD1916_tempA

$LOGIT ""
cat /dev/null > AD1917_temp
for file in /etc/skel/.cshrc /etc/skel/.login /etc/skel/.profile /etc/skel/.bashrc /etc/skel/.bash_profile /etc/skel/.bash_login /etc/skel/.tcshrc
do
if [ -f $file ]; then
   grep -i umask $file | grep -v "^#" | grep -v "077" >> /dev/null 2>&1
   if ((!$?)); then
      echo $file >> AD1917_temp
      grep -i umask $file | grep -v "^#" | grep -v "077" >> AD1917_temp
   fi
else
   $LOGIT "AD.1.9.1.7 : The file $file does not exist on this server."
fi
done
if [ -s AD1917_temp ]; then
   $LOGIT "AD.1.9.1.7 : WARNING - Skeleton files exist that appear to reset or override the umask setting:"
   cat AD1917_temp >> $LOGFILE
else
   $LOGIT "AD.1.9.1.7 : No skeleton files were found on the server that appear to reset or override the umask setting."
fi
rm -rf AD1917_temp

$LOGIT ""
GOODBAD=1
if [[ -s /etc/issue ]] && [[ ! -z `grep -v "^#" /etc/issue` ]]; then
   $LOGIT "AD.2.0.1 : The /etc/issue file exists and contains active entries."
#   $LOGIT "Here is the contents:"; $LOGIT ""
   cat /etc/issue >> $LOGFILE
   GOODBAD=0
   $LOGIT ""
fi
if [[ -s /etc/motd ]] && [[ ! -z `grep -v "^#" /etc/motd` ]]; then
   $LOGIT "AD.2.0.1 : The /etc/motd file exists and contains active entries."
#   $LOGIT "Here is the contents:"; $LOGIT ""
   cat /etc/motd >> $LOGFILE
   GOODBAD=0
   $LOGIT ""
fi
if (($GOODBAD)); then
   $LOGIT "AD.2.0.1 : WARNING - Both the /etc/issue and the /etc/motd files either do not exist or neither contain any active entries!"
fi

$LOGIT ""
rpm -qa | grep -q "openssh-server"
if ((!$?)); then
   $LOGIT "AD.2.1.1 : SFTP is installed."
   which sftp > /dev/null 2>&1
   if ((!$?)); then
      which sftp >> $LOGFILE
   fi
else
   $LOGIT "AD.2.1.1 : WARNING - SFTP does not appear to be installed."
   $LOGIT "AD.2.1.1 : THIS SCRIPT CANNOT DO ANY FURTHER CHECKS ON THIS SECTION #!!!"
fi

$LOGIT ""
GOODBAD=1
rpm -qa | grep -q "openssl"
if ((!$?)); then
   $LOGIT "AD.2.1.2 : openssl is installed on this server."
   which openssl > /dev/null 2>&1
   if ((!$?)); then
      which openssl >> $LOGFILE
   fi
   GOODBAD=0
fi
gpg --version > /dev/null 2>&1
if ((!$?)); then
   $LOGIT "AD.2.1.2 : GPG is installed on this server."
   gpg --version | head -1 >> $LOGFILE
   GOODBAD=0
fi
if (($GOODBAD)); then
   $LOGIT "AD.2.1.2 : WARNING - Neither openssl nor GPG appear to be installed on this server!"
fi

$LOGIT ""
if [ $OSFlavor = "RedHat" ]; then
   cat /dev/null > AD213_temp
   for file in `ls -al /etc/pam.d | grep -v "^d" | awk '{print $9}'`
   do
   cat /etc/pam.d/$file | grep "^password" | egrep 'required|sufficient' | grep -q "pam_unix.so"
   if ((!$?)); then
      cat /etc/pam.d/$file | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
      if (($?)); then
         echo "/etc/pam.d/$file" >> AD213_temp
      fi
   fi
   done
   if [ $RHVER -ge 6 ]; then
      if [ -f /etc/pam.d/system-auth ]; then
         cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
         if ((!$?)); then
            $LOGIT "AD.2.1.3 : The /etc/pam.d/system-auth file contains the password required|sufficient pam_unix.so md5 setting:"
            cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep 'md5|sha512' >> $LOGFILE
         fi
         if [ -f /etc/pam.d/password-auth ]; then
            cat /etc/pam.d/password-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
            if ((!$?)); then
               $LOGIT "AD.2.1.3 : The /etc/pam.d/password-auth file contains the password required|sufficient pam_unix.so md5 setting:"
               cat /etc/pam.d/password-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep 'md5|sha512' >> $LOGFILE
            else
               $LOGIT "AD.2.1.3 : WARNING - The /etc/pam.d/password-auth file does not contain the required setting!"
            fi
         else
            $LOGIT "AD.2.1.3 : WARNING - The /etc/pam.d/password-auth file does NOT exist!"
         fi
      fi
   fi
   if [ -f /etc/pam.d/passwd ]; then
      cat /etc/pam.d/passwd | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
      if ((!$?)); then
         $LOGIT "AD.2.1.3 : The /etc/pam.d/passwd file contains the password required|sufficient pam_unix.so md5 setting:"
         cat /etc/pam.d/passwd | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep 'md5|sha512' >> $LOGFILE
      fi
   elif [ -f /etc/pam.d/system-auth ]; then
      cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
      if ((!$?)); then
         $LOGIT "AD.2.1.3 : The /etc/pam.d/system-auth file contains the password required|sufficient pam_unix.so md5 setting:"
         cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep 'md5|sha512' >> $LOGFILE
      fi
   elif [ -s AD213_temp ]; then
      $LOGIT "AD.2.1.3 : WARNING - File(s) exist in /etc/pam.d that have password required|sufficient pam_unix.so"
      $LOGIT "but do not have md5 or sha512 set:"
      cat AD213_temp >> $LOGFILE
   else
      $LOGIT "AD.2.1.3 : All file(s) in /etc/pam.d that contain password required|sufficient pam_unix.so"
      $LOGIT "have md5 or sha512 set."
   fi
   rm -rf AD213_temp
elif [[ $OSFlavor = "SuSE" && $SVER -ge 10 ]]; then
   cat /dev/null > AD213_temp
   for file in `ls -al /etc/pam.d | grep -v "^d" | awk '{print $9}'`
   do
   cat /etc/pam.d/$file | grep "^password" | egrep 'required|sufficient' | egrep -q 'pam_unix2.so|pam_unix_passd.so'
   if ((!$?)); then
      cat /etc/pam.d/$file | grep "^password" | egrep 'required|sufficient' | egrep 'pam_unix2.so|pam_unix_passd.so' | egrep -q 'md5|sha512'
      if (($?)); then
         echo "/etc/pam.d/$file" >> AD213_temp
      fi
   fi
   done
   if [ -f /etc/pam.d/passwd ]; then
      cat /etc/pam.d/passwd | grep "^password" | egrep 'required|sufficient' | egrep 'pam_unix2.so|pam_unix_passd.so' | egrep -q 'md5|sha512'
      if ((!$?)); then
         $LOGIT "AD.2.1.3 : The /etc/pam.d/passwd file contains the password required|sufficient pam_unix.so md5 setting:"
         cat /etc/pam.d/passwd | grep "^password" | egrep 'required|sufficient' | egrep 'pam_unix2.so|pam_unix_passd.so' | egrep 'md5|sha512' >> $LOGFILE
      fi
   elif [ -f /etc/pam.d/system-auth ]; then
      cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | egrep 'pam_unix2.so|pam_unix_passd.so' | egrep -q 'md5|sha512'
      if ((!$?)); then
         $LOGIT "AD.2.1.3 : The /etc/pam.d/system-auth file contains the password required|sufficient pam_unix.so md5 setting:"
         cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | egrep 'pam_unix2.so|pam_unix_passd.so' | egrep 'md5|sha512' >> $LOGFILE
      fi
   elif [ -s AD213_temp ]; then
      $LOGIT "AD.2.1.3 : WARNING - File(s) exist in /etc/pam.d that have password required|sufficient pam_unix.so"
      $LOGIT "but do not have md5 or sha512 set:"
      cat AD213_temp >> $LOGFILE
   else
      $LOGIT "AD.2.1.3 : All file(s) in /etc/pam.d that contain password required|sufficient pam_unix.so"
      $LOGIT "have md5 or sha512 set."
   fi
   rm -rf AD213_temp
elif [[ $OSFlavor = "SuSE" && $SVER -le 9 ]]; then
   cat /dev/null > AD213_temp
   for file in `ls -al /etc/pam.d | grep -v "^d" | awk '{print $9}'`
   do
   cat /etc/pam.d/$file | grep "^password" | egrep 'required|sufficient' | grep -q "pam_unix.so"
   if ((!$?)); then
      cat /etc/pam.d/$file | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
      if (($?)); then
         echo "/etc/pam.d/$file" >> AD213_temp
      fi
   fi
   done
   if [ -f /etc/pam.d/passwd ]; then
      cat /etc/pam.d/passwd | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
      if ((!$?)); then
         $LOGIT "AD.2.1.3 : The /etc/pam.d/passwd file contains the password required|sufficient pam_unix.so md5 setting:"
         cat /etc/pam.d/passwd | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep 'md5|sha512' >> $LOGFILE
      fi
   elif [ -f /etc/pam.d/system-auth ]; then
      cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep -q 'md5|sha512'
      if ((!$?)); then
         $LOGIT "AD.2.1.3 : The /etc/pam.d/system-auth file contains the password required|sufficient pam_unix.so md5 setting:"
         cat /etc/pam.d/system-auth | grep "^password" | egrep 'required|sufficient' | grep "pam_unix.so" | egrep 'md5|sha512' >> $LOGFILE
      fi
   elif [ -s AD213_temp ]; then
      $LOGIT "AD.2.1.3 : WARNING - File(s) exist in /etc/pam.d that have password required|sufficient pam_unix.so"
      $LOGIT "but do not have md5 or sha512 set:"
      cat AD213_temp >> $LOGFILE
   else
      $LOGIT "AD.2.1.3 : All file(s) in /etc/pam.d that contain password required|sufficient pam_unix.so"
      $LOGIT "have md5 or sha512 set."
   fi
   rm -rf AD213_temp
else
   $LOGIT "AD.2.1.3 : WARNING - THIS IS AN UNSUPPORTED VERSION OF LINUX AND CANNOT BE CHCKED!!!"
fi

$LOGIT ""
cat /dev/null > AD214_temp
for ID in `cat /etc/passwd | awk -F':' '{print $1}'`
do
IDhome=`grep "^$ID:" /etc/passwd | awk -F':' '{print $6}'`
if [[ -n $IDhome ]] && [[ -d $IDhome ]]; then
   if [ -d $IDhome/.ssh ]; then
      if [ -f $IDhome/.ssh/id_rsa ]; then
         PERM=`ls -al $IDhome/.ssh/id_rsa | awk '{print $1}' | cut -c5-6,8-9`
         if [ $PERM != "----" ]; then
            echo "$ID:" >> AD214_temp
            ls -al $IDhome/.ssh/id_rsa >> AD214_temp
            echo "" >> AD214_temp
         fi
      fi
   fi
fi
done
$LOGIT "AD.2.1.4 : THIS SCRIPT CAN ONLY CHECK LOCAL USERS!"
if [ -s AD214_temp ]; then
   $LOGIT "AD.2.1.4 : WARNING - The following users have private keys that are readable and/or writeable by other than the owner:"
   cat AD214_temp >> $LOGFILE
else
   $LOGIT "AD.2.1.4 : All local users were checked and no private keys were found that were readable and/or writeable by other than the owner."
fi
rm -rf AD214_temp

$LOGIT ""
$LOGIT "AD.5.0.1 : THIS SCRIPT CANNOT CHECK THIS SECTION!!!"

$LOGIT ""
cat /dev/null > AD502_temp
for id in `cat /etc/passwd | awk -F':' '{print $1}'`
do
   GROUPlist=`/usr/bin/groups $id | awk -F':' '{print $2}'`
   for GROUP in `/usr/bin/groups $id | awk -F':' '{print $2}'`
   do
   GROUPid=`grep "^$GROUP:" /etc/group | awk -F':' '{print $3}'`
   if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
      if [[ $GROUPid -le 99 ]] || [[ $GROUPid -ge 101 && $GROUPid -le 199 ]]; then
         grep -wq $id AD502_temp
         if (($?)); then
            if [ ! -s AD502_temp ]; then
               echo "USERid\t:\tGroup(s)" >> AD502_temp
               echo "========================" >> AD502_temp
            fi
            echo "$id\t:\t$GROUPlist" >> AD502_temp
         fi
      fi
   else
      if [ $GROUPid -le 99 ]; then
         grep -wq $id AD502_temp
         if (($?)); then
            if [ ! -s AD502_temp ]; then
               echo "USERid\t:\tGroup(s)" >> AD502_temp
               echo "========================" >> AD502_temp
            fi
            echo "$id\t:\t$GROUPlist" >> AD502_temp
         fi
      fi
   fi
   done
done
if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
   TEMPout="GID <= 99 or GID >= 101 and <= 199"
else
   TEMPout="GID <= 99"
fi
if [ -s AD502_temp ]; then
   $LOGIT "AD.5.0.2 : Here is a list of USERids which belong to group(s) with $TEMPout :"
   cat AD502_temp >> $LOGFILE
else
   $LOGIT "AD.5.0.2 : N/A - There are not USERids which belong to group(s) with $TEMPout."
fi
rm -rf AD502_temp



##
#This section is for HIPAA Accounts only!!!
##
if ((!$HIPAA_Check)); then
   $LOGIT ""
   ShowLogList=1
   if [ -f /etc/cron.daily/logrotate ]; then
      if [ -f /etc/logrotate.conf ]; then
         grep "^rotate" /etc/logrotate.conf > /dev/null 2>&1
         if ((!$?)); then
            RotateDays=`grep "^rotate" /etc/logrotate.conf | awk '{print $2}' | head -1`
            if [ $RotateDays -lt 39 ]; then
               $LOGIT "AD.10.1.2.1 : WARNING - The system is NOT keeping 270 days worth of log files. It is only keeping $RotateDays week(s) of log files."
            else
               $LOGIT "AD.10.1.2.1 : The system is keeping at least 270 days worth of log files."
               grep "^rotate" /etc/logrotate.conf | head -1 >> $LOGFILE
            fi
         else
            $LOGIT "AD.10.1.2.1 : WARNING - The rotate paramter is not set in /etc/logrotate.conf!"
            ShowLogList=0
         fi
      else
         $LOGIT "AD.10.1.2.1 : WARNING - The /etc/logrotate.conf file does not exist!"
         ShowLogList=0
      fi
   else
      $LOGIT "AD.10.1.2.1 : WARNING - The /etc/cron.daily/logrotate file does not exist!"
      ShowLogList=0
   fi
   if ((!$ShowLogList)); then
      $LOGIT "AD.10.1.2.1 : Here is a long listing of the system log files. Ensure there are at least 270 days worth:"
      for file in messages secure wtmp faillog
      do
      ls -al /var/log/$file | awk '{print $9,"==== "$6,$7,$8}' >> $LOGFILE
      done
   fi
   
   $LOGIT ""
   $LOGIT "AD.10.1.2.2 - Refer to section 20 below, if necessary."
   
   $LOGIT ""
   if [ -f /etc/profile ]; then
      grep "/etc/profile.d/IBMsinit.sh" /etc/profile | grep -v "^#" > /dev/null 2>&1
      if (($?)); then
         grep "/etc/profile.local" /etc/profile | grep -v "^#" /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.10.1.4.1 : WARNING - The /etc/profile file does not invoke the /etc/profile.d/IBMsinit.sh script. It also does not invoke /etc/profile.local as a secondary check!"
         else
            grep "/etc/profile.d/IBMsinit.sh" /etc/profile.local | grep -v "^#" > /dev/null 2>&1
            if ((!$?)); then
               $LOGIT "AD.10.1.4.1 : The /etc/profile invokes /etc/profile.local which invokes /etc/profile.d/IBMsinit.sh."
               grep "/etc/profile.d/IBMsinit.sh" /etc/profile.local | grep -v "^#" >> $LOGFILE
               if [ ! -f /etc/profile.d/IBMsinit.sh ]; then
                  $LOGIT "AD.10.1.4.1 : WARNING - The /etc/profile.d/IBMsinit.sh script does not exist!"
               else
                  grep "TMOUT" /etc/profile | grep -v "^#" > /dev/null 2>&1
                  if ((!$?)); then
                     FoundTimeOut=`cat /etc/profile | grep -n "TMOUT" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     FoundLocalCall=`cat /etc/profile | grep -n "/etc/profile.local" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     if [ $FoundTimeOut -gt $FoundLocalCall ]; then
                        $LOGIT "AD.10.1.4.1 : WARNING - The TMOUT setting is set/reset after the invocation of /etc/profile.local!"
                     else
                        $LOGIT "AD.10.1.4.1 : The TMOUT setting was not found after the invocation of the /etc/profile.local."
                     fi
                  else
                     $LOGIT "AD.10.1.4.1 : The TMOUT setting was not found in the /etc/profile file."
                  fi
                  grep "TMOUT" /etc/profile.local | grep -v "^#" /dev/null 2>&1
                  if ((!$?)); then
                     FoundTimeOut=`cat /etc/profile.local | grep -n "TMOUT" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     FoundIBMScript=`cat /etc/profile.local | grep -n "/etc/profile.d/IBMsinit.sh" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     if [ $FoundTimeOut -gt $FoundIBMScript ]; then
                        $LOGIT "AD.10.1.4.1 : WARNING - The TMOUT setting is set/reset after the invocation of the /etc/profile.d/IBMsinit.sh script!"
                     else
                        $LOGIT "AD.10.1.4.1 : The TMOUT seting was not found after the invocation of the /etc/profile.d/IBMsinit.sh script."
                     fi
                  else
                     $LOGIT "AD.10.1.4.1 : The TMOUT setting was not found in the /etc/profile.local file."
                  fi
               fi
            else
               $LOGIT "AD.10.1.4.1 : WARNING - The /etc/profile invokes the /etc/profile.local, but /etc/profile.local does NOT invoke the /etc/profile.d/IBMsinit.sh script!"
            fi
         fi
      else
         $LOGIT "AD.10.1.4.1 : The /etc/profile invokes the /etc/profile.d/IBMsinit.sh script."
         grep "/etc/profile.d/IBMsinit.sh" /etc/profile | grep -v "^#" >> $LOGFILE
         if [ ! -f /etc/profile.d/IBMsinit.sh ]; then
            $LOGIT "AD.10.1.4.1 : WARNING - The /etc/profile.d/IBMsinit.sh script does not exist!"
         else
            grep "TMOUT" /etc/profile | grep -v "^#" > /dev/null 2>&1
            if ((!$?)); then
               FoundTimeOut=`cat /etc/profile | grep -n "TMOUT" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
               FoundIBMScript=`cat /etc/profile | grep -n "/etc/profile.d/IBMsinit.sh" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
               if [ $FoundTimeOut -gt $FoundIBMScript ]; then
                  $LOGIT "AD.10.1.4.1 : WARNING - The TMOUT setting is set/reset after the invocation of the /etc/profile.d/IBMsinit.sh script in /etc/profile!"
               else
                  $LOGIT "AD.10.1.4.1 : The TMOUT setting was not found after the invocation of the /etc/profile.d/IBMsinit.sh script."
               fi
            else
               $LOGIT "AD.10.1.4.1 : The TMOUT setting was not found in /etc/profile."
            fi
         fi
      fi
   else
      $LOGIT "AD.10.1.4.1 : WARNING - The /etc/profile file does NOT exist!"
   fi
   

   $LOGIT ""
   RPMcheck=1
   for RPMsum in coreutils openssl
   do
   rpm -q $RPMsum > /dev/null 2>&1
   if ((!$?)); then
      RPMcheck=0
   fi
   done
   if ((!$RPMcheck)); then
      $LOGIT "AD.10.1.4.2 : The following RPM(s) are installed:"
      rpm -q openssl coreutils >> $LOGFILE
   else
      $LOGIT "AD.10.1.4.2 : WARNING - None of the required RPMs are installed!"
   fi
   
   $LOGIT ""
   $LOGIT "AD.10.1.4.3 : THIS SCRIPT CANNOT CHECK THIS SECTION!!!"

   $LOGIT ""
   if [ -f /etc/csh.login ]; then
      grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login | grep -v "^#" > /dev/null 2>&1
      if (($?)); then
         grep "/etc/csh.login.local" /etc/csh.login | grep -v "^#" /dev/null 2>&1
         if (($?)); then
            $LOGIT "AD.10.1.4.6 : WARNING - The /etc/csh.login file does not invoke the /etc/profile.d/IBMsinit.csh script. It also does not invoke /etc/csh.login.local as a secondary check!"
         else
            grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login.local | grep -v "^#" > /dev/null 2>&1
            if ((!$?)); then
               $LOGIT "AD.10.1.4.6 : The /etc/csh.login invokes /etc/csh.login.local which invokes /etc/profile.d/IBMsinit.csh."
               grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login.local | grep -v "^#" >> $LOGFILE
               if [ ! -f /etc/profile.d/IBMsinit.csh ]; then
                  $LOGIT "AD.10.1.4.6 : WARNING - The /etc/profile.d/IBMsinit.csh script does not exist!"
               else
                  grep "autologout" /etc/csh.login | grep -v "^#" > /dev/null 2>&1
                  if ((!$?)); then
                     FoundTimeOut=`cat /etc/csh.login | grep -n "autologout" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     FoundLocalCall=`cat /etc/csh.login | grep -n "/etc/csh.login.local" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     if [ $FoundTimeOut -gt $FoundLocalCall ]; then
                        $LOGIT "AD.10.1.4.6 : WARNING - The autologout setting is set/reset after the invocation of /etc/csh.login.local!"
                     else
                        $LOGIT "AD.10.1.4.6 : The autologout setting was not found after the invocation of the /etc/csh.login.local."
                     fi
                  else
                     $LOGIT "AD.10.1.4.6 : The autologout setting was not found in the /etc/csh.login file."
                  fi
                  grep "autologout" /etc/csh.login.local | grep -v "^#" /dev/null 2>&1
                  if ((!$?)); then
                     FoundTimeOut=`cat /etc/csh.login.local | grep -n "autologout" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     FoundIBMScript=`cat /etc/csh.login.local | grep -n "/etc/profile.d/IBMsinit.csh" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
                     if [ $FoundTimeOut -gt $FoundIBMScript ]; then
                        $LOGIT "AD.10.1.4.6 : WARNING - The autologout setting is set/reset after the invocation of the /etc/profile.d/IBMsinit.csh script!"
                     else
                        $LOGIT "AD.10.1.4.6 : The autologout seting was not found after the invocation of the /etc/profile.d/IBMsinit.csh script."
                     fi
                  else
                     $LOGIT "AD.10.1.4.6 : The autologout setting was not found in the /etc/csh.login.local file."
                  fi
               fi
            else
               $LOGIT "AD.10.1.4.6 : WARNING - The /etc/csh.login invokes the /etc/csh.login.local, but /etc/csh.login.local does NOT invoke the /etc/profile.d/IBMsinit.csh script!"
            fi
         fi
      else
         $LOGIT "AD.10.1.4.6 : The /etc/csh.login invokes the /etc/profile.d/IBMsinit.csh script."
         grep "/etc/profile.d/IBMsinit.csh" /etc/csh.login | grep -v "^#" >> $LOGFILE
         if [ ! -f /etc/profile.d/IBMsinit.csh ]; then
            $LOGIT "AD.10.1.4.6 : WARNING - The /etc/profile.d/IBMsinit.csh script does not exist!"
         else
            grep "autologout" /etc/csh.login | grep -v "^#" > /dev/null 2>&1
            if ((!$?)); then
               FoundTimeOut=`cat /etc/csh.login | grep -n "autologout" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
               FoundIBMScript=`cat /etc/csh.login | grep -n "/etc/profile.d/IBMsinit.csh" | grep -v "^#" | tail -1 | awk -F':' '{print $1}'`
               if [ $FoundTimeOut -gt $FoundIBMScript ]; then
                  $LOGIT "AD.10.1.4.6 : WARNING - The autologout setting is set/reset after the invocation of the /etc/profile.d/IBMsinit.csh script in /etc/csh.login!"
               else
                  $LOGIT "AD.10.1.4.6 : The autologout setting was not found after the invocation of the /etc/profile.d/IBMsinit.csh script."
               fi
            else
               $LOGIT "AD.10.1.4.6 : The autologout setting was not found in /etc/csh.login."
            fi
         fi
      fi
   else
      $LOGIT "AD.10.1.4.6 : WARNING - The /etc/csh.login file does NOT exist!"
   fi

   $LOGIT ""
   if [ -f /etc/profile.d/IBMsinit.sh ]; then
      grep "TMOUT" /etc/profile.d/IBMsinit.sh | grep -v "^#" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.10.1.4.7 : WARNING - The TMOUT setting does not appear in the /etc/profile.d/IBMsinit.sh script!"
      else
         TMOUTsetting=`grep "TMOUT" /etc/profile.d/IBMsinit.sh | grep -v "^#" | tail -1 | awk -F'=' '{print $2}'`
         if [ $TMOUTsetting -gt 1800 ]; then
            $LOGIT "AD.10.1.4.7 : WARNING - The TMOUT setting in /etc/profile.d/IBMsinit.sh is set to a value that is higher than 1800:"
         else
            $LOGIT "AD.10.1.4.7 : The TMOUT setting in /etc/profile.d/IBMsinit.sh is set to 1800 or lower:"
         fi
         grep "TMOUT" /etc/profile.d/IBMsinit.sh | grep -v "^#" | tail -1 >> $LOGFILE
      fi
      grep "export TMOUT" /etc/profile.d/IBMsinit.sh | grep -v "^#" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.10.1.4.7 : WARNING - The TMOUT variable is NOT being exported in /etc/profile.d/IBMsinit.sh!"
      else
         $LOGIT "AD.10.1.4.7 : The TMOUT variable is being exported in /etc/profile.d/IBMsinit.sh:"
         grep "export TMOUT" /etc/profile.d/IBMsinit.sh | grep -v "^#" >> $LOGFILE
      fi
   else
      $LOGIT "AD.10.1.4.7 : WARNING - The /etc/profile.d/IBMsinit.sh script does NOT exist!"
   fi
   
   $LOGIT ""
   if [ -f /etc/profile.d/IBMsinit.csh ]; then
      grep "set autologout=30" /etc/profile.d/IBMsinit.csh | grep -v "^#" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.10.1.4.8 : WARNING - The autologout setting does not exist in /etc/profile.d/IBMsinit.csh!"
      else
         AutoLogOutSetting=`grep "set autologout=30" /etc/profile.d/IBMsinit.csh | grep -v "^#" | tail -1 | awk -F'=' '{print $2}'`
         if [ $AutoLogOutSetting -gt 30 ]; then
            $LOGIT "AD.10.1.4.8 : WARNING - The autologout setting in /etc/profile.d/IBMsinit.csh is set to a value that is higher than 30!"
         else
            $LOGIT "AD.10.1.4.8 : The autologout setting in /etc/profile.d/IBMsinit.csh is set to 30 or lower:"
         fi
         grep "set autologout=30" /etc/profile.d/IBMsinit.csh | grep -v "^#" | tail -1 >> $LOGFILE
      fi
   else
      $LOGIT "AD.10.1.4.8 : WARNING - The /etc/profile.d/IBMsinit.csh script does NOT exist!"
   fi

   $LOGIT ""
   for file in /etc/skel/.cshrc /etc/skel/.login /etc/skel/.profile /etc/skel/.bashrc /etc/skel/.bash_profile /etc/skel/.bash_login /etc/skel/.tcshrc
   do
   if [ -f $file ]; then
      egrep -i 'TMOUT|autologout' $file | grep -v "^#" | grep "=" > /dev/null 2>&1
      if (($?)); then
         $LOGIT "AD.10.1.4.9 : The file $file exists, but does not contain the TMOUT or autologout variables in it."
      else
         $LOGIT "AD.10.1.4.9 : WARNING - The file $file exists and appears to contain the TMOUT and/or autologout variable in it!"
         egrep -i 'TMOUT|autologout' $file | grep -v "^#" | grep "=" >> $LOGFILE
      fi
   else
      $LOGIT "AD.10.1.4.9 : The file $file does not exist on this server."
   fi
   done
   
   $LOGIT ""
   grep ":/bin/sync" /etc/passwd | grep -v "^sync:" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.10.1.4.10 : The /bin/sync shell is not associated with any ID other than sync."
   else
      $LOGIT "AD.10.1.4.10 : WARNING - The /bin/sync shell is associated with ID(s) other than sync!"
      grep ":/bin/sync" /etc/passwd | grep -v "^sync:" >> $LOGFILE
   fi
   grep ":/sbin/shutdown" /etc/passwd | grep -v "^shutdown:" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.10.1.4.10 : The /sbin/shutdown shell is not associated with any ID other than shutdown."
   else
      $LOGIT "AD.10.1.4.10 : WARNING - The /sbin/shutdown shell is associated with ID(s) other than shutdown!"
      grep ":/sbin/shutdown" /etc/passwd | grep -v "^shutdown:" >> $LOGFILE
   fi
   grep ":/sbin/halt" /etc/passwd | grep -v "^halt:" > /dev/null 2>&1
   if (($?)); then
      $LOGIT "AD.10.1.4.10 : The /sbin/halt shell is not associated with any ID other than halt."
   else
      $LOGIT "AD.10.1.4.10 : WARNING - The /sbin/halt shell is associated with ID(s) other than halt!"
      grep ":/sbin/halt" /etc/passwd | grep -v "^halt:" >> $LOGFILE
   fi
   cat /dev/null > AD101410_temp
   for UserID in `cat /etc/passwd | awk -F':' '{print $1}' | egrep -vw 'sync|shutdown|halt'`
   do
   UserIDShell=`grep "$UserID:" /etc/passwd | awk -F':' '{print $7}'`
   echo $UserIDShell | egrep '/bin/csh|/bin/tcsh|/bin/sh|/bin/bash|/bin/false|/sbin/nologin' > /dev/null 2>&1
   if (($?)); then
      if [ -L $UserIDShell ]; then
         TestShell=`readlink $UserIDShell`
         echo $TestShell | egrep 'chs|tcsh|sh|bash|false|nologin' > /dev/null 2>&1
         if (($?)); then
            grep "$UserID:" /etc/passwd >> AD101410_temp
         fi
      else
         grep "$UserID:" /etc/passwd >> AD101410_temp
      fi
   fi
   done
   if [ -s AD101410_temp ]; then
      $LOGIT "AD.10.1.4.10 : WARNING - ID(s) exist that with a shell that does not meet requirements:"
      cat AD101410_temp >> $LOGFILE
   else
      $LOGIT "AD>10.1.4.10 : All other IDs are set to use a log shell that meets all requirements of this section."
   fi
   rm -rf AD101410_temp
fi

##
#This section is for Privileged Monitoring Accounts only!!!
##
if ((!$PMS_Check)); then
   $LOGIT ""
   if [ $OSFlavor = "RedHat" ]; then
      if [ $RHVER -lt 5 ]; then
         if [ -f /etc/syslog.conf ]; then
            grep "\*.info" /etc/syslog.conf | grep "mail.none" | grep "authpriv.none" | grep "cron.none" | grep -q "/var/log/messages"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.1 : The '*.info;mail.none;authpriv.none;cron.none /var/log/messages' entry exists in /etc/syslog.conf"
               grep "\*.info" /etc/syslog.conf | grep "mail.none" | grep "authpriv.none" | grep "cron.none" | grep "/var/log/messages" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.1 : WARNING - The '*.info;mail.none;authpriv.none;cron.none /var/log/messages' entry does NOT exist in /etc/syslog.conf"
            fi
            grep "\*.info" /etc/syslog.conf | grep "mail.none" | grep -q "\@"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.1 : The '*.info;mail.none @' entry appears to exist in /etc/syslog.conf"
               grep "\*.info" /etc/syslog.conf | grep "mail.none" | grep -"\@" >> $LOGFILE
               $LOGIT "AD.20.1.2.1 : Please verify the above entry contains the actual TCIM Collector hostname or IP!"
            else
               $LOGIT "AD.20.1.2.1 : WARNING - The '*.info;mail.none @' entry does NOT appear to exist in /etc/syslog.conf!"
            fi
         else
            $LOGIT "AD.20.1.2.1 : WARNING - The /etc/syslog.conf file does not exist!"
         fi
      else
         $LOGIT "AD.20.1.2.1 : N/A - This is a $OSFLavor $RHVER server."
         $LOGIT ""
         if [ -f /var/log/audit/audit.log ]; then
            $LOGIT "AD.20.1.2.2 : The audit.log file exists:"
            ls -al /var/log/audit/audit.log >> $LOGFILE
         else
            $LOGIT "AD.20.1.2.2 : WARNING - The audit.log file does not exist!"
         fi
         if [ -f /etc/audit/audit.rules ]; then
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/usr" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.1 : The '-a exit,always -F path=/usr -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/usr" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.1 : WARNING - The '-a exit,always -F path=/usr -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.2 : The '-a exit,always -F path=/etc -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.2 : WARNING - The '-a exit,always -F path=/etc -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.3 : The '-a exit,always -F path=/var/log -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.3 : WARNING - The '-a exit,always -F path=/var/log -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/tmp" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.4 : The '-a exit,always -F path=/tmp -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/tmp" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.4 : WARNING - The '-a exit,always -F path=/tmp -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/faillog" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.5 : The '-a exit,always -F path=/var/log/faillog -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/faillog" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.5 : WARNING - The '-a exit,always -F path=/var/log/faillog -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/messages" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.6 : The '-a exit,always -F path=/var/log/messages -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/messages" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.6 : WARNING - The '-a exit,always -F path=/var/log/messages -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/wtmp" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.7 : The '-a exit,always -F path=/var/log/wtmp -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/wtmp" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.7 : WARNING - The '-a exit,always -F path=/var/log/wtmp -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/secure" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.8 : The '-a exit,always -F path=/var/log/secure -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/secure" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.8 : WARNING - The '-a exit,always -F path=/var/log/secure -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/ssh/sshd_config" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.9 : The '-a exit,always -F path=/etc/ssh/sshd_config -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/ssh/sshd_config" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.9 : WARNING - The '-a exit,always -F path=/etc/ssh/sshd_config -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/default" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.10 : The '-a exit,always -F path=/etc/default -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/default" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.10 : WARNING - The '-a exit,always -F path=/etc/default -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/audit/audit.log" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.11 : The '-a exit,always -F path=/var/log/audit/audit.log -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/var/log/audit/audit.log" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.11 : WARNING - The '-a exit,always -F path=/var/log/audit/audit.log -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/audit/auditd.conf" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.12 : The '-a exit,always -F path=/etc/audit/auditd.conf -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/audit/auditd.conf" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.12 : WARNING - The '-a exit,always -F path=/etc/audit/auditd.conf -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/audit/audit.rules" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.13 : The '-a exit,always -F path=/etc/audit/audit.rules -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/audit/audit.rules" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.13 : WARNING - The '-a exit,always -F path=/etc/audit/audit.rules -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/sbin/auditctl" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.14 : The '-a exit,always -F path=/sbin/auditctl -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/sbin/auditctl" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.14 : WARNING - The '-a exit,always -F path=/sbin/auditctl -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/sbin/auditd" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.15 : The '-a exit,always -F path=/sbin/auditd -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/sbin/auditd" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.15 : WARNING - The '-a exit,always -F path=/sbin/auditd -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/sbin/ausearch" | grep -q "\-F perm=a"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.16 : The '-a exit,always -F path=/sbin/ausearch -F perm=a' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/sbin/ausearch" | grep "\-F perm=a" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.16 : WARNING - The '-a exit,always -F path=/sbin/ausearch -F perm=a' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/syslog.conf" | egrep -q '\-F perm=wa|\-F perm=aw'
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.17 : The '-a exit,always -F path=/etc/syslog.conf -F perm=wa' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/syslog.conf" | egrep '\-F perm=wa|\-F perm=aw' >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.17 : WARNING - The '-a exit,always -F path=/etc/syslog.conf -F perm=wa' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/syslog.conf" | egrep -q '\-F perm=wa|\-F perm=aw'
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.18 : The '-a exit,always -F path=/etc/syslog.conf -F perm=wa' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=/etc/syslog.conf" | egrep '\-F perm=wa|\-F perm=aw' >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.18 : WARNING - The '-a exit,always -F path=/etc/syslog.conf -F perm=wa' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=" | grep "[a-z]/snmpd.conf" | egrep -q '\-F perm=wa|\-F perm=aw'
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.19 : The '-a exit,always -F path=<path to snmpd >/snmpd.conf -F perm=wa' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=" | grep "[a-z]/snmpd.conf" | egrep '\-F perm=wa|\-F perm=aw' >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.19 : WARNING - The '-a exit,always -F path=<path to snmpd >/snmpd.conf -F perm=wa' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=" | grep "[a-z]/snmp/snmpd.conf" | egrep -q '\-F perm=wa|\-F perm=aw'
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.20 : The '-a exit,always -F path=<path to snmpd >/snmp/snmpd.conf -F perm=wa' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=" | grep "[a-z]/snmp/snmpd.conf" | egrep '\-F perm=wa|\-F perm=aw' >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.20 : WARNING - The '-a exit,always -F path=<path to snmpd >/snmp/snmpd.conf -F perm=wa' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=" | grep "[a-z]/snmpd/snmpd.conf" | egrep -q '\-F perm=wa|\-F perm=aw'
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.21 : The '-a exit,always -F path=<path to snmpd >/snmpd/snmpd.conf -F perm=wa' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=" | grep "[a-z]/snmpd/snmpd.conf" | egrep '\-F perm=wa|\-F perm=aw' >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.21 : WARNING - The '-a exit,always -F path=<path to snmpd >/snmpd/snmpd.conf -F perm=wa' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            root_home=`grep "^root:" /etc/passwd | awk -F ':' '{print $6}'`
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=$root_home/.rhosts" | egrep -q '\-F perm=wa|\-F perm=aw'
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.22 : The '-a exit,always -F path=<root home>/.rhosts -F perm=wa' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=$root_home/.rhosts" | egrep '\-F perm=wa|\-F perm=aw' >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.22 : WARNING - The '-a exit,always -F path=<root home>/.rhosts -F perm=wa' entry does NOT exist in /etc/audit/audit.rules!"
            fi
            $LOGIT ""
            root_home=`grep "^root:" /etc/passwd | awk -F ':' '{print $6}'`
            grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=$root_home/.netrc" | egrep -q '\-F perm=wa|\-F perm=aw'
            if ((!$?)); then
               $LOGIT "AD.20.1.2.3.23 : The '-a exit,always -F path=<root home>/.netrc -F perm=wa' entry exists in /etc/audit/audit.rules:"
               grep "^\-a exit,always" /etc/audit/audit.rules | grep "\-F path=$root_home/.netrc" | egrep '\-F perm=wa|\-F perm=aw' >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.3.23 : WARNING - The '-a exit,always -F path=<root home>/.netrc -F perm=wa' entry does NOT exist in /etc/audit/audit.rules!"
            fi
         else
            X=1
            until [ $X -eq 24 ]
            do
            $LOGIT ""
            $LOGIT "AD.20.1.2.3.$X : WARNING - The /etc/audit/audit.rules file does NOt exist!"
            ((X+=1))
            done
         fi
         $LOGIT ""
         if [ -f /etc/sudoers ]; then
            grep "ALL=(ALL)" /etc/sudoers | grep "NOPASSWD" | grep -q "/sbin/ausearch"
            if ((!$?)); then
               $LOGIT "AD.20.1.2.4 : CAUTION - The parameters 'ALL=(ALL) NOPASSWD /sbin/ausearch' were found in /etc/sudoers. However, this script canNOT determine the TCIM collector ID is correct. Please verify!"
               grep "ALL=(ALL)" /etc/sudoers | grep "NOPASSWD" | grep "/sbin/ausearch" >> $LOGFILE
            else
               $LOGIT "AD.20.1.2.4 : WARNING - The parameters 'ALL=(ALL) NOPASSWD /sbin/ausearch' were NOT found in /etc/sudoers."
            fi
         else
            $LOGIT "AD.20.1.2.4 : WARNING - The /etc/sudoers file could not be found!"
         fi
      fi
   else
      $LOGIT ""
      $LOGIT "AD.20.1.2.1 : N/A - This is a $OSFlavor server"
      $LOGIT ""
      $LOGIT "AD.20.1.2.2 : N/A - This is a $OSFlavor server"
      X=1
      until [ $X -eq 24 ]
      do
      $LOGIT ""
      $LOGIT "AD.20.1.2.3.$X : N/A - This is a $OSFlavor server"
      ((X+=1))
      done
   fi
fi








$LOGIT " "
$LOGIT " "
$LOGIT " "
$LOGIT "#########################################################################"
$LOGIT "#"
$LOGIT "#		iSeC ssh checking begins here:"
$LOGIT "#"
$LOGIT "#########################################################################"
$LOGIT " "
$LOGIT " "

SSHD=/etc/ssh/sshd_config
#OUTPUT=/tmp/ISEC_SSH_`uname -n`.`date +%m%d%y`.output.txt
#SUB variable is used in the ShouldNot_Comment function to determine which routines
#to run dependent on the number of variables to check. 
#Setting of 0 means 1 variable to check which is the default.
SUB=0
FOUND=1


###################################################
# Functions are here:
###################################################
ShouldNot_Comment () {
CHECK=0
NUMINST=`/bin/grep -w $VAL $SSHD | /bin/grep -v grep | /bin/grep -wv and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions | wc -l`
if [ $NUMINST -gt 1 ]; then
	$LOGIT "WARNING - More than one entry of $VAL was found in $SSHD"
	$LOGIT "WARNING - The $SSHD file MAY need to be checked manually and cleaned up!"
fi
/bin/grep -w $VAL $SSHD | /bin/grep -v grep | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions > /dev/null 2>&1
if [ $? -eq 0 ]; then
	/bin/grep -w $VAL $SSHD | /bin/grep -v grep | /bin/grep -v and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions >> $LOGFILE
	/bin/grep -w $VAL $SSHD | /bin/grep -v "^#" | /bin/grep -v grep | grep -vw regenerates | grep -vw pass | /bin/grep -vw and | grep -vw setting | grep -vw Uncomment | grep -vw versions > /dev/null 2>&1
		if [ $? -eq 1 ]; then
			CHECK=1
			$LOGIT "The above line should not be #ed out" 
		fi
	TEST=`/bin/grep -w $VAL $SSHD | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions | awk '{print $2}' | head -1`
	if [ $SUB -eq 0 ]; then
		if [ $TEST != $VAL2 ]; then
			$LOGIT "The above line should be set to $VAL2"
			CHECK=1
		fi
	elif [ $SUB -eq 1 ]; then
		if [ $TEST != $VAL2 ] && [ $TEST != $VAL3 ] && [ $TEST != $VAL4 ]; then
			$LOGIT "The above line should be set to $VAL2 or $VAL3 or $VAL4"
			CHECK=1
		fi
	elif [ $SUB -eq 3 ]; then
	   if ((!$?)); then
	      TEST=`echo $TEST | awk -F":" '{print $NF}'`
	   fi
		VAL3a=`echo $VAL3 | tr -d [[:alpha:]]`
		VAL3b=`echo $VAL3 | tr -d [[:digit:]]`
		TESTa=`echo $TEST | tr -d [[:alpha:]]`
		TESTb=`echo $TEST | tr -d [[:digit:]]`
		if [[ $TESTb = *[$VAL3b] ]] || [[ -z $TESTb ]] && [ $TESTa -le $VAL3a ]; then
			CHECK=$CHECK
		else
			CHECK=1
        		$LOGIT "The above line should bet set to a Max value of of $VAL2"
		fi		
	fi

else
	CHECK=1
	$LOGIT " WARNING - $VAL setting not found in $SSHD"
fi
if [ $CHECK -eq 0 ]; then
	$LOGIT "	$VAL is set correctly"
else
	$LOGIT "	WARNING - $VAL is NOT configured correctly."
fi
#SUB set back to 0 to run standard
SUB=0
return
} #ShouldNot_Comment

Should_Comment () {
CHECK=0
NUMINST=`/bin/grep -w $VAL $SSHD | /bin/grep -v grep | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions | wc -l`
if [ $NUMINST -gt 1 ]; then
	$LOGIT "WARNING - More than one entry of $VAL was found in $SSHD"
	$LOGIT "WARNING - The $SSHD file MAY need to be checked manually and cleaned up!"
fi
/bin/grep -w $VAL $SSHD | /bin/grep -v grep | /bin/grep -vw and | grep -vw regenerates | grep -vw setting | grep -vw Uncomment | grep -vw versions | grep -vw pass > /dev/null 2>&1
if [ $? -eq 0 ]; then
	/bin/grep -w $VAL $SSHD | /bin/grep -v grep | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions >> $LOGFILE
	if [ $NUMINST -gt 1 ]; then
	   /bin/grep -w $VAL $SSHD | /bin/grep -vw and | grep -vw pass | grep -vw regenerates | grep -vw setting | grep -vw Uncomment | grep -vw versions | grep -vw pass | grep -v "^#" > /dev/null 2>&1
	   if ((!$?)); then
	      TEST=`/bin/grep -w $VAL $SSHD | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions | grep -vw pass | grep -v "^#" | tail -1 | awk '{print $2}'`
	   else
	      TEST=`/bin/grep -w $VAL $SSHD | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions | grep -vw pass | tail -1 | awk '{print $2}'`
	   fi
	else
	   TEST=`/bin/grep -w $VAL $SSHD | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions | grep -vw pass | awk '{print $2}'`
	fi
	if [ $SUB -eq 0 ]; then
	   /bin/grep -w $VAL $SSHD | /bin/grep -v "^#" | grep -vw regenerates | /bin/grep -v grep | /bin/grep -vw and | grep -vw setting | grep -vw Uncomment | grep -vw versions | grep -vw pass > /dev/null 2>&1
		if [ $? -eq 0 ] && [ $TEST != $VAL2 ]; then
			$LOGIT "The above line should be #ed out or set to $VAL2"
			CHECK=1
		fi
	elif [ $SUB -eq 1 ]; then
	   /bin/grep -w $VAL $SSHD | /bin/grep -v "^#" | /bin/grep -v grep | grep -vw regenerates | /bin/grep -vw and | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions > /dev/null 2>&1
		if [ $? -eq 0 ] && [ $TEST != $VAL2 ] && [ $TEST != $VAL3 ] && [ $TEST != $VAL4 ]; then
			$LOGIT "The above line should be #ed out or set to $VAL2 or $VAL3 or $VAL4"
			CHECK=1
		fi
	elif [ $SUB -eq 3 ]; then
	   echo $TEST | grep ":" > /dev/null 2>&1
	   if ((!$?)); then
	      TEST=`echo $TEST | awk -F":" '{print $NF}'`
	   fi
		VAL3a=`echo $VAL3 | tr -d [[:alpha:]]`
		VAL3b=`echo $VAL3 | tr -d [[:digit:]]`
		TESTa=`echo $TEST | tr -d [[:alpha:]]`
		TESTb=`echo $TEST | tr -d [[:digit:]]`
		/bin/grep -w $VAL $SSHD | /bin/grep -v "^#" | /bin/grep -v grep | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions > /dev/null 2>&1
		if [ $? -eq 0 ] || [[ $TESTb = *[$VAL3b] ]] || [[ -z $TESTb ]] && [ $TESTa -le $VAL3a ]; then
			CHECK=$CHECK
		else
			CHECK=1
        		$LOGIT "The above line should bet #ed out or set to a Max value of $VAL2"
		fi
	elif [ $SUB -eq 4 ]; then
	   echo $TEST | grep "h" > /dev/null 2>&1
	   if ((!$?)); then
	      HOURS=0
	   else
	      HOURS=1
	   fi
		VAL3a=`echo $VAL3 | tr -d [[:alpha:]]`
		VAL3b=`echo $VAL3 | tr -d [[:digit:]]`
		VAL4a=`echo $VAL4 | tr -d [[:alpha:]]`
		VAL4b=`echo $VAL4 | tr -d [[:digit:]]`
		TESTa=`echo $TEST | tr -d [[:alpha:]]`
		TESTb=`echo $TEST | tr -d [[:digit:]]`
		if ((!$HOURS)); then
   		/bin/grep -w $VAL $SSHD | /bin/grep -v "^#" | /bin/grep -v grep | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions > /dev/null 2>&1
   		if [ $? -eq 0 ] || [[ $TESTb = *[$VAL3b] ]] || [[ -z $TESTb ]] && [ $TESTa -le $VAL3a ]; then
   			CHECK=$CHECK
   		else
   			CHECK=1
           		$LOGIT "The above line should bet #ed out or set to a Max value of $VAL2 or $VAL4"
   		fi
		else
		   /bin/grep -w $VAL $SSHD | /bin/grep -v "^#" | /bin/grep -v grep | /bin/grep -vw and | grep -vw regenerates | grep -vw pass | grep -vw setting | grep -vw Uncomment | grep -vw versions > /dev/null 2>&1
   		if [ $? -eq 0 ] || [[ $TESTb = *[$VAL3b] ]] || [[ -z $TESTb ]] && [ $TESTa -le $VAL4a ]; then
   			CHECK=$CHECK
   		else
   			CHECK=1
           		$LOGIT "The above line should bet #ed out or set to a Max value of $VAL2 or $VAL4"
   		fi
      fi
	fi
else
	CHECK=0
	$LOGIT " $VAL was not found in $SSHD so it should be ok."
fi
if [ $CHECK -eq 0 ]; then
	$LOGIT "	$VAL is set correctly"
else
	$LOGIT "	WARNING - $VAL is NOT configured correctly."
fi
#SUB set back to 0 to run standard
SUB=0
return
} #Should_Comment

SSHD_Answer () {
MsgAnswer=1
until [ "$MsgAnswer" = "y" ] || [ "$MsgAnswer" = "Y" ] || [ "$MsgAnswer" = "n" ] || [ "$MsgAnswer" = "N" ]
do
   echo 1 > /tmp/isec_question_prompt
   sleep 6
	echo
	echo "WARNING - The sshd_config file cannot be found at: $SSHD or /usr/local/etc/sshd_config"
	echo "Do you know where it is installed? (y/n)\c"
	read MsgAnswer
done

case $MsgAnswer in
y|Y)
	echo
	echo "Plese enter the FULL path of the sshd_config file."
	echo "For example:  /blah/blah/something/sshd_config"
	echo "What is the FULL path of the sudoers file: \c"
	read SSHD_Path
	SSHD=$SSHD_Path
	echo "User entered the sshd_config path to be: $SSHD"
	echo
	echo 0 > /tmp/isec_question_prompt
	SSHD_Check;
;;
n|N)
	echo
	echo "WARNING - Cannot read the sshd_config file to check the iSeC compliance settings!"
	echo " "
	echo "	*** WARNING - ssh compliance checking has not taken place!!! ***"
	echo " "
	echo "Skipping to the sudo iSeC compliance checking"
	FOUND=1
	echo 0 > /tmp/isec_question_prompt
	echo
;;
esac
} #SSHD_Answer

SSHD_Check () {
if [ -f $SSHD ]; then
	$LOGIT "The sshd_config file has been found:  $SSHD"
	#Run the rest of the ssh portion of the script
	FOUND=0
elif [ -f /usr/local/etc/sshd_config ]; then
	SSHD=/usr/local/etc/sshd_config
	$LOGIT "The sshd_config file has been found: $SSHD"
	#Run the rest of the ssh portion of the script
	FOUND=0
else
	if ((!$INTERSIL)); then
		SSHD_Answer;
	elif ((!$TADDMSIL)); then
	   echo 1 > /tmp/isec_question_prompt
	   sleep 5
		echo
		echo "WARNING - Cannot read the sshd_config file to check the iSeC compliance settings!"
		echo " "
		echo "	*** WARNING - ssh compliance checking has not taken place!!! ***"
		echo " "
		echo "Skipping to the sudo iSeC compliance checking"
		FOUND=1
		echo
		echo 0 > /tmp/isec_question_prompt
   else
      echo "WARNING - Cannot read the sshd_config file to check the iSeC compliance settings!" >> $LOGFILE
		echo " " >> $LOGFILE
		echo "	*** WARNING - ssh compliance checking has not taken place!!! ***" >> $LOGFILE
		echo " " >> $LOGFILE
		echo "Skipping to the sudo iSeC compliance checking" >> $LOGFILE
		FOUND=1
	fi
fi
} #SSHD_Check


###################################################
# Body of the script begins here:
###################################################

#Get our SSH version:
SSHBinaryFound=0
$LOGIT " 	Checking version of SSH "
ssh -V > /dev/null 2>&1
if ((!$?)); then
   SSH_VERSION=`ssh -V 2>&1`
   $LOGIT $SSH_VERSION
elif [ -x /usr/bin/ssh ]; then
   SSH_VERSION=`/usr/bin/ssh -V 2>&1`
   $LOGIT $SSH_VERSION
elif [ -x /usr/local/bin/ssh ]; then
   SSH_VERSION=`/usr/local/bin/ssh -V 2>&1`
   $LOGIT $SSH_VERSION
else
   $LOGIT "WARNING - The ssh binary could not be found"
   $LOGIT "WARNING - Cannot determine ssh version!"
   SSHBinaryFound=1
fi

#Determine what SSH package is installed & version info...
SunSSHInstalled=1
OpenSSHInstalled=1
if ((!$SSHBinaryFound)); then
   echo $SSH_VERSION | grep -i openssh > /dev/null 2>&1
   if (($?)); then
      echo $SSH_VERSION | grep -i "Sun_SSH" > /dev/null 2>&1
      if (($?)); then
         echo "WARNING - Unable to determine what SSH package is installed!" | tee -a $LOGFILE
      else
         SSHver=`echo $SSH_VERSION | awk '{print $1}' | awk -F'_' '{print $3}' | cut -d',' -f1`
         SSHtype="Sun_SSH"
         $LOGIT "This server is running $SSHtype version $SSHver"
         SunSSHInstalled=0
      fi
   else
      SSHver=`echo $SSH_VERSION | awk '{print $1}' | awk -F'_' '{print $2}' | cut -d',' -f1 | cut -c1-3`
      SSHtype="OpenSSH"
      $LOGIT "This server is running $SSHtype version $SSHver"
      OpenSSHInstalled=0
   fi
fi

#We need to set our SSH version to only one decimal as some use x.x.x or more which we can't do comparisons with.
BaseSSHver=`echo $SSHver | cut -c1-3`

#Verify sshd_config file exists where expected:
SSHD_Check;

#If the sshd_config file was found then we continue below:
if [ $FOUND -eq 0 ]; then
$LOGIT "             ## Checking SSH setting ##"

$LOGIT " 	"
$LOGIT "AV.1.1.1 : Checking PermitEmptyPasswords from $SSHD"
#Special check for SunSSH only:
SPECIALcheck=1
if ((!$SunSSHInstalled)); then
   if [ -f /etc/default/login ]; then
      grep "PASSREQ=NO" /etc/default/login | grep -v "^#" > /dev/null 2>&1
      if ((!$?)); then
         $LOGIT "AV.1.1.1 : WARNING - PASSREQ=NO exists in /etc/default/login!"
         $LOGIT "AV.1.1.1 : PermitEmptyPasswords should NOT be #ed out and set to no"
         VAL=PermitEmptyPasswords
         VAL2=no
         ShouldNot_Comment;
         SPECIALcheck=0
      fi
   fi
fi
if (($SPECIALcheck)); then
   $LOGIT "AV.1.1.1 : This line should be #ed out or set to no"
   VAL=PermitEmptyPasswords
   VAL2=no
   Should_Comment;
fi

$LOGIT " "
$LOGIT "AV.1.1.2 : N/A - This server uses $SSHtype"
$LOGIT " "

$LOGIT " "
$LOGIT "AV.1.1.3 : N/A - This server uses $SSHtype"
$LOGIT " "

$LOGIT "AV.1.2.1.2 : Checking LogLevel from $SSHD"
$LOGIT "AV.1.2.1.2 : This line should be #ed out OR set to INFO or higher "
VAL=LogLevel
# SUB set to 2 so it won't do the VAL2 check since it can be set a number of things that are all ok
SUB=2
Should_Comment;

$LOGIT ""
$LOGIT "AV.1.2.1.3 : Checking LogLevel from $SSHD"
$LOGIT "AV.1.2.1.3 : This line should be #ed out OR set to INFO or higher "
VAL=LogLevel
# SUB set to 2 so it won't do the VAL2 check since it can be set a number of things that are all ok
SUB=2
Should_Comment;

$LOGIT ""
$LOGIT "AV.1.2.2 : N/A - This server uses $SSHtype"
$LOGIT " "

Z=1
until [ $Z -eq 7 ]
do
$LOGIT " "
$LOGIT "AV.1.2.3.$Z : N/A - This server uses $SSHtype"
$LOGIT " "
((Z+=1))
done

Z=1
until [ $Z -eq 5 ]
do
$LOGIT " "
$LOGIT "AV.1.2.4.$Z : N/A - This server uses $SSHtype"
$LOGIT " "
((Z+=1))
done

$LOGIT ""
ShowLogList=1
if [ -f /etc/cron.daily/logrotate ]; then
   if [ -f /etc/logrotate.conf ]; then
      grep "^rotate" /etc/logrotate.conf > /dev/null 2>&1
      if ((!$?)); then
         RotateDays=`grep "^rotate" /etc/logrotate.conf | awk '{print $2}' | head -1`
         if [ $RotateDays -lt 13 ]; then
            $LOGIT "AV.1.2.4 : WARNING - The system is NOT keeping 90 days worth of log files. It is only keeping $RotateDays week(s) of log files."
         else
            $LOGIT "AV.1.2.4 : The system is keeping at least 90 days worth of log files."
            grep "^rotate" /etc/logrotate.conf | head -1 >> $LOGFILE
         fi
      else
         $LOGIT "AV.1.2.4 : WARNING - The rotate paramter is not set in /etc/logrotate.conf!"
         ShowLogList=0
      fi
   else
      $LOGIT "AV.1.2.4 : WARNING - The /etc/logrotate.conf file does not exist!"
      ShowLogList=0
   fi
else
   $LOGIT "AV.1.2.4 : WARNING - The /etc/cron.daily/logrotate file does not exist!"
   ShowLogList=0
fi
if ((!$ShowLogList)); then
   $LOGIT "AV.1.2.4 : Here is a long listing of the system log files. Ensure there are at least 90 days worth:"
   for file in messages secure wtmp faillog
   do
   ls -al /var/log/$file | awk '{print $9,"==== "$6,$7,$8}' >> $LOGFILE
   done
fi

$LOGIT " "
#Crazy decimal comparisons require a bit more logic....
SSHverCompare=`echo "if ( $BaseSSHver <= 3.7) 1" | bc`
if [[ -z $SSHverCompare ]]; then
        SSHverCompare=0
fi
if (( $OpenSSHInstalled==0 && $SSHverCompare==1 )) || ((!$SunSSHInstalled)); then
   $LOGIT "AV.1.4.1 : Checking KeepAlive from $SSHD"
   $LOGIT "AV.1.4.1 : This line SHOULD be #ed out OR set to yes"
   VAL=keepalive
   VAL2=yes
   Should_Comment;
else
   $LOGIT "AV.1.4.1 : N/A - This server uses $SSHtype $SSHver"
fi

$LOGIT " 	" 
SSHverCompare=`echo "if ( $BaseSSHver >= 3.8) 1" | bc`
if [[ -z $SSHverCompare ]]; then
        SSHverCompare=0
fi
if (( $OpenSSHInstalled==0 && $SSHverCompare==1 )); then
   $LOGIT "AV.1.4.2 : Checking TCPKeepAlive from $SSHD"
   $LOGIT "AV.1.4.2 : This line SHOULD be #ed out OR set to yes"
   VAL=TCPKeepAlive
   VAL2=yes
   Should_Comment;
else
   $LOGIT "AV.1.4.2 : N/A - This server uses $SSHtype $SSHver"
fi

$LOGIT " 	" 
$LOGIT "AV.1.4.3 : Checking LoginGraceTime from $SSHD"
$LOGIT "AV.1.4.3 : This line should be #ed out OR set to Max of 2mins (2m) or 120 seconds"
VAL=LoginGraceTime
VAL2=2m
#This is our max value integer including minutes or seconds
VAL3=2ms
#Set SUB to 3 so it will do a max check
SUB=3
Should_Comment;

#MaxConnections
$LOGIT " "
$LOGIT "AV.1.4.4 : N/A - This server uses $SSHtype $SSHver"

$LOGIT " 	"
$LOGIT "AV.1.4.5 : Checking MaxStartups from $SSHD"
$LOGIT "AV.1.4.5 : This line should be #ed out which defaults to 10 OR set to max of 100"
VAL=MaxStartups
VAL2=100
#This is our max value
VAL3=100
#Set SUB to 3 so it will do a max check
SUB=3
Should_Comment;

#KeepAlive - VanDyke VShell Only
$LOGIT " "
$LOGIT "AV.1.4.6 : N/A - This server uses $SSHtype $SSHver"

#Authentication Timeout - VanDyke VShell Only
$LOGIT " "
$LOGIT "AV.1.4.7 : N/A - This server uses $SSHtype $SSHver"

$LOGIT " 	"
SSHverCompare=`echo "if ( $BaseSSHver >= 3.9) 1" | bc`
if [[ -z $SSHverCompare ]]; then
        SSHverCompare=0
fi
if (( $OpenSSHInstalled==0 && $SSHverCompare==1 )); then
   $LOGIT "AV.1.4.8 : Checking MaxAuthTries from $SSHD"
   $LOGIT "AV.1.4.8 : This line should NOT be #ed out and set to max of 5"
   VAL=MaxAuthTries
   VAL2=5
   #This is our max value
   VAL3=5
   #Set SUB to 3 so it will do a max check
   SUB=3
   ShouldNot_Comment;
else
   $LOGIT "AV.1.4.8 : N/A - This server uses $SSHtype $SSHver"
fi

#Maximum Authentication Retries - VanDyke VShell Only
$LOGIT " "
$LOGIT "AV.1.4.9 : N/A - This server uses $SSHtype $SSHver"

#Bitvise and/or Attachmate Only
Z=10
until [ $Z -eq 19 ]
do
$LOGIT " "
$LOGIT "AV.1.4.$Z : N/A - This server uses $SSHtype"
$LOGIT " "
((Z+=1))
done

$LOGIT " 	"
$LOGIT "AV.1.5.1 : Checking KeyRegenerationInterval from $SSHD"
$LOGIT "AV.1.5.1 : This line should be #ed out OR set to Max of 1 hour (1h) or 3600 seconds and must NOT be 0"
VAL=KeyRegenerationInterval
VAL2=1h
#This is our max integer value including h, m or s
VAL3=1hms
#This one can also be set in seconds, so 2 variables:
VAL4=3600
#Set SUB to 4 so it will do a max check with 2 variables
SUB=4
Should_Comment;

$LOGIT " 	" 
$LOGIT "AV.1.5.2 : Checking Protocol from $SSHD"
$LOGIT "AV.1.5.2 : The SSH protocol(s) that are accepted by the server. SSH Protocol 1 is known to contain inherent weaknesses."
$LOGIT "AV.1.5.2 : Therefore, Protocol 2 must be enabled. Protocol 1 is permissible only in situations where"
$LOGIT "AV.1.5.2 : interoperability issues prevent the use of Protocol 2."
$LOGIT "AV.1.5.2 : This line should be #ed out OR Recommended setting '2', '2,1' or '1,2' "
$LOGIT "AV.1.5.2 : If commented out it defaults to 2,1"
#SUB set to 1 so it can do multiple comparisons since multiple values are allowed
SUB=1
VAL=Protocol
VAL2=2
VAL3=2,1
VAL4=1,2
Should_Comment;

#SSH1ServerKeyTime - RemotelyAnywhere Only
$LOGIT " "
$LOGIT "AV.1.5.3 : N/A - This server uses $SSHtype $SSHver"

#SSH2 - RemotelyAnywhere Only
$LOGIT " "
$LOGIT "AV.1.5.4 : N/A - This server uses $SSHtype $SSHver"

$LOGIT " 	"
$LOGIT "AV.1.5.5 : Checking GatewayPorts from $SSHD"
$LOGIT "AV.1.5.5 : This line SHOULD be #ed out and/or set to no"
VAL=GatewayPorts
VAL2=no
Should_Comment;

#Bitvise WinSSHD Only
$LOGIT ""
$LOGIT "AV.1.5.6 : N/A - This server uses $SSHtype"

#Attachmate Windows Only
$LOGIT ""
$LOGIT "AV.1.5.7 : N/A - This server uses $SSHtype"

$LOGIT " "
$LOGIT "AV.1.7.1.1 : Checking PermitRootLogin from $SSHD"
$LOGIT "AV.1.7.1.1 : This line should NOT be #ed and set to no"
VAL=PermitRootLogin
VAL2=no
ShouldNot_Comment;

#Public key authentication, location of private keys
$LOGIT " "
VAL=PermitRootLogin
VAL2=no
ShouldNot_Comment;
$LOGIT "AV.1.7.1.2 : THIS SCRIPT CANNOT CHECK THIS SECTION!"

#Public key authentication, required bit length
$LOGIT " "
$LOGIT "AV.1.7.2 : THIS SCRIPT CANNOT CHECK THIS SECTION!"

$LOGIT " 	"
$LOGIT "AV.1.7.3.1 : Checking HostbasedAuthentication from $SSHD"
$LOGIT "AV.1.7.3.1 : If set to 'yes', all hosts accessed are subject to the requirements of this document."
VAL=HostbasedAuthentication
VAL2=no
Should_Comment;

$LOGIT " 	"
$LOGIT "AV.1.7.3.2 : Checking HostbasedAuthentication from $SSHD"
$LOGIT "AV.1.7.3.2 : If set to 'yes', /etc/hosts.equiv must not be used. "
VAL=HostbasedAuthentication
VAL2=no
Should_Comment;
if [ -s /etc/hosts.equiv ]; then
   $LOGIT "AV.1.7.3.2 : WARNING - The /etc/hosts.equiv file exists and contains data!"
else
   $LOGIT "AV.1.7.3.2 : The /etc/hosts.equiv file does NOT exist"
fi

$LOGIT " 	"
$LOGIT "AV.1.7.3.3 : Checking HostbasedAuthentication from $SSHD"
$LOGIT "AV.1.7.3.3 : If not #ed AND set to 'yes', /etc/shosts.equiv MUST be used. "
VAL=HostbasedAuthentication
VAL2=no
Should_Comment;
grep "^HostbasedAuthentication" $SSHD | grep "yes" > /dev/null 2>&1
if ((!$?)); then
   if [ ! -s /etc/shosts.equiv ]; then
      $LOGIT "AV.1.7.3.3 : WARNING - The /etc/shosts.equiv file does NOT exist or contain data!"
   else
      $LOGIT "AV.1.7.3.3 : The /etc/shosts.equiv file exists"
   fi
else
   $LOGIT "AV.1.7.3.3 : N/A - HostbasedAuthentication is not enabled"
fi

$LOGIT " 	"
$LOGIT "AV.1.7.4 : Checking PubkeyAuthentication from $SSHD"
$LOGIT "AV.1.7.4 : If set to 'yes', the requirements in the 'Public Key Authentication' section must be applied."
$LOGIT "AV.1.7.4 : The default is 'yes' for OpenSSH and SunSSH and valid only if Protocol version 2 is enabled"
VAL=PubkeyAuthentication
VAL2=no
ShouldNot_Comment;

$LOGIT " 	"
$LOGIT "AV.1.7.5 : Checking RSAAuthentication from $SSHD"
$LOGIT "AV.1.7.5 : If set to 'yes', the requirements in the 'Public Key Authentication' section must be applied. "
$LOGIT "AV.1.7.5 : The default is 'yes' for OpenSSH and SunSSH and valid only if Protocol version 1 is enabled"
VAL=RSAAuthentication
VAL2=no
ShouldNot_Comment;

$LOGIT " 	"
$LOGIT "AV.1.7.6 : Checking HostbasedAuthentication from $SSHD"
$LOGIT "AV.1.7.6 : If set to 'yes', the requirements in the 'Host-Based' section must be applied. "
VAL=HostbasedAuthentication
VAL2=no
Should_Comment;

#AllowedAuthentications - F-Secure and SSH Communications Only
$LOGIT " "
$LOGIT "AV.1.7.7 : N/A - This server uses $SSHtype $SSHver"

#Authentications Allowed - VanDyke VShell Only
$LOGIT " "
$LOGIT "AV.1.7.8 : N/A - This server uses $SSHtype $SSHver"

#AuthPubkey - RemotelyAnywhere Only
$LOGIT " "
$LOGIT "AV.1.7.9 : N/A - This server uses $SSHtype $SSHver"

#Bitvise WinSSHD Only
$LOGIT ""
$LOGIT "AV.1.7.10 - N/A - This server uses $SSHtype"

#Attachmate Windows only
$LOGIT ""
$LOGIT "AV.1.7.11 - This server uses $SSHtype"

$LOGIT " "
Z=1
for file in bin/openssl bin/scp bin/scp2 bin/sftp bin/sftp2 bin/sftp-server bin/sftp-server2 \
bin/slogin bin/ssh bin/ssh2 bin/ssh-add bin/ssh-add2 bin/ssh-agent bin/ssh-agent2 \
bin/ssh-askpass bin/ssh-askpass2 bin/ssh-certenroll2 bin/ssh-chrootmgr bin/ssh-dummy-shell \
bin/ssh-keygen bin/ssh-keygen2 bin/ssh-keyscan bin/ssh-pam-client \
bin/ssh-probe bin/ssh-probe2 bin/ssh-pubkeymgr bin/ssh-signer bin/ssh-signer2 \
lib/libcrypto.a lib/libssh.a lib/libssl.a lib/libz.a \
lib-exec/openssh/sftp-server lib-exec/openssh/ssh-keysign \
lib-exec/openssh/ssh-askpass lib-exec/sftp-server lib-exec/ssh-keysign \
lib-exec/ssh-rand-helper \
libexec/openssh/sftp-server libexec/openssh/ssh-keysign \
libexec/openssh/ssh-askpass libexec/sftp-server libexec/ssh-keysign \
libexec/ssh-rand-helper \
sbin/sshd sbin/sshd2 sbin/sshd-check-conf lib/svc/method/sshd \
lib/ssh/sshd
do
if [ -f /usr/opt/freeware/$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /usr/opt/freeware/$file`
   FOUND="/usr/opt/freeware"
elif [ -f /usr/$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /usr/$file`
   FOUND="/usr"
elif [ -f /usr/local/$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /usr/local/$file`
   FOUND="/usr/local"
elif [ -f /usr/local/ssl/$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /usr/local/ssl/$file`
   FOUND="/usr/local/ssl"
elif [ -f /opt/freeware/$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /opt/freeware/$file`
   FOUND="/opt/freeware"
elif [ -f /usr/openssh/$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /usr/openssh/$file`
   FOUND="/usr/openssh"
elif [ -f /usr/ssh/$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /usr/ssh/$file`
   FOUND="/usr/ssh"
elif [ -f /$file ]; then
   $LOGIT "AV.1.8.2.$Z : "`ls -al /$file`
   FOUND="/"
else
   $LOGIT "AV.1.8.2.$Z : N/A - The file $file was not found on this server"
   FOUND=0
fi

#OSR Groups and UserIDs.
#Difficult to determine what is a system user and group per iSeC V3.0
#Research shows these files are typically owned by root:root so this script
#will only check for that:
##
if [ $FOUND != 0 ]; then
   if [ -L $FOUND/$file ]; then
      FOUND=`dirname $FOUND/$file`
      LINK=`basename $FOUND/$file`
      file=`ls -ald $FOUND/$LINK | awk '{print $NF}'`
      $LOGIT "AV.1.8.2.$Z : "`ls -al $FOUND/$LINK`
   fi
   FILEUSER=`ls -ald $FOUND/$file | awk '{print $3}'`
   FILEGROUP=`ls -ald $FOUND/$file | awk '{print $4}'`
   FILEPERM=`ls -ald $FOUND/$file | awk '{print $1}' | cut -c9`
#   echo $FILEUSER | egrep -f OSR_USERIDS > /dev/null 2>&1
#   if (($?)); then
   if [ $FILEUSER != "root" ]; then
#      $LOGIT "AV.1.8.2.$Z : WARNING - The OSR $FOUND/$file is NOT assigned to an approved userID"
      $LOGIT "AV.1.8.2.$Z : WARNING - The OSR $FOUND/$file is NOT owned by root."
   else
      $LOGIT "AV.1.8.2.$Z : The $FOUND/$file OSR is assigned to an approved userID"
   fi
#   echo $FILEGROUP | egrep -f OSR_GROUPS > /dev/null 2>&1
#   if (($?)); then
   if [ $FILEGROUP != "root" ]; then
      $LOGIT "AV.1.8.2.$Z : WARNING - The OSR $FOUND/$file is not assigned to group root."
#      $LOGIT "AV.1.8.2.$Z : WARNING - The OSR $FOUND/$file is NOT assigned to an approved groupID"
   else
      $LOGIT "AV.1.8.2.$Z : The $FOUND/$file OSR is assigned to an approved groupID"
   fi
   if [ $FILEPERM = "w" ]; then
      $LOGIT "AV.1.8.2.$Z : WARNING - The OSR $FOUND/$file has permissions set on other that is NOT r-x or more restrictive!"
   else
      $LOGIT "AV.1.8.2.$Z : The OSR $FOUND/$file has permissions set on other that are r-x or more restrictive."
   fi
fi
((Z+=1))
$LOGIT " "
done

Z=1
for file in /etc/openssh/sshd_config /etc/ssh/sshd_config \
/etc/ssh/sshd2_config /etc/ssh2/sshd_config \
/etc/ssh2/sshd2_config /etc/sshd_config /etc/sshd2_config \
/usr/local/etc/sshd_config /usr/local/etc/sshd2_config \
/usr/lib/ssh/ssh-keysign
do
if [ -f $file ]; then
   $LOGIT "AV.1.8.3.$Z : "`ls -al $file`
##
#Difficult to determine what is a system user and group per iSeC V3.0
#Research shows these files are typically owned by root:root so this script
#will only check for that:
##
   FILEUSER=`ls -ald $file | awk '{print $3}'`
   FILEGROUP=`ls -ald $file | awk '{print $4}'`
   FILEPERM=`ls -ald $file | awk '{print $1}' | cut -c9`
#   echo $FILEUSER | egrep -f OSR_USERIDS > /dev/null 2>&1
#   if (($?)); then
   if [ $FILEUSER != "root" ]; then
#      $LOGIT "AV.1.8.3.$Z : WARNING - The OSR $file is NOT assigned to an approved userID"
      $LOGIT "AV.1.8.3.$Z : WARNING - The OSR $file is NOT owned by root."
   else
      $LOGIT "AV.1.8.3.$Z : The $file OSR is assigned to an approved userID"
   fi
#   echo $FILEGROUP | egrep -f OSR_GROUPS > /dev/null 2>&1
#   if (($?)); then
   if [ $FILEGROUP != "root" ]; then
#      $LOGIT "AV.1.8.3.$Z : WARNING - The OSR $file is NOT assigned to an approved groupID"
      $LOGIT "AV.1.8.3.$Z : WARNING - The OSR $file is not assigned to group root."
   else
      $LOGIT "AV.1.8.3.$Z : The $file OSR is assigned to an approved groupID"
   fi
   if [ $FILEPERM = "w" ]; then
      $LOGIT "AV.1.8.3.$Z : WARNING - The OSR $file has permissions set on other that is NOT r-x or more restrictive!"
   else
      $LOGIT "AV.1.8.3.$Z : The OSR $file has permissions set on other that are r-x or more restrictive."
   fi
else
   $LOGIT "AV.1.8.3.$Z : N/A - The file $file was not found on this server"
fi
((Z+=1))
$LOGIT " "
done

$LOGIT " "
Z=1
until [ $Z -eq 8 ]
do
$LOGIT "AV.1.8.4.$Z : N/A - This is a Linux server"
$LOGIT ""
((Z+=1))
done

$LOGIT " "
Z=1
until [ $Z -eq 15 ]
do
if [ $Z -ne 9 ]; then
   $LOGIT "AV.1.8.5.$Z : N/A - This is a Linux server"
   $LOGIT ""
fi
((Z+=1))
done

$LOGIT " 	"
if ((!$OpenSSHInstalled)); then
   SSHverCompare=`echo "if ( $BaseSSHver >= 3.5) 1" | bc`
   if [[ -z $SSHverCompare ]]; then
           SSHverCompare=0
   fi
   if (($SSHverCompare)); then
      $LOGIT "AV.1.9.1 : Checking PermitUserEnvironment from $SSHD"
      $LOGIT "AV.1.9.1 : This line should be #ed out or set to no"
      VAL=PermitUserEnvironment
      VAL2=no
      Should_Comment;
   else
      $LOGIT "AV.1.9.1 : N/A - This server uses $SSHtype $SSHver"
   fi
elif ((!$SunSSHInstalled)); then
   SSHverCompare=`echo "if ( $BaseSSHver >= 1.2) 1" | bc`
   if [[ -z $SSHverCompare ]]; then
           SSHverCompare=0
   fi
   if (($SSHverCompare)); then
      $LOGIT "AV.1.9.1 : Checking PermitUserEnvironment from $SSHD"
      $LOGIT "AV.1.9.1 : This line should be #ed out OR set to no"
      VAL=PermitUserEnvironment
      VAL2=no
      Should_Comment;
   else
      $LOGIT "AV.1.9.1 : N/A - This server uses $SSHtype $SSHver"
   fi
else
   $LOGIT "AV.1.9.1 : N/A - This server uses $SSHtype $SSHver"
fi

$LOGIT " "
$LOGIT "AV.1.9.2 : Checking StrictModes from $SSHD"
$LOGIT "This line should be #ed out or set to yes"
VAL=StrictModes
VAL2=yes
Should_Comment;

SSHverCompare=`echo "if ( $BaseSSHver >= 3.9) 1" | bc`
if [[ -z $SSHverCompare ]]; then
        SSHverCompare=0
fi
if (( $OpenSSHInstalled==0 && $SSHverCompare==1 )); then
   $LOGIT ""
   cat /dev/null > AV193_temp
   $LOGIT "AV.1.9.3 : Checking AcceptEnv from $SSHD"
#   $LOGIT "AV.1.9.3 : Parameter MUST NOT EXIST in sshd_config"
   /bin/grep "^AcceptEnv" $SSHD > /dev/null 2>&1
   if ((!$?)); then
      /bin/grep "^AcceptEnv" $SSHD | egrep -w 'TERM|PATH|HOME|MAIL|SHELL|LOGNAME|USER|USERNAME|LIBPATH|SHLIB_PATH' > /dev/null 2>&1
      if ((!$?)); then
         /bin/grep "^AcceptEnv" $SSHD | egrep -w 'TERM|PATH|HOME|MAIL|SHELL|LOGNAME|USER|USERNAME|LIBPATH|SHLIB_PATH' >> AV193_temp
      fi
      /bin/grep "^AcceptEnv" $SSHD | grep -w '[a-Z]*[a-Z]_RLD' > /dev/null 2>&1
      if ((!$?)); then
         /bin/grep "^AcceptEnv" $SSHD | grep -w '[a-Z]*[a-Z]_RLD' >> AV193_temp
      fi
      grep "^AcceptEnv" $SSHD | egrep -w 'DYLD_[a-Z]*[a-Z]|LD_[a-Z]*[a-Z]|LDR_[a-Z]*[a-Z]' > /dev/null 2>&1
      if ((!$?)); then
         grep "^AcceptEnv" $SSHD | egrep -w 'DYLD_[a-Z]*[a-Z]|LD_[a-Z]*[a-Z]|LDR_[a-Z]*[a-Z]' >> AV193_temp
      fi
      if [ -s AV193_temp ]; then
         $LOGIT "AV.1.9.3 : WARNING - An illegal variable has been found associated with the AcceptEnv parameter in $SSHD."
         cat AV193_temp >> $LOGFILE
      else
         $LOGIT "AV.1.9.3 : The AcceptEnv parameter was found in $SSHD, but no illegal variables were associated with it:"
         /bin/grep "^AcceptEnv" $SSHD >> $LOGFILE
      fi
#     $LOGIT `/bin/grep -i AcceptEnv $SSHD`
#   	$LOGIT "AV.1.9.3 : WARNING - This parameter should be removed from $SSHD"
   else
   	$LOGIT "AV.1.9.3 : The AcceptEnv parameter was not found in $SSHD"
   fi
   rm -rf AV193_temp
else
   $LOGIT "AV.1.9.3 : N/A - This server uses $SSHtype $SSHver"
fi

$LOGIT " 	" 
$LOGIT "AV.2.0.1.1 : Checking PrintMotd from $SSHD"
$LOGIT "AV.2.0.1.1 : This line should be #ed out OR set to yes"
VAL=PrintMotd
VAL2=yes
Should_Comment;

$LOGIT " "
$LOGIT "AV.2.0.1.2 : N/A - This server uses $SSHtype $SSHver"

#VanDyke Only
$LOGIT ""
$LOGIT "AV.2.0.1.3 - N/A - This server uses $SSHtype"

#Attachmate Windows Only
$LOGIT ""
$LOGIT "AV.2.0.1.4 - N/A - This server uses $SSHtype"

$LOGIT " "
grep "^Protocol" $SSHD  > /dev/null 2>&1
if ((!$?)); then
   TEST=`grep "^Protocol" $SSHD | awk '{print $2}'`
   echo $TEST | grep "1" > /dev/null 2>&1
   if ((!$?)); then
      $LOGIT `grep "^Protocol" $SSHD`
      $LOGIT "AV.2.1.1.1 : WARNING - Protocol 1 is enabled in $SSHD"
      $LOGIT "AV.2.1.1.1 : THIS SCRIPT CANNOT CHECK THE BIT LENGTH FOR PUBLIC KEYS!"
   else
      $LOGIT "AV.2.1.1.1 : N/A - Protocol 1 is not enabled in $SSHD"
   fi
else
   $LOGIT "AV.2.1.1.1 : N/A - Protocol 1 is not enabled in $SSHD"
fi

$LOGIT " "
$LOGIT "AV.2.1.1.2 : Data Transmissions - All native encryption ciphers...."
$LOGIT "AV.2.1.1.2 : THIS SCRIPT CANNOT CHECK THIS SECTION!"

$LOGIT " "
$LOGIT "AV.2.1.1.3 : Data Transmissions - DES algorithm...."
$LOGIT "AV.2.1.1.3 : THIS SCRIPT CANNOT CHECK THIS SECTION!"

$LOGIT " "
$LOGIT "AV.2.1.1.4 : Data Transmission - Server host keys...."
$LOGIT "AV.2.1.1.4 : THIS SCRIPT CANNOT CHECK THIS SECTION!"

#Bitvise WinSSHD Only
$LOGIT ""
$LOGIT "AV.2.1.1.5 - N/A - This server uses $SSHtype"

#Attachmate Windows Only
$LOGIT ""
$LOGIT "AV.2.1.1.6 - N/A - This server uses $SSHtype"

#Attachmate Windows Only
$LOGIT ""
$LOGIT "AV.2.1.1.7 - N/A - This server uses $SSHtype"

$LOGIT " "
#$LOGIT "AV.2.2.1.1 : Private Key Passphrases must be assigned to all private keys used...."
#$LOGIT "AV.2.2.1.1 : THIS SCRIPT CANNOT CHECK THIS SECTION!"
cat /dev/null > AV2211
CHECK=1
for FILE in `find /home -type f  -name "id_[dr]sa*" -print   2>/dev/null | grep -v .pub`
do
if [ -f $FILE ]; then
   CHECK=0
fi
grep  "ENCRYPTED" $FILE > /dev/null 2>&1
if (($?)); then
   echo "NOT using Pass Phrase:	$FILE" >> AV2211
fi
done
if ((!$CHECK)); then
   if [ -s AV2211 ]; then
      $LOGIT "AV.2.2.1.1 : WARNING - Private ssh keyfiles exist without encryption set:"
      cat AV2211 >> $LOGFILE
   else
      $LOGIT "AV.2.2.1.1 : All private ssh keyfiles have a passphrase set."
   fi
else
   $LOGIT "AV.2.2.1.1 : No private ssh keyfiles were found on the server."
fi
rm AV2211

$LOGIT " "
if ((!$CHECK)); then
   $LOGIT "AV.2.2.1.2 : Private Key Passphrase - must have minimum number of 5 words each...."
   $LOGIT "AV.2.2.1.2 : THIS SCRIPT CANNOT CHECK THIS SECTION AS THE PASSHPHRASES ARE ENCRYPTED!"
else
   $LOGIT "AV.2.2.1.2 : No private ssh keyfiles were found on the server."
fi

$LOGIT " "
if ((!$CHECK)); then
   $LOGIT "AV.2.2.1.3 : Private Key Passphrase - system to system authentication...."
   $LOGIT "AV.2.2.1.3 : THIS SCRIPT CANNOT CHECK THIS SECTION! WE HAVE NO WAY OF CHECKING THE SERVER(S) THIS USER HAS ACCESS TO TO VERIFY THE AUTHORIZED_KEYS FILE!!"
else
   $LOGIT "AV.2.2.1.3 : No private ssh keyfiles were found on the server."
fi

$LOGIT " "
cat /dev/null > AV2214
CHECK=1
for FILE in `find /home -type f \( -name "authorized_keys" -o -name "authorized_keys2" \) -print  2>/dev/null`
do
if [ -f $FILE ]; then
   CHECK=0
fi
if [ -s $FILE ]; then
   grep "^from=" $FILE > /dev/null 2>&1
   if (($?)); then
      echo $FILE >> AV2214
   fi
fi
done
if ((!$CHECK)); then
   if [ -s AV2214 ]; then
      $LOGIT "AV.2.2.1.4 : WARNING - authorized_keys[2] file(s) exist which do not contain the 'from=' option."
      $LOGIT "AV.2.2.1.4 : This script is unable to deterimine which users are security administration or systems authority rights."
      $LOGIT "AV.2.2.1.4 : Here is a list of the file(s) found:"
      cat AV2214 >> $LOGFILE
   else
      $LOGIT "AV.2.2.1.4 : All authorized_keys and/or authorized_keys2 file(s) contain the 'from=' option in them."
   fi
else
   $LOGIT "AV.2.2.1.4 : No authorized_keys nor authorized_keys2 files were found on the server."
fi
rm AV2214

$LOGIT " "
id sshd > /dev/null 2>&1
if ((!$?)); then
   $LOGIT "AV.5.0.1 : Here is a list of group(s) that the sshd ID belongs to:"
   /usr/bin/groups sshd | awk -F':' '{print $2}' >> $LOGFILE
else
   $LOGIT "AV.5.0.1 : WARNING - The user ID sshd does NOT exist!"
fi

##
#This section is for HIPAA Accounts only!!!
##
if ((!$HIPAA_Check)); then
   $LOGIT ""
   ShowLogList=1
   if [ -f /etc/cron.daily/logrotate ]; then
      if [ -f /etc/logrotate.conf ]; then
         grep "^rotate" /etc/logrotate.conf > /dev/null 2>&1
         if ((!$?)); then
            RotateDays=`grep "^rotate" /etc/logrotate.conf | awk '{print $2}' | head -1`
            if [ $RotateDays -lt 39 ]; then
               $LOGIT "AV.10.1.1.2 : WARNING - The system is NOT keeping 270 days worth of log files. It is only keeping $RotateDays week(s) of log files."
            else
               $LOGIT "AV.10.1.1.2 : The system is keeping at least 270 days worth of log files."
               grep "^rotate" /etc/logrotate.conf | head -1 >> $LOGFILE
            fi
         else
            $LOGIT "AV.10.1.1.2 : WARNING - The rotate paramter is not set in /etc/logrotate.conf!"
            ShowLogList=0
         fi
      else
         $LOGIT "AV.10.1.1.2 : WARNING - The /etc/logrotate.conf file does not exist!"
         ShowLogList=0
      fi
   else
      $LOGIT "AV.10.1.1.2 : WARNING - The /etc/cron.daily/logrotate file does not exist!"
      ShowLogList=0
   fi
   if ((!$ShowLogList)); then
      $LOGIT "AV.10.1.1.2 : Here is a long listing of the system log files. Ensure there are at least 270 days worth:"
      for file in messages secure wtmp faillog
      do
      ls -al /var/log/$file | awk '{print $9,"==== "$6,$7,$8}' >> $LOGFILE
      done
   fi
fi
   


#If the sshd_config file was not found then we skipped the ssh checks and moved on to sudo checks
fi
















$LOGIT " "
$LOGIT " "
$LOGIT " "
$LOGIT "#########################################################################"
$LOGIT "#"
$LOGIT "#		iSeC sudo checking begins here:"
$LOGIT "#"
$LOGIT "#########################################################################"
$LOGIT " "
$LOGIT " "

SUDO=/etc/sudoers

###################################################
# Sudo functions are here:
###################################################
SUDO_Answer () {
MsgAnswer1=1
until [ "$MsgAnswer1" = "y" ] || [ "$MsgAnswer1" = "Y" ] || [ "$MsgAnswer1" = "n" ] || [ "$MsgAnswer1" = "N" ]
do
   echo 1 > /tmp/isec_question_prompt
   sleep 6
	echo
	echo "WARNING - The sudoers file cannot be found at the following locations:"
	echo "$SUDO"
	echo "/usr/local/etc/sudoers"
	echo "/opt/sfw/etc/sudoers"
	echo "Do you know where it is installed? (y/n)\c"
	read MsgAnswer1
done

case $MsgAnswer1 in
y|Y)
	echo
	echo "Plese enter the FULL path of the sudoers file."
	echo "For example:  /blah/blah/something/sudoers"
	echo "What is the FULL path to the sudoers file: \c"
	read SUDO_Path
	SUDO=$SUDO_Path
	echo "User entered the sudoers path to be: $SUDO"
	echo 0 > /tmp/isec_question_prompt
	sleep 2
	SUDO_Check;
;;
n|N)
	echo
	echo "WARNING - Cannot read the sudoers file to check the iSeC compliance settings!"
	echo " "
	echo "	*** WARNING - sudo compliance checking has not taken place!!! ***"
	echo " "
	echo 0 > /tmp/isec_question_prompt
	sleep 2
	FOUND1=1
;;
esac
} #SUDO_Answer

#Let's confirm our location of the sudoers file:
SUDO_Check () {
if [ -f $SUDO ]; then
	$LOGIT "The sudoers file has been found:  $SUDO"
	#Run the rest of the sudo portion of the script
	FOUND1=0
elif [ -f /usr/local/etc/sudoers ]; then
	SUDO=/usr/local/etc/sudoers
	$LOGIT "The sudoers file has been found: $SUDO"
	#Run the rest of the sudo portion of the script
	FOUND1=0
elif [ -f /opt/sfw/etc/sudoers ]; then
   SUDO=/opt/sfw/etc/sudoers
   $LOGIT "The sudoers file has been found: $SUDO"
   #Run the rest of the sudo portion of the script
   FOUND1=0
else
	if ((!$INTERSIL)); then
		SUDO_Answer;
	elif ((!$TADDMSIL)); then
	   echo 1 > /tmp/isec_question_prompt
	   sleep 6
		echo
		echo "WARNING - Cannot read the sudoers file to check the iSeC compliance settings!"
		echo " "
		echo "	*** WARNING - sudo compliance checking has not taken place!!! ***"
		echo " "
		echo 0 > /tmp/isec_question_prompt
		sleep 2
		FOUND1=1
   else
      echo "WARNING - Cannot read the sudoers file to check the iSeC compliance settings!" >> $LOGFILE
		echo " " >> $LOGFILE
		echo "	*** WARNING - sudo compliance checking has not taken place!!! ***" >> $LOGFILE
		echo " " >> $LOGFILE
		FOUND1=1
	fi
fi
} #SUDO_Check




#The last portion of the full iSeC script for sudo is in Perl.
#So we need to add some code to call the perl functions correctly.
#If the sudoers file has been located we will run:
SUDO_Check;
if [ $FOUND1 -eq 0 ]; then
grep "!logfile" $SUDO | grep -v "^#" > /dev/null 2>&1
if (($?)); then
   $LOGIT "ZY.1.2.1 : The setting !logfile was not found in $SUDO"
else
   $LOGIT "ZY.1.2.1 : WARNING - The setting !logfile was found in $SUDO"
   grep "!logfile" $SUDO | grep -v "^#" >> $LOGFILE
fi

$LOGIT " "
SudoSpecificLog=1
grep "logfile=" $SUDO | grep -v "^#" > /dev/null 2>&1
if (($?)); then
   $LOGIT "ZY.1.2.2 : A sudo specific log file was not defined in $SUDO. Sudo is using the default syslog function."
else
   $LOGIT "ZY.1.2.2 : A sudo specific log file is defined in $SUDO:"
   grep "logfile=" $SUDO | grep -v "^#" >> $LOGFILE
   if [ ! -f /var/log/sudo.log ]; then
      $LOGIT "ZY.1.2.2 : WARNING - The /var/log/sudo.log file does NOT exist!"
   else
      $LOGIT "ZY.1.2.2 : The /var/log/sudo.log file exists:"
      ls -al /var/log/sudo.log >> $LOGFILE
      SudoSpecificLog=0
   fi
fi

$LOGIT ""
$LOGIT "ZY.1.2.3 : Secondary logging can be performed via numerous methods."
$LOGIT "ZY.1.2.3 : This script is not able to check this section!"

$LOGIT ""
if (($NinetyDayLogRotate)); then
   $LOGIT "ZY.1.2.4 : WARNING - The system is not configured to retain 90 days worth of logs!"
else
   $LOGIT "ZY.1.2.4 : The system is configured to retain 90 days worth of logs."
   if ((!$SudoSpecificLog)); then
      if [ -d /etc/logrotate.d ]; then
         grep -q "/var/log/sudo.log" /etc/logrotate.d/*
         if (($?)); then
            $LOGIT "ZY.1.2.4 : WARNING - The /var/log/sudo.log does not appear to be configured in logrotate for 90 day retention!"
         else
            $LOGIT "ZY.1.2.4 : The /var/log/sudo.log appears to be configured for 90 day retention:"
            grep "/var/log/sudo.log" /etc/logrotate.d/*
         fi
      else
         $LOGIT "ZY1.2.4 : WARNING - The /var/log/sudo.log does not appear to be configured in logrotate for 90 day retention!"
      fi
   fi
fi

$LOGIT " "
grep -i "nopasswd" $SUDO | grep -v "^#" > /dev/null 2>&1
if (($?)); then
   $LOGIT "ZY.1.4.1 : The 'nopasswd' parameter is not used in $SUDO"
else
   $LOGIT "ZY.1.4.1 : The 'nopasswd' parameter is used in $SUDO"
fi

$LOGIT " "
sudo -L > /dev/null 2>&1
if ((!$?)); then
   if [ `sudo -L | grep -ic "noexec"` -lt 2 ]; then
      $LOGIT "ZY.1.4.2.0 : WARNING - The 'noexec' function is not compiled in this version of sudo!"
      $LOGIT "ZY.1.4.2.0 : Review to the Perl script report below to determine if shell escape commands have been restricted in the sudoers file."
   else
      $LOGIT "ZY.1.4.2.0 : The 'noexec' function is compiled into this version of sudo:"
      sudo -L | grep -i "noexec" >> $LOGFILE
   fi
else
   ZY1420_check=1
   if [ -f /etc/sudo.conf ]; then
      grep -q "^#Path noexec" /etc/sudo.conf
      if ((!$?)); then
         NoexecLib=`grep "^#Path noexec" /etc/sudo.conf | awk '{print $3}'`
         echo $NoexecLib | grep -q "/sudo_noexec.so"
         if ((!$?)); then
            if [ -e $NoexecLib ]; then
               $LOGIT "ZY.1.4.2.0 : The 'noexec' function is compiled into this version of sudo. The library containing the 'noexec' policies was also found:"
               ls -ald $NoexecLib >> $LOGFILE
            else
               $LOGIT "ZY.1.4.2.0 : WARNING : The 'noexec' function appears to be compiled into this version of sudo. However the library containing the 'noexec' policies could not be found from /etc/sudo.conf"
            fi
            ZY1420_check=0
         else
            $LOGIT "ZY.1.4.2.0 : WARNING : The 'noexec' function appears to be compiled into this version of sudo. However the library containing the 'noexec' policies is not the default sudo name and may have been altered or re-compiled."
            ZY1420_check=0
         fi
      fi
      if (($ZY1420_check)); then
         grep -q "^Path noexec" /etc/sudo.conf
         if ((!$?)); then
            NoexecLib=`grep "^#Path noexec" /etc/sudo.conf | awk '{print $3}'`
            echo $NoexecLib | grep -q "/sudo_noexec.so"
            if ((!$?)); then
               if [ -e $NoexecLib ]; then
                  $LOGIT "ZY.1.4.2.0 : The 'noexec' function is compiled into this version of sudo. The library containing the 'noexec' policies was also found:"
                  ls -ald $NoexecLib >> $LOGFILE
               else
                  $LOGIT "ZY.1.4.2.0 : WARNING : The 'noexec' function appears to be compiled into this version of sudo. However the library containing the 'noexec' policies could not be found from /etc/sudo.conf"
               fi
               ZY1420_check=0
            else
               $LOGIT "ZY.1.4.2.0 : WARNING : The 'noexec' function appears to be compiled into this version of sudo. However the library containing the 'noexec' policies is not the default sudo name and may have been altered or re-compiled."
               ZY1420_check=0
            fi
         fi
      fi
      if (($ZY1420_check)); then
         $LOGIT "ZY.1.4.2.0 : WARNING : The 'noexec' function should be compiled in this version of sudo. However, it is not defined in the /etc/sudo.conf file for the library containing the policies."
      fi
   else
      $LOGIT "ZY.1.4.2.0 : WARNING : The 'noexec' function should be compiled in this version of sudo. However, the /etc/sudo.conf file canNOT be located to verify the library containing the policies."
   fi
fi

$LOGIT " "
cat $SUDO | grep -v "^#" | egrep -iw 'bash2bug|bashbug|ed|ex|ftp|less|more|pg|vi|smitty|smit|view|gvim|gview|evim|eview|vimdiff|find' > /dev/null 2>&1
if ((!$?)); then
   cat $SUDO | grep -v "^#" | egrep -iw 'bash2bug|bashbug|ed|ex|ftp|less|more|pg|vi|smitty|smit|view|gvim|gview|evim|eview|vimdiff|find' | grep -iwv "noexec" > /dev/null 2>&1
   if ((!$?)); then
      $LOGIT "ZY.1.4.2.1 : WARNING - Commands exist in the $SUDO file which do not have the 'NOEXEC' keyword associated with them!"
      cat $SUDO |  grep -v "^#" | egrep -iw 'bash2bug|bashbug|ed|ex|ftp|less|more|pg|vi|smitty|smit|view|gvim|gview|evim|eview|vimdiff|find' | grep -iwv "noexec" >> $LOGFILE
   else
      $LOGIT "ZY.1.4.2.1 : Commands allowing shell escapes exist in the $SUDO file, but all have the 'NOEXEC' keyword associated with them."
   fi
else
   $LOGIT "ZY.1.4.2.1 : No commands allowing shell escapes exist in the $SUDO file"
fi

$LOGIT " "
$LOGIT "ZY.1.4.3.1 : Review to the Perl script report below to determine if full paths have been used for specific commands."
$LOGIT " "
$LOGIT "ZY.1.4.3.2 : Users considered to have admin or system authority....THIS SCRIPT CANNOT CHECK THIS SETTING!"

$LOGIT " "
grep "SUDOSUDO" $SUDO | grep -v "^#" | grep "/bin/sudo" > /dev/null 2>&1
if (($?)); then
   $LOGIT "ZY.1.4.3.3 : WARNING - Users have not been prevented from using sudo to invoke sudo in $SUDO"
else
   $LOGIT "ZY.1.4.3.3 : Users have been prevented from using sudo to invoke sudo in $SUDO"
   grep "SUDOSUDO" $SUDO | grep -v "^#" | grep "/bin/sudo" >> $LOGFILE
   grep "ALL ALL=!SUDOSUDO" $SUDO >> $LOGFILE
fi

$LOGIT " "
cat $SUDO | grep -v "^#" | grep "=" > ZY144
cat ZY144 | awk -F'=' '{print $NF}' | grep -w "ALL" > /dev/null 2>&1
if ((!$?)); then
   $LOGIT "ZY.1.4.4 : WARNING - Entries exist in $SUDO that end in =ALL. This script is unable to check the numerous methods which could be used to establish proper logging is in place!"
else
   $LOGIT "ZY.1.4.4 : No entries exist in $SUDO that end in =ALL."
fi
rm ZY144

$LOGIT " "
cat $SUDO | grep -v "^#" | egrep -w 'ed|ex|vi|view|gvim|gview|evim|eview' > /dev/null 2>&1
if ((!$?)); then
   $LOGIT "ZY.1.4.5 : WARNING - Access to edit files has been granted in $SUDO not using sudoedit!"
   cat $SUDO | grep -v "^#" | egrep -w 'ed|ex|vi|view|gvim|gview|evim|eview' >> $LOGFILE
else
   $LOGIT "ZY.1.4.5 : No access has been granted in $SUDO to edit files not using sudoedit."
fi

$LOGIT " "
ZY1810=0
if [ `ls -alL $SUDO | awk '{print $3}'` != "root" ]; then
   echo "ZY.1.8.1.0 : WARNING - The file $SUDO is not owned by user root!"
   ZY1810=1
fi
if [ `ls -alL $SUDO | awk '{print $1}' | cut -c9` = "w" ]; then
   $LOGIT "ZY.1.8.1.0 : WARNING - The file $SUDO is world-writable!"
   ZY1810=1
fi
if ((!$ZY1810)); then
   $LOGIT "ZY.1.8.1.0 : The file $SUDO is owned by root and is not world-writable."
fi
$LOGIT "ZY.1.8.1.0 : `ls -alL $SUDO`"
##
#Commenting the below section as the Linux Tech Spec does not have a list of
#approved OSR Groups or UserIDs...
##
#FILEUSER=`ls -alL $SUDO | awk '{print $3}'`
#FILEGROUP=`ls -alL $SUDO | awk '{print $4}'`
#echo $FILEUSER | egrep -f OSR_USERIDS > /dev/null 2>&1
#if (($?)); then
#   $LOGIT "ZY.1.8.1 : WARNING - The OSR $SUDO is NOT assigned to an approved userID"
#else
#   $LOGIT "ZY.1.8.1 : The $SUDO OSR is assigned to an approved userID"
#fi
#echo $FILEGROUP | egrep -f OSR_GROUPS > /dev/null 2>&1
#if (($?)); then
#   $LOGIT "ZY.1.8.1 : WARNING - The OSR $SUDO is NOT assigned to an approved groupID"
#else
#   $LOGIT "ZY.1.8.1 : The $SUDO OSR is assigned to an approved groupID"
#fi

$LOGIT ""
IncludeDirBail=1
IncludeDirBail1=1
grep -wq "^#includedir" $SUDO
if ((!$?)); then
   TestPath=`grep -w "^#includedir" $SUDO | awk '{print $2}'`
   if [ ! -z $TestPath ]; then
      echo $TestPath | grep -q "^/"
      if (($?)); then
         DirPath=`dirname $SUDO`/$TestPath
      else
         DirPath=$TestPath
      fi
      if [ -d $DirPath ]; then
         IncludeDirBail=0
         if [ `ls -ald $DirPath | awk '{print $3}'` != "root" ]; then
            $LOGIT "ZY.1.8.1.1 : WARNING - The #includedir directory $DirPath is NOT owned by root!"
         else
            $LOGIT "ZY.1.8.1.1 : The #includedir directory $DirPath is owned by root."
         fi
         DIRPERM=`ls -ald $DirPath | awk '{print $1}' | cut -c5-10`
         echo "$DIRPERM" | grep -q [rwx]
         if ((!$?)); then
            $LOGIT "ZY.1.8.1.1 : WARNING - The #includedir directory $DirPath does not have permissions of 700!"
         else
            $LOGIT "ZY.1.8.1.1 : The #includedir directory $DirPath has permissions of 700."
         fi
         ls -ald $DirPath >> $LOGFILE
         if [ `ls $DirPath | wc -l` -gt 0 ]; then
            IncludeDirBail1=0
            cat /dev/null > ZY1811_temp
            find $DirPath -type f ! -user root -o ! -perm 700 >> ZY1811_temp
            find $DirPath -type d ! -user root -o ! -perm 700  >> ZY1811_temp
            if [ -s ZY1811_temp ]; then
               $LOGIT "ZY.1.8.1.1 : WARNING - Files/directories exist in the #includedir directory $DirPath that are not owned by root and/or do not have permissions of 700!"
               for file in `cat ZY1811_temp`
               do
               ls -ald $file >> $LOGFILE
               done
            else
               $LOGIT "ZY.1.8.1.1 : Any files/directories located in the #includedir $DirPath have the correct owner and permissions."
            fi
         else
            $LOGIT "ZY.1.8.1.1 : No files or directories exist in the #includedir $DirPath."
         fi
      else
         $LOGIT "ZY.1.8.1.1 : WARNING - The path specified by the #includedir directive for $DirPath does NOT exist!"
         grep -w "^#includedir" $SUDO >> $LOGFILE
      fi
   else
      $LOGIT "ZY.1.8.1.1 : WARNING - The #includedir directive contains no parameter after it in the $SUDO file!"
      grep -w "^#includedir" $SUDO >> $LOGFILE
   fi
else
   $LOGIT "ZY.1.8.1.1 : The sudoers file $SUDO does not contain the #includedir directive."
fi
rm -rf ZY1811_temp

$LOGIT ""
if ((!$IncludeDirBail)); then
   echo $TestPath | grep -q "^/"
   if (($?)); then
      $LOGIT "ZY.1.8.1.2 : WARNING - The #includedir directive names a directory or file that does not contain the full path!"
   else
      $LOGIT "ZY.1.8.1.2 : The #includedir directive names a directory that specifies the full path:"
   fi
   grep "^#includedir" $SUDO >> $LOGFILE
else
   $LOGIT "ZY.1.8.1.2 : The sudoers file $SUDO does not contain the #includedir directive."
fi

$LOGIT ""
if ((!$IncludeDirBail)); then
   cat /dev/null > ZY1813_temp
   if [ `ls -ald $DirPath | awk '{print $1}' | cut -c9` = "w" ]; then
      echo $DirPath >> ZY1813_temp
   fi
   entry=$DirPath
   until [ `basename $entry` = "/" ]
   do
   entry=`dirname $entry`
   if [ `ls -ald $entry | awk '{print $1}' | cut -c9` = "w" ]; then
      echo $entry >> ZY1813_temp
   fi
   done
   if [ -s ZY1813_temp ]; then
      $LOGIT "ZY.1.8.1.3 : WARNING - Directory(ies) exist in the path referenced by the #includedir directive that do not have permissions for other set to r-x or more restrictive:"
      for file in `cat ZY1813_temp`
      do
      ls -ald $file >> $LOGFILE
      done
   else
      $LOGIT "ZY.1.8.1.3 : Any directory(ies) in the path referenced by the #includedir directive have permissions for other set to r-x or more restrictive."
   fi
   rm -rf ZY1813_temp
else
   $LOGIT "ZY.1.8.1.3 : The sudoers file $SUDO does not contain the #includedir directive."
fi

$LOGIT ""
grep -wq "^#include" $SUDO
if ((!$?)); then
   TestPath=`grep -w "^#include" $SUDO | awk '{print $2}'`
   if [ ! -z $FilePath ]; then
      echo $TestPath | grep -q "^/"
      if (($?)); then
         FilePath=`dirname $SUDO`/$TestPath
         $LOGIT "ZY.1.8.4 : WARNING - The file specified by the #include directive in $SUDO does NOT contain the full path!"
      else
         FilePath=$TestPath
         $LOGIT "ZY.1.8.1.4 : The file specified by the #include directive in $SUDO contains the full path."
      fi
      $LOGIT ""
      echo $TestPath >> $LOGFILE
      if [ -f $FilePath ]; then
         cat /dev/null > ZY1815_temp
         entry=$FilePath
         until [ `basename $entry` = "/" ]
         do
         entry=`dirname $entry`
         if [ `ls -ald $entry | awk '{print $1}' | cut -c9` = "w" ]; then
            echo $entry >> ZY1815_temp
         fi
         done
         if [ -s ZY1815_temp ]; then
            $LOGIT "ZY.1.8.1.5 : WARNING - A directory in the path of the file named by the #include directive does not have permissions for other set to r-x or more restrictive!"
            for file in `cat ZY1815_temp`
            do
            ls -ald $file >> $LOGFILE
            done
         else
            $LOGIT "ZY.1.8.1.5 : All directories in the path of the file named by the #inclue directive have permissions for other set to r-x or more restrictive."
         fi
         rm -rf ZY1815_temp
      else
         $LOGIT "ZY.1.8.1.5 : WARNING - The file referenced by the #include directive in the $SUDO file does not exist!"
         grep -w "^#include" $SUDO >> $LOGFILE
      fi
   else
      $LOGIT "ZY.1.8.1.4 : WARNING - There is no variable set for a file after the #include directive in $SUDO!"
      $LOGIT ""
      $LOGIT "ZY.1.8.1.5 : WARNING - There is no variable set for a file after the #include directive in $SUDO!"
      grep -w "^#include" $SUDO >> $LOGFILE
   fi
else
   $LOGIT "ZY.1.8.1.4 : The #include directive does not exist in the $SUDO sudoers file."
   $LOGIT ""
   $LOGIT "ZY.1.8.1.5 : The #include directive does not exist in the $SUDO sudoers file."
fi
         


$LOGIT " "
$LOGIT "ZY.4.0.4 : "
ls -al /var/log | grep -v "^d" >> $LOGFILE

$LOGIT " "
$LOGIT " "
$LOGIT " "
$LOGIT "ZY.5.0.1 : 'Security and System Administrative Authority'....THIS SCRIPT CANNOT CHECK THIS SETTING!"

$LOGIT " "
$LOGIT "#############################################################################"
$LOGIT "Below is the output from the Perl report script which parses the sudoers file for evaluation:"
$LOGIT "#############################################################################"
$LOGIT " "

export SUDO=$SUDO 
export OUTPUT=/tmp/ISEC_`uname -n`.`date +%m%d%y`.output.txt
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

/usr/bin/perl <<-'EOF'> /dev/null 2>&1
###########################################################################
##     $Id: sudo_chk,v 2.0 ##
###########################################################################
#
# Syntax: sudo_chk [ -c sudoers file ][-h|-V][-v][-l]
#
#-------------------------------------------------------------------------
# Desc:	This program reads a the sudoers file
#	 and prepares a report of users and commands
#	 It will issue warning messages for sytax it cannot parse, 
#        as well as for syntax that is not recommended. 
#	 It will also check that !logfile is not in the sudoers file, 
#	 if the specified logfile (if any) exists, and that sudo commands
#        specified are only writable by root.
#	 
#
#-------------------------------------------------------------------------
# Global variables
#
# Environment

require "Getopt/Std.pm";
use Getopt::Std;
use File::Basename;
use Sys::Hostname;

$pn = basename($0);
$hostname=hostname();

if ($security_home eq "") {
   $security_tmpdir="/tmp";
}

my $args = @ARGV;
my $logfile = "$security_tmpdir/$pn.log";
#my $final_rptfile = "$security_tmpdir/$pn.rpt";
my $final_rptfile = $ENV{"OUTPUT"};
my $groupfile = "/etc/group";
my $pswdfile = "/etc/passwd";
my $errfile = "/tmp/$pn.err.$$";
my $rptfile = "/tmp/$pn.rpt.$$";
my $log_it=0;

format ERR = 
===================================================================
SUDO AUTHORITY REVALIDATION REPORT
===================================================================
System: @<<<<<<<<<<<<<<<<<<<< Report Date: @<<<<<<<<<<<<<<<<<<<<<
$hostname,$run_date
Sudo configuration file last modified:     @<<<<<<<<<<<<<<<<<<<<<
$last_mod_date

===================================================================
WARNINGS AND ERRORS
===================================================================
.

format RPT_TOP =

For details on commands included in each command alias, 
note at bottom of report. 
===================================================================
User Authorizations
===================================================================

Userid       Hosts                  User Information                
----------  ---------------------  ---------------------------------
.

format RPT =
@<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$name,$host,$user_gecos
.

format MSG =
@<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$name,$host,$user_gecos
.

#-------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------

&getopts('hVvlc:');

if ($opt_h) {
  &help();
  &show_use();
  exit 0;
}

if ($opt_V) {
  &show_version;
  exit 0;
}

if ($opt_v) {
  $verbose="yes";
}

if ($opt_l) {
    $log_it=1;
}

if ($opt_c) {
    $configfile = $opt_c;
}

if ($configfile eq "") {
   $configfile="/etc/sudoers";
   if ($verbose eq "yes") {
      echo "Using default config file $configfile\n";
   }
}

$RC = 1;
#if ($log_it) {
#   open(LOGFILE, ">>$logfile") or die("$pn can't write to $logfile");
#   &log("$pn Started");
#}

&update();
&det_last_mod_date();

open(ERR,">>$errfile")|| die "can't open $errfile";
  select(ERR);
  $- = 0;
  select(STDOUT);

write ERR;

open(RPT,">>$rptfile")|| die "can't open $rptfile";
  select(RPT);
  $- = 0;
  select(STDOUT);

&load_sudoers_file_into_array();
&alert_on_forbidden_syntax();
&check_logfile_settings();
&load_group_file();
&load_passwd_file();
&parse_sudoers_file();
&load_host_aliases();
&expand_useralias_groups();
&parse_useralias_lines();
&parse_command_aliases_into_cmds();
&validate_userids();
&list_cmds_by_user();
&explain_cmds();
&explain_hosts();
&explain_runas();
&analyze_cmds();

close GRPFILE;
close PSWDFILE;
close ERR;
close RPT;

if ($log_it) {
   &update();
   &log("$pn Ended, RC=$RC");
   close LOGFILE;
}

#system ("cat $errfile $rptfile"); # to std out for auto-admin
#if ($log_it) {
   system ("cat $errfile $rptfile >> $final_rptfile"); # to save a copy locally.
#}

# Clean up temp files
unlink $errfile; 
unlink $rptfile; 
exit $RC;

#-------------------------------------------------------------------------
# Subroutines
#-------------------------------------------------------------------------
sub help {
  echo "\n";
  echo "                  $pn\n";
  echo "\n";
  echo "      This program reads the /etc/sudoers  file or\n";
  echo "      a specified config file using the  -c option\n";
  echo "      and prepares a report of users and commands.\n";
  echo "      It will also issue warning messages  for any\n"; 
  echo "      syntax that it cannot parse,  as well as for\n";
  echo "      syntax that is not recommended.   When using\n";
  echo "      the -v option it supplies additional message\n"; 
  echo "      which identifies source of each entry.  This\n";
  echo "      may be helpful  should repeat entries exist.\n";
  echo "\n";
  echo "      It will also check that !logfile is not in \n";
  echo "      the sudoers file, if the specified logfile \n";
  echo "      (if any) exists, and that sudo commands \n";
  echo "      specified are only writable by root.\n";
  echo "\n";

};

sub show_use
{
  echo "usage: $pn [-h|V] [-v] [-c sudoers_file] [-l]\n";
  echo "  or   $pn {defaults to /etc/sudoers}\n";
  echo "  or   $pn -v (Gives source message for each entry)\n";
  echo "\n";
  echo "       -c < sudoers file> Specify full path of sudoers file\n";
  echo "       -h   Displays help and usage message\n";
  echo "       -l   Create $security_tmpdir/$pn.log and $security_tmpdir/$pn.rpt\n";
  echo "       -V   Displays program's version number\n";
  echo "       -v   Displays source message for each entry\n";
} # end show_use

sub show_version
{
  $version='Revision: 2.0 $';
  echo "$pn: $version\n";
} # end show_version



sub log {
	print LOGFILE " $timestamp: @_ \n";
}

sub dump_array {
	my ($item,$go_on) = "";
	my $array2dump = $_[0];
	echo "ARRAY: $array2dump\n";
	foreach $item (@$array2dump) {
	    echo "$array2dump: $item\n";
	}
#	echo "continue?\n";
#	read STDIN,$go_on,2;
}

sub dump_hash {
	my ($item,$go_on) = "";
	my $hash2dump =  $_[0];
	echo "HASH: $hash2dump\n";
	foreach $item (keys %$hash2dump) {
	    echo "$hash2dump:$item:$$hash2dump{$item} \n";
	}
#	echo "continue?\n";
#	read STDIN,$go_on,2;
}

sub load_sudoers_file_into_array {
# Create an array  @sudoers_file, which we read countless times....
 open CFGFILE, "$configfile" or die "$pn: $configfile: $!";

 # -------------------------------------------
 # Note: Line below maybe a mistake "ls -l"
 # chop ($ls_cfg = `ls -l $configfile `);
 # -------------------------------------------
 chomp ($ls_cfg = `ls $configfile`);
 if ($log_it) {
    &log("Validating config file  $ls_cfg");
 }

 while (defined($line = <CFGFILE>)){
           chop $line;
           if ($line =~ /^#/) {  ; next; }  	# drop comments
           if ( $line !~  /\w/ ) { ; next;}     # drop blank lines
           if ($line =~ s/\\$//) {          	# handle continuation chars
               $nline = <CFGFILE>;
               $nline =~ s/^\s+//;  		# remove any leading spaces
               $line.= $nline;
               redo unless eof(CFGFILE);
           }
	   push @sudoers_file, $line;
 } # end of while
 close CFGFILE;
} # end of sub

sub det_last_mod_date {
  # ---------------------------------------------------------------
  # Stat the config file, then use localtime and pretty it up to 
  # to provide last modified date....
  # ---------------------------------------------------------------
  $mod_times = (stat("$configfile"))[9];

  if ($mod_times >= 0 && $mod_times < 2147483648) {
     ($sec, $min, $hours, $mday, $mon, $year)=localtime($mod_times);

     $mod_month= (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[$mon];
     $year=$year+1900;
     $last_mod_date="$mod_month $mday, $year";
  } else { echo "Enter integer value between 0 and 2147483647\n"; }
}

sub alert_on_forbidden_syntax {
  # --------------------------------------------------------------------------------------
  # Scan through the file for certain characters and structures we don't like to see.
  # --------------------------------------------------------------------------------------
  local $line = "";
  foreach $line ( @sudoers_file) {
     if ($line =~ /\+/) {  
        print ERR "ERROR: Syntax cannot be parsed. $line \n";
        $RC = $RC+10; 
     }  # no netgroups, please
     # ---------------------------------------------------- 
     # Disable Runas errors, use runas_check routine
     # ---------------------------------------------------- 
     # if ($line =~ /^Runas/) {  
     #    print ERR "ERROR: Syntax cannot be parsed. $line \n";
     #    $RC = $RC+10; 
     # }  # no Runas suppport, yet
  # --------------------------------------------------------------------------------------
  # Omit next line to prevent the patch-table pusher function from reporting false errors.
  # --------------------------------------------------------------------------------------
     if ($line =~ /\w\(\w\)\w\(\w\)w/ ) {  
        print ERR "WARNING: () () Syntax is not recommended. $line \n";
        $RC = $RC+10; 
     }  # Double parens mean switch over then back. NG
  }; # end of loop 
}    # end of alert on syntax sub

sub check_logfile_settings {
  # --------------------------------------------------------------------------------------
  # Scan through the file and report if !logfile is found. If Default logfile is
  # specified, post an error if it doesn't exist.
  # --------------------------------------------------------------------------------------
  local $line = "";
  local $lf = "";
  foreach $line ( @sudoers_file) {
     if ($line =~ /\!logfile/) {  
        print ERR "ERROR: !logfile entry found.\n";
        $RC = $RC+10; 
     }  #  no !logfile entry
  # --------------------------------------------------------------------------------------
  # Omit next line to prevent the patch-table pusher function from reporting false errors.
  # --------------------------------------------------------------------------------------
     if ($line =~ /logfile=/) {  
       (@line_fields) = split(" ",$line);
       foreach $lff (@line_fields) {
          if ($lff =~/logfile=/) {
            ($junk, $lf) = split ("=",$lff);
	    # if there is a comma at the end of a logfile name, remove it
	    if ($lf =~ /,/) { chop ($lf);}
	  }
       } # end of foreach to find logfile= field (lff)
       if (! -f "$lf") {
          print ERR "ERROR: specified sudo logfile $lf does not exist.\n\n";
          $RC = $RC+10; 
       }
     } # check if logfile exists  
   } # end foreach loop
}    # end of check_logfile_settings sub

sub load_group_file {
# load a hash %groups, where the key is the name of the groupid
# load a hash %gids, where the key is the numeric groupid
#----------------------------------------------------
# NEW: Method builds hash using getgrent C lib call
#----------------------------------------------------

my($name, $passwd, $gid, $members);

setgrent or die "$pn: error reading group list: $!";
while (($name, $passwd, $gid, $members) = getgrent) {
  $members =~ tr/ /,/;
  $groups{$name} = $members;
  $gids{$name} = $gid;
}
endgrent;
} # End of sub

sub load_passwd_file {
  #----------------------------------------------------
  # load a hash %users with userid values
  # load a hash %user_gecos with gecos information 
  # load a hash %user_groups to contain users primary group
  #----------------------------------------------------
  # NEW: Method builds hash using getpwent C lib call
  #----------------------------------------------------
  my($name,$passwd,$uid,$gid,$quota,$comment,$gcos,$dir,$shell);

  setpwent or die "$pn: error reading user list: $!";
  while (($name,$passwd,$uid,$gid,$quota,$comment,$gcos,$dir,$shell) = getpwent) {
    $users{$name} = $name;
    if ($gcos) {
      $user_gecos_hash{$name} = $gcos;
    } else {
      $user_gecos_hash{$name} = "$name: (No user info found)";
    }
    if (exists ($user_groups{$gid})) {
      $user_groups{$gid} = $user_groups{$gid}.",".$name;
    } else {
      $user_groups{$gid} = $name;
    }
  }
  endpwent;
}

#----------------------------------------------
# OMIT: Old method builds hash from /etc/passwd
#----------------------------------------------
# open PSWDFILE, "$pswdfile" or die "$pn: $pswdfile: $!";
# while (<PSWDFILE>){
# 	chomp;
# 	@line = split /:/;
# 	$the_user = $line[0];
# 	$the_group = $line[3];
# 	$user_gecos = $line[4];
# 	$users{$the_user} = $the_user;
# 	if ($user_gecos) {
# 	   $user_gecos_hash{$the_user} = $user_gecos;
# 	}
# 	else {
# 	    $user_gecos_hash{$the_user} = "(No user info found)";
# 	}
# 	if (exists ($user_groups{$the_group})) {
# 		$user_groups{$the_group} = $user_groups{$the_group}.",".$the_user;
#  	} else {
# 		$user_groups{$the_group} = $the_user;
# 	}
# 
# }

sub parse_sudoers_file {
# create an array for each of 3 types of aliases in the sudoers file.
   local $line = "";
   local $group_line = "";
   local $group_alias_name = "";
   local $entries = "";

   foreach $entry_type (User_Alias,Cmnd_Alias,Runas_Alias) {
       foreach $line ( @sudoers_file) {
	   if ($line =~ /$entry_type/) {   
              push (@$entry_type, $line);   # ok, the line is worth pursuing
	   }
	}; # end of standard defined aliases
   } # end of foreach alias type

   # ---------------------------------
   # Creates the follow arrays for 
   # any corresponding entries.
   # ---------------------------------
   # dump_array (User_Alias);
   # dump_array (Cmnd_Alias);
   # dump_array (Runas_Alias);
   # ---------------------------------

   # ---------------------------------------------------------------
   # Check sudoers file for and group aliases begining with % sign
   # ---------------------------------------------------------------
   foreach $group_line ( @sudoers_file) {
     if ($group_line =~ /^\%/) {
	#----------------------------
	# place %group in Group_Alias
	#----------------------------
        push (@Groups, $group_line);
     }
   } 

   $Groups=@Groups;
   if ($Groups gt 0) {
      foreach $group_line (@Groups) {
       ($group_alias_name, $entries) = split(" ",$group_line);
       ($null, $group_name) = split(/%/,$group_alias_name,2);

       if (exists $groups{$group_name}) {
          $group_mbrs =  $groups{$group_name};
	  if ($group_mbrs) {
	     # chomp($group_mbrs);
             &load_Group_Alias_Array($group_name);
	  }

          $target_gid = $gids{$group_name};
	  if ($target_gid) {
            $group_mbrs = $user_groups{$target_gid};
	    # chomp($group_mbrs);
            &load_Group_Alias_Array($target_gid);
          }
       
       } else { 
                print  ERR "ERROR: Group $group_name does not exist!\n";
                $RC = $RC+10;
       }
     }

   }
   # ---------------------------------
   # Creates the follow array for 
   # any corresponding entries.
   # ---------------------------------
   # dump_array (Group_Alias);
   # ---------------------------------
}  # end of sub

sub load_Group_Alias_Array {
# ---------------------------------------------
# Load @ok_users users defined as exceptions
# ---------------------------------------------
  $test=$_[0];
  local ($line, $next);

  if ($group_mbrs) {
     ($user_entry,$next) = split(/,/,$group_mbrs,2);
     $group_mbrs=$next;
     chomp ($user_entry,$next);
	if ($user_entry eq $users{$user_entry}) {
           $line="$group_alias_name:$user_entry\t$entries";
           push (@Group_Alias,$line);
	   while ($next) {
              ($user_entry,$next) = split(/,/,$group_mbrs,2);
              $group_mbrs=$next;
              chomp ($user_entry,$next);
	      if ($user_entry eq $users{$user_entry}) {
                 $line="$group_alias_name:$user_entry\t$entries";
                 push (@Group_Alias,$line);
              } else { echo "ERROR: User $user_entry does not exist!\n"; }
           }
        } else { echo "ERROR: User $user_entry does not exist!\n"; }
  } 
}

sub load_host_aliases {
# Create an array of hostnames contained within each host alias  
   local $line = "";
   $Host_Aliases{ALL}= "All"; # save this alias entry as default.
       foreach $line ( @sudoers_file) {
	   if ($line =~ /Host_Alias/) {   
       	       ($header,$line2) = split /=/,$line,2;
	       $header =~ s/Host_Alias//;
	       $header =~ s/\s+//g;
               $Host_Aliases{$header}= $line2; # save this alias entry
	   }
	}; # end of loop loading array
} # end of sub

sub expand_useralias_groups {
# --------------------------------------------------------------
# What if we catch a useralias with a % in it? 
# we have to pick up the user names out of the groups file, plus
# those who have it as their primary gid in /etc/passwd.....
# then we just put it back in the array like it was a list of ids 
# for this we use %User_Alias_hash, which is the most complete
# list of users in a given useralias
# --------------------------------------------------------------

  foreach $alias_line (@User_Alias) {
     while ($alias_line =~ /%/) {
       ($user_alias_name, $entries) = split  /%/,$alias_line,2;
       ($group_name,$rest) = split(/,/,$entries,2);
       # NEW LINES
       &strip_spaces($group_name);
       $group_name=$value;
       if ($groups{$group_name}) {
          $group_mbrs =  $groups{$group_name};
          $target_gid = $gids{$group_name};
          $more_folks = $user_groups{$target_gid};
	  if ($more_folks) { $more_folks=",$more_folks"; }
          if ($rest) {
             $alias_line = $user_alias_name.$group_mbrs.$more_folks.",".$rest;
          } else {
                   $alias_line = $user_alias_name.$group_mbrs.$more_folks;
          }
       } elsif ($gids{$group_name}) {
         $target_gid = $gids{$group_name};
         $more_folks = $user_groups{$target_gid};
         if ($rest) {
            $alias_line = $user_alias_name.$more_folks.",".$rest;
         } else {
            $alias_line = $user_alias_name.$more_folks;
         }
       } else { 
              print  ERR "ERROR: Group $group_name does not exist! \n";
              $RC = $RC+10;
              if ($rest) {
                 $alias_line = $user_alias_name.",".$rest;
              } else {
                 $alias_line = $user_alias_name;
              }
       }
     }
     my @group = split(/=/,$alias_line,2);
     $user_alias_name =  $group[0];	
     ($label, $user_alias_name) = split(" ",$user_alias_name);
     $user_alias_mbrs =  $group[1];	
     #create User_Alias_hash{useralias} entry with array
     if ($user_alias_mbrs) {
        $User_Alias_hash{$user_alias_name} =  $user_alias_mbrs;
     }

  } #end of foreach in array
} # end of sub

sub parse_useralias_lines {
# --------------------------------------------------------------
# We parse the sudoers file lines and for a given user alias 
# line prepare the list of command aliases 
# (with changes for enhanced readability)
# --------------------------------------------------------------
    foreach $alias_entry (keys %User_Alias_hash){
        local $line = "";
        foreach $line ( @sudoers_file) {
            if ($line =~ /^$alias_entry/) {
	       # -----------------------------------------------
	       # Following substitution step is no longer 
	       # neccessary because NOPASSWD is disabled.
	       # -----------------------------------------------
   	       # $line =~ s/NOPASSWD/NOTE-Without a Password/;
   	       $line =~ s/!/cannot issue: /;
   	       $line =~ s/\(/ \(As user /g;
               # -----------------------------------------------
               # SHOULD test for uniqueness....
               # -----------------------------------------------
               $command_aliases_for_user_alias{$alias_entry} = $line;
	       # add commands to the all_commands_list for further analysis
	       push @all_commands_list, $commands;
            } # end of if matches user alias
        } # end of foreach line
    } # end of foreach alias entry

} # end of sub parse useralias lines

sub parse_command_aliases_into_cmds {
# --------------------------------------------------------------
# In the report, we want to print the list of commands in place 
# of the alias create a hash %command_hash
# --------------------------------------------------------------
    foreach $cmnd_entry (@Cmnd_Alias){
            ($good_part, $commands) =  split /=/,$cmnd_entry;
            ($junk, $cmnd_name) =  split " " ,$good_part ;
            $command_hash{$cmnd_name} = $commands;
	    # add commands to the all_commands_list for further analysis
	    push @all_commands_list, $commands;
 
    } # end of foreach
} # end of sub

sub strip_spaces {
# -------------------------------------------------------------------------
# If any string has leading or ending spaces then remove and return them.
# -------------------------------------------------------------------------
  $value=$_[0];
  
  $value=~s/^\s//;
  $value=~s/\s$//;
  return $value;
}

sub validate_userids {
# -------------------------------------------------------------------------
# Is each person in sudoers (by name or by membership in a User_Alias) a
# defined user on the system. It is easy to remove users and miss sudoers.
# -------------------------------------------------------------------------
  foreach $User_Alias_to_check (sort (keys %User_Alias_hash)) {
        # ----------------------------------------------------------------
        # Kill the commas  at the start of line and remove any spaces
        # ----------------------------------------------------------------
	$User_Alias_hash{$User_Alias_to_check} =~ s/^,//;  
	$User_Alias_hash{$User_Alias_to_check} =~ s/\s//g;  
	@names_in_alias = split(/,/,$User_Alias_hash{$User_Alias_to_check});
        # ----------------------------------------------------------------
        # Take the list of names from the User_Alias entry and check each
        # ----------------------------------------------------------------
	foreach $specific_name (@names_in_alias ){
	if ( ! exists $users{$specific_name}) {
		print ERR  "ERROR: User spec $specific_name is not a valid userid.\n";
		$RC = $RC+10;
	} # end of if to check id
	} # end of foreach specific name
  } # end of foreach to check each user-alias

    # let's look for plain userauth lines and check their ids.
  local $line = "";
  foreach $line ( @sudoers_file) {
# be sure we have only the lines we want
           if ($line =~ /(^Defaults|^User_Alias|^Cmnd_Alias|^Runas_Alias|^Host_Alias|^%)/) { next; }
# remove spaces
	   ($user,$junk) = split(/\s+/,$line,2);
	   if ( ! exists $User_Alias_hash{$user} ){
               if (! exists $users{$user})  {
		print ERR  "ERROR: User $user is not a valid userid.\n";
		$RC = $RC+10;
               }
	   } # end of if to check id
  } # end of foreach line in sudoers

} # end of sub

sub list_cmds_by_user {
    # -------------------------------------------------------------------
    # Users get auth 3 ways: 
    #		1:  Users assoicated with User_Alias 
    #		2:  Users extracted from Group_Alias
    #		3:  Users listed as single entries from sudoers file
    # Note: folks who are in sudoers but don't have a valid ID are not 
    # reported here.  We covered them at the error msg pt.
    # -------------------------------------------------------------------

# ------------------------------------------
# Case 1, Userids from User_Alias
# ------------------------------------------
  foreach $User_Alias_to_check (sort (keys %User_Alias_hash)) {
        @names_in_alias = split /,/,$User_Alias_hash{$User_Alias_to_check};
        # for each specific userid name in the User_Alias, get gecos, if we have any, 
        foreach $specific_name (@names_in_alias ){
	   if (exists $user_gecos_hash{$specific_name} ){ # plug in GECOS, if we have it
              $user_gecos = $user_gecos_hash{$specific_name};
	   } else {
      $user_gecos = "(No user information found)";
           }
           if (exists  $command_aliases_for_user_alias{$User_Alias_to_check}) {  
           # if we have a user line that begins w/this user alias, we put those cmds to this specific user
              ($junk_user,$rest_of_line) =  split /\s+/,$command_aliases_for_user_alias{$User_Alias_to_check},2; 
              # get the hostname, elim = and spaces, expand it if its an alias
              ($host,$command_aliases_to_print) = split /=/,$rest_of_line,2;
              $host =~ s/=//;
              $host =~ s/\s+//g;
	      $orig_hostname = $host; # if the string gets too long, we use this alias as is
                  if ($Host_Aliases{$host}) {
                      $host= $Host_Aliases{$host};
                      $length = split //,$host ;
                      if ($length > 20)  { # 20 char, per the format statement above.
                          $host= " See alias: $orig_hostname ";
                     }
                  }
 # in any case, write the record to the report, user line then cmd line.

               $name = $specific_name;
               write RPT; # uses $name, $host, $user_gecos
               print RPT "Commands: $command_aliases_to_print\n";
	       if ($verbose eq "yes") { print RPT "Granted VIA: User_Alias:$User_Alias_to_check\n";
               }
               print RPT "\n";

	   } else { # well, we can find the user, but no auth was granted to that username or alias. 
               $name = $specific_name;
               write RPT; # uses $name, $host, $user_gecos
	       print RPT "is defined, but has no authorizations under the $User_Alias_to_check entry! \n";
               print RPT "\n";
	      $RC = $RC+1;
	   }
	}
  } # end of foreach
# ------------------------------------------
# Case 2, userids from Group_Alias
# ------------------------------------------

   $Groups=@Group_Alias;
   if ($Groups gt 0) {
      foreach $group_line (@Group_Alias) { 
         ($group_alias_name, $rest_of_line) = split(/:/,$group_line);
         ($found_userid, $entry) = split(" ",$rest_of_line);
	 ($host,$command_aliases_to_print) = split /=/,$entry,2;
	 $host =~ s/=//;
	 $host =~ s/\s+//g;
         $orig_hostname = $host; # if the string gets too long, we use this alias as is
           if ($Host_Aliases{$host}) {
              $host= $Host_Aliases{$host};
              $length = split //,$host ;
              if ($length > 20)  { # 20 char, per the format statement above.
                 $host= " See alias: $orig_hostname ";
              }
           }
	 if (exists $user_gecos_hash{$found_userid} ){ # plug in GECOS, if we have it
            $user_gecos = $user_gecos_hash{$found_userid};
	 } else {
            $user_gecos = "(No user information found)";
         }
         # in any case, write the record to the report, user line then cmd line.

         $name = $found_userid;
         write RPT; # uses $name, $host, $user_gecos
         print RPT "Commands: $command_aliases_to_print\n";
	 if ($verbose eq "yes") { print RPT "Granted VIA Group Alias:$group_alias_name\n";
         }
         print RPT "\n";
      }
   }

# ------------------------------------------
# Case 3, single entry userids, 
#         not from User_Alias or Group_Alias
# ------------------------------------------

  foreach $userid (keys %users){ # look for each valid user to have his own line in sudoers
    local $line = "";
    foreach $line ( @sudoers_file) { # toss out the lines we do not want, and find lines matching valid system userids
           if ($line =~ /(^User_Alias|^Cmnd_Alias|^Runas_Alias|^Host_Alias|^%)/) { next; }
           if ($line =~ /^$userid/)  {   # the id is in our sudoers file
               $line =~ s/NOPASSWD/NOTE-Without a Password/;
               $line =~ s/!/cannot issue: /;
               $line =~ s/\(/ \(As user /g;
               $command_aliases_for_userid{$userid} = $line;
           }  # end of if user is in file
    } # end of loop reading array
  } # end of foreach userid entry

        # Once again, we have a found_userid (that is, the userid itself is at the start of the field) 
	# so we link it up to it's aliases, check for gecos and print.
        foreach $found_userid (sort (keys %command_aliases_for_userid )) {
           ($junk_user,$rest_of_line) =  split /\s+/,$command_aliases_for_userid{$found_userid},2; # get the hostname, elim == and spaces
	   ($host,$command_aliases_to_print) = split /=/,$rest_of_line,2;
	   # add commands to the all_commands_list for further analysis
	   push @all_commands_list, $command_aliases_to_print;
	   $host =~ s/=//;
	   $host =~ s/\s+//g;
           $orig_hostname = $host; # if the string gets too long, we use this alias as is
                  if ($Host_Aliases{$host}) {
                      $host= $Host_Aliases{$host};
                      $length = split //,$host ;
                      if ($length > 20)  { # 20 char, per the format statement above.
                          $host= " See alias: $orig_hostname ";
                     }
                  }
	   if (exists $user_gecos_hash{$found_userid} ){ # plug in GECOS, if we have it
              $user_gecos = $user_gecos_hash{$found_userid};
	   } else {
              $user_gecos = "(No user information found)";
           }
           # in any case, write the record to the report, user line then cmd line.

           $name = $found_userid;
           write RPT; # uses $name, $host, $user_gecos
           print RPT "Commands: $command_aliases_to_print\n";
	   if ($verbose eq "yes") { print RPT "Granted VIA Single Entry:$name\n";
	   }
           print RPT "\n";
       } # end of foreach found id


} # end of sub 

# for readability, we'll save the listing of cmds to aliases til the end.
sub explain_cmds {
  print RPT  "\n\n===================================================================\n";
  print RPT  "Mapping of commands to command aliases\n";
  print RPT  "===================================================================\n\n";
  foreach $command_def (sort (keys %command_hash)) {
	print  RPT "Command alias $command_def gives authority to: \n";
	print  RPT "$command_hash{$command_def}\n\n";
	}
}

# for readability, we'll save the listing of hosts to aliases til the end.
sub explain_hosts {
  $host_name = "";
  print RPT  "\n\n===================================================================\n";
  print RPT  "Mapping of host aliases to specific hosts\n";
  print RPT  "===================================================================\n\n";
  foreach $host_name (sort (keys %Host_Aliases)) {
        if ($host_name =~ /ALL/) { ; next} # lets not look too simpleminded
	print  RPT "Host alias $host_name refers to: \n";
	print  RPT "$Host_Aliases{$host_name}\n\n";
	}
}

sub explain_runas {
   print RPT  "===================================================================\n";
   print RPT  "Mapping of Runas aliases to specific users or groups\n";
   print RPT  "===================================================================\n\n";
   foreach $runas_name (sort (@Runas_Alias)) {
   	print  RPT "$runas_name\n\n";
   }
}

# check every executable in the sudoers for being writable to root only
sub analyze_cmds {
   undef %cmd_jash;
   undef @all_processed_cmds;
   undef @unique_commands;
   foreach $cmd_entry (@all_commands_list) {
      @cmds = split (",",$cmd_entry);
      foreach $cmd (sort (@cmds)) {
        $cmd =~ s/NOTE-Without a Password: //;
        $cmd_nosp=&strip_spaces($cmd);
        ###print  RPT "NON uniq cmd is $cmd_nosp\n\n";
        # create an array of individual commands
        push @all_processed_cmds, $cmd_nosp;
      }
   }
   # now create an array of unique commands
   %cmd_hash = map { $_ => 1 } @all_processed_cmds;
   @unique_commands = sort keys %cmd_hash;
   foreach $unique_cmd (sort (@unique_commands)) {
     ($unique_cmd,$rest) = split (/\s+/,$unique_cmd,2) ;
     ###print RPT "uniq cmd is $unique_cmd\n\n";
     &check_command ($unique_cmd);
   }
}
sub check_command {
   my $command = $_[0] ;

   if ($command =~ /([A-Z]|[a-z]|\/|\-|\_)\*/) {
      print ERR "WARNING: command $command has an asterisk. Please check for proper ownership and permissions.\n\n";
   }
   else {
      if (! -x "$command") { 
         print ERR "ERROR: command $command doesn't exist or is not executable.\n\n"
      }
      else {
         # check if owned by root and if is writable only by root
	 @listing = split (" ",`ls -lH $command`);
	 if ( "@listing[2]" != root ) { 
	    print ERR "ERROR: command $command is not owned by root.\n\n";
	 }
	 else {
	    @perms = split ("", @listing[0]);
	    if ("$perms[5]" eq "w")  {
	       print ERR "ERROR: command $command is writable by others then root.\n\n";
	       return;
	    }
	    if ("$perms[8]" eq "w") {
	       print ERR "ERROR: command $command is writable by others then root.\n\n";
	    }
	 }
      }
   }
}

sub update {
  $raw_date = localtime;
  ($dow, $month, $dom, $tm, $year) = split /\s+/,$raw_date,5;
  $run_date = "$month $dom, $year";
  $timestamp = "$month $dom $year $tm";
}
#Finish Perl call here
EOF

#Finish up if we found sudoers here:
fi

$LOGIT ""
$LOGIT "iSeC Scanning is completed."


#done
echo "\n\n\n\n\n\t====>> End Of Log File\n\n" >> $LOGFILE

if ((!$TADDMSIL)); then
   ##Let our secondary script die off....
   sleep 6
   
   echo -e "\n\niSeC Scanning is completed."
   echo -e "\nYour output is in $LOGFILE"
   echo -e "\nPlease wait. . . .\n\n"
   
   #Ensure our secondary script is gone:
   sleep 7
   ps -ef | grep isec_LINUX_progress.sh | grep -v grep > /dev/null 2>&1
   if ((!$?)); then
      BadPID=`ps -ef | grep isec_LINUX_progress.sh | grep -v grep | awk '{print $2}'`
      kill -9 $BadPID
   fi
   rm -rf /tmp/isec_LINUX_progress.sh
   rm -rf /tmp/isec_question_prompt
fi

#Create our CSV file here, if desired:
MsgAnswer2=1
if ((!$INTERSIL)); then
   echo "You also can create CSV files to make it easier to transfer the results to a"
   echo "spreadsheet for archival and/or to send to the security team."
   until [ "$MsgAnswer2" = "y" ] || [ "$MsgAnswer2" = "Y" ] || [ "$MsgAnswer2" = "n" ] || [ "$MsgAnswer2" = "N" ]
   do
#   echo -e "\nWould you like to create CSV results files now? (y/n): \c"
#   read MsgAnswer2
   MsgAnswer2=y
   done
elif (($TADDMSIL)); then
   MsgAnswer2=Y
else
   MsgAnswer2=N
fi

case $MsgAnswer2 in
y|Y)
   for file in LINUX_OS_isec SSH_isec SUDO_isec
   do
      if ((!$TADDMSIL)); then
   	   echo -e "\nCreating CSV output file for $file now. . . ."
   	fi
   	CSVFile=/tmp/${file}_`uname -n`.`date +%m%d%y`.output.csv
   	cat /dev/null > $CSVFile
      for section in $(eval echo \$${file})
      do
      #There is a bug in RHEL6 grep and LC so we have to force the LC to read ranges properly.
      if [ $OSFlavor = "RedHat" ] && [ $RHVER -ge 6 ]; then
         grep $section $LOGFILE | LC_COLLATE=C grep -v "$section.[0-9A-z]" > /dev/null 2>&1
      else
         grep $section $LOGFILE | grep -v "$section.[0-9A-z]" > /dev/null 2>&1
      fi
      if ((!$?)); then
         echo -e "\"\c" >> $CSVFile
         sed -e '/./{H;$!d;}' -e "x;/$section /!d;" $LOGFILE >> $CSVFile
         echo -e "\"" >> $CSVFile
      else
         echo >> $CSVFile
      fi
      done
      if ((!$TADDMSIL)); then
         echo "The CSV file for $file has been created. It can be found at:"
         echo "$CSVFile"
      fi
      sleep 4
   done
;;
n|N)
   if ((!$TADDMSIL)); then
	   echo -e "\nSkipping CSV file creation.\n"
	fi
;;
esac

if ((!$TADDMSIL)); then
   echo -e "\n\n\tEnd of script. Exiting....\n\n"
fi
exit 0

##Close if statement if logfile could not be created:
else
   echo -e "\n\nERROR! Could not create the logfile! Exiting...."
   exit 1
fi
