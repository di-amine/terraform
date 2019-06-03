resource "google_compute_instance_group" "test" {
  name        = "${var.namegroupe}"
  description = "${var.descriptiongroupe}"
  zone        = "${var.zonegroupe}"
  network     = "${google_compute_network.network.self_link}"
}

resource "google_compute_network" "network" {
  name                    = "${var.namenetwork}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "${var.subnet1}"
  ip_cidr_range = "10.2.0.0/16"
  region        = "${var.regionsubnet}"
  network       = "${google_compute_network.network.self_link}"
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "${var.subnet2}"
  ip_cidr_range = "10.3.0.0/16"
  region        = "${var.regionsubnet}"
  network       = "${google_compute_network.network.self_link}"

  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_firewall" "firewall" {
  name    = "test-firewall"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewallkube" {
  name    = "firewallkube"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}






resource "google_compute_instance" "vm1" {
  name         = "${var.namevm}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zonevm}"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "${var.imagevm}"
    }
    auto_delete = true
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "${google_compute_network.network.self_link}"
    subnetwork = "${google_compute_subnetwork.subnet1.self_link}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}


// -------------------------------------------------------------
// CLUSTER 


resource "google_container_cluster" "primary" {
  name     = "${var.clustername}"
  location = "${var.lactcluster}"
  network  = "${google_compute_network.network.self_link}"
  subnetwork = "${google_compute_subnetwork.subnet2.self_link}"


  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  ip_allocation_policy {
      node_ipv4_cidr_block = "10.3.0.0/24"
  }

  private_cluster_config {
      master_ipv4_cidr_block = "10.4.0.0/28"
      enable_private_nodes = true
      enable_private_endpoint = true
  }
  
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "10.2.0.0/16"
      display_name = "net1"
    }
    cidr_blocks {
      cidr_block = "10.3.0.0/16"
      display_name = "net2"
    }
  }




  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes1" {
  name       = "${var.myNodePool}-1"
  location   = "${var.lactnode}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata {
      disable-legacy-endpoints = "true"
      name                     = "stateles"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes2" {
  name       = "${var.myNodePool}-2"
  location   = "${var.lactnode}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata {
      disable-legacy-endpoints = "true"
      name                     = "statefull"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

