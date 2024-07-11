#!/bin/bash

# Function to execute a command and capture its output and errors
execute_command() {
    local command=$1
    local output=$(eval "$command" 2>&1)
    # Escape HTML special characters in output
    output=$(echo "$output" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
    echo "$output"
}

# Function to generate HTML report
generate_html_report() {
    local hostname=$(hostname)
    local date_time=$(date -u '+%Y-%m-%d_%H-%M-%S_%Z')
    local report_name="${hostname}-${date_time}.html"

    cat <<EOF >"$report_name"
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Linux Incident Response Diagnosis Report</title>
    <link href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdn.bootcdn.net/ajax/libs/popper.js/1.6.0/popper.min.js"></script>
    <script src="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <style type="text/css">
        .card-body {
            -ms-flex: 1 1 auto;
            flex: 1 1 auto;
            min-height: 1px;
            padding: 1.25rem;
            background-color: #000102;
            color:#00ff70;
        }
        pre {
            display: block;
            font-size: 87.5%;
            color: #00ff70;
            overflow-y: auto;
            max-height: 500px;
        }
    </style>
</head>

<body id="top">
    <div class="container">
        <h1 class="mt-3">Linux - IR Computer Diagnosis Report</h1>
        <form action="/submit-incident" method="post">
            <fieldset class="form-group">
                <legend>Analyst Notes</legend>
                <textarea class="form-control" rows="5"></textarea>
            </fieldset>
            <fieldset class="form-group">
                <legend>Meta Information</legend>
                <div class="form-group">
                    <label for="reportGenerationDate" class="col-form-label">Report Generation Date (UTC):</label>
                    <input type="text" id="reportGenerationDate" name="reportGenerationDate" class="form-control"
                        value="$(date -u '+%Y-%m-%d %H:%M:%S %Z')" disabled>
                </div>
                <div class="form-group">
                    <label for="incidentHandlerName">Report Generated By: on1y</label>
                    <input type="text" id="incidentHandlerName" name="incidentHandlerName" class="form-control" value="xon1y">
                </div>
            </fieldset>
        </form>
    </div>

    <div class="container mt-4">
EOF

    # Loop through the provided commands and add sections to the HTML report
    # )
commands=(
        #基础信息
        "echo Basic Information || ----------基础信息----------"
        "ifconfig && ip a||网络接口和IP地址."
        # "arp -a||ARP表."
        "hostname||显示系统的主机名."
        "uname -a||显示系统信息，包括内核版本."
        "df -h||显示磁盘使用情况."
        "free -m||显示内存使用情况."
        "top -n 1 -o %CPU||显示实时系统统计信息."
        "cat /etc/passwd||用户账户."
        "cat /etc/shadow||密码信息."
        "cat /etc/group||用户组信息."
        "cat /etc/sudoers||sudoers文件内容."
        "uptime||系统运行时间."
        "cat /proc/meminfo||内存信息."
        "last -f /var/log/wtmp||登录历史记录."
        "cat /etc/resolv.conf||DNS解析器配置."
        "cat /etc/hosts||显示hosts文件内容."
        "ls -alR /proc/*/cwd||列出进程的当前工作目录."
        "iptables -L -v -n||显示防火墙规则."
        "service --status-all||列出所有可用的服务."
        "netstat -punta||网络统计信息."
        "echo \$PATH||显示系统的PATH环境变量."

        #mss 可疑系统账号检查
        "echo MSS_Check_Suspicious system account check || ----------可疑系统账号检查----------"
        "more /etc/passwd | awk -F: '{if(\$3==0) print \$1}' || 超级用户"
        "awk -F: '{a[\$3]++}END{for(i in a)if(a[i]>1)print i}' /etc/passwd || 克隆用户"
        "cat /etc/passwd | grep -E \"/bin/bash$\" | awk -F: '{print \$1}' || 系统可登录用户"
        "more /etc/passwd | awk -F: '{if(\$3>=1000)print \$1}' || 非系统自带用户"
        "awk -F: '(\$2==\"\"){print \$1}' /etc/shadow || 空口令用户"
        "cat /etc/group | awk -F: '{if(\$1!=\"root\"&&\$3==0) print \$1}' || 特权用户"
        #mss 系统账号登录检查
        "echo Check the system account login || ----------系统账号登录检查----------"
        "who || 当前登录用户"
        "lastb || 用户登录的错误信息"
        "lastlog || 所有用户最后登录信息."
        "journalctl _COMM=sshd | grep \"Accepted\" || SSH登录成功记录"
        "journalctl _COMM=sshd | grep \"Failed\" || SSH登录失败记录"
        #mss 异常端口、进程排查
        "echo Check abnormal ports, processes, and services || ----------异常端口、进程、服务排查----------"
        "netstat -punta || 端口外联排查"
        "pstree -p || 进程树排查"
        "ps aux || 进程排查"
        #mss 启动项排查
        "echo Check startup items || ----------启动项排查----------"
        "systemctl list-unit-files --type=service || systemctl服务排查"
        "service --status-all || systemctl服务状态排查"
        "cat /etc/rc.local || rc.local启动项"
        "cat /etc/rc.d/rc.local || rc.local启动项"
        "cat /etc/rc.d/init.d/ || init.d启动项"
        "cat /etc/profile || profile启动项"
        "cat /etc/bashrc || bashrc启动项"
        "cat /etc/profile.d/* || profile.d启动项"
        "cat ~/.bashrc || .bash_profile启动项"
        "cat ~/.bash_profile || .bash_profile启动项"
        "cat ~/.bash_logout || .bash_logout启动项"
        "cat ~/.profile || .profile启动项"
        #mss 计划任务
        "echo Scheduled task checking || ----------计划任务排查----------"
        "crontab -l || crontab计划任务"
        "journalctl -u crond | journalctl计划任务执行记录"
        #mss 可疑文件排查
        "echo Check the suspicious file || ----------可疑文件排查----------"
        "ls -alt /tmp/ | head -20 || /tmp目录临时文件排查"  
        # "find / -mtime 0 | grep -E \"\.(py|sh|perl|pl|php|asp|jsp)$\" || 可疑脚本文件排查"
        #mss 日志排查
        "echo Check system logs || ----------日志排查----------"
        "tail /var/log/auth.log|| Authentication logs."
        "tail /var/log/syslog.log|| System logs."
        "tail /var/log/demon.log|| Demon logs."
        "tail /var/log/apache/access.log|| Apache Access Logs."
        "tail /var/log/nginx/access.log|| Nginx Access Logs."
        "tail /var/log/mysqld.log|| MySQL Server Logs."
    )

    for command_info in "${commands[@]}"; do
        command=$(echo "$command_info" | awk -F '\\|\\|' '{print $1}')
        description=$(echo "$command_info" | awk -F '\\|\\|' '{print $2}')
        # Create an anchor tag for each description
        echo "        <a href=\"#${description// /_}\" class=\"list-group-item list-group-item-action\">$description</a>" >>"$report_name"
    done

    for command_info in "${commands[@]}"; do
        command=$(echo "$command_info" | awk -F '\\|\\|' '{print $1}')
        description=$(echo "$command_info" | awk -F '\\|\\|' '{print $2}')
        # 使用description生成一个安全的ID，将空格替换为下划线
        safe_id=${description// /_}
        echo "<div class=\"card mt-3\" id=\"$safe_id\">" >>"$report_name" # 添加id属性
        echo "    <div class=\"card-header bg-dark text-white\">" >>"$report_name"
        echo "        <h5 class=\"mb-0\">$description - $command</h5>" >>"$report_name"
        echo "    </div>" >>"$report_name"
        echo "    <div class=\"card-body\">" >>"$report_name"
        output=$(execute_command "$command")
        echo "        <pre>" >>"$report_name"
        echo "$output" >>"$report_name"
        echo "        </pre>" >>"$report_name"
        echo "    </div>" >>"$report_name"
        echo "</div>" >>"$report_name" # Close the card div
        echo "<div class=\"text-center mt-3\">" >>"$report_name"
        echo "    <a href=\"#top\" class=\"btn btn-primary\">Back to Top</a>" >>"$report_name"
        echo "</div>" >>"$report_name"
        echo "Command Completed: $command_info"  # Verbose output
    done
    # Closing HTML
    cat <<EOF >>"$report_name"
    </div>
</body>

</html>
EOF

    echo "HTML report generated: $report_name"
}

# Run checks and generate the report
generate_html_report