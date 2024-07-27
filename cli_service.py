import os
import subprocess
from flask import Flask, jsonify

app = Flask(__name__)

def run_cli_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return result.stdout, result.stderr
    except subprocess.CalledProcessError as e:
        return e.stdout, e.stderr

@app.route('/api/view_versions', methods=['GET'])
def view_versions():
    result = run_cli_command('dob view-version')
    return jsonify(result)

@app.route('/api/list_ec2_instances', methods=['GET'])
def list_ec2_instances():
    result = run_cli_command('dob list-ec2')
    return jsonify(result)

@app.route('/api/list_s3_buckets', methods=['GET'])
def list_s3_buckets():
    result = run_cli_command('dob list-s3')
    return jsonify(result)

@app.route('/api/create_ec2_instance', methods=['POST'])
def create_ec2_instance():
    data = request.json
    command = f"dob create-ec2 --instance-type {data['instance_type']} --ami-id {data['ami_id']} --key-name {data['key_name']} --security-group {data['security_group']} --count {data['count']} --tags {data['tags']}"
    result = run_cli_command(command)
    return jsonify(result)

@app.route('/api/create_ec2_dob', methods=['POST'])
def create_ec2_dob():
    data = request.json
    command = f"dob create-ec2-dob {data['dob_screenplay']}"
    result = run_cli_command(command)
    return jsonify(result)

@app.route('/api/recreate_ec2', methods=['POST'])
def recreate_ec2():
    data = request.json
    command = f"dob recreate-ec2 --version-id {data['version_id']}"
    result = run_cli_command(command)
    return jsonify(result)

@app.route('/api/delete_ec2', methods=['POST'])
def delete_ec2():
    data = request.json
    command = f"dob delete-ec2 --ids {','.join(data['ids'])}"
    if 'version_id' in data:
        command += f" --version-id {data['version_id']}"
    result = run_cli_command(command)
    return jsonify(result)

@app.route('/api/list_s3_objects', methods=['POST'])
def list_s3_objects():
    data = request.json
    command = f"dob list-objects --bucket-name {data['bucket_name']}"
    result = run_cli_command(command)
    return jsonify(result)

@app.route('/api/delete_s3_bucket', methods=['POST'])
def delete_s3_bucket():
    data = request.json
    command = f"dob delete-bucket --bucket-name {data['bucket_name']}"
    result = run_cli_command(command)
    return jsonify(result)

@app.route('/api/delete_s3_object', methods=['POST'])
def delete_s3_object():
    data = request.json
    command = f"dob delete-object --bucket-name {data['bucket_name']} --object-key {data['object_key']}"
    result = run_cli_command(command)
    return jsonify(result)

@app.route('/api/configure_aws', methods=['POST'])
def configure_aws():
    data = request.json
    command = f"dob configure-aws --aws-access-key-id {data['aws_access_key_id']} --aws-secret-access-key {data['aws_secret_access_key']} --region {data['region']}"
    result = run_cli_command(command)
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
