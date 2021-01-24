# Equinix-Metal-VPN-Router

This repo has Terraform plans to deploy a network edge device on Equinix Metal as a router-gateway for L2TP/IPSec VPN and to be configured with basic network perimeter security configurations.

## Install Terraform 
Terraform is just a single binary.  Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path. 
 
Here is an example for **macOS**: 
```bash 
curl -LO https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_darwin_amd64.zip 
unzip terraform_0.12.18_darwin_amd64.zip 
chmod +x terraform 
sudo mv terraform /usr/local/bin/ 
``` 

## Initialize Terraform 
Terraform uses modules to deploy infrastructure. In order to initialize the modules you run: `terraform init`. This should download a few modules into a hidden directory called `.terraform` 


## Reserve a /28 Public IP Address block from the Equinix Metal Portal:
* Go to console.equinix.com
  * IPs and Networks
    * IPs
      * Request IP addresses
        * Public IPv4
        * Location = select the datacenter you're deploying this to
        * Quantity = /28 (16 IPs)
        * Add a description for your new block.


## Modify your variables 
There is a `terraform.tfvars` file that you can copy and use to update with your deployment variables. Open the file in a text editor to update the variables.

* Modify the variable: public_ips_cidr = ["123.123.123.0/28"]

The following variable blocks must be validated to be accurate for your desired deployment:

* `auth_token` - This is your Equinix API key.
* `ssh_private_key_path` - The local private part of your Equinix Metal SSH key. - Make sure this is correct and accessible.
* `public_ips_cidr` - This should be the IP block /28 that you reserved in the previous step
* `project_id` - The Equinix Metal project you'd like to deploy this into.
* `organization_id` - Your Equinix Metal org.

# Device provisioning - Update this to reflect your desired state
* router_hostname = "edge-gateway"
* router_size = "c3.medium.x86"     <--- Validate the server plan is available to provision in your desired location
* facility = "dc13"                 <--- Validate your facility/datacenter code is correct
* router_os = "ubuntu_18_04"        <--- Validate your OS code is correct
* billing_cycle = "hourly"          

 
## Deploy the Router-Gateway 
 
All there is left to do now is to deploy the Router-Gateway! 

```bash 
terraform apply
``` 

Once the script completes, your router-gateway should be visable and green in the portal, and accessible via SSH as well. 

Your terminal should display something like these outputs:

``` 
Apply complete! Resources: 9 added, 0 changed, 0 destroyed. 
 
Outputs: 
output "VPN_Endpoint"
output "VPN_PSK" 
output "VPN_User" 
output "VPN_Pasword" 
``` 
### Connect to the Environment

There is an L2TP IPsec VPN setup. There is an L2TP IPsec VPN client for every platform. You'll need to reference your operating system's documentation on how to connect to an L2TP IPsec VPN.

MAC how to configure L2TP IPsec VPN - https://support.apple.com/guide/mac-help/set-up-a-vpn-connection-on-mac-mchlp2963/mac

Chromebook how to configure LT2P IPsec VPN - https://support.google.com/chromebook/answer/1282338?hl=en

Make sure to enable all traffic to use the VPN (aka do not enable split tunneling) on your L2TP client.

Some corporate networks block outbound L2TP traffic. If you are experiening issues connecting, you may try a guest network or personal hotspot.

## Cleaning the environement
To clean up a created environment (or a failed one), run `terraform destroy --auto-approve`.

If this does not work for some reason, you can manually delete each of the resources created in Packet (including the project) and then delete your terraform state file, `rm -f terraform.tfstate`.
