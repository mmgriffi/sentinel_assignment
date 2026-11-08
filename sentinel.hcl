# sentinel.hcl

mock "tfplan/v2" {
  module {
     source = "./terraform/mock-tfplan-v2.sentinel"
  }
}
policy "allowed-providers" {
  source = "./sentinel/allowed-providers.sentinel"
  enforcement_level = "advisory"
}

policy "instance_type" {
  source = "./sentinel/instance_type.sentinel"
  enforcement_level = "advisory"
}

policy "sovereigney" {
  source = "./sentinel/sovereignty.sentinel"
  enforcement_level = "advisory"
}


