import socket
import threading
import datetime
import os
import requests

def get_instance_metadata():
    """Fetch instance metadata such as instance ID, public IP, etc."""
    metadata_base_url = "http://169.254.169.254/latest/meta-data"
    instance_id = requests.get(f"{metadata_base_url}/instance-id").text
    public_ip = requests.get(f"{metadata_base_url}/public-ipv4").text
    return instance_id, public_ip

def log(message, log_dir):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    log_file = os.path.join(log_dir, f"{timestamp}-log.txt")
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] {message}\n")
    print(f"[{timestamp}] {message}")


def udp_dns_responder(log_dir):
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_socket.bind(("", 53))
    instance_id, public_ip = get_instance_metadata()

    while True:
        message, client_address = udp_socket.recvfrom(4096)
        response = f"Instance ID: {instance_id}, Public IP: {public_ip}".encode()
        source_ip, source_port = udp_socket.getsockname()
        dest_ip, dest_port = client_address
        udp_socket.sendto(response, client_address)
        log(f"Received UDP message from {client_address} and responded with {response} (5-tuple: Source {source_ip}:{source_port} -> Destination {dest_ip}:{dest_port})", log_dir)


def tcp_dns_responder(log_dir):
    tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp_socket.bind(("", 53))
    tcp_socket.listen(5)
    instance_id, public_ip = get_instance_metadata()

    while True:
        client_socket, client_address = tcp_socket.accept()
        source_ip, source_port = tcp_socket.getsockname()
        dest_ip, dest_port = client_address
        request = client_socket.recv(4096)
        response = f"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nInstance ID: {instance_id}, Public IP: {public_ip}"
        client_socket.send(response.encode())
        log(f"Received TCP request from {client_address} and responded with HTTP 200 OK (5-tuple: Source {source_ip}:{source_port} -> Destination {dest_ip}:{dest_port})", log_dir)
        client_socket.close()


def tcp_http_responder(log_dir):
    tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp_socket.bind(("", 8080))
    tcp_socket.listen(5)
    instance_id, public_ip = get_instance_metadata()

    while True:
        client_socket, client_address = tcp_socket.accept()
        source_ip, source_port = tcp_socket.getsockname()
        dest_ip, dest_port = client_address
        request = client_socket.recv(4096)
        response = f"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nInstance ID: {instance_id}, Public IP: {public_ip}"
        client_socket.send(response.encode())
        log(f"Received TCP request from {client_address} and responded with HTTP 200 OK (5-tuple: Source {source_ip}:{source_port} -> Destination {dest_ip}:{dest_port})", log_dir)
        client_socket.close()


def main():
    log_dir = "/home/ec2-user/"
    os.makedirs(log_dir, exist_ok=True)

    udp_thread = threading.Thread(target=udp_dns_responder, args=(log_dir,))
    udp_thread.daemon = True
    udp_thread.start()

    tcp_dns_thread = threading.Thread(target=tcp_dns_responder, args=(log_dir,))
    tcp_dns_thread.daemon = True
    tcp_dns_thread.start()

    tcp_http_thread = threading.Thread(target=tcp_http_responder, args=(log_dir,))
    tcp_http_thread.daemon = True
    tcp_http_thread.start()

    udp_thread.join()
    tcp_dns_thread.join()
    tcp_http_thread.join()

if __name__ == "__main__":
    main()
