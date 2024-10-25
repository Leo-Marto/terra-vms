echo "[back]" >> inventory.ini
echo "$IP_DIR ansible_user=$USER ansible_ssh_private_key_file=$SSH_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' " >> inventory.ini
echo "[db]" >> inventory.ini
echo "10.0.2.5 ansible_user=$USER ansible_ssh_private_key_file=$SSH_KEY "  >> inventory.ini
echo "[db:vars]" >> inventory.ini
echo "ansible_ssh_common_args='"'-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i '$SSH_KEY -W %h:%p $USER@$IP_DIR'"'"'" >> inventory.ini
