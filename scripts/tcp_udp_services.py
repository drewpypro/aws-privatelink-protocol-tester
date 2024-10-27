import socket
import threading
import datetime
import os
import requests
import paramiko

# Get instance metadata
def get_instance_metadata():
    metadata_base_url = "http://169.254.169.254/latest/meta-data"
    instance_id = requests.get(f"{metadata_base_url}/instance-id").text
    public_ip = requests.get(f"{metadata_base_url}/public-ipv4").text
    return instance_id, public_ip

# Logging Function
def log(message, log_dir):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d')
    log_file = os.path.join(log_dir, f"{timestamp}-log.txt")
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] {message}\n")
    print(f"[{timestamp}] {message}")

# TCP HTTP Responder on Port 8080
def tcp_http_responder(log_dir):
    tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp_socket.bind(('', 8080))
    tcp_socket.listen(5)
    instance_id, public_ip = get_instance_metadata()

    while True:
        client_socket, client_address = tcp_socket.accept()
        source_ip, source_port = tcp_socket.getsockname()
        dest_ip, dest_port = client_address
        request = client_socket.recv(4096)
        log(f"Received TCP request from {client_address}: {request.decode()}", log_dir)
        response = f"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nInstance ID: {instance_id}, Public IP: {public_ip}"
        client_socket.send(response.encode())
        client_socket.close()

# SSH Server on Port 53
def ssh_server(log_dir):
    ssh_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssh_server_socket.bind(('', 53))
    ssh_server_socket.listen(5)

    while True:
        client_socket, client_address = ssh_server_socket.accept()
        log(f"SSH connection attempt from {client_address}", log_dir)
        transport = paramiko.Transport(client_socket)
        transport.add_server_key(paramiko.RSAKey(filename='/home/ec2-user/server_rsa_key'))
        server = paramiko.ServerInterface()
        try:
            transport.start_server(server=server)
        except paramiko.SSHException:
            log("SSH negotiation failed", log_dir)

# TCP Header Echo Responder on Port 8081
def tcp_header_echo_responder(log_dir):
    tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp_socket.bind(('', 8081))
    tcp_socket.listen(5)

    while True:
        client_socket, client_address = tcp_socket.accept()
        source_ip, source_port = tcp_socket.getsockname()
        dest_ip, dest_port = client_address
        request = client_socket.recv(4096)
        log(f"Received TCP request from {client_address}: {request.decode()}", log_dir)
        client_socket.close()

# TCP Fast Open Responder on Port 8082
def tcp_fast_open_responder(log_dir):
    tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp_socket.bind(('', 8082))
    tcp_socket.listen(5)

    while True:
        client_socket, client_address = tcp_socket.accept()
        source_ip, source_port = tcp_socket.getsockname()
        dest_ip, dest_port = client_address
        log(f"Received TCP Fast Open request from {client_address}", log_dir)
        client_socket.send(b"Hello from TCP Fast Open Server")
        client_socket.close()

# Main Function
def main():
    log_dir = "/home/ec2-user/"
    os.makedirs(log_dir, exist_ok=True)

    tcp_http_thread = threading.Thread(target=tcp_http_responder, args=(log_dir,))
    tcp_http_thread.daemon = True
    tcp_http_thread.start()

    ssh_thread = threading.Thread(target=ssh_server, args=(log_dir,))
    ssh_thread.daemon = True
    ssh_thread.start()

    tcp_header_thread = threading.Thread(target=tcp_header_echo_responder, args=(log_dir,))
    tcp_header_thread.daemon = True
    tcp_header_thread.start()

    tcp_fast_open_thread = threading.Thread(target=tcp_fast_open_responder, args=(log_dir,))
    tcp_fast_open_thread.daemon = True
    tcp_fast_open_thread.start()

    tcp_http_thread.join()
    ssh_thread.join()
    tcp_header_thread.join()
    tcp_fast_open_thread.join()

if __name__ == "__main__":
    main()
