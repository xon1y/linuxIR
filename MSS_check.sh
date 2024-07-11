#!/bin/bash

BASE_DIR="./system_check"
mkdir -p "$BASE_DIR"

commands=(
    # 基础信息
    "echo Basic Information > $BASE_DIR/basic_info/00_basic_info.txt"
    "ifconfig > $BASE_DIR/basic_info/01_ifconfig.txt"
    "ip a > $BASE_DIR/basic_info/02_ip_a.txt"
    "hostname > $BASE_DIR/basic_info/03_hostname.txt"
    "uname -a > $BASE_DIR/basic_info/04_uname_a.txt"
    "df -h > $BASE_DIR/basic_info/05_df_h.txt"
    "free -m > $BASE_DIR/basic_info/06_free_m.txt"
    "top -n 1 -o %CPU > $BASE_DIR/basic_info/07_top.txt"
    "cat /etc/passwd > $BASE_DIR/basic_info/08_passwd.txt"
    "cat /etc/shadow > $BASE_DIR/basic_info/09_shadow.txt"
    "cat /etc/group > $BASE_DIR/basic_info/10_group.txt"
    "cat /etc/sudoers > $BASE_DIR/basic_info/11_sudoers.txt"
    "uptime > $BASE_DIR/basic_info/12_uptime.txt"
    "cat /proc/meminfo > $BASE_DIR/basic_info/13_meminfo.txt"
    "last -f /var/log/wtmp > $BASE_DIR/basic_info/14_wtmp.txt"
    "cat /etc/resolv.conf > $BASE_DIR/basic_info/15_resolv_conf.txt"
    "cat /etc/hosts > $BASE_DIR/basic_info/16_hosts.txt"
    "ls -alR /proc/*/cwd > $BASE_DIR/basic_info/17_proc_cwd.txt"
    "iptables -L -v -n > $BASE_DIR/basic_info/18_iptables.txt"
    "service --status-all > $BASE_DIR/basic_info/19_service_status_all.txt"
    "netstat -punta > $BASE_DIR/basic_info/20_netstat.txt"
    "echo \$PATH > $BASE_DIR/basic_info/21_path.txt"

    # 可疑系统账号检查
    "echo MSS_Check_Suspicious_system_account_check > $BASE_DIR/suspicious_accounts/00_suspicious_accounts.txt"
    "awk -F: '{if(\$3==0) print \$1}' /etc/passwd > $BASE_DIR/suspicious_accounts/01_superuser.txt"
    "awk -F: '{a[\$3]++}END{for(i in a)if(a[i]>1)print i}' /etc/passwd > $BASE_DIR/suspicious_accounts/02_cloned_users.txt"
    "cat /etc/passwd | grep -E \"/bin/bash$\" | awk -F: '{print \$1}' > $BASE_DIR/suspicious_accounts/03_login_users.txt"
    "awk -F: '{if(\$3>=1000)print \$1}' /etc/passwd > $BASE_DIR/suspicious_accounts/04_non_system_users.txt"
    "awk -F: '(\$2==\"\"){print \$1}' /etc/shadow > $BASE_DIR/suspicious_accounts/05_empty_password_users.txt"
    "awk -F: '{if(\$1!=\"root\"&&\$3==0) print \$1}' /etc/group > $BASE_DIR/suspicious_accounts/06_privileged_users.txt"

    # 系统账号登录检查
    "echo Check_the_system_account_login > $BASE_DIR/account_login/00_account_login.txt"
    "who > $BASE_DIR/account_login/01_current_users.txt"
    "lastb > $BASE_DIR/account_login/02_failed_logins.txt"
    "lastlog > $BASE_DIR/account_login/03_last_logins.txt"
    "journalctl _COMM=sshd | grep \"Accepted\" > $BASE_DIR/account_login/04_ssh_success.txt"
    "journalctl _COMM=sshd | grep \"Failed\" > $BASE_DIR/account_login/05_ssh_failed.txt"

    # 异常端口、进程排查
    "echo Check_abnormal_ports_processes_services > $BASE_DIR/abnormal_ports_processes/00_abnormal_ports_processes.txt"
    "netstat -punta > $BASE_DIR/abnormal_ports_processes/01_ports.txt"
    "pstree -p > $BASE_DIR/abnormal_ports_processes/02_process_tree.txt"
    "ps aux > $BASE_DIR/abnormal_ports_processes/03_process_list.txt"

    # 启动项排查
    "echo Check_startup_items > $BASE_DIR/startup_items/00_startup_items.txt"
    "systemctl list-unit-files --type=service > $BASE_DIR/startup_items/01_systemctl_services.txt"
    "service --status-all > $BASE_DIR/startup_items/02_service_status_all.txt"
    "cat /etc/rc.local > $BASE_DIR/startup_items/03_rc_local.txt"
    "cat /etc/rc.d/rc.local > $BASE_DIR/startup_items/04_rc_d_local.txt"
    "ls /etc/rc.d/init.d/ > $BASE_DIR/startup_items/05_init_d.txt"
    "cat /etc/profile > $BASE_DIR/startup_items/06_profile.txt"
    "cat /etc/bashrc > $BASE_DIR/startup_items/07_bashrc.txt"
    "cat /etc/profile.d/* > $BASE_DIR/startup_items/08_profile_d.txt"
    "cat ~/.bashrc > $BASE_DIR/startup_items/09_user_bashrc.txt"
    "cat ~/.bash_profile > $BASE_DIR/startup_items/10_user_bash_profile.txt"
    "cat ~/.bash_logout > $BASE_DIR/startup_items/11_user_bash_logout.txt"
    "cat ~/.profile > $BASE_DIR/startup_items/12_user_profile.txt"

    # 计划任务
    "echo Scheduled_task_checking > $BASE_DIR/scheduled_tasks/00_scheduled_tasks.txt"
    "crontab -l > $BASE_DIR/scheduled_tasks/01_crontab.txt"
    "journalctl -u crond > $BASE_DIR/scheduled_tasks/02_crond_logs.txt"

    # 可疑文件排查
    "echo Check_suspicious_files > $BASE_DIR/suspicious_files/00_suspicious_files.txt"
    "ls -alt /tmp/ | head -20 > $BASE_DIR/suspicious_files/01_tmp_files.txt"
    # "find / -mtime 0 | grep -E \"\.(py|sh|perl|pl|php|asp|jsp)$\" > $BASE_DIR/suspicious_files/02_suspicious_scripts.txt"

    # 日志排查
    "echo Check_system_logs > $BASE_DIR/system_logs/00_system_logs.txt"
    "tail /var/log/auth.log > $BASE_DIR/system_logs/01_auth_log.txt"
    "tail /var/log/syslog > $BASE_DIR/system_logs/02_syslog.txt"
    "tail /var/log/daemon.log > $BASE_DIR/system_logs/03_daemon_log.txt"
    "tail /var/log/apache2/access.log > $BASE_DIR/system_logs/04_apache_access_log.txt"
    "tail /var/log/nginx/access.log > $BASE_DIR/system_logs/05_nginx_access_log.txt"
    "tail /var/log/mysql/mysql.log > $BASE_DIR/system_logs/06_mysql_log.txt"
)

mkdir -p "$BASE_DIR/basic_info"
mkdir -p "$BASE_DIR/suspicious_accounts"
mkdir -p "$BASE_DIR/account_login"
mkdir -p "$BASE_DIR/abnormal_ports_processes"
mkdir -p "$BASE_DIR/startup_items"
mkdir -p "$BASE_DIR/scheduled_tasks"
mkdir -p "$BASE_DIR/suspicious_files"
mkdir -p "$BASE_DIR/system_logs"

for cmd in "${commands[@]}"; do
    eval $cmd
done