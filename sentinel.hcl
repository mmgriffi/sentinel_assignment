# sentinel.hcl

mock "tfplan/v2" {
  module {
     source = "./terraform/mock-tfplan-v2.sentinel"
  }
}
mock "tfconfig/v2" {
  module {
    source = "./terraform/mock-tfconfig-v2.sentinel"
  }
}
policy "allowed-providers" {
  source = "./sentinel/allowed-providers.sentinel"
  enforcement_level = "advisory"
  #enforcement_level = "hard-mandatory"
}

policy "instance_type" {
  source = "./sentinel/instance_type.sentinel"
  enforcement_level = "advisory"
  #enforcement_level = "hard-mandatory"
}
policy "network" {
  source = "./sentinel/network.sentinel"
  enforcement_level = "advisory"
  #enforcement_level = "hard-mandatory"
}
#This is checking region for the resources I had in my terraform (ec2, rds, s3 only)
policy "sovereigney" {
  source = "./sentinel/sovereignty.sentinel"
  enforcement_level = "advisory"
  #enforcement_level = "hard-mandatory"
}
# On searching, found that my initial script was restricted.. would need to expand for every type of resource.
# This is an alternative way to check the region for any resource type I try to add. 

policy "sovereigney_2" {
  source = "./sentinel/sovereignty_2.sentinel"
  enforcement_level = "advisory"
  #enforcement_level = "hard-mandatory"
}

