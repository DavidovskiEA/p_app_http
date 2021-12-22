#!/usr/bin/python3

import os
import sys

inputs = ['apt', 'yum']
a = input("input apt or yum:").lower()
if a not in inputs:
    print('Wrong input:' + a)
    sys.exit()
else:
    print(a)
ip = input('IP like x.x.x.x:')
print(ip)
domain = input('Input your domain:')
print(domain)
if a == 'apt':
    os.system('apt install -y nginx')
    os.system('apt install -y mysql')
    os.system('apt install -y php-fpm php-mysql')
    os.system('touch /etc/nginx/sites-available/' + domain + '.conf')
    os.system('cat test.txt > /etc/nginx/sites-available/' + domain + '.conf')
    os.system('mkdir /var/www/html/' + domain)
    with open('/etc/nginx/sites-available/' + domain + '.conf') as domain_file:
        current_file = domain_file.read()
    current_file = current_file.replace('example.com', ip)
    with open('/etc/nginx/sites-available/' + domain + '.conf', 'w') as replaced_file:
        replaced_file.write(current_file)
    with open('/etc/nginx/sites-available/' + domain + '.conf') as domain1_file:
        current_file1 = domain1_file.read()
    current_file1 = current_file1.replace('root /var/www/html', 'root /var/www/html/' + domain)
    with open('/etc/nginx/sites-available/' + domain + '.conf', 'w') as replaced_file1:
        replaced_file1.write(current_file1)
    source_sym_link = '/etc/nginx/sites-available/' + domain + '.conf'
    target_sym_link = '/etc/nginx/sites-enabled/' + domain + '.conf'
    print(source_sym_link)
    print(target_sym_link)
    try:
        os.unlink('/etc/nginx/sites-available/default')
    except:
        print("No file to unlink symbollink")
    try:
        os.symlink(source_sym_link, target_sym_link)
    except:
        print("Simbol link exist")
    os.system('cat vhost.txt > /var/www/html/' + domain + '/' + 'index.html')
    with open('/var/www/html/' + domain + '/' + 'index.html') as vhost_file:
        current_vhost_file = vhost_file.read()
    current_vhost_file = current_vhost_file.replace('<title></title>', '<title>' + domain + '</title>')
    with open('/var/www/html/' + domain + '/' + 'index.html', 'w') as replaced_file:
        replaced_file.write(current_vhost_file)
    os.system('systemctl reload nginx')
if a == 'yum':
    os.system('yum install nginx')
    os.system('yum install -y nginx')
    os.system('yum install -y mysql')
    os.system('yum install -y php-fpm php-mysql')
    os.system('touch /etc/nginx/sites-available/' + domain + '.conf')
    os.system('cat test.txt > /etc/nginx/sites-available/' + domain + '.conf')
    os.system('mkdir /var/www/html/' + domain)
    with open('/etc/nginx/sites-available/' + domain + '.conf') as domain_file:
        current_file = domain_file.read()
    current_file = current_file.replace('example.com', ip)
    with open('/etc/nginx/sites-available/' + domain + '.conf', 'w') as replaced_file:
        replaced_file.write(current_file)
    with open('/etc/nginx/sites-available/' + domain + '.conf') as domain1_file:
        current_file1 = domain1_file.read()
    current_file1 = current_file1.replace('root /var/www/html', 'root /var/www/html/' + domain)
    with open('/etc/nginx/sites-available/' + domain + '.conf', 'w') as replaced_file1:
        replaced_file1.write(current_file1)
    source_sym_link = '/etc/nginx/sites-available/' + domain + '.conf'
    target_sym_link = '/etc/nginx/sites-enabled/' + domain + '.conf'
    print(source_sym_link)
    print(target_sym_link)
    try:
        os.unlink('/etc/nginx/sites-available/default')
    except:
        print("No file to unlink symbollink")
    try:
        os.symlink(source_sym_link, target_sym_link)
    except:
        print("Simbol link exist")
    os.system('cat vhost.txt > /var/www/html/' + domain + '/' + 'index.html')
    with open('/var/www/html/' + domain + '/' + 'index.html') as vhost_file:
        current_vhost_file = vhost_file.read()
    current_vhost_file = current_vhost_file.replace('<title></title>', '<title>' + domain + '</title>')
    with open('/var/www/html/' + domain + '/' + 'index.html', 'w') as replaced_file:
        replaced_file.write(current_vhost_file)
    os.system('systemctl reload nginx')