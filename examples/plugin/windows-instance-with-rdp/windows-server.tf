provider "opc" {
  user           = "${var.user}"
  password       = "${var.password}"
  identityDomain = "${var.domain}"
  endpoint       = "${var.endpoint}"
}

data "template_file" "userdata" {
  vars {
    admin_password = "${var.administrator_password}"
  }

  template = <<EOF
{
	"userdata": {
			"enable_rdp": true,
			"administrator_password": "$${admin_password}"
	}
}
EOF
}

resource "opc_compute_instance" "instance1" {
  name       = "windows-server-1"
  label      = "My Windows Server 2012 R2"
  shape      = "oc3"
  imageList  = "/Compute-${var.domain}/${var.user}/Microsoft_Windows_Server_2012_R2"
  attributes = "${data.template_file.userdata.rendered}"
}

resource "opc_compute_security_association" "instance1_enable-rdp" {
  vcable  = "${opc_compute_instance.instance1.vcable}"
  seclist = "${opc_compute_security_list.enable-rdp.name}"
}

resource "opc_compute_security_list" "enable-rdp" {
  name                 = "Enable-RDP-access"
  policy               = "DENY"
  outbound_cidr_policy = "PERMIT"
}

resource "opc_compute_security_rule" "allow-rdp" {
  name             = "Allow-rdp-access"
  source_list      = "seciplist:/oracle/public/public-internet"
  destination_list = "seclist:${opc_compute_security_list.enable-rdp.name}"
  action           = "permit"
  application      = "/oracle/public/rdp"
  disabled         = false
}

resource "opc_compute_ip_association" "instance1_ipreservation" {
  vcable     = "${opc_compute_instance.instance1.vcable}"
  parentpool = "ipreservation:${opc_compute_ip_reservation.ipreservation1.name}"
}

resource "opc_compute_ip_reservation" "ipreservation1" {
  parentpool = "/oracle/public/ippool"
  permanent  = true
}
