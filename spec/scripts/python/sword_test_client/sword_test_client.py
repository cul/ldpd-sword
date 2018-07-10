import requests

user_id = None
user_passwd = None
host_ip = None
port_number = None

def set_credentials(user_id_arg, user_passwd_arg):
    global user_id
    user_id = user_id_arg
    global user_passwd
    user_passwd = user_passwd_arg

def set_host_and_port(host_ip_arg, port_number_arg):
    global host_ip
    host_ip = host_ip_arg
    global port_number
    port_number = port_number_arg

def set_host(host_ip_arg):
    global host_ip
    host_ip = host_ip_arg

def check_settings():
    msg = list()
    if not user_id:
        msg.append('user_id not set')
    if not user_passwd:
        msg.append('user_passwd not set')
    if not host_ip:
        msg.append('host_ip not set')
    if not port_number:
        msg.append('port_number not set')
    return msg

def request_service_doc(url_suffix):
    check_settings()
    allowed_url_suffix = {'servicedocument',
                          'service-document',
                          'service_document'}
    if (url_suffix not in allowed_url_suffix):
        print('url_suffix is invalid')
        return
    if (not user_id or not user_passwd):
        print('Need to set credentials')
        return
    if not port_number:
        print("Port not set")
        url = 'https://' + host_ip + '/sword/' + url_suffix
    else:
        url = 'https://' + host_ip + ':' + str(port_number) + '/sword/' + url_suffix
    print('Sending service document request to ' + url)
    return requests.get(url,auth=(user_id,user_passwd))
    
def post_deposit_http(collection_slug,file_arg):
    headers_data = {'Content-type': 'application/zip'}
    check_settings()
    if not port_number:
        print("Port not set")
        url = 'http://' + host_ip + '/sword/deposit/' + collection_slug
    else:
        url = 'http://' + host_ip + ':' + str(port_number) + '/sword/deposit/' + collection_slug
    print('Depositing to ' + url)
    response = requests.post(url,auth=(user_id,user_passwd), headers=headers_data, data=open(file_arg,'rb'))
    return response

def post_deposit_https(collection_slug,file_arg):
    headers_data = {'Content-type': 'application/zip'}
    check_settings()
    if not port_number:
        print("Port not set")
        url = 'https://' + host_ip + '/sword/deposit/' + collection_slug
    else:
        url = 'https://' + host_ip + ':' + str(port_number) + '/sword/deposit/' + collection_slug
    print('Depositing to ' + url)
    response = requests.post(url,auth=(user_id,user_passwd), headers=headers_data, data=open(file_arg,'rb'))
    return response
