module "qa" {
	source = "../modules/tf"

	environment = {
		name           = "qa"
		network_prefix = "10.11"
	}
}