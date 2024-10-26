import argparse
import socket
import csv
import datetime
import os

def log(message, log_dir, start_time):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    if log_dir:
        log_file = os.path.join(log_dir, f"{start_time}-log.txt")
        with open(log_file, 'a') as f:
            f.write(f"[{timestamp}] {message}\n")
    print(f"[{timestamp}] {message}")


def write_report(data, report_dir, start_time):
    if report_dir:
        report_file = os.path.join(report_dir, f"{start_time}-report.csv")
        with open(report_file, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["Timestamp", "Protocol", "Source IP", "Source Port", "Destination IP", "Destination Port", "Status"])
            for entry in data:
                writer.writerow(entry)


def udp_test(target_host, target_port, log_enabled, report_data, log_dir, start_time):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind(('', 0))
        sock.settimeout(5)
        source_ip, source_port = sock.getsockname()
        sock.sendto(b'test', (target_host, target_port))
        response, addr = sock.recvfrom(4096)
        dest_ip, dest_port = addr
        result = f"UDP Test Success: Source {source_ip}:{source_port} -> Destination {dest_ip}:{dest_port} - Received '{response}'"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "UDP", source_ip, source_port, dest_ip, dest_port, "Success"])
    except Exception as e:
        source_ip, source_port = sock.getsockname()
        result = f"UDP Test Failed: Source {source_ip}:{source_port} -> Destination {target_host}:{target_port} - Error: {e}"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "UDP", source_ip, source_port, target_host, target_port, "Failed"])
    finally:
        sock.close()


def tcp_test(target_host, target_port, log_enabled, report_data, log_dir, start_time):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(('', 0))
        sock.settimeout(5)
        sock.connect((target_host, target_port))
        source_ip, source_port = sock.getsockname()
        message = "GET / HTTP/1.1\r\nHost: {}\r\n\r\n".format(target_host)
        sock.sendall(message.encode())
        response = sock.recv(4096)
        result = f"TCP Test Success: Source {source_ip}:{source_port} -> Destination {target_host}:{target_port} - Received response"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", source_ip, source_port, target_host, target_port, "Success"])
    except Exception as e:
        source_ip, source_port = sock.getsockname()
        result = f"TCP Test Failed: Source {source_ip}:{source_port} -> Destination {target_host}:{target_port} - Error: {e}"
        if log_enabled:
            log(result, log_dir, start_time)
        report_data.append([datetime.datetime.now(), "TCP", source_ip, source_port, target_host, target_port, "Failed"])
    finally:
        sock.close()


def main():
    parser = argparse.ArgumentParser(description="AWS PrivateLink Protocol Tester")
    parser.add_argument("--log", action='store_true', help="Generate a full log file with $day/hour/minute-log.txt.")
    parser.add_argument("--report", action='store_true', help="Generate a CSV report with $day/hour/minute-report.csv.")
    parser.add_argument("--both", action='store_true', help="Generate both log and report files.")
    parser.add_argument("--shell", action='store_true', help="Output only to the shell without writing any files.")
    args = parser.parse_args()

    if not any(vars(args).values()):
        parser.print_help()
        return

    log_enabled = args.log or args.both
    report_enabled = args.report or args.both
    shell_enabled = args.shell

    udp_target_host = "10.1.2.69"
    tcp_target_host = "10.1.2.169"
    udp_port = 53
    tcp_port = 8080
    report_data = []
    start_time = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')

    if log_enabled or report_enabled:
        log_dir = "/home/ec2-user/"
        report_dir = "/home/ec2-user/"
        os.makedirs(log_dir, exist_ok=True)
        os.makedirs(report_dir, exist_ok=True)
    else:
        log_dir = None

    # Run UDP test
    udp_test(udp_target_host, udp_port, log_enabled or shell_enabled, report_data, log_dir, start_time)
    # Run TCP test
    tcp_test(tcp_target_host, tcp_port, log_enabled or shell_enabled, report_data, log_dir, start_time)

    if report_enabled:
        write_report(report_data, report_dir, start_time)

if __name__ == "__main__":
    main()
