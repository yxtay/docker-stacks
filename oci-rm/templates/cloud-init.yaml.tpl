#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl
  - git

runcmd:
  - [ echo, "Starting user-provided cloud-init script" ]
  - |
    ${indent(4, user_data_content)}
  - [ echo, "Finished user-provided cloud-init script" ]
